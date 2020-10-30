%let name=covid19_us_paneled_deaths;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to:
https://twitter.com/disclosetv/status/1279181133394120716/photo/1
(but using deaths data)
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

%getdata(time_series_covid19_deaths_US.csv);
/*
*/

/*
filename confcsv "\\sashq\root\u\realliso\public_html\ods10\time_series_covid19_deaths_US.csv";
*/
filename confcsv "time_series_covid19_deaths_US.csv";
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

proc transpose data=reported_data out=reported_data (rename=(_name_=datestring col1=deaths_cumulative));
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
select unique statename, date, sum(deaths_cumulative) as deaths_cumulative
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
lag=lag(deaths_cumulative);
run;
data reported_data; set reported_data;
by statename;
if first.statename then deaths_this_day=deaths_cumulative;
else deaths_this_day=deaths_cumulative-lag;
run;

/* Calculate the per-capita values */
data reported_data; set reported_data;
deaths_this_day_per_million=deaths_this_day/population_mil;
run;

/* Calculate the 7-day moving average */
proc expand data=reported_data out=reported_data;
by statename;
convert deaths_this_day_per_million=avg / method=none transformout=(cmovave 7 trim 3);
run;

/* get rid of the 3 obsns on each end, that don't have a centered moving average*/
/*
data reported_data; set reported_data (where=(avg^=.));
run;
*/

/* 
Calculate the sum of the deaths, so you can calculate the
total deaths per capita for each state, so you can sort by that.
*/
proc sql noprint;
create table reported_data as
select reported_data.*, sum(deaths_this_day) as sum_deaths
from reported_data
group by statename;
quit; run;
data reported_data; set reported_data;
sum_deaths_per_million=sum_deaths/population_mil;
run;
proc sort data=reported_data out=reported_data;
by descending sum_deaths_per_million statename date;
run;
data reported_data; set reported_data;
by statename notsorted;
if first.statename then rank+1;
run;

proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from reported_data;
quit; run;


/* There's no title statement option to 'unbold' the title text, therefore do it in an ods style */
proc template;
define style styles.nobold;
parent=styles.htmlblue; 
class GraphFonts / 'GraphTitleFont' = ("<sans-serif>, <MTsans-serif>",11pt);
end;
run;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Covid-19 deaths trend, by state") 
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

title1 h=13pt c=gray33 "US States Daily Reported COVID-19 Deaths per Million Persons";
title2 h=11pt c=gray77 "Red line is 7-day moving average. States sorted by total deaths per million (dpm).";
title3 h=11pt c=gray77 "Data courtesy of the Johns Hopkins University CSSE (01MAR2020 to &maxdate)";

data reported_data; set reported_data (where=(date>='01mar2020'd));
/* this is a bit 'deceptive', but the way Johns Hopkins reports data & corrections, there 
can be some negative numbers. I include them in the moving average line, but I don't want
to show needles going below zero. So, I delete those obsns here, to make the graph look cleaner.  */
if deaths_this_day_per_million<0 then deaths_this_day_per_million=.;
length statename_plus $100;
statename_plus=trim(left(statename))||' ('||trim(left(put(sum_deaths_per_million,comma12.0)))||' dpm)';
run;

proc sgpanel data=reported_data noautolegend;
format date monname1.;
panelby statename / columns=5 rows=5 sort=data novarname noheader spacing=10 border uniscale=all;
needle y=deaths_this_day_per_million x=date / displaybaseline=off
 lineattrs=(color=cx82CFFD) tip=none;
series y=avg x=date / group=statename  
 lineattrs=(color=red thickness=2 pattern=solid) tip=none;
/*
inset statename / position=top nolabel textattrs=(color=gray33 size=10pt);
*/
inset statename_plus / position=top nolabel textattrs=(color=gray33 size=10pt);
rowaxis display=(nolabel noline noticks)
 values=(0 to 60 by 20)
/*
 valuesdisplay=(' ' '20' '40' '60')
*/
 valueattrs=(color=gray33) grid 
 offsetmin=0 offsetmax=0;
colaxis display=(nolabel noline noticks /*novalues*/) 
 values=('01mar2020'd to '01nov2020'd by month) 
 valueattrs=(color=gray33 size=7pt) grid 
 offsetmin=0 offsetmax=0;
run;

proc sql noprint;
create table reported_summary as
select unique statename, sum_deaths_per_million
from reported_data
order by sum_deaths_per_million descending;
quit; run;

title2 c=gray33 "Total deaths per capita in each state (as of &maxdate)";
proc print data=reported_summary label
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
label statename='State';
label sum_deaths_per_million='Deaths per Million';
format sum_deaths_per_million comma10.0;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
