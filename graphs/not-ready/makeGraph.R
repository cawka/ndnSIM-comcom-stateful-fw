library (ggplot2)
library (gridExtra)


theme_test <- function(base_size = 12, base_family = "") {
  structure(list(
    axis.line = theme_blank(),
    axis.text.x = theme_text(family = base_family, size = base_size * 0.7, lineheight = 0.7, vjust = 1.2),
    axis.text.y = theme_text(family = base_family, size = base_size * 0.7, lineheight = 0.7, hjust = 1.2),
    axis.ticks = theme_segment(colour = "black", size=0.2),
    axis.title.x = theme_text(family = base_family, size = base_size, vjust = 0.5),
    axis.title.y = theme_text(family = base_family, size = base_size, angle = 90, vjust = 0.5),
    axis.ticks.length = unit(0.15, "cm"),
    axis.ticks.margin = unit(0.1, "cm"),

    legend.background = theme_rect(fill="white", colour="black", size=0.1),
    legend.margin = unit(0.2, "cm"),
    legend.key = theme_rect(fill = "grey95", colour = "white"),
    legend.key.size = unit(1.2, "lines"),
    legend.key.height = NA,
    legend.key.width = NA,
    legend.text = theme_text(family = base_family, size = base_size * 0.8),
    legend.text.align = NA,
    legend.title = theme_text(family = base_family, size = base_size * 0.8, face = "bold", hjust = 1),
    legend.title.align = 0,
    legend.position = "top",
    legend.direction = "horizontal",
    legend.justification = "center",
    legend.box = "horizontal",

    panel.background = theme_rect(fill = "white", colour = NA),
    panel.border = theme_rect(fill = NA, colour = "grey50"),
    panel.grid.major = theme_line(colour = "grey90", size = 0.2),
    panel.grid.minor = theme_line(colour = "grey98", size = 0.5),
    panel.margin = unit(c(0, 0, 0, 0), "lines"),

    strip.background = theme_rect(fill = "grey80", colour = NA),
    strip.text.x = theme_text(family = base_family, size = base_size * 0.8),
    strip.text.y = theme_text(family = base_family, size = base_size * 0.8, angle = -90),

    plot.background = theme_rect(colour = NA, fill = "white"),
    plot.title = theme_text(family = base_family, size = base_size * 1.2),
    plot.margin = unit(c(0, 0, 0, 0), "lines")
  ), class = "options")
}

values = read.table ("agg-plot.log", row.names=NULL, header=TRUE)
values.total = read.table ("agg-total-plot.log", row.names=NULL, header=TRUE)

## values$`Finishing time` = "for individual flows \nfor all runs"
## values.total$`Finishing time` = "for all flows \nfor individual run"

## all = rbind (values, values.total)
## all$`Finishing time` = factor (all$`Finishing time`, ordered=TRUE, levels=c("for individual flows \nfor all runs",
##                                                                      "for all flows \nfor individual run"))

all = values.total

file.graph = paste ('times-all-runs.pdf', sep='')
## pdf (file.graph, width=3.35, height=3.35)
postscript ("times-all-runs.eps", onefile=TRUE, horizontal=FALSE, paper="special", width=3.35, height=3.35)
setEPS ()
ggplot (all, aes (x = TCP, y=NDN)) +
  ## geom_point (aes(size=`Finishing time`, shape=`Finishing time`, colour=`Finishing time`, fill=`Finishing time`)) +
  geom_point (size=3, shape=21, colour="black", fill="gray70") +
  geom_abline (slope = 1, intercept = 0) +
  ## scale_size_manual (values = c(1, 3)) +
  ## scale_shape_manual (values = c(20, 23)) +
  ## scale_colour_manual (values = c("gray45", "black")) +
  ## scale_fill_manual (values = c("gray45", "white")) +
  scale_x_continuous ("Finishing time of TCP flows, seconds", limits=c(35,110)) +
  scale_y_continuous ("Finishing time of NDN flows, seconds", limits=c(35,110)) +
  theme_test (10) +
  opts (legend.position = c(0.573, 0.9)) 

#  geom_point (data = values.total, shape=23, colour=I("black"), fill=I("white"), size=I(3)) +
#+
#  opts (title="Finish time for NDN and TCP flows (all runs)", plot.margin=unit(c(0,0,0,0), "lines"))
#+
#  theme_set(theme_grey(10)) 

  ## geom_text (data = agg.total.plot, hjust=1, size=10, x=1, y=1, aes (label = paste("Total", round(TCP-NDN,2)))) +
  ## geom_text (aes (x=TCP+0.5, label = round(TCP-NDN,2)), hjust = 0) +

dev.off ()

pdf ("congestion-finishing-time-histogram.pdf", width=3.35, height=3.35) 

## ggplot (subset(all, `Finishing time`=="for all flows for a run")) +
ggplot(all) +
  geom_rect (aes(xmin=0, xmax=1-0.125, ymin=0, ymax=0.6), fill="black", colour=NA, alpha=0.3) + #, position=position_identity()) +
  geom_histogram (aes(x = TCP/NDN, y=..density../4, fill=`Finishing time`), colour=I("black"), binwidth=0.25, position="dodge") +
  theme_test (10) +
  scale_y_continuous ("Fraction of flows", limits=c(-0.1,0.6)) +
  scale_x_continuous ("Ratio of finishing time between TCP and NDN", limits=c(0,5), breaks=seq(0,5,0.5)) +
  coord_cartesian (xlim=c(0,4.2), ylim=c(0,0.55)) +
  scale_fill_manual ("Ratio of finishing time", values = c("white", "gray10")) +
  opts (legend.position = c(0.573, 0.9)) 

dev.off ()
