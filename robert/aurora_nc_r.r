name <- "aurora_nc_r"

# Got shapefile from https://co.beaufort.nc.us/downloads/gis/gis-data

#install.packages('devtools')
#devtools::install_github("dkahle/ggmap")
#install.packages(c("ggplot2","tidyverse"))
# Enter '1' to install all packages with more recent version available
# hmm ... failed to install ggmap ... the package I probably most wanted?

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# interactive/mouse-over/tooltip capability
#install.packages("ggiraph")
library(ggiraph)

# needed to save html version with mouse-over text
#install.packages("plotly")
library(plotly)

# needed, to use label_number() on y-axis degree values
#install.packages("scales")
library(scales)

# https://www.r-graph-gallery.com/168-load-a-shape-file-into-r.html
# read shapfiies, and such
#install.packages("rgdal")
library(rgdal)

# to get tidy to convert geospatial data to data frame
#install.packages("maptools")
library(maptools)

# general polygon clipper
#install.packages("gpclib")
library(gpclib)

# to get tidy (replacement for fortify)
#install.packages("broom")
library(broom)

# for get_map
#install.packages("ggmap") 
library(ggmap)

# needed for join()
#install.packages("plyr")
library(plyr)

# to get the format_dollars() 
#install.packages("priceR")
library(priceR)

# ---------------------------------------------

# Import the Beaufort county shapefile
# (takes 2-3 minutes to run)
county_spdf <- readOGR(dsn="D:/Public/beaufort_county/Parcels.shp",verbose=FALSE)
# See what's in the shapefile
summary(county_spdf@data)

# subset just the town of Aurora, NC
city_spdf <- subset(county_spdf,TOWNSHIP=='13')

# convert to unprojected lat/long coordinates in eastlong degrees
city_spdf <- spTransform(city_spdf,"+init=epsg:4326")

# convert geospatial data to data frame, so ggplot2 can handle it
# id is the parcel id, and group is the id plus a segment number
city_frame <- tidy(city_spdf,region="GPINLONG")
#head(city_frame)

# Get unique info for each parcel, and merge it back in with
# the map data frame (since tidy only saves certain variables)
# (I want extra variables for the mouse-over)
temp_unique <- data.frame(
 city_spdf@data$GPINLONG,
 city_spdf@data$PROP_ADDR,
 city_spdf@data$CalcAcres,
 city_spdf@data$TOT_VAL,
 city_spdf@data$YR_BUILT,
 city_spdf@data$NAME1,
 city_spdf@data$NAME2
 )
names(temp_unique) <- c("id","PROP_ADDR","CalcAcres","TOT_VAL","YR_BUILT","NAME1","NAME2")
city_frame_plus <- join(city_frame,temp_unique,by="id")
#head(city_frame_plus)

# manually assign to color buckets, based on year built
city_frame_plus <- city_frame_plus %>% mutate(
 city_frame_plus, yr_built_range=
  ifelse(YR_BUILT<=1900,'1800-1900',
   ifelse(YR_BUILT<=1950,'1901-1950',
    ifelse(YR_BUILT<=1999,'1951-1999',
     ifelse(YR_BUILT>=2000,'2000s',
      'NA')))))

# create the tooltip (mouse-over) text
city_frame_plus$tooltip_text <- paste(
 "ID: ",city_frame_plus$id,"<br>",
 "Address: ",city_frame_plus$PROP_ADDR,"<br>",
 "Acres: ",city_frame_plus$CalcAcres,"<br>",
 "Value: ",format_dollars(city_frame_plus$TOT_VAL),"<br>",
 "Year built: ",city_frame_plus$YR_BUILT,"<br>",
 "Owner: ",city_frame_plus$NAME1,"<br>",
 "Owner 2: ",city_frame_plus$NAME2,
 sep=" ")
#head(city_frame_plus)


# --------------------------------------------------------------------

# get the background map tiles for specific lat/long area
# https://rdrr.io/cran/ggmap/man/get_stamenmap.html
# if I try to zoom farther, I don't get all the terrain background tiles
# my_map <- get_stamenmap(bb=c(left=-80.7,bottom=35.715,right=-80.66,top=35.75),zoom=13,maptype="terrain",color="bw")
# my_map <- get_stamenmap(bb=c(left=-80.7,bottom=35.715,right=-80.66,top=35.75),zoom=13,maptype="watercolor")

my_map <- get_stamenmap(bb=c(left=-76.803,bottom=35.294,right=-76.775,top=35.312),zoom=14,maptype="toner")

# https://cfss.uchicago.edu/notes/raster-maps-with-ggmap/
# get_map() is just a wrapper (makes it more confusing)
# get_googlemap() now requires API key
# get_openstreetmap() is now defunct

# draw the background map, and then overlay the property parcel polygons
my_plot <- 
 ggmap(my_map)+
 geom_polygon(data=city_frame_plus,color="#333333",
  aes(x=long,y=lat,group=group,fill=yr_built_range,text=tooltip_text)) +
 scale_fill_manual(name="Year built:",values=c("#d7191c", "#fdae61", "#a6d96a", "#1a9641", "#efefef")) +
 xlab('') + ylab('') +
 theme_bw() +
  theme(axis.line = element_blank(),
  axis.text = element_blank(),
  axis.ticks = element_blank()
 ) +
labs(title="Properties in Aurora, NC (March 2021 snapshot)") +
theme(plot.title=element_text(size=26,color="#333333",face="bold",hjust=0.5,margin=margin(10,0,5,0))) +
theme(legend.margin=margin(-2,0,0,0)) +
theme(legend.position="bottom",legend.box.margin=margin(0,0,10,0)) +
theme(legend.title=element_text(size=15)) +
theme(legend.text=element_text(size=15))

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,width=12,height=10,units="in")

# save as html, with mouse-over text
# center the graph on the web page (default is left-justified)
# write the tools needed to display the graph into shared_lib (1 copy for all my samples)
my_plot1 <- plotly::ggplotly(my_plot,width=1200,height=1000,tooltip="text") %>% layout(autosize=FALSE)
my_plot2 <- htmltools::div(my_plot1,align="center")
htmltools::save_html(my_plot2,paste(name,".htm",sep=""),background="white",libdir="shared_lib")

