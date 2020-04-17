%let name=us_flu_deaths;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from:
https://www.cdc.gov/flu/weekly/index.htm
Pneumonia and Influenza (P&I) Mortality Surveillance graph
View Chart Data

Different file name each week:
https://www.cdc.gov/flu/weekly/weeklyarchives2018-2019/data/NCHSData09.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2018-2019/data/NCHSData27.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2018-2019/data/NCHSData38.csv
** note that the years switch mid-year! **
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData43.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData45.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData46.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData48.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData51.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData52.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData01.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData02.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData04.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData07.csv
https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData14.csv
*/

%let latest=https://www.cdc.gov/flu/weekly/weeklyarchives2019-2020/data/NCHSData14.csv;

filename csv_file url "&latest";
/*
filename csv_file "NCHSData02.csv";
*/

data my_data;
infile csv_file lrecl=200 dlm=',' pad firstobs=2;
label flu_deaths='Deaths';
format flu_deaths comma8.0;
input year week pct_deaths_due_to_pneu_and_flu expected 
 threshold all_deaths pneumonia_deaths flu_deaths;
if year>=2010 then output;
run;

/* this extra variable is to plot the text label on the last value */
data my_data; set my_data end=last;
output;
if last then do;
 week=week+1;
 latest=flu_deaths;
 latest_text='latest';
 flu_deaths=.;
 output;
 end;
run;

data last; set my_data end=last;
if last then output;
run;
proc sql noprint;
select year into :maxyear separated by ' ' from last;
select week into :maxweek separated by ' ' from last;
quit; run;

/* 
Since ods graphics title2 does not support url links yet, 
annotate the title2 (annotated text supports url links).
*/
data anno_title2;
length label $100 anchor x1space y1space function $50 textcolor $12 url $300;
function='text';
x1space='graphpercent'; y1space='graphpercent';
anchor='center';
textcolor="gray33"; textsize=11; textweight='normal'; 
width=100; widthunit='percent'; 
x1=42; y1=90;
url="https://www.cdc.gov/flu/weekly/index.htm";
label="Data source: cdc.gov ";
output;
x1=57; y1=90;
url="&latest";
label="(through &maxyear, week &maxweek)"; 
output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US Flu Deaths") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=1000px height=500px noborder; 

title1 h=14pt c=gray33 "Influenza (Flu) Deaths Per Week in the US";
/*
title2 h=12pt c=gray99 ls=0.5 "Data source: cdc.gov (through &maxyear, week &maxweek)";
*/
title2 h=1pt ' ';

proc sgpanel data=my_data noautolegend sganno=anno_title2;
panelby year / onepanel columns=8 novarname 
 colheaderpos=bottom layout=columnlattice 
 headerattrs=(size=12pt color=gray33) noborder;
band x=week lower=0 upper=flu_deaths / fill fillattrs=(color=red) 
 tip=(flu_deaths year week);
scatter x=week y=latest / markerattrs=(color=blue symbol=triangleleftfilled)
 datalabel=latest_text datalabelpos=right tip=(flu_deaths year week)
 datalabelattrs=(color=blue size=10pt);
rowaxis labelpos=top values=(0 to 1750 by 250)
 valueattrs=(size=11pt color=gray33)
 labelattrs=(size=11pt color=gray33)
 offsetmax=0 offsetmin=0;
colaxis values=(1 to 52 by 1) display=(nolabel noticks novalues) 
 offsetmax=0 offsetmin=0;
refline 52 / axis=x lineattrs=(color=graycc thickness=1px);
refline 0 to 1750 by 250 / axis=y lineattrs=(color=graycc thickness=1px);
run;

proc sgplot data=my_data sganno=anno_title2;
spline x=week y=flu_deaths / group=year curvelabel curvelabelpos=start;
yaxis labelpos=top values=(0 to 1750 by 250)
 offsetmin=0 offsetmax=0;
run;

/*
proc print data=my_data; run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
