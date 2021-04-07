name <- "us_black_population_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# data manipulation package (needed for the part where I calculate the percent)
#install.packages("dplyr")
library(dplyr)

# needed, to use label_number() on y-axis degree values
#install.packages("scales")
library(scales)

#--------------------------------------------------

# Data from https://www.census.gov/quickfacts/fact/table/US/PST045219
# 2019 US population estimate 328,239,523
# Black or African American 13.4% (.134*328,239,523 = 43,984,096.082)
# Not Black 328,239,523 - 43,984,096 = 284,255,427
my_data<-read.table(header=TRUE,text="
population race
 43984096 Black
284225427 Not-Black
")

# calculate the percent for each slice
my_data <- my_data %>% mutate(perc = population/sum(population) )

# create pie slice label containing 2 lines of text
my_data$slice_label <- paste(my_data$race, scales::percent(my_data$perc,accuracy=.1),sep='\n')

print(my_data)

# --------------------------------------------------------------------

# plot the data
# This is basically a geom_col() bar chart, on a polar coordinate system

my_plot <- ggplot(data=my_data,aes(x="",y=population,fill=race)) +
 geom_col(color="#555555") +
 coord_polar(theta="y",direction=-1) +
 scale_fill_manual(values=c("Black"="#a6d854","Not-Black"="#fc8d62")) +
 geom_text(aes(label=slice_label),position=position_stack(vjust=0.5),color="#333333",size=5) +

ggtitle(sprintf("Percent of U.S. Population that is Black (2019)")) +

# remove grid and numeric labels, around the pie
theme_void() +
theme(legend.position="none") +

# control the look of the title
theme(plot.title=element_text(color="#333333",face="bold",size=15,hjust=0.5,margin=margin(10,0,10,0))) 

# --------------------------------------------------------------------

# save graph as a png 
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,dpi=100,height=6.0,width=6.5,units="in")

