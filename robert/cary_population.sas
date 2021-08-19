%let name=cary_population;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
SAS versions of graphs from 2021 Budget doc:
https://www.townofcary.org/home/showpublisheddocument/25221/637401875918170000
*/

/* from page 422 */
/* got years 2003 and 2004 from https://www.townofcary.org/home/showpublisheddocument/17831/636377797286670000 */
data pop_data;
label year='Fiscal Year';
label population='Total annual population';
informat population comma7.;
format population comma7.;
/*
To have the year in the mouse-over tip text as 2010, rather than 2,010
you must use the f4.0 format (rather than the default, or 4.0 format)
and you must also specity the tip=() variables (rather than letting 
them default.
*/
format year f4.0;
input year population;
datalines;
2003 102,496
2004 105,575
2005 106,644
2006 109,129
2007 113,486
2008 119740
2009 127,201
2010 131,862
2011 136,695
2012 139,672
2013 142,257
2014 144,982
2015 150,009
2016 154,175
2017 160,390
2018 163,930
2019 167,547
2020 170,322
2021 173,728
;
run;

data pop_data; set pop_data;

label change_in_population='Annual change from prior year';
format change_in_population comma8.0;
change_in_population=population-lag(population);

label percent_change='Annual percent change from prior year';
format percent_change percentn7.2;
percent_change=(population-lag(population))/lag(population);

/* In Cary's graph, it appears they rounded the values, to the nearest percent */
label rounded_percent_change='Annual percent change from prior year';
format rounded_percent_change percentn7.2;
rounded_percent_change=round(percent_change,.01);

if year>=2005 then output;
run;


/* Annotate a transparent 'Bad Graph' label */
data anno_bad_graph;
length label $100 anchor x1space y1space textweight $50;
layer="front";
function="text"; textcolor="red"; textweight='bold';
textsize=60; transparency=.65; rotate=45;
width=130; widthunit='percent';
anchor='center';
x1space='datapercent';
y1space='datapercent';
x1=50;
y1=55;
label="Bad Graph";
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Statistics") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=700px height=500px noborder;

title1 h=15pt c=gray33 "Town of Cary Population History";

proc sgplot data=pop_data noborder;
vbarparm category=year response=population / barwidth=.7 
 fillattrs=(color=cx4C7AA3) nooutline tip=(year population);
yaxis display=(noline noticks) labelpos=top
 labelattrs=(color=gray33 size=11pt weight=bold)
 values=(0 to 200000 by 50000) 
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

proc sgplot data=pop_data noborder sganno=anno_bad_graph;
vbarparm category=year response=population / barwidth=.7
 fillattrs=(color=cx4C7AA3) nooutline tip=(year population);
yaxis display=(noline noticks) labelpos=top
 labelattrs=(color=gray33 size=11pt weight=bold)
 values=(100000 to 180000 by 20000)
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;


proc sgplot data=pop_data noborder;
vbarparm category=year response=change_in_population / barwidth=.7
 fillattrs=(color=cx4C7AA3) nooutline tip=(year change_in_population);
yaxis display=(noline noticks) labelpos=top 
 labelattrs=(color=gray33 size=11pt weight=bold)
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

/* 
Hmm ... it appears Cary's graph was rounding the % change to the nearest whole %.
Whereas I do not round mine.
Also, connecting data points with a line is misleading (values along the line are not
really what the value would be, at that point during the year).
*/

proc sgplot data=pop_data noborder sganno=anno_bad_graph;
series y=rounded_percent_change x=year / markers tip=(year rounded_percent_change);
yaxis display=(noline noticks) labelpos=top
 labelattrs=(color=gray33 size=11pt weight=bold)
 values=(0 to .07 by .01) offsetmin=0 
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

data bad_demo; set pop_data;
output;
if year<2021 then do;
 rounded_percent_change=0; output;
 end;
run;

data anno_ugly_graph; set anno_bad_graph;
label='Ugly Graph';
run;

proc sgplot data=bad_demo noborder sganno=anno_ugly_graph;
series y=rounded_percent_change x=year / markers tip=(year rounded_percent_change);
yaxis display=(noline noticks) labelpos=top
 labelattrs=(color=gray33 size=11pt weight=bold)
 values=(0 to .07 by .01) offsetmin=0 
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

proc sgplot data=pop_data noborder;
vbarparm category=year response=percent_change / barwidth=.7
 fillattrs=(color=dodgerblue) nooutline tip=(year percent_change);
yaxis display=(noline noticks) labelpos=top 
 labelattrs=(color=gray33 size=11pt weight=bold)
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis type=linear labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

/*
Let's fake some negative population growth, to demonstrate how the
bar coloring would work with a negative and positive value.
*/
data negative_demo; set pop_data;
if year=2017 then percent_change=.01;
if year=2018 then percent_change=-.008;
if year=2019 then percent_change=-.016;
if year=2020 then percent_change=-.003;
run;

data negative_demo; set negative_demo;
if percent_change>=0 then change='Positive';
else change='Negative';
run;

/* An attribute map, to guarantee 'Positive' values blue, and 'Negative' values red. */
data myattrs;
length fillcolor $12 value $100;
id="some_id";
fillcolor="dodgerblue"; value='Positive'; output;
fillcolor="cxFF4040"; value='Negative'; output;
run;

data anno_proof; set anno_bad_graph;
textsize=45;
label='Proof-of-Concept';
run;

title1 h=15pt c=gray33 "Proof-of-Concept Population History";
proc sgplot data=negative_demo noborder noautolegend sganno=anno_proof dattrmap=myattrs;
vbarparm category=year response=percent_change / barwidth=.7
 group=change attrid=some_id
 nooutline tip=(year percent_change);
yaxis display=(noline noticks) labelpos=top
 labelattrs=(color=gray33 size=11pt weight=bold)
 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(noline noticks) type=linear
 labelattrs=(color=gray33 size=11pt weight=bold)
 grid gridattrs=(pattern=dot color=gray11);
run;

/*
proc print data=pop_data;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
