%let name=covid19_us_states;

/*
Note to self - use 9.4m6a to run the new sgmap features...
ssh -x unixbb.fyi.sas.com (old unix password)
export DISPLAY=l10h879.na.sas.com:0
sdsenv dev/mva-v940m6a -box laxno
cd /u/realliso/public_html/ods10
sdssas covid19_us_states.sas
*/

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to:
https://www.linkedin.com/posts/troy-hughes-27a998a8_covid19-pandemic-arizona-activity-6677722829468897280-OHmJ/
*/

%macro getdata(csvname);
%let csvurl=https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series;
filename csvfile url "&csvurl./&csvname";
data _null_;
 n=-1;
 infile csvfile recfm=s nbyte=n length=len _infile_=tmp;
 input;
 file "&csvname" recfm=n;
 put tmp $varying32767. len;
run;
%mend getdata;

/*
%getdata(time_series_covid19_confirmed_US.csv);
*/

filename confcsv "time_series_covid19_confirmed_US.csv";
proc import datafile=confcsv
 out=reported_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

/*
There are some weird Utah obsns where the fips is blank and the fips field in the UID aren't Utah.
So I get rid of obsns with blank fips.
*/
data reported_data (drop = uid iso2 iso3 code3 admin2 country_region lat long_ combined_key rename=(province_state=statename)); 
 set reported_data (where=(iso2='US' and fips^=. and province_state^='Grand Princess'));
run;

proc transpose data=reported_data out=reported_data (rename=(_name_=datestring col1=confirmed_cumulative));
by fips statename notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data reported_data (drop = month day year datestring);
 set reported_data;
statename=trim(left(statename));
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
format date date9.;
date=mdy(month,day,year);
run;

proc sql noprint;
/* sum() the values for each state */
create table reported_data as
select unique statename, date, sum(confirmed_cumulative) as confirmed_cumulative
from reported_data
group by statename, date
order by statename, date;
/* merge in population, in millions, for each state */
create table reported_data as 
select unique reported_data.*, (us_data.population_2010/1000000) as population_mil
from reported_data left join sashelp.us_data
on reported_data.statename=us_data.statename;
quit; run;

/* Calculate the daily reported cases, from the cumulative values */
data reported_data; set reported_data;
lag=lag(confirmed_cumulative);
run;
data reported_data; set reported_data;
by statename;
if first.statename then cases_this_day=confirmed_cumulative;
else cases_this_day=confirmed_cumulative-lag;
run;

/* Calculate the per-capita values */
data reported_data; set reported_data;
cases_this_day_per_million=cases_this_day/population_mil;
run;

/* Calculate the 7-day moving average */
proc expand data=reported_data out=reported_data;
by statename;
convert cases_this_day_per_million=avg / method=none transformout=(cmovave 7 trim 3);
run;

/* get rid of the 3 obsns on each end, that don't have a centered moving average*/
data reported_data; set reported_data (where=(avg^=.));
run;

/* Get the latext/max date in the data, and save it to a macro variable */
proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from reported_data;
quit; run;

/* Get the latest value for each state */
proc sql noprint;
create table current_highest as
select unique statename, date, avg as latest_avg
from reported_data
where date="&maxdate"d
order by latest_avg desc;
quit; run;

/* assign numeric rank to each state, based on the (descending) sorted data */
/* create extra variables to control color of lines for the max 7 states */
data current_highest; set current_highest;
rank=_n_;
length statename_color $100;
if rank<=7 then do;
 statename_color=trim(left(statename))||' ('||trim(left(put(latest_avg,comma8.1)))||')';
 end;
else do;
 rank=.;
 statename_color='';
 end;
run;

/* merge the rank & statename_color back the main dataset, and order by the rank (to assign colors in desired order) */
proc sql noprint;
create table reported_data as
select unique reported_data.*, current_highest.rank, current_highest.statename_color
from reported_data left join current_highest
on reported_data.statename=current_highest.statename
order by rank, statename, date;
quit; run;

/* insert a missing-value between each state, to work with sgplot's break option, for the gray lines */
data reported_data; set reported_data;
by statename notsorted;
output;
if last.statename then do;
 date=.;
 avg=.;
 output;
 end;
run;

/*
Since ods graphics footnote does not support url links yet,
annotate the footnote (annotated text supports url links).
This also allows me to control the position/alighment of
the legend better than the footnote statement.
*/
data anno_footnote;
length label $300 anchor x1space y1space function $50 textcolor $12;
layer='front';
function='text';
x1=10; 
x1space='wallpercent'; y1space='graphpercent';
anchor='left';
/* let the 'raven' ods style control the color */
/* textcolor="white"; */
textsize=9; textweight='normal';
width=100; widthunit='percent';
url="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/";
y1=6.5; label="Raw data downloaded from GitHub (https://raw.githubusercontent.com/CSSEGISandData/COVID-19/)";
output;
url="";
y1=y1-3; label="COVID-19 case data courtesy of the Johns Hopkins University Center for Systems Science and Engineering (CSSE)";
output;
run;

/* First, create a map in a separate file (you'll annotate the png on the graph later) */
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name._map.htm" style=raven;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 antialiasmax=50000
 maxlegendarea=100
 imagemap tipmax=25000
 imagefmt=png imagename="&name._map"
 width=240px height=160px noborder;
/*
 width=210px height=140px noborder;
 width=240px height=160px noborder;
 width=270px height=180px noborder;
 width=300px height=200px noborder;
 width=800px height=600px noborder;
*/

data my_map; set mapsgfk.us;
statename=fipnamel(state);
run;

/* Use a non-missing value for the 'other' state rank, so it will be assigned a choro color */
data my_map_data; set current_highest;
if rank=. then rank=99;
run;

proc sgmap mapdata=my_map maprespdata=my_map_data noautolegend /*noopaque*/;
/* you *must* run this with SAS 9.4m6a or higher, for the styleattrs colors to work this way! */
styleattrs datacolors=(red orange yellow lime dodgerblue purple violet gray88);
choromap rank / mapid=statename discrete lineattrs=(thickness=1 color=gray33)
/*
Annotated images don't support html mouse-over text for the states (like the 
old SAS/Graph Proc Greplay did), so don't bother using the tip=.
 tip=(statename_color)
*/
 ;
run;

/*
proc print data=my_map_data; run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;

/* Annotate the image into the graph */
data anno_map;
function='image'; 
image='covid19_us_states_map.png';
/*layer='back'; ... bummer - this puts it behind the black background */
drawspace='datapercent';
anchor='bottomleft';
x1=52;
y1=60;
imagescale='fit';
heightunit='pixel';
widthunit='pixel';
width=300*.7;  
height=200*.7; 
/*width=28;*/ /* percent of the available area */
run;

data anno_all; set anno_footnote anno_map;
run;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Covid-19 trend, by state") 
 style=raven;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 antialiasmax=50000
 maxlegendarea=100
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 width=950px height=600px noborder;

title1 h=12pt "United States Daily Reported COVID-19 Cases per Million Persons, by State";
title2 h=12pt ls=0.7 "Current 7 Highest States (based on &maxdate data snapshot) Plotted in Color";
title3 h=4pt " ";

%let axismax=600;

/* first, plot all the states, as gray lines */
proc sgplot data=reported_data noautolegend pad=(left=3pct right=5pct bottom=12pct) sganno=anno_all;;
label avg='Daily Cases per Million Persons (7-day moving average)';
/* plot a gray line for each state */
series y=avg x=date / break lineattrs=(color=gray77 thickness=1) tip=none;
/* overlay a colored line for the top 7 states */
styleattrs datacontrastcolors=(gray red orange yellow lime dodgerblue purple violet);
series y=avg x=date / group=statename_color nomissinggroup name='max' 
 lineattrs=(thickness=2 pattern=solid) tip=none y2axis;
yaxis  labelattrs=(size=11.5pt weight=normal) offsetmin=0 offsetmax=.05 values=(0 to &axismax by 100);
y2axis offsetmin=0 offsetmax=.05 values=(0 to &axismax by 100) display=(nolabel);
xaxis display=(nolabel) 
 values=("01mar2020"d to "01jul2020"d by month)
 valueattrs=(size=9pt)
 offsetmin=0 offsetmax=.05;
keylegend 'max' / title='' linelength=15px 
 position=topleft location=inside outerpad=(left=10pt top=11pt)
 valueattrs=(size=9pt weight=normal) 
 noopaque noborder across=1;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
