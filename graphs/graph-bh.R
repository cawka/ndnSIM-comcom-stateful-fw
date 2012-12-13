library (ggplot2)
library (gridExtra)

run.list = 0:2316

all.runs <- data.frame ();
for (run in run.list) {
  cat("Run ", run, "\n")
  input.file = paste(sep="-", "runs-6-bh/blackhole", run, "consumers-seqs.log")

  data = read.table (input.file, header = TRUE, sep = "\t")
  s = subset(data, SeqNo == 11 & Type == "OutInterest")
  
  s$Run = run;

  all.runs <- rbind (all.runs, s)
}

## retx = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,"Unreach.")
retx = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,"Unreach.")
## retx = levels (as.factor(all.hist$Retx))

all.by.node <- with (all.runs, aggregate (all.runs[,6], by=list(Run = Run, Node=Node, AppId = AppId), FUN=length))
all.by.node$x[all.by.node$x >= 19] = "Unreach."
all.hist <- with (all.by.node, aggregate (all.by.node[,4], by=list(Run = Run, Retx = x), FUN=length))

all.hist$Retx = factor(all.hist$Retx, levels=retx, ordered=TRUE)

base.hist = merge (data.frame (Retx = retx), data.frame (Run = run.list), all=TRUE)
base.hist$Retx = factor(base.hist$Retx, levels=retx, ordered=TRUE)
all.hist.adjusted = merge(all.hist, base.hist, all.y=TRUE)
all.hist.adjusted[is.na(all.hist.adjusted$x),]$x = 0 # These are not missing values, these are just zeros

library (doBy)
d = summaryBy(x ~ Retx, all.hist.adjusted, FUN=c(mean), keep.names=TRUE)
names(d) = c("Retx", "Mean")
## names(d) = c("Retx", "Mean", "ymin", "lower", "middle", "upper", "ymax")


all.hist.adjusted$`Number of retransmissions` = factor(all.hist.adjusted$Retx, ordered=TRUE, levels=retx)
d$`Number of retransmissions` = factor(d$Retx, ordered=TRUE, levels=retx)

number.of.runs = length(unique(all.hist$Run))

pdf ("histogram-bh-new.pdf", width=10, height=5)

ggplot (d) +
  geom_histogram (aes (x=`Number of retransmissions`, y=Mean/50, width=1), size=0.2, fill=I("lightblue"), colour=I("black"), stat="identity") + 
  geom_boxplot(data=all.hist.adjusted, aes(x=`Number of retransmissions`, y=x/50), size=0.5, width=0.5) +
  scale_y_continuous (name="Fraction of flows") +
  opts (title=paste("Number end-host retransmissions with quantiles (boxes) and outliers (dots) -", number.of.runs, "runs"))

dev.off ()

all.runs <- data.frame ();
for (run in run.list) {
  cat("Run ", run, "\n")
  input.file = paste(sep="-", "runs-5-bh/blackhole", run, "consumers-seqs.log")
  input.file = paste(sep="-", "ns-3/blackhole", run, "weights.log")

  data = read.table (input.file, header = TRUE, sep = "\t")

  shortest = subset(x[,2:5], SeqNo==10)[,c(1,2,4)]
  names(shortest)[names(shortest)=="Weight"] = "Shortest"
  stretched = subset(x[,2:5], SeqNo==11)[,c(1,2,4)]
  names(stretched)[names(stretched)=="Weight"] = "Stretched"
  s = merge (shortest, stretched, all.x=TRUE)
  s$Stretch = result$`Stretched` / result$`Shortest`
  
  s$Run = run;

  all.runs <- rbind (all.runs, s)
}

## Ecdf over all species
cdf.all <- summarize(all.runs, Stretch = unique(Stretch), 
                     ecdf = ecdf(Stretch)(unique(Stretch)))
## cdf.all[nrow(cdf.all)+1,] = c(1.0,0)

ggplot (cdf.all, aes(Stretch, ecdf)) +
  geom_step () +
  geom_point () +
  scale_y_continuous (limits=c(0,1))
  ## geom_histogram (binwidth=0.001, size=0.2, fill=I("lightblue"), colour=I("black"))

plot (ecdf (all.runs$Stretch))
