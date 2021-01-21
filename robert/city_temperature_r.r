name <- "city_temperature_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# needed to save html version with mouse-over text
#install.packages("plotly")
library(plotly)

# needed, to use label_number() on y-axis degree values
#install.packages("scales")
library(scales)

# needed for antialiasing (triggered by type="cairo" in ggsave)
#install.packages("Cairo")
library(Cairo)

#--------------------------------------------------

# or could read data in-line
my_data<-read.table(header=TRUE,text="
month temp city
   1      52.1    Phoenix
   1      40.5    Raleigh
   1      12.2    Minneapolis
   2      55.1    Phoenix
   2      42.2    Raleigh
   2      16.5    Minneapolis
   3      59.7    Phoenix
   3      49.2    Raleigh
   3      28.3    Minneapolis
   4      67.7    Phoenix
   4      59.5    Raleigh
   4      45.1    Minneapolis
   5      76.3    Phoenix
   5      67.4    Raleigh
   5      57.1    Minneapolis
   6      84.6    Phoenix
   6      74.4    Raleigh
   6      66.9    Minneapolis
   7      91.2    Phoenix
   7      77.5    Raleigh
   7      71.9    Minneapolis
   8      89.1    Phoenix
   8      76.5    Raleigh
   8      70.2    Minneapolis
   9      83.8    Phoenix
   9      70.6    Raleigh
   9      60.0    Minneapolis
  10      72.2    Phoenix
  10      60.2    Raleigh
  10      50.0    Minneapolis
  11      59.8    Phoenix
  11      50.0    Raleigh
  11      32.4    Minneapolis
  12      52.5    Phoenix
  12      41.2    Raleigh
  12      18.6    Minneapolis
")
#head(my_data)
#print(my_data)

# Or, read data from a text file
#my_data <- read.table(header=TRUE,file='city_temperature_r.txt')
#head(my_data)

# --------------------------------------------------------------------

# plot the data

# first identify which variables play what roles
my_plot <- ggplot(my_data,aes(x=month,y=temp,group=city,color=city,label=city))+

# create a title, with a unicode character for the 'degrees' fahrenheit
ggtitle(sprintf('Average Monthly Temperature (\u00b0F)')) +

# reference lines (draw before you draw the data lines, so these will be 'behind' the colored data lines)
geom_vline(xintercept=3.4,color="gray55",linetype="dotted") +
geom_vline(xintercept=6.4,color="gray55",linetype="dotted") +
geom_vline(xintercept=9.4,color="gray55",linetype="dotted") +
geom_hline(yintercept=32,color="gray80",size=1,linetype="dotted") +

# annotate a text label on the reference line at 32 degrees
annotate(geom="text",label="Freezing",x=1,y=32,size=3.5) +
# annotate the seasons
annotate(geom="text",vjust=.5,hjust=.5,size=3.5,y=97,x=2,label="Winter") +
annotate(geom="text",vjust=.5,hjust=.5,size=3.5,y=97,x=5,label="Spring") +
annotate(geom="text",vjust=.5,hjust=.5,size=3.5,y=97,x=8,label="Summer") +
annotate(geom="text",vjust=.5,hjust=.5,size=3.5,y=97,x=11,label="Fall") +

# colors for the lines and markers
scale_color_manual(values=c("#1C86EE","red","#c906c7")) +

# draw colored lines after reference lines, so they'll be on top
geom_line(size=1) +

# colored markers, with custom mouse-over text
# causes "Warning message: Ignoring unknown aesthetics: text" ... but that's ok
geom_point(shape=1,size=2,
 aes(text=paste("City: ",city,"<br>Month: ",month,"<br>Temp: ",temp))) +

# city names (from label=) at the end of each line (month=12)
geom_text(data=subset(my_data,month==12), 
 position=position_nudge(0.5),hjust=0,size=3.5,show.legend=FALSE) +
# don't clip the text labels that go outside the axes
coord_cartesian(clip="off") +

# add degree symbol unicode 00b0 to the yaxis tick values
# (the expand= gets rid of space after last tickmark)
scale_y_continuous(labels=label_number(suffix ="\u00b0"), 
 limits=c(0,100),breaks=seq(0,100,by=20),expand=c(0,0)) +

# hard-code the text month names, to show instead of numeric months
scale_x_continuous(expand=c(.01,.90), breaks=seq(1,12,by=1), 
 labels=c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')) +

# blank out the axis labels
ylab(" ") +
xlab(" ") +

# Now for the 'theme' stuff...

# I don't want the default gray frame behind the graph, so use black & white theme
# (be sure to put this before all the other theme-related changes)
theme_bw() +

# control the look of the title
theme(plot.title=element_text(color="gray33",face="bold",hjust=0.5,size=16,margin=margin(10,0,10,0))) +

# get rid of the legend
theme(legend.position="none") +

# make the axis tick values bold
theme(axis.text.x=element_text(face="bold",color="gray22",size=10),
      axis.text.y=element_text(face="bold",color="gray22",size=10)) +

# put some extra space to right of graph, for the city labels
theme(plot.margin=unit(c(.5,2,.5,.5),"cm")) +

# get rid of major & minor gridlines, get rid of all borders, then make left & bottom axis lines visible
theme(
 panel.grid.major=element_blank(),
 panel.grid.minor=element_blank(),
 panel.border=element_blank(),
 axis.line=element_line(color="gray33")
 ) 

# --------------------------------------------------------------------

# Output 2 versions of the graph (a png, and a html page with mouse-over text)

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
#ggsave(filename="city_temperature_r.png",device="png",type="cairo",plot=my_plot,dpi=100,height=5,width=8.5,units="in")
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=5,width=8.5,units="in")

# save as html, with mouse-over text
my_plot1 <- plotly::ggplotly(my_plot,width=850,height=500,tooltip="text") %>% layout(autosize=FALSE)

# center the graph on the web page (default is left-justified)
my_plot2 <- htmltools::div(my_plot1,align="center")
# write the tools needed to display the graph into shared_lib (1 copy for all my samples)
#htmltools::save_html(my_plot2,"city_temperature_r.htm",background="white",libdir="shared_lib")
htmltools::save_html(my_plot2,paste(name,".htm",sep=""),background="white",libdir="shared_lib")

