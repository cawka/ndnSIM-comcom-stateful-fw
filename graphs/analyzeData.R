library (ggplot2)
library (gridExtra)

all.runs = c(0:99)

values <- data.frame ()
values.total <- data.frame ()

for (run in all.runs) {
  cat(run,"\n")
  file.ndn = paste ('ns-3/run-', run, '-consumers-seqs.log', sep='')
  file.tcp = paste ('ns-3/run-', run, '-tcp-consumers-seqs.log', sep='')

  seqs.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
  seqs.ndn = subset (seqs.ndn, Type == "InData")
  seqs.ndn$Type = as.factor("NDN");

  seqs.tcp = read.table (file.tcp, header = TRUE, sep = "\t")
  seqs.tcp = subset (seqs.tcp, SeqNo >= 1)
  seqs.tcp$Type = as.factor("TCP");

  seqs = merge (seqs.ndn, seqs.tcp, all=TRUE)
  seqs$Flow = as.factor(paste(sep='', "Node ", seqs$Node, " App ", seqs$AppId))
  
  agg = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type, Flow = seqs$Flow), FUN=max)

  agg.plot = as.data.frame (cbind (TCP = subset(agg, Type=="TCP")[,3], NDN = subset(agg, Type=="NDN")[,3]))

  agg.total = aggregate(seqs[,c(1,6)], by=list(Type = seqs$Type), FUN=max)
  agg.total.plot = as.data.frame (cbind (TCP = subset(agg.total, Type=="TCP")[,2],
                                         NDN = subset(agg.total, Type=="NDN")[,2]))
  
  write.table (agg.plot, "agg-plot.log", row.names=FALSE, append=(run!=all.runs[1]), col.names=(run==all.runs[1])) 
  write.table (agg.total.plot, "agg-total-plot.log", row.names=FALSE, append=(run!=all.runs[1]), col.names=(run==all.runs[1])) 
  values = rbind (values, agg.plot)
  values.total = rbind (values.total, agg.total.plot)
}

values = read.table ("agg-plot.log", row.names=NULL, header=TRUE)
values.total = read.table ("agg-total-plot.log", row.names=NULL, header=TRUE)

file.graph = paste ('times-all-runs.pdf', sep='')
pdf (file.graph, width=10, height=8) 

g <- ggplot (values, aes (x = TCP, y=NDN)) +
  geom_point (colour=I("black"), fill=I("blue"), size = I(3)) +
  geom_point (data = values.total, colour=I("black"), fill=I("white"), size=I(4)) +
  geom_abline (slope = 1, intercept = 0) +
  opts (title="Finish time for NDN and TCP flows (all runs)") 

  ## geom_text (data = agg.total.plot, hjust=1, size=10, x=1, y=1, aes (label = paste("Total", round(TCP-NDN,2)))) +
  ## geom_text (aes (x=TCP+0.5, label = round(TCP-NDN,2)), hjust = 0) +
grid.arrange (g)

dev.off ()

