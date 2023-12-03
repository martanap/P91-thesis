library(ggplot2)
library(scales)
library(latex2exp)
library(colorspace)
library(dplyr)
library(plyr)
library(viridis)
library(grid)
library(gridExtra)

model_bulk <- read.csv(file.choose(), header=T)
model_bulk$type <- "bulk"

p <- ggplot(data=model_bulk, aes(x=time, y=product)) + xlab(TeX('Time (min)')) + ylab(TeX('Fluorescein ($\\mu$M)')) + geom_line(data=model_bulk, aes(x=time, y=product)) + scale_color_discrete_qualitative(palette ="Set2") 
p <- p + theme_gray(base_size=11) + theme(plot.background = element_rect(fill = "transparent",colour = NA),  legend.box.background = element_rect(fill = "transparent", colour=NA), legend.background = element_blank(), legend.key=element_blank())
p <- p + theme(legend.title = element_blank()) 
p

reactionprogressindroplets <- readRDS(file = "reactionprogressindroplets.rds")
reactionprogressindropletsstats<- ddply(reactionprogressindroplets, .(`Time..min.`), summarize,  Integrated.Intensity..RFU.=median(Integrated.Intensity..RFU.))
reactionprogressindropletsstats$transformtoconcentration <- reactionprogressindropletsstats$Integrated.Intensity..RFU.*0.39189


reactionprogressindroplets$Time..min. <- as.numeric(as.character(reactionprogressindroplets$Time..min.))
reactionprogressindropletsstats$Time..min. <- as.numeric(as.character(reactionprogressindropletsstats$Time..min.))

q <- ggplot(reactionprogressindroplets) + geom_jitter(alpha=0.3, size=0.5, aes(y=reactionprogressindroplets$Integrated.Intensity..RFU., x=reactionprogressindroplets$Time..min., color=reactionprogressindroplets$Time..min.))
q <- q + scale_y_continuous(limits = c(50,400)) + scale_x_continuous(limits = c(0,600)) + scale_color_viridis(name="Time (min)") + xlab("Time (min)") + ylab("Fluorescence intensity (RFI)") 
#q <- q + guides(color=guide_legend(title="Time (min)"))
q <- q + geom_line(data=data.frame((c1=reactionprogressindropletsstats$Integrated.Intensity..RFU.), c2=(reactionprogressindropletsstats$Time..min.)), aes(x=c2, y=c1), size=0.5) + geom_point(data=data.frame((c1=reactionprogressindropletsstats$Integrated.Intensity..RFU.), c2=(reactionprogressindropletsstats$Time..min.)), aes(x=c2, y=c1), size=0.5)
q <- q + theme_gray(base_size=11) + theme(plot.background = element_rect(fill = "transparent",colour = NA), legend.box.background = element_rect(fill = "transparent", colour=NA), legend.key=element_blank(), legend.background=element_blank(), legend.position = "right", legend.margin=margin(t = 0, unit='cm'))
q


r <- ggplot(data=model_bulk, aes(x=time, y=product)) + xlab(TeX('Time (min)')) + ylab(TeX('Fluorescein ($\\mu$M)')) + geom_line(data=model_bulk, aes(x=time, y=product, color=type)) +  scale_color_manual(values=c('#D86894'))
r <- r + theme_gray(base_size=11) + theme(plot.background = element_rect(fill = "transparent",colour = NA),  legend.box.background = element_rect(fill = "transparent", colour=NA), legend.background = element_blank(), legend.key=element_blank(), legend.position="none")
r <- r + theme(legend.title = element_blank())
r <- r + geom_line(data=data.frame((d1=reactionprogressindropletsstats$transformtoconcentration), d2=(reactionprogressindropletsstats$Time..min.)), aes(x=d2, y=d1), size=0.5) + geom_point(data=data.frame((d1=reactionprogressindropletsstats$transformtoconcentration), d2=(reactionprogressindropletsstats$Time..min.)), aes(x=d2, y=d1), size=0.5)

r

merged <- grid.arrange(q, r, nrow=1, widths=c(1,0.78))

