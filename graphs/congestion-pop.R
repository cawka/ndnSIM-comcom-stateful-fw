#!/usr/bin/env Rscript

args = commandArgs (TRUE)
if (length(args) == 0) {
  cat ("Usage: ./graphs/congestion-pop.R <comma-separated-list-of-runs>\n\n")
  cat ("No parameters were specified, assuming it was run as [./graphs/congestion-pop.R 1]\n")

  args = c("1")
}

runs   = args[1]

suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
suppressPackageStartupMessages (library(doBy))
suppressPackageStartupMessages (library(digest))

source ("graphs/graph-style.R")

processedFile = paste(sep="", "results/congestion-pop-processed-",digest(runs),".data")

if (!file.exists (processedFile)) {

  cat (sep="","Processing data and saving to [", processedFile ,"]\n")

  data.all = data.frame ()

  for (run in strsplit(runs,",")[[1]]) {
    cat (run, "\n")
    ###### NDN

    filename = paste(sep="", "results/congestion-pop-run-", run, "-ndn-consumers-seqs.log")

    data.run = read.table (filename, header = TRUE, sep = "\t")
    data.run$Node = factor (data.run$Node)

    data.run = subset (data.run, Type == "FullDelay" & SeqNo == 2000)[, c(1,2)]

    data.run$Run = run

    data.run.ndn = data.run

    ###### TCP

    filename = paste(sep="", "results/congestion-pop-run-", run, "-tcp-consumers-seqs.log")

    data.run = read.table (filename, header = TRUE, sep = "\t")
    data.run$Node = factor (data.run$Node)

    data.run = subset (data.run, SeqNo == 2001)[, c(1,2)]
    data.run = summaryBy (Time ~ Node, data=data.run, FUN=min)

    data.run$Run = run

    data.run.tcp = data.run

    ###### Combined

    names(data.run.tcp) = c("Node", "Time.TCP", "Run")
    names(data.run.ndn) = c("Time.NDN", "Node", "Run")

    data.run = merge (data.run.ndn,data.run.tcp)

    data.all = rbind (data.all, data.run)
  }

  save (data.all, file = processedFile)
} else {
  cat (sep="", "Loading pre-processed data from [",processedFile,"]\n")
  load (file=processedFile)
}

data.finish <- summaryBy (Time.NDN + Time.TCP ~ Run, data = data.all, FUN=max)

g <- ggplot () +
  ## geom_point (aes(size=`Finishing time`, shape=`Finishing time`, colour=`Finishing time`, fill=`Finishing time`)) +
  geom_point (aes (x = Time.TCP, y=Time.NDN), data = data.all, size=3, shape=21, colour="black", fill="gray70") +

  geom_point (aes (x = Time.TCP.max, y=Time.NDN.max), data = data.finish, size=5, shape=21, colour="black", fill="blue") +

  geom_abline (slope = 1, intercept = 0) +
  ## scale_size_manual (values = c(1, 3)) +
  ## scale_shape_manual (values = c(20, 23)) +
  ## scale_colour_manual (values = c("gray45", "black")) +
  ## scale_fill_manual (values = c("gray45", "white")) +
  ## scale_x_continuous ("Finishing time of TCP flows, seconds", limits=c(35,110)) +
  ## scale_y_continuous ("Finishing time of NDN flows, seconds", limits=c(35,110)) +
  theme_custom () +
  theme (legend.position = c(0.573, 0.9))


if (!file.exists ("graphs/pdfs")) {
  dir.create ("graphs/pdfs")
}

cat ("Writing graph to [graphs/pdfs/congestion-pop.pdf]\n")

pdf ("graphs/pdfs/congestion-pop.pdf")
g
x = dev.off ()

## file.graph = paste ('times-all-runs.pdf', sep='')
## ## pdf (file.graph, width=3.35, height=3.35)
## postscript ("times-all-runs.eps", onefile=TRUE, horizontal=FALSE, paper="special", width=3.35, height=3.35)
## setEPS ()
