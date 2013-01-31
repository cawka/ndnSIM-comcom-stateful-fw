#!/usr/bin/env Rscript

suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
## suppressPackageStartupMessages (library(doBy))

source ("graphs/graph-style.R")

tcp.data = read.table ('results/congestion-zoom-tcp-rate-trace.log', header = TRUE, sep = "\t")
tcp.data$Node = factor (tcp.data$Node)
tcp.data$Type = factor (tcp.data$Type)
tcp.data$Interface = factor (tcp.data$Interface-1)

tcp.data = subset (tcp.data, Type == "In")[,c(1,2,3,6)]


ndn.data = read.table ('results/congestion-zoom-ndn-rate-trace.log', header = TRUE, sep = "\t")
ndn.data$Node = factor (ndn.data$Node)
ndn.data$Type = factor (ndn.data$Type)

ndn.data = subset (ndn.data, Type == "InData")[,c(1,2,3,7)]
names (ndn.data) = names (tcp.data)

ndn.data$Type = "NDN"
tcp.data$Type = "TCP"

data = rbind (ndn.data, tcp.data)

g <- ggplot (data=data, aes(x=Time, y=Kilobytes, color = Type, linetype = Type)) +
  geom_line (size = 0.8) +
  facet_wrap (~ Node + Interface) +
  scale_color_manual (values = c("red", "blue")) +
  theme_custom ()

if (!file.exists ("graphs/pdfs")) {
  dir.create ("graphs/pdfs")
}

cat ("Writing graph to [graphs/pdfs/congestion-zoom.pdf]\n")
pdf (file = "graphs/pdfs/congestion-zoom.pdf")
g
x = dev.off ();
