#!/usr/bin/env Rscript

suppressPackageStartupMessages (library(ggplot2))
suppressPackageStartupMessages (library(reshape2))
## suppressPackageStartupMessages (library(doBy))

source ("graphs/graph-style.R")

tcp.data = read.table ('results/congestion-zoom-ipv4-rate-trace.log', header = TRUE, sep = "\t")
tcp.data$Node = factor (tcp.data$Node)
tcp.data$Type = factor (tcp.data$Type)
tcp.data$Interface = factor (tcp.data$Interface-1)

tcp.data = subset (tcp.data, Type == "In")[,c(1,2,3,6)]

## tcp.data.agg = summarizeBy ()

## ggplot (data=tcp.data, aes(x=Time, y=Kilobytes)) + geom_point () + facet_wrap (~ Node + Interface)


ndn.data = read.table ('results/congestion-zoom-rate-trace.log', header = TRUE, sep = "\t")
ndn.data$Node = factor (ndn.data$Node)
ndn.data$Type = factor (ndn.data$Type)

ndn.data = subset (ndn.data, Type == "InData")[,c(1,2,3,7)]
names (ndn.data) = names (tcp.data)

ndn.data$Type = "NDN"
tcp.data$Type = "TCP"

data = rbind (ndn.data, tcp.data)

ggplot (data=data, aes(x=Time, y=Kilobytes, color = Type, linetype = Type)) +
  geom_line (size = 0.8) +
  facet_wrap (~ Node + Interface) +
  scale_color_manual (values = c("red", "blue")) +
  theme_custom ()


## data.packets = subset (raw.data, Type == "InData") #%/* | Type == "OutData")
## data.packets$Type <- factor (data.packets$Type)

## x = data.packets [ -c(3,4) ]
## data.agg = aggregate (list(Packets = x$Packets, Kilobytes = x$Kilobytes),
##   by=list(Time = x$Time, Node = x$Node, Type = x$Type), FUN=sum, na.rm = TRUE)


## interests.packets = subset (raw.data, Type != "InData" & Type != "OutData" & Type != "DropData" & Type != "DropNacks" & Type != "DropInterests")
## interests.packets$Type <- factor (interests.packets$Type)

## # data <- ggplot (data.packets, aes(x=Time))

## # data +
## #  geom_line (aes (y=Kilobytes*8, colour=Type, shape=Type)) +
## #  facet_grid (Node ~ FaceDescr)

## data.agg = subset (data.agg, Node == "c1" | Node == "c2" | Node == "c3" | Node == "c4")
## data.agg$Node = factor (data.agg$Node)

## pdf ("client-data.agg.pdf", width=10, height=6)

## data <- ggplot (data.agg, aes(x=Time))
## data +
##   geom_line (aes (y=Kilobytes*8, group=Node, colour=Node)) +
##   geom_point (aes (y=Kilobytes*8, group=Node, colour=Node, shape = Node))

## dev.off ()


## pdf ("client-interests.agg.pdf", width=10, height=10)

## interests.agg = subset (interests.packets, Node == "c1" | Node == "c2" | Node == "c3" | Node == "c4")
## interests.agg$Node = factor (interests.agg$Node)

## interests <- ggplot (interests.agg, aes(x=Time))
## interests +
##   geom_line (aes (y=Kilobytes*8, group=Type, colour=Type)) +
##   facet_grid (Node ~ FaceDescr)

## dev.off ()


## x = interests.packets [ -c(3,4) ]
## interests.agg2 = aggregate (list(Packets = x$Packets, Kilobytes = x$Kilobytes),
##   by=list(Time = x$Time, Node = x$Node, Type = x$Type), FUN=sum, na.rm = TRUE)


## pdf ("all-interests.agg.pdf", width=10, height=6)
## data <- ggplot (interests.agg2, aes(x=Time))
## data +
##   geom_line (aes (y=Kilobytes*8, group=Type, colour=Type)) +
##   facet_wrap (~ Node)
##   ## geom_point (aes (y=Kilobytes*8, group=Type, colour=Type, shape=Type)) +
## dev.off ()


## for (run in 0:79) {
##   file.ndn = paste ('runs-3/run-', run, '-consumers-seqs.log', sep='')
##   file.tcp = paste ('runs-3/run-', run, '-tcp-consumers-seqs.log', sep='')
##   ## file.graph = paste ('seqs-', run, '.pdf', sep='')
##   file.graph = paste ('seqs-', run, '.jpg', sep='')

##   ## pdf (file.graph, width=10, height=8)
##   jpeg (file.graph, width=800, height=600)

##   seqs.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
##   seqs.ndn = subset (seqs.ndn, Type == "InData")
##   seqs.ndn$Type = as.factor("NDN");

##   seqs.tcp = read.table (file.tcp, header = TRUE, sep = "\t")
##   seqs.tcp = subset (seqs.tcp, SeqNo >= 1)
##   seqs.tcp$Type = as.factor("TCP");

##   seqs = merge (seqs.ndn, seqs.tcp, all=TRUE)
##   seqs$Flow = as.factor(paste(sep='', "Node ", seqs$Node, " App ", seqs$AppId))

##   g.ndn <- ggplot (seqs, aes (x = Time)) +
##     geom_point (aes (y = SeqNo, colour = Flow), size = I(0.5)) +
##     facet_grid(Type ~ .) +
##     opts (title="Sequence numbers of incoming ContentObject packets")

##   ## legend.position = "none",

##   grid.arrange (g.ndn)

##   dev.off ()
## }

## for (run in 0:79) {
##   file.ndn = paste ('runs-3/run-', run, '-consumers-seqs.log', sep='')
##   file.tcp = paste ('runs-3/run-', run, '-tcp-consumers-seqs.log', sep='')
##   file.graph = paste ('times-', run, '.pdf', sep='')

##   seqs.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
##   seqs.ndn = subset (seqs.ndn, Type == "InData")
##   seqs.ndn$Type = as.factor("NDN");

##   seqs.tcp = read.table (file.tcp, header = TRUE, sep = "\t")
##   seqs.tcp = subset (seqs.tcp, SeqNo >= 1)
##   seqs.tcp$Type = as.factor("TCP");

##   seqs = merge (seqs.ndn, seqs.tcp, all=TRUE)
##   seqs$Flow = as.factor(paste(sep='', "Node ", seqs$Node, " App ", seqs$AppId))

##   pdf (file.graph, width=10, height=8)
##   agg = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type, Flow = seqs$Flow), FUN=max)

##   agg.plot = as.data.frame (cbind (TCP = subset(agg, Type=="TCP")[,3], NDN = subset(agg, Type=="NDN")[,3]))

##   agg.total = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type), FUN=max)
##   agg.total.plot = as.data.frame (cbind (TCP = subset(agg.total, Type=="TCP")[,2],
##                                          NDN = subset(agg.total, Type=="NDN")[,2]))

##   g <- ggplot (agg.plot, aes (x = TCP, y=NDN)) +
##     geom_point (aes (colour = TCP-NDN), size = I(5)) +
##     geom_text (aes (x=TCP+0.5, label = round(TCP-NDN,2)), hjust = 0) +
##     geom_point (data = agg.total.plot, size=15, colour=I("yellow")) +
##     geom_text (data = agg.total.plot, hjust=1, size=10, aes (label = paste("Total", round(TCP-NDN,2)))) +
##     geom_abline (slope = 1, intercept = 0) +
##     opts (title="Finish time for NDN and TCP flows")

##   grid.arrange (g)

##   dev.off ()
## }


## values <- data.frame ()
## values.total <- data.frame ()

## for (run in 0:79) {
##   cat(run,"\n")
##   file.ndn = paste ('runs-3/run-', run, '-consumers-seqs.log', sep='')
##   file.tcp = paste ('runs-3/run-', run, '-tcp-consumers-seqs.log', sep='')

##   seqs.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
##   seqs.ndn = subset (seqs.ndn, Type == "InData")
##   seqs.ndn$Type = as.factor("NDN");

##   seqs.tcp = read.table (file.tcp, header = TRUE, sep = "\t")
##   seqs.tcp = subset (seqs.tcp, SeqNo >= 1)
##   seqs.tcp$Type = as.factor("TCP");

##   seqs = merge (seqs.ndn, seqs.tcp, all=TRUE)
##   seqs$Flow = as.factor(paste(sep='', "Node ", seqs$Node, " App ", seqs$AppId))

##   agg = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type, Flow = seqs$Flow), FUN=max)

##   agg.plot = as.data.frame (cbind (TCP = subset(agg, Type=="TCP")[,3], NDN = subset(agg, Type=="NDN")[,3]))

##   agg.total = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type), FUN=max)
##   agg.total.plot = as.data.frame (cbind (TCP = subset(agg.total, Type=="TCP")[,2],
##                                          NDN = subset(agg.total, Type=="NDN")[,2]))

##   values = rbind (values, agg.plot)
##   values.total = rbind (values.total, agg.total.plot)
## }

## file.graph = paste ('times-all-runs.pdf', sep='')
## pdf (file.graph, width=10, height=8)

## g <- ggplot (values, aes (x = TCP, y=NDN)) +
##   geom_point (aes (colour = TCP-NDN), size = I(5)) +
##   geom_point (data = values.total, size=8, colour=I("yellow")) +
##   geom_abline (slope = 1, intercept = 0) +
##   opts (title="Finish time for NDN and TCP flows (all runs)")

##   ## geom_text (data = agg.total.plot, hjust=1, size=10, x=1, y=1, aes (label = paste("Total", round(TCP-NDN,2)))) +
##   ## geom_text (aes (x=TCP+0.5, label = round(TCP-NDN,2)), hjust = 0) +
## grid.arrange (g)

## dev.off ()


## +
##   Geom_text (aes(x = 0, y = -10),   hjust = 0.5, vjust = 1, label = "RTT=100ms", size = I(2)) +
##   geom_text (aes(x = 2.5, y = -10), hjust = 0.5, vjust = 1, label = "RTT=20ms", size = I(2)) +
##   geom_text (aes(x = 5, y = -10),   hjust = 0.5, vjust = 1, label = "RTT=200ms", size = I(2)) +
##   geom_text (aes(x = 7.5, y = -10), hjust = 0.5, vjust = 1, label = "RTT=5ms", size = I(2))

## pdf ("ndn-20-flows-run-5.pdf", width=10, height=10)

## seqs.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
## seqs.ndn = subset (seqs.ndn, Type == "InData")
## seqs.ndn$Flow = as.factor(paste(sep='', "Node ", seqs.ndn$Node, " App ", seqs.ndn$AppId))
## levels(seqs.ndn$Flow)

## g.ndn <- ggplot (seqs.ndn, aes (x = Time)) +
##   geom_point (aes (y = SeqNo, colour = Flow), size = I(1)) +
##   opts (title="Sequence numbers of incoming ContentObject packets (dynamic demand)")

## g.ndn

## dev.off ()

  ## geom_text (aes (y = SeqNo, label = SeqNo), size=1) +

    ## scale_x_continuous (limits=c(0,100)) +

