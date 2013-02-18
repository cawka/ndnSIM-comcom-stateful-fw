#!/usr/bin/env Rscript

suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
suppressPackageStartupMessages (library(doBy))
suppressPackageStartupMessages (library(digest))

source ("graphs/graph-style.R")

processedFile = "results/figure-10-twenty-flow-congestion.data"
cat (sep="", "Loading pre-processed data from [",processedFile,"]\n")
load (file=processedFile)

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

cat ("Writing graph to [graphs/pdfs/figure-10-twenty-flow-congestion.pdf]\n")

pdf ("graphs/pdfs/figure-10-twenty-flow-congestion.pdf")
g
x = dev.off ()

## file.graph = paste ('times-all-runs.pdf', sep='')
## ## pdf (file.graph, width=3.35, height=3.35)
## postscript ("times-all-runs.eps", onefile=TRUE, horizontal=FALSE, paper="special", width=3.35, height=3.35)
## setEPS ()
