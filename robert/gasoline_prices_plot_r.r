name <- "gasoline_prices_plot_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# needed to save html version with mouse-over text
#install.packages("plotly")
library(plotly)

# needed, to use label_number() on y-axis degree values
#install.packages("scales")
library(scales)

# needed, to read Excel spreadsheets
#install.packages("tidyverse")
library(readxl)
library(httr)

# read the Excel spreadsheet from the web
url <- "https://www.eia.gov/dnav/pet/hist_xls/EMM_EPMR_PTE_NUS_DPGw.xls"
GET(url,write_disk(tf<-tempfile(fileext=".xls")))
# or, use a copy I saved somewhere
#tf <- "../ods1/EMM_EPMR_PTE_NUS_DPGw.xls"
my_data <- read_excel(tf,sheet="Data 1",skip=2)

# change the names of the variables, to ones I like better
names(my_data) <- c("date_time","gasoline_price")

# Create a date, with just the date part from the date_time
my_data <- my_data %>% mutate(date=as.Date(date_time))

# Add a price_range color variable, based on the gasoline_price
my_data <- my_data %>% mutate(price_range=as.character(as.integer(gasoline_price/.50)))

#head(my_data)

# Only keep data 2001 or later
my_data <- my_data[my_data$date>="2001-01-01",]
#head(my_data)

# get the 1 row of data, with the max date value
max_day_data <- my_data %>% filter(date==max(date))
#head(max_day_data)
# Save these values in variables I can use in the footnote 'caption'
max_date <- max(as.character(max_day_data$date, format="%B %d, %Y"))
end_price <- max(dollar(max_day_data$gasoline_price))

# --------------------------------------------------------------------

# first identify which variables play what roles in the plot(s)
my_plot <- ggplot(my_data,aes(x=date,y=gasoline_price,color=price_range)) +

# set the labels (title, footnote/caption, yaxis)
labs(
 title="US Regular Gasoline - Average Retail Price",
 caption=paste("Data source: eia.doe.gov  ",max_date," (ending price = ",end_price,")"), 
 y="$/gal"
 ) +

# draw the 'needle' bars
geom_col() +

# draw an 'x' marker on the last value
geom_point(data=max_day_data,shape='cross',size=2,color="black") +

# control the colors of the needles
scale_color_manual(values = c(
 "1" = "#FFFFCC", 
 "2" = "#FFEDA0",
 "3" = "#FED976",
 "4" = "#FEB24C",
 "5" = "#FD8D3C",
 "6" = "#FC4E2A",
 "7" = "#E31A1C",
 "8" = "#BD0026",
 "9" = "#800026"
 )) +

# control the yaxis
scale_y_continuous(limits=c(0,5),breaks=seq(0,5.00,.50),
 expand=c(0,0),labels=scales::dollar_format(),
 # second y-axis, on right-hand side (same as left-side)
 sec.axis=sec_axis(trans=~.,name=derive(),breaks=derive(),
  labels=derive(),guide=derive())) +

# control the xaxis
scale_x_date(limits=c(as.Date("2001-1-1"),as.Date("2022-1-1")),breaks=date_breaks("year"),expand=c(0,0),
 labels=date_format("%Y")) +

# blank out the x axis label
xlab(" ") +

# use black & white theme, so there's no fill behind the graph
theme_bw() +

# make theme modifications *after* changing the theme ...

# control color of axes and tick marks
theme(panel.border=element_rect(color="#999999")) +
theme(axis.ticks=element_line(color="#999999")) +
# get rid of minor gridlines
theme(panel.grid.minor=element_blank()) +

# center the title
theme(plot.title=element_text(size=18,hjust=0.5,face="bold",color="#333333",margin=margin(t=10,r=0,b=20,l=0))) +

theme(plot.caption=element_text(size=9,hjust=0.5,face="plain",color="#777777")) +

# add some space around the graph
theme(plot.margin=unit(c(t=5.5,r=25.5,b=5.5,l=5.5),"pt")) +

# angle the xaxis (year) values 90 degrees
theme(axis.text.x=element_text(face="bold",color="#333333",size=11,angle=90,vjust=.5),
      axis.text.y=element_text(face="bold",color="#333333",size=11)) +

# move the yaxis label to the top, and angle horizontally
theme(axis.title.y=element_text(angle=0,hjust=0,vjust=1)) +
theme(axis.title.y.right=element_text(angle=0,hjust=0,vjust=1)) +

theme(legend.position="none") 

# --------------------------------------------------------------------

# Output 2 versions of the graph (a png, and a html page with mouse-over text)

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=6,width=9.5,units="in")

# save as html, with mouse-over text
my_plot1 <- plotly::ggplotly(my_plot,width=850,height=500,tooltip="text") %>% layout(autosize=FALSE)

# center the graph on the web page (default is left-justified)
my_plot2 <- htmltools::div(my_plot1,align="center")
# write the tools needed to display the graph into shared_lib (1 copy for all my samples)
# the html output does not look good, for this graph...
#htmltools::save_html(my_plot2,paste(name,".htm",sep=""),background="white",libdir="shared_lib")

