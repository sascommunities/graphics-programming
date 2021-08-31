%let name=cary_temperature;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/rdu-weather-history/table/
*/

proc import datafile="D:\public\cary\2021\rdu-weather-history.csv" dbms=dlm out=weather_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;

data weather_data; set weather_data;
year=.; year=put(date,year4.);
day=date;
run;

proc sort data=weather_data out=weather_data;
by date;
run;
/*
*/

%let mydata=weather_data;

%let color0=graydd;
%let color1=cx9B30FF;
%let color2=cxB0E2FF;
%let color3=cx4AC948;
%let color4=cxFFCC11;
%let color5=red;

/* from http://www.nws.noaa.gov/ost/air_quality/FAQ_01172011.pdf */
proc format;
value binfmt
.='no data'
1='<=32'
2='33-60'
3='61-85'
4='86-99'
5='100+'
;
run;

/* Cary's temperature data is in integers (no decimal) */
data &mydata; set &mydata;
format colorbin binfmt.;
if TemperatureMax=. then colorbin=.;
else if TemperatureMax<=32 then colorbin=1;
else if TemperatureMax<=60 then colorbin=2;
else if TemperatureMax<=85 then colorbin=3;
else if TemperatureMax<=99 then colorbin=4;
else colorbin=5;
length  details $300;
details='a0'x||'0d'x||'The maximum temperature on '||
 trim(left(put(day,downame.)))||' '||lowcase(put(day,date9.))||
 ' was: '||trim(left(put(TemperatureMax,comma5.0)));
run;

/* My algorithm assumes you have an obs for each day, so create a grid of all days */
/* Make sure the data is sorted, so you can use "by year" later */
proc sort data=&mydata out=&mydata; 
by year day;
run;
proc sql noprint; 
select min(year) into :min_year from &mydata; 
select max(year) into :max_year from &mydata; 
quit; run;
data grid_days;
 format day date9.;
 do day="01jan.&min_year"d to "31dec.&max_year"d by 1;
  weekday=put(day,weekday.);
  downame=trim(left(put(day,downame.)));
  monname=trim(left(put(day,monname.)));
  year=put(day,year.);
  output;
 end;
run;
/* Join your data with the grid-of-days */
proc sql noprint;
create table &mydata as select * 
from grid_days left join &mydata 
on grid_days.day eq &mydata..day;
quit; run;

/* 
Some day, once sgmap is more functional (and supports annotate), 
you'll use these map polygons for the calendar days, rather than 
sgplot polygon statement.
*/

/* Create polygons of the calendar days */
/* You're starting with minimum date at top/left, max at bottom/right */
data datemap; set &mydata;
by year;
if first.year then x_corner=1;
else if trim(left(downame)) eq "Sunday" then x_corner+1;
y_corner=((&min_year-year)*8.5)-weekday;
/* output 4 X/Y coordinates per each day, forming a rectangle that GMAP can draw */
x=x_corner; y=y_corner; output;
x=x+1; output;
y=y-1; output;
x=x-1; output;
run;

/* Create darker outline to annotate around each month */
/* (this is similar to annotating a state outline onto a county map) */
data anno_month_outline; set datemap;
/* combination of year & month makes a unique id for these outlines */
length yr_mon $ 15;
yr_mon=trim(left(put(day,year.)))||"_"||trim(left(put(day,month.)));
order+1;
run;
/* Sort it, so you can use "by" in next step */
proc sort data=anno_month_outline out=anno_month_outline;
by yr_mon order;
run;
/* Remove the internal borders, within each month */
proc gremove data=anno_month_outline out=anno_month_outline;
 by yr_mon; 
 id day;
run;
/* Now, convert the gmap data set into annotate move/draw commands */
data anno_month_outline (keep = layer function x1 y1 x1space y1space 
 fillcolor linecolor linethickness display);
 set anno_month_outline; 
 by yr_mon;
length function x1space y1space fillcolor linecolor display $50;
layer="front";
display="outline";
linecolor="black";
linethickness=1;
x1space="datavalue";
y1space="datavalue";
x1=x; y1=y;
if first.yr_mon then function='polygon';
else function='polycont';
run;


/* Annotate some text labels for year and day-of-week, along the left */
proc sql noprint;
create table anno_year_and_weekday as select unique year from &mydata;
quit; run;
data anno_year_and_weekday; set anno_year_and_weekday;
length function x1space y1space textweight anchor $50 label $100;
layer="front"; width=100; widthunit='percent'; 
function="text"; textcolor="gray33"; 
x1space="datavalue";
y1space="datavalue"; 
y1=((&min_year-year)*8.5)-1.50;
x1=-11;
anchor="left";
textsize=9;
textweight="bold"; 
label=trim(left(year)); output;
x1=-.1;
anchor="right";
textsize=7;
textweight="normal"; 
label="Sunday"; output;
y1=y1-1; label="Monday"; output;
y1=y1-1; label="Tuesday"; output;
y1=y1-1; label="Wednesday"; output;
y1=y1-1; label="Thursday"; output;
y1=y1-1; label="Friday"; output;
y1=y1-1; label="Saturday"; output;
run;

/* Annotate some labels for the 3-character month name, along the top */
data anno_month;
length function x1space y1space textweight anchor $50 label $100;
layer="front"; width=100; widthunit='percent'; 
function="text"; textcolor="gray33"; 
x1space="datavalue";
y1space="datavalue"; 
y1=1;
spacing=4.5;
anchor="center";
textsize=8;
textweight="bold"; 
x1=(spacing/3)*-1;
x1=x1+spacing; label="JAN"; output;
x1=x1+spacing; label="FEB"; output;
x1=x1+spacing; label="MAR"; output;
x1=x1+spacing; label="APR"; output;
x1=x1+spacing; label="MAY"; output;
x1=x1+spacing; label="JUN"; output;
x1=x1+spacing; label="JUL"; output;
x1=x1+spacing; label="AUG"; output;
x1=x1+spacing; label="SEP"; output;
x1=x1+spacing; label="OCT"; output;
x1=x1+spacing; label="NOV"; output;
x1=x1+spacing; label="DEC"; output;
run;

data anno_all; set anno_year_and_weekday anno_month anno_month_outline;
run;

/* sort the data, so the color legend will be sorted in the desired order */
data datemap; set datemap;
original_order=_n_;
run;
proc sort data=datemap out=datemap;
by colorbin original_order;
run;


/* --------------------------------------------------------------- */

/* To be able to write the ods template, for the calendar map */
ods path(prepend) work.templat(update);

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Weather") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=25000
 imagefmt=png imagename="&name"
 noborder; 

/* put this in a variable, so I don't have to re-type it so many times */
%let title2stuff= link='https://data.townofcary.org/pages/homepage/'
 h=10pt c=gray77 "Data source: https://data.townofcary.org/pages/homepage/ (August 2021)";

title1 h=14pt c=gray33 "Cary NC Daily Maximum Temperature";
title2 &title2stuff;

ods graphics / width=800px height=450px;
proc sgplot data=weather_data noborder noautolegend;
label TemperatureMax='Degrees Fahrenheit';
scatter y=TemperatureMax x=Date / group=year markerattrs=(symbol=circlefilled size=3px /*color=gray33*/);
yaxis display=(noline noticks) grid gridattrs=(pattern=dot color=gray88) values=(20 to 110 by 10);
xaxis display=(noline noticks nolabel) grid gridattrs=(pattern=dot color=gray88);
run;

title2 h=10pt 'a0'x;
footnote1 &title2stuff;

ods graphics / width=750px height=1200px;
proc sgplot data=datemap nowall noborder pad=(left=30pct) sganno=anno_all;
format colorbin binfmt.;
styleattrs datacolors=(&color0 &color1 &color2 &color3 &color4 &color5);
polygon x=x y=y id=day / group=colorbin fill 
 outline lineattrs=(color=grayaa) tip=(details)
 name='legend1';
yaxis display=(nolabel novalues noticks noline);
xaxis display=(nolabel novalues noticks noline);
keylegend 'legend1' / across=6 fillheight=8pt noborder;
run;


/*
proc contents data=weather_data; run;

proc print data=weather_data (obs=10);
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
