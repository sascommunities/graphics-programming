name <- "us_age_distribution_analysis_r"

# get access to the ggplot2 stuff
#install.packages("ggplot2")
library(ggplot2)

# needed to save html version with mouse-over text
#install.packages("plotly")
library(plotly)

# needed for percent() format/function
#install.packages("scales")
library(scales)

# Imitating graph from:
# http://healthintelligence.drupalgardens.com/content/which-percentage-people-older-and-younger-you
# http://flowingdata.com/2016/05/10/who-is-older-and-younger-than-you/
# 
# Using World Population Projection (link in article).
# http://esa.un.org/unpd/wpp/DVD/Files/1_Indicators%20(Standard)/ASCII_FILES/WPP2015_INT_F3_Population_Annual_Single_Medium.zip
# (I pre-processed the data in SAS, and copy-n-pasted below)

# Read in the pre-processed data
my_data<-read.table(header=TRUE,text="
your_age value bar_segment
0 0.0000 Younger
0 0.9881 Older
1 0.0119 Younger
1 0.9763 Older
2 0.0237 Younger
2 0.9642 Older
3 0.0358 Younger
3 0.9520 Older
4 0.0480 Younger
4 0.9395 Older
5 0.0605 Younger
5 0.9270 Older
6 0.0730 Younger
6 0.9143 Older
7 0.0857 Younger
7 0.9015 Older
8 0.0985 Younger
8 0.8887 Older
9 0.1113 Younger
9 0.8758 Older
10 0.1242 Younger
10 0.8629 Older
11 0.1371 Younger
11 0.8500 Older
12 0.1500 Younger
12 0.8372 Older
13 0.1628 Younger
13 0.8243 Older
14 0.1757 Younger
14 0.8115 Older
15 0.1885 Younger
15 0.7988 Older
16 0.2012 Younger
16 0.7861 Older
17 0.2139 Younger
17 0.7735 Older
18 0.2265 Younger
18 0.7609 Older
19 0.2391 Younger
19 0.7479 Older
20 0.2521 Younger
20 0.7344 Older
21 0.2656 Younger
21 0.7204 Older
22 0.2796 Younger
22 0.7059 Older
23 0.2941 Younger
23 0.6911 Older
24 0.3089 Younger
24 0.6765 Older
25 0.3235 Younger
25 0.6621 Older
26 0.3379 Younger
26 0.6481 Older
27 0.3519 Younger
27 0.6344 Older
28 0.3656 Younger
28 0.6210 Older
29 0.3790 Younger
29 0.6076 Older
30 0.3924 Younger
30 0.5939 Older
31 0.4061 Younger
31 0.5802 Older
32 0.4198 Younger
32 0.5663 Older
33 0.4337 Younger
33 0.5524 Older
34 0.4476 Younger
34 0.5388 Older
35 0.4612 Younger
35 0.5257 Older
36 0.4743 Younger
36 0.5131 Older
37 0.4869 Younger
37 0.5009 Older
38 0.4991 Younger
38 0.4890 Older
39 0.5110 Younger
39 0.4770 Older
40 0.5230 Younger
40 0.4647 Older
41 0.5353 Younger
41 0.4522 Older
42 0.5478 Younger
42 0.4394 Older
43 0.5606 Younger
43 0.4263 Older
44 0.5737 Younger
44 0.4134 Older
45 0.5866 Younger
45 0.4006 Older
46 0.5994 Younger
46 0.3879 Older
47 0.6121 Younger
47 0.3755 Older
48 0.6245 Younger
48 0.3630 Older
49 0.6370 Younger
49 0.3503 Older
50 0.6497 Younger
50 0.3370 Older
51 0.6630 Younger
51 0.3234 Older
52 0.6766 Younger
52 0.3093 Older
53 0.6907 Younger
53 0.2950 Older
54 0.7050 Younger
54 0.2807 Older
55 0.7193 Younger
55 0.2665 Older
56 0.7335 Younger
56 0.2524 Older
57 0.7476 Younger
57 0.2385 Older
58 0.7615 Younger
58 0.2249 Older
59 0.7751 Younger
59 0.2116 Older
60 0.7884 Younger
60 0.1987 Older
61 0.8013 Younger
61 0.1862 Older
62 0.8138 Younger
62 0.1743 Older
63 0.8257 Younger
63 0.1628 Older
64 0.8372 Younger
64 0.1516 Older
65 0.8484 Younger
65 0.1407 Older
66 0.8593 Younger
66 0.1301 Older
67 0.8699 Younger
67 0.1198 Older
68 0.8802 Younger
68 0.1100 Older
69 0.8900 Younger
69 0.1007 Older
70 0.8993 Younger
70 0.0920 Older
71 0.9080 Younger
71 0.0840 Older
72 0.9160 Younger
72 0.0766 Older
73 0.9234 Younger
73 0.0698 Older
74 0.9302 Younger
74 0.0635 Older
75 0.9365 Younger
75 0.0576 Older
76 0.9424 Younger
76 0.0521 Older
77 0.9479 Younger
77 0.0471 Older
78 0.9529 Younger
78 0.0424 Older
79 0.9576 Younger
79 0.0380 Older
80 0.9620 Younger
80 0.0338 Older
81 0.9662 Younger
81 0.0299 Older
82 0.9701 Younger
82 0.0262 Older
83 0.9738 Younger
83 0.0228 Older
84 0.9772 Younger
84 0.0196 Older
85 0.9804 Younger
85 0.0167 Older
86 0.9833 Younger
86 0.0140 Older
87 0.9860 Younger
87 0.0116 Older
88 0.9884 Younger
88 0.0094 Older
89 0.9906 Younger
89 0.0075 Older
90 0.9925 Younger
90 0.0059 Older
91 0.9941 Younger
91 0.0045 Older
92 0.9955 Younger
92 0.0034 Older
93 0.9966 Younger
93 0.0025 Older
94 0.9975 Younger
94 0.0018 Older
95 0.9982 Younger
95 0.0012 Older
96 0.9988 Younger
96 0.0008 Older
97 0.9992 Younger
97 0.0006 Older
98 0.9994 Younger
98 0.0004 Older
99 0.9996 Younger
99 0.0002 Older
100 0.9998 Younger
100 0.0000 Older
")

# For 'Younger', multiply value by -1, so bar will point down from zero line.
# ('if' would only look at first obsn. 'ifelse' works on all obsns)
my_data$value <- ifelse (my_data$bar_segment=='Younger',my_data$value*-1,my_data$value)

#str(my_data)
head(my_data)

# --------------------------------------------------------------------

# start the plot
my_plot <- ggplot(my_data,aes(x=your_age,weight=value,fill=bar_segment,
 text=paste("If you are ",your_age," years old, then ",percent(value,.1),
 " of the population is ",bar_segment," than you"))) +
# bar chart (color = outline color)
geom_bar(color="#eeeeee") +
# colors of bar segments
scale_fill_manual(values=c("Younger"="#b2df8a","Older"="#fdbf6f")) +
# reference lines (draw after you draw the bars, so these will be 'on top')
geom_hline(yintercept=0,color="gray80",size=1) +
# annotate some text on the graph
annotate(geom="text",vjust=.5,hjust=.5,size=4.0,y=.2,x=20,color="#777777",
 label="% of population older than you",fontface=2) +
annotate(geom="text",vjust=.5,hjust=.5,size=4.0,y=-.25,x=70,color="#777777",
 label="% of population younger than you",fontface=2) +
# title & subtitle
labs(title="U.S. Age Distribution in Year 2016") +
labs(subtitle="Data source: World Population Prospects. DESA, Population Division, UN") +

# control the yaxis
scale_y_continuous(breaks=seq(-1,1,by=.2), 
 limits=c(-1,1),expand=c(0,0),
 labels=c('100%','80%','60%','40%','20%','0%','20%','40%','60%','80%','100%')) +
ylab("") +

# control the xaxis
scale_x_continuous(breaks=seq(0,100,by=10),
 expand=c(0,0)) +
xlab("Your Age") +

# I don't want the default gray frame behind the graph, so use black & white theme
# (be sure to put this before all the other theme-related changes)
theme_bw() +

# control color of axes and tick marks
theme(panel.border=element_rect(color="#999999")) +
theme(axis.ticks=element_blank()) +
theme(panel.border=element_blank()) +
# get rid of minor gridlines
theme(panel.grid.minor=element_blank()) +
# put some extra space to right and bottom of graph
theme(plot.margin=unit(c(0,.5,.3,0),"cm")) +
# add space between xaxis label and tick values
theme(axis.title.x=element_text(margin=margin(t=7,r=0,b=0,l=0))) +
# get rid of the legend
theme(legend.position="none") +
# control the look of the title, and add a little extra margin above it
theme(plot.title=element_text(color="gray33",face="bold",hjust=0.5,size=15,margin=margin(10,0,0,0))) +
theme(plot.subtitle=element_text(color="gray33",hjust=0.5,size=11,margin=margin(8,0,10,0))) 

# --------------------------------------------------------------------

# Output 2 versions of the graph (a png, and a html page with mouse-over text)

# save graph as a png (with no mouse-over text)
# the type="cairo" makes the png anti-aliased
ggsave(filename=paste(name,".png",sep=""),device="png",type="cairo",
 plot=my_plot,dpi=100,height=6,width=8,units="in")

# note that subtitle not supported in ggplotly https://github.com/ropensci/plotly/issues/799
# note that the 'text' used for the mouse-over is defined in the ggplot aes text=
# prepart to save as html, with mouse-over text
# center the graph on the web page (default is left-justified)
# write the tools needed to display the graph into shared_lib (1 copy for all my samples)
my_plot1 <- plotly::ggplotly(my_plot,width=800,height=600,tooltip="text") %>% layout(autosize=FALSE)
my_plot2 <- htmltools::div(my_plot1,align="center")
htmltools::save_html(my_plot2,paste(name,".htm",sep=""),background="white",libdir="shared_lib")
