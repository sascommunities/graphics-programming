%let name=city_temperature_sas;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
length city $12;
input  month temp city $;
datalines;
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
;
run;
/*
proc print data=my_data (obs=10); run;
*/

/* Annotate some labels on the graph */
data anno_seasons;
length function x1space y1space anchor $50;
layer="front";
function="text"; textcolor="gray33"; textsize=9;
textweight='bold'; anchor='center';
width=50; widthunit='percent';
x1space='datavalue';
y1space='datavalue';
length label $100;
x1=2; y1=95; label='Winter'; output;
x1=5; y1=95; label='Spring'; output;
x1=8; y1=95; label='Summer'; output;
x1=11; y1=95; label='Fall'; output;
run;

/* Custom user-defined format, to make numbers print as text month name */
proc format;
value mmm_fmt
1='Jan'
2='Feb'
3='Mar'
4='Apr'
5='May'
6='Jun'
7='Jul'
8='Aug'
9='Sep'
10='Oct'
11='Nov'
12='Dec'
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Phoenix, Raleigh, Minneapolis temperature") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=800px height=500px border; 

ods escapechar='^';
title1 height=16pt c=gray33 "Average Monthly Temperatures (^{unicode '00b0'x}F)";

proc sgplot data=my_data noborder noautolegend sganno=anno_seasons;
format month mmm_fmt.;
format temp comma5.1;
label city='City' month='Month' temp='Temp.';
styleattrs datacontrastcolors=(red cxc906c7 cx1C86EE);
refline 3.4 6.4 9.4 / axis=x lineattrs=(color=gray22 pattern=34);
refline 32 / axis=y lineattrs=(color=gray55 pattern=34) 
 label="Freezing" labelloc=outside labelpos=min;
series x=month y=temp / group=city lineattrs=(thickness=5)
 curvelabel curvelabelpos=max curvelabelloc=outside 
 markers markerattrs=(symbol=circle size=7pt)
 tip=(city month temp);
yaxis display=(nolabel) values=(0 to 100 by 20) 
 valuesdisplay=(" " "20^{unicode '00b0'x}" "40^{unicode '00b0'x}" 
  "60^{unicode '00b0'x}" "80^{unicode '00b0'x}" "100^{unicode '00b0'x}")
 valueattrs=(size=11pt weight=bold color=gray33)
 offsetmin=0 offsetmax=0;
xaxis display=(nolabel) values=(1 to 12 by 1)
 valueattrs=(size=11pt weight=bold color=gray33)
 offsetmin=.04 offsetmax=.02;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
