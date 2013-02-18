#!/usr/bin/env Rscript

suppressPackageStartupMessages (library(reshape2))
suppressPackageStartupMessages (library(doBy))
suppressPackageStartupMessages (library(digest))

processedFile = "results/figure-10-twenty-flow-congestion.data"

cat (sep="", "Pre-processing data\n")

###### NDN

data.run = read.table (bzfile("results/figure-10-twenty-flow-congestion-ndn.txt.bz2"), header = TRUE, sep = "\t")
data.run$Node = factor (data.run$Node)
data.run$Run = factor (data.run$Run)

data.run = subset (data.run, Type == "FullDelay" & SeqNo == 2000)[, c(1,2,3)]

data.run.ndn = data.run

###### TCP

data.run = read.table (bzfile("results/figure-10-twenty-flow-congestion-tcp.txt.bz2"), header = TRUE, sep = "\t")
data.run$Node = factor (data.run$Node)
data.run$Run = factor (data.run$Run)

data.run = subset (data.run, SeqNo == 2001)[, c(1,2,3)]
data.run = summaryBy (Time ~ Node + Run, data=data.run, FUN=min)

data.run.tcp = data.run

###### Combined

names(data.run.tcp) = c("Node", "Run", "Time.TCP")
names(data.run.ndn) = c("Run", "Time.NDN", "Node")

data.all = merge (data.run.ndn, data.run.tcp)

save (data.all, file = processedFile)
