library (ggplot2)
library (gridExtra)

setwd ("~/Botan/ns3-ndn/")

for (run in 0:79) {  
  file.ndn = paste ('runs-3/run-', run, '-windows.log', sep='')
  file.tcp = paste ('runs-3/run-', run, '-tcp-windows.log', sep='')
  file.graph = paste ('windows-', run, '.pdf', sep='')

  wnd.ndn = read.table (file.ndn, header = TRUE, sep = "\t")
  wnd.ndn$Flow = with (wnd.ndn, as.factor(paste(sep='', "Node ", Node, " App ", AppId)))
  wnd.ndn$Type = as.factor("NDN");

  wnd.tcp = read.table (file.tcp, header = TRUE, sep = "\t")
  wnd.tcp$Flow = with (wnd.tcp, as.factor(paste(sep='', "Node ", Node, " App ", AppId)))  
  wnd.tcp$Window = (wnd.tcp$Window - 2080) / 1040;
  wnd.tcp$Type = as.factor("TCP");
  wnd.tcp = subset (wnd.tcp, Window < 10000)

  wnd = merge (wnd.ndn, wnd.tcp, all=TRUE)
  wnd$Flow = as.factor(paste(sep='', "Node ", wnd$Node, " App ", wnd$AppId))
  
  
  pdf (file.graph, width=10, height=8)

  g <- ggplot (wnd, aes (x=Time, y=Window)) +
    geom_point (aes (colour = Flow), size=I(1.5)) +
    facet_grid (Type ~ .)
  ## +
  ##   opts (legend.position ="none")

  grid.arrange (g)

  dev.off ()
}

