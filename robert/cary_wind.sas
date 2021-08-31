%let name=cary_wind;

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
 (title="Cary NC - Wind") 
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

title1 h=14pt c=gray33 "Cary NC Daily Average Wind Speed";
title2 &title2stuff;
ods graphics / width=1500px height=600px;
proc sgplot data=weather_data;
format date date9.;
format day_of_year monname3.;
heatmapparm x=day_of_year y=year colorresponse=AvgWindSpeed /
 colormodel=(cxf7fbff cx08306b) tip=(date AvgWindSpeed);
yaxis values=(2009 to 2020 by 1) display=(nolabel noticks) offsetmin=.05 offsetmax=.05;
xaxis values=('01jan1960'd to '01jan1961'd by month) display=(nolabel);
run;

title1 h=14pt c=gray33 "Cary NC Daily Wind Direction (years 2009 to 2020)";
title2 &title2stuff;
ods graphics / width=800px height=350px;
proc sgplot data=weather_data;
format date date9.;
format day_of_year monname3.;
scatter y=Fastest2MinWindDir x=day_of_year / markerattrs=(color=cx08306b) 
 transparency=.6 tip=(date Fastest2MinWindDir);
yaxis label="Direction" values=(0 to 360 by 90) reverse
 valuesdisplay=('0 north' '90 east' '180 south' '270 west' '360 north');
xaxis display=(nolabel)
 values=('01jan1960'd to '01jan1961'd by month);
run;

/*
proc print data=weather_data (obs=10); 
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
