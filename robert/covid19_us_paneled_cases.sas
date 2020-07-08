%let name=covid19_us_paneled_cases;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to:
https://twitter.com/disclosetv/status/1279181133394120716/photo/1
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

filename confcsv "\\sashq\root\u\realliso\public_html\ods10\time_series_covid19_confirmed_US.csv";
/*
filename confcsv "time_series_covid19_confirmed_US.csv";
*/
proc import datafile=confcsv
 out=reported_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

/*
There are some weird Utah obsns where the fips is blank and the fips field in the UID aren't Utah.
So I get rid of obsns with blank fips.
*/
data reported_data (
  drop = uid iso2 iso3 code3 admin2 country_region lat long_ combined_key 
  rename=(province_state=statename)
  ); 
 set reported_data (where=(
 iso2='US' and 
 fips^=. and 
 province_state not in ('Grand Princess' 'Diamond Princess' 'District of Columbia')
 ));
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
/*
data reported_data; set reported_data (where=(avg^=.));
run;
*/

/* Get the latext/max date in the data, and save it to a macro variable */
proc sql noprint;
select max(date) format=date9. into :maxdate1 separated by ' ' from reported_data where avg^=.;
select max(date) format=date9. into :maxdate2 separated by ' ' from reported_data;
quit; run;

/* Get the latest value for each state */
proc sql noprint;
create table current_highest as
select unique statename, date, avg as latest_avg
from reported_data
where date="&maxdate1"d
order by latest_avg desc;
quit; run;

/* assign numeric rank to each state, based on the (descending) sorted data */
/* create extra variables to control color of lines for the max 7 states */
data current_highest; set current_highest;
rank=_n_;
run;

/* merge the rank back the main dataset, and order by the rank (to assign colors in desired order) */
proc sql noprint;
create table reported_data as
select unique reported_data.*, current_highest.rank
from reported_data left join current_highest
on reported_data.statename=current_highest.statename
order by rank, statename, date;
quit; run;


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
textsize=9; textweight='normal';
width=100; widthunit='percent';
url="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/";
y1=6.5; label="Raw data downloaded from GitHub (https://raw.githubusercontent.com/CSSEGISandData/COVID-19/)";
output;
url="";
y1=y1-3; label="COVID-19 case data courtesy of the Johns Hopkins University Center for Systems Science and Engineering (CSSE)";
output;
run;

/* There's no title statement option to 'unbold' the title text, therefore do it in an ods style */
proc template;
define style styles.nobold;
parent=styles.htmlblue;
class GraphFonts / 'GraphTitleFont' = ("<sans-serif>, <MTsans-serif>",11pt);
end;
run;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Covid-19 cases trend, by state") 
 style=nobold;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 antialiasmax=50000
 maxlegendarea=100
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 width=950px height=900px noborder;

%let axismax=600;

title1 h=13pt c=gray33 "US States Daily Reported COVID-19 Cases per Million Persons";
title2 h=11pt c=gray77 "Blue line is 7-day moving average. States sorted by most recent moving average value.";
title3 h=11pt c=gray77 "Data courtesy of the Johns Hopkins University CSSE (01MAR2020 to &maxdate2)";

data reported_data; set reported_data (where=(date>='01mar2020'd));
/* this is a bit 'deceptive', but the way Johns Hopkins reports data & corrections, there 
can be some negative numbers. I include them in the moving average line, but I don't want
to show needles going below zero. So, I delete those obsns here, to make the graph look cleaner.  */
if cases_this_day_per_million<0 then cases_this_day_per_million=.;
run;

proc sgpanel data=reported_data noautolegend;
format date monname3.;
panelby statename / columns=5 rows=5 sort=data novarname noheader spacing=10 border uniscale=all;
needle y=cases_this_day_per_million x=date / displaybaseline=off
 lineattrs=(color=pink) tip=none;
series y=avg x=date / group=statename  
 lineattrs=(color=blue thickness=2 pattern=solid) tip=none;
inset statename / position=top nolabel textattrs=(color=gray33 size=10pt);
rowaxis display=(nolabel noline noticks)
 values=(0 to 800 by 200)
 valuesdisplay=(' ' '200' '400' '600' '800')
 valueattrs=(color=gray33) grid 
 offsetmin=0 offsetmax=0;
colaxis display=(nolabel noline noticks novalues) 
 values=('01mar2020'd to '01aug2020'd by month) 
 valueattrs=(color=gray33) grid 
 offsetmin=0 offsetmax=0;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
