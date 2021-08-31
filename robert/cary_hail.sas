%let name=cary_hail;

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
day_of_year=mod(juldate(date),1000);
run;

proc sort data=weather_data out=weather_data;
by date;
run;
/*
*/

/* --------------------------------------------------------------- */

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Hail") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=25000
 imagefmt=png imagename="&name"
 ANTIALIASMAX=10000
 noborder; 

/* put this in a variable, so I don't have to re-type it so many times */
%let title2stuff= link='https://data.townofcary.org/pages/homepage/'
 h=10pt c=gray77 "Data source: https://data.townofcary.org/pages/homepage/ (August 2021)";

title1 h=14pt c=gray33 "Cary NC Daily Hail";
title2 &title2stuff;
ods graphics / width=1500px height=300px;
proc sgplot data=weather_data (where=(hail='Present')) noautolegend;
format date date9.;
format day_of_year monname3.;
scatter x=day_of_year y=year / group=hail markerattrs=(color=black) transparency=.3;
yaxis values=(2009 to 2020 by 1) display=(nolabel noticks) offsetmin=.05 offsetmax=.05;
xaxis values=('01jan1960'd to '01jan1961'd by month) display=(nolabel);
run;

/*
*/
proc print data=weather_data (where=(year=2009)); 
var date hail;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
