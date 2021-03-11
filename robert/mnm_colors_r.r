name <- "mnm_colors_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# needed to save html version with mouse-over text
#install.packages("plotly")
library(plotly)

# needed, to use label_number() on y-axis degree values
# needed for percent() format/function
#install.packages("scales")
library(scales)

# needed for antialiasing (triggered by type="cairo" in ggsave)
#install.packages("Cairo")
library(Cairo)

# needed for annotate_textp()
#install.packages("ggalt")
#library(ggalt)

# needed for annotate_textp()
#install.packages("gtable")
#library(gtable)


#--------------------------------------------------

# read data in-line
my_data<-read.table(header=TRUE,text="
mnm_color count
Green  99
Red    86
Blue  102
Orange 73
Yellow 54
Brown  77
")

# calculate the percent for each color
my_data <- my_data %>% mutate(calculated_percent = count/sum(count))

print(my_data)


#Colour Palette
pal <- c(
  "Blue"   = "#4cbbe6",
  "Green"  = "#74e059", 
  "Red"    = "#d22515", 
  "Orange" = "#fbb635", 
  "Yellow" = "#f4f25f", 
  "Brown"  = "#5d242a" 
)


# --------------------------------------------------------------------

# plot the data



my_plot <- ggplot(my_data, aes(x=reorder(mnm_color,-count),y=count,
 fill=mnm_color,label=count,text=calculated_percent)) +
geom_bar(color="#777777",width=.7,stat="identity") +
scale_fill_manual(values=pal,limits=names(pal)) +
geom_label(size=3.2,vjust=1.0,fontface="bold",fill=alpha(c("white"),0.7)) +
geom_text(size=3.2,vjust=-.50,fontface="bold",aes(label=percent(calculated_percent,.1))) +
labs(x=NULL,y=NULL) +

#theme(plot.title = element_text(hjust = -0.16, vjust=2.12, colour="#68382C", size = 14)) +

labs(subtitle="Count") +

scale_y_continuous(limits=c(0,120),breaks=seq(0,120,by=20),expand=c(0,0)) +
geom_hline(aes(yintercept=0),color="#777777",linetype="solid") +


# use black & white theme, so there's no fill behind the graph
theme_bw() +

theme(legend.position="none") +
theme(axis.text.y=element_text(color="#555555",size=11,face="plain")) +
theme(axis.text.x=element_text(color="#333333",size=11,face="bold")) +

# get rid of minor Y gridlines, and major X gridlines
theme(panel.grid.minor=element_blank()) +
theme(panel.grid.major.x=element_blank()) +
theme(panel.grid.major=element_line(colour="#cccccc")) +

theme(panel.border=element_blank()) +
theme(axis.ticks=element_blank()) +

theme(plot.title=element_text(color="#333333",face="bold",hjust=0.5,size=17,margin=margin(5,0,10,0))) +
theme(plot.subtitle=element_text(color="#555555",face="plain",hjust=-.06,size=11,margin=margin(0,0,12,0))) +
ggtitle(sprintf('Frequency of Colors in an M&M Packet')) 

# --------------------------------------------------------------------

ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=4.5,width=6,units="in")

