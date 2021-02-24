name <- "world_earthquakes_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

#install.packages("dplyr")
library(dplyr)

#install.packages("maps")
library(maps)

# needed for antialiasing (triggered by type="cairo" in ggsave)
#install.packages("Cairo")
library(Cairo)

#--------------------------------------------------

# read data from a text file
my_data <- read.table(sep="\t",header=TRUE,file="../ods11/earthquakes_2000_2020.tsv")
# only keep earthquakes with >= 7 magnitude
my_data <- my_data[my_data$Mag>=7.0,]
# create a new variable containing just the integer part of magnitude (no decimal)
my_data$mag_int <- as.character(as.integer(my_data$Mag))
#head(my_data)

# get the world map, and remove Antarctica
my_map <- map_data("world")
my_map <- my_map[my_map$region!="Antarctica",]
head(my_map)

# --------------------------------------------------------------------

my_plot <- ggplot() +
# draw the world map polygons (countries), and color them yellow
geom_polygon(data=my_map,aes(x=long,y=lat,group=group),fill="#ffffaa") +  
# draw the bubbles at the earthquake locations. size & color them by the magnitude integer value.
geom_point(data=my_data,aes(x=Longitude,y=Latitude,size=mag_int,color=factor(mag_int)),shape=1,stroke=1.1) +
# these are the colors to use for magnitude integer values 7, 8, and 9
scale_color_manual(name="mag_int",values=c("7"="#a6d854","8"="#377eb8","9"="#e7298a")) +
# these are the sizes for the 3 bubbles
scale_size_manual (values= c(2,6,9)) +

#ggtitle(sprintf('Major Earthquakes (magnitude 8.x, 8.x, or 9.x) Years 2000-2020')) +

labs(
 title="Major Earthquakes (magnitude 7.x, 8.x, or 9.x) Years 2000-2020",
 caption="Data source: https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/search") +

# I don't want the default gray frame behind the graph, so use black & white theme
# (be sure to put this before all the other theme-related changes)
theme_bw() +
theme(plot.title=element_text(color="#555555",face="bold",hjust=0.5,size=15,margin=margin(5,0,0,0))) +
theme(plot.caption=element_text(color="#777777",hjust=0.5,size=10,margin=margin(0,0,2,0))) +
theme(panel.grid.major=element_blank()) +
theme(panel.grid.minor=element_blank()) +
theme(axis.text.x=element_blank()) +
theme(axis.text.y=element_blank()) +
theme(axis.title.x=element_blank()) +
theme(axis.title.y=element_blank()) +
theme(panel.border=element_blank()) +
theme(axis.ticks=element_blank()) +
theme(legend.position="none") 


# --------------------------------------------------------------------

# Output 2 versions of the graph (a png, and a html page with mouse-over text)

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=5,width=11,units="in")

# save as html, with mouse-over text
#my_plot1 <- plotly::ggplotly(my_plot,width=850,height=500,tooltip="text") %>% layout(autosize=FALSE)

# center the graph on the web page (default is left-justified)
#my_plot2 <- htmltools::div(my_plot1,align="center")
# write the tools needed to display the graph into shared_lib (1 copy for all my samples)
#htmltools::save_html(my_plot2,"city_temperature_r.htm",background="white",libdir="shared_lib")
#htmltools::save_html(my_plot2,paste(name,".htm",sep=""),background="white",libdir="shared_lib")

