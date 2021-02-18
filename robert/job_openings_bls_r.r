name <- "job_openings_bls_r"

# This code might help: http://lenkiefer.com/2018/09/11/jolts-update/

#install.packages("tidyverse")
library(readxl)

# for melt()
#install.packages("data.table")
library(data.table)

#install.packages("plotly")
library(plotly)

# -----------------------------------------------------------

# custom function to process data from Excel spreadsheet
read_data <- function(xlsfile,survey_title) {

# read the Excel spreadsheet
temp_data <- read_excel(xlsfile,sheet=1,skip=11)

# turn the month columns into values
temp_data <- melt(as.data.table(temp_data),id=c("Year"),
 value.name="job_openings_rate",variable.name="month")

# divide by 100, so I can use % formats
temp_data$job_openings_rate <- temp_data$job_openings_rate/100

# Use year & month, and create a proper date variable (for 15th of each month)
temp_data$date <- as.Date(paste("15",temp_data$month,temp_data$Year,sep=""),"%d%b%Y")

# add a variable for the descriptive text (which you passed-in to the macro)
temp_data$survey_title <- c(survey_title)

# remove rows with missing/NA data
temp_data <- na.omit(temp_data)

# sort the data, and save the last (most recent) row in temp_latest
temp_data <- temp_data[order(temp_data$date),]
temp_latest <- tail(temp_data,n=1)
my_latest <<- rbind(my_latest,temp_latest)

# append the temp_data to the global my_data
my_data <<- rbind(my_data,temp_data)

}

# initialize the datasets
my_data <- data.frame()
my_latest <- data.frame()

# read in the 12 spreadsheets, using the custom function
read_data("../ods4/SeriesReport-20190411072035_0b99d7.xlsx","Total nonfarm")
read_data("../ods4/SeriesReport-20190411084943_987910.xlsx","Trade, transportation, and utilities")
read_data("../ods4/SeriesReport-20190411091327_530482.xlsx","Professional and business services")
read_data("../ods4/SeriesReport-20190411091852_3ae78c.xlsx","Education and health services")
read_data("../ods4/SeriesReport-20190411092515_a7430e.xlsx","Leisure and hospitality")
read_data("../ods4/SeriesReport-20190411092906_c269ba.xlsx","Manufacturing")
read_data("../ods4/SeriesReport-20190411093420_c2726b.xlsx","Government")
read_data("../ods4/SeriesReport-20190411094247_8b3456.xlsx","Construction")
read_data("../ods4/SeriesReport-20190411094638_8479b9.xlsx","Other services")
read_data("../ods4/SeriesReport-20190411095010_9fd34a.xlsx","Financial activities")
read_data("../ods4/SeriesReport-20190411095445_7d57c5.xlsx","Information")
read_data("../ods4/SeriesReport-20190411095643_4052a1.xlsx","Mining and logging")

print(my_data)

#print(my_latest)

# --------------------------------------------------------------------

my_plot <- ggplot(data=my_data,aes(x=date,y=job_openings_rate,color=survey_title)) +

geom_line(color=NA) +

# plot the data as (semi-transparent) colored area below the line
geom_ribbon(alpha=0.5,aes(ymin=0,ymax=job_openings_rate,fill=survey_title),color=NA) +

# draw line along top of the ribbon, with darker/non-transparent version of same color
geom_line(size=0.20)+

# show the latest value with a dashed horizontal line (note: this is in a separate dataset)
geom_hline(data=my_latest,aes(yintercept=job_openings_rate),linetype="dashed",color="#777777",size=0.5) +

# show the latest value with a single marker (note: this is in a separate dataset)
geom_point(data=my_latest,aes(x=date,y=job_openings_rate),color="#777777",size=1.5,shape=16) +

#this creates the grid of graphs
facet_wrap(~ survey_title,ncol=4) +

scale_y_continuous(
 breaks=seq(0,.08,by=.02), 
 limits=c(0,.08),expand=c(0,0),
 labels=scales::percent_format(accuracy=1)) +
scale_x_date(
 breaks=seq(as.Date("2000-01-01"),as.Date("2020-01-01"),by="5 years"),
 limits=as.Date(c("2000-01-01","2020-01-01")),
 expand=c(0,0),
#labels=date_format("%Y")
 labels=c(' ','2005','2010','2015','2020')
 ) +

labs(x="",y="",
 title="U.S. Job Openings Rate, by Industry",
 subtitle="Dashed line --- represents latest value (Feb 2019)",
 caption="Data source: U.S. Bureau of Labor Statistics Job Openings and Labor Turnover Survey - Downloaded 11apr2019, values through Feb 2019") +

theme_minimal() +
theme(plot.title=element_text(size=15,hjust=0.5,face="bold",color="#333333",margin=margin(t=11,r=0,b=0,l=0))) +
theme(plot.subtitle=element_text(size=11,hjust=0.5,face="plain",color="#777777",margin=margin(t=8,r=0,b=8,l=0))) +
theme(plot.caption=element_text(size=10,hjust=0.5,face="plain",color="#777777",margin=margin(t=0,r=0,b=0,l=0))) +
theme(panel.grid.minor=element_blank()) +
theme(plot.margin=unit(c(0,.7,.3,0),"cm")) +
theme(legend.position="none")

# --------------------------------------------------------------------

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=8,width=10,units="in")

