name <- "state_population_map_r"

#install.packages("plotly")
library(plotly)

#install.packages("usmap")
library(usmap)

# read the data (same as SAS sample data sashelp.us_data
# note: plot_usmap() macro requires the variable to be named state, rather than statecode
my_data<-read.table(header=TRUE,text="
state population_2010
AL 4,779,736 
AK 710,231 
AZ 6,392,017 
AR 2,915,918 
CA 37,253,956 
CO 5,029,196 
CT 3,574,097 
DE 897,934 
FL 18,801,310 
GA 9,687,653 
HI 1,360,301 
ID 1,567,582 
IL 12,830,632 
IN 6,483,802 
IA 3,046,355 
KS 2,853,118 
KY 4,339,367 
LA 4,533,372 
ME 1,328,361 
MD 5,773,552 
MA 6,547,629 
MI 9,883,640 
MN 5,303,925 
MS 2,967,297 
MO 5,988,927 
MT 989,415 
NE 1,826,341 
NV 2,700,551 
NH 1,316,470 
NJ 8,791,894 
NM 2,059,179 
NY 19,378,102 
NC 9,535,483 
ND 672,591 
OH 11,536,504 
OK 3,751,351 
OR 3,831,074 
PA 12,702,379 
RI 1,052,567 
SC 4,625,364 
SD 814,180 
TN 6,346,105 
TX 25,145,561 
UT 2,763,885 
VT 625,741 
VA 8,001,024 
WA 6,724,540 
WV 1,852,994 
WI 5,686,986 
WY 563,626 
")

# the numbers with commas were read in as character.
# remove the commas, and convert the column to numeric
my_data$population_2010 = as.numeric(gsub(",","",(gsub("\\.","",my_data$population_2010))))

# manually put the state populations into desired legend bucket
my_data <- my_data %>% mutate(
 my_data, population_bucket=
  ifelse(population_2010<=10000000,"1",
   ifelse(population_2010<=20000000,"2",
    ifelse(population_2010<=30000000,"3","4"))))

# check to make sure population_2010 is numeric
#str(my_data)
#head(my_data)
#print(my_data)

# --------------------------------------------------------------------

# https://www.rdocumentation.org/packages/usmap/versions/0.5.1/topics/plot_usmap

my_plot <- plot_usmap(
 data=my_data,regions="state",values="population_bucket",
 labels=FALSE,color="#333333") + # state outline color

# manually set the colors & text labels for the 4 bucket values
scale_fill_manual(name="population_bucket",
 values=c(
 '1'="#f7f7f7", 
 '2'="#cccccc", 
 '3'="#969696", 
 '4'="#525252"), 
 labels=c(
 '<=10,000,000',
 '10-20,000,000',
 '20-30,000,000',
 '>30,000,000'),
 na.translate=FALSE) + 
 # don't show 'NA' in the legend

# control the label and text size of the legend
guides(fill=guide_legend(title="Population Range: ")) +
theme(legend.text=element_text(size=11)) +
theme(legend.title=element_text(size=11)) +
# move legend closer to the map
theme(legend.position="bottom",legend.justification="center",
 legend.margin=margin(0,0,0,0),legend.box.margin=margin(-20,0,0,0)) + 

# control the title
ggtitle("State Population in Year 2010") +
# add space above title (10), reduce space between title and map (-10)
theme(plot.title=element_text(color="#333333",face="bold",hjust=0.5,size=24,
 margin=margin(10,0,-10,0))) +

# remove visible rectangle around the map
theme(plot.background=element_rect(fill="white"),
 panel.background=element_rect(color=NA,fill=NA)) + 

# remove space on right & left, add space above title and below legend
#theme(plot.margin = unit(c(t,r,b,l),"cm")) 
theme(plot.margin = unit(c(.2,0,.5,0),"cm")) 

# --------------------------------------------------------------------

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",plot=my_plot,
 dpi=100,height=6.5,width=8.25,units="in")

