%let name=covid_deaths_x_cases;

/*
I'm using recycled code here, therefore this is not as efficient as it could be ...
*/

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
%let path=\\sashq\root\u\realliso\public_html\ods10\;
%let path=/u/realliso/public_html/ods10/;
*/
%let path=../ods10/;

%macro getdata(csvname);
%let csvurl=https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series;
filename csvfile url "&csvurl./&csvname";
data _null_;
 n=-1;
 infile csvfile recfm=s nbyte=n length=len _infile_=tmp;
 input;
 file "&path&csvname" recfm=n;
 put tmp $varying32767. len;
run;
%mend getdata;

/* these will usually be downloaded by previous jobs, so no need to download them again */
/*
%getdata(time_series_covid19_confirmed_US.csv);
%getdata(time_series_covid19_deaths_US.csv);
*/


/* ---------------------- Cases ----------------------------- */

/*
filename confcsv "\\sashq\root\u\realliso\public_html\ods10\time_series_covid19_confirmed_US.csv";
*/
filename confcsv "&path.time_series_covid19_confirmed_US.csv";
proc import datafile=confcsv
 out=reported_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

data reported_data (
  drop = uid iso2 iso3 code3 admin2 country_region lat long_ combined_key 
  rename=(province_state=statename)
  ); 
 set reported_data (where=(
 iso2='US' and 
 province_state not in ('Grand Princess' 'Diamond Princess')
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

/* Use my pop data, which is more current than sashelp.us_data */
libname robsdata "../democd103";
data us_data; set robsdata.us_data;
population=popestimate2019;
run;

proc sql noprint;
/* sum() the county values for each state */
create table reported_data as
select unique statename, date, sum(confirmed_cumulative) as confirmed_cumulative
from reported_data
group by statename, date
order by statename, date;
/* merge in population, in millions, for each state */
create table reported_data as 
select unique reported_data.*, (us_data.population/1000000) as population_mil
from reported_data left join us_data
on reported_data.statename=us_data.statename;
quit; run;

/* Calculate the per-capita values */
data reported_data; set reported_data;
cases_this_day_per_million=confirmed_cumulative/population_mil;
format percent_infected percent7.2;
percent_infected=(cases_this_day_per_million/1000000);
run;


/* ---------------------- Deaths ----------------------------- */


/*
filename deadcsv "\\sashq\root\u\realliso\public_html\ods10\time_series_covid19_deaths_US.csv";
*/
filename deadcsv "&path.time_series_covid19_deaths_US.csv";
proc import datafile=deadcsv
 out=deaths_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

data deaths_data (
  drop = uid iso2 iso3 code3 admin2 country_region lat long_ combined_key 
  rename=(province_state=statename)
  ); 
 set deaths_data (where=(
 iso2='US' and 
 province_state not in ('Grand Princess' 'Diamond Princess')
 ));
run;

proc transpose data=deaths_data out=deaths_data (rename=(_name_=datestring col1=deaths_cumulative));
by fips statename notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data deaths_data (drop = month day year datestring);
 set deaths_data;
statename=trim(left(statename));
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
format date date9.;
date=mdy(month,day,year);
run;

proc sql noprint;
/* sum() the values for each state */
create table deaths_data as
select unique statename, date, sum(deaths_cumulative) as deaths_cumulative
from deaths_data
group by statename, date
order by statename, date;
/* merge in population, in millions, for each state */
create table deaths_data as 
select unique deaths_data.*, (us_data.population/1000000) as population_mil
from deaths_data left join us_data
on deaths_data.statename=us_data.statename;
quit; run;

/* Calculate the per-capita values */
data deaths_data; set deaths_data;
deaths_this_day_per_million=deaths_cumulative/population_mil;
run;


/* Merge the 2 datasets together.  */
proc sql noprint;
create table my_data as 
 select unique reported_data.*, deaths_data.deaths_this_day_per_million
 from reported_data left join deaths_data
 on reported_data.statename=deaths_data.statename and reported_data.date=deaths_data.date;
quit; run;

/* find the latest/max date */
proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from my_data;
quit; run;

data my_data; set my_data;
label statename='State';
label deaths_this_day_per_million='COVID-19 deaths per million population';
label percent_infected='Percent of state population reported infected';
format deaths_this_day_per_million comma8.0;
format percent_infected percentn7.2;
/* create a special obsn to plot a marker at the latest date */
if date="&maxdate"d then do;
  label latest_deaths='COVID-19 deaths per million population';
  label latest_infected='Percent of state population reported infected';
  format latest_deaths comma8.0;
  format latest_infected percentn7.2;
 latest_infected=percent_infected;
 latest_deaths=deaths_this_day_per_million;
 end;
run;


data anno_diagonal;
length label $300 x1space y1space anchor layer $50;
layer="back"; /* be sure to use 'nowall' with this */
x1space='wallpercent'; y1space='wallpercent';
x2space='wallpercent'; y2space='wallpercent';
function='line'; linethickness=1;
linecolor='gray77';
x1=0; y1=0; x2=100; y2=100;
output;
run;



/* ----------------------------------------------------------- */

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Covid-19 cases & deaths") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 antialiasmax=50000
 maxlegendarea=100
 imagemap tipmax=50000 
 LABELMAX=50000
 imagefmt=png imagename="&name"
 width=700px height=630px noborder;

title1 h=14pt c=gray33 "COVID-19 Deaths vs Infections, by state";
title2 h=11pt c=gray33 "Based on Johns Hopkins data, through &maxdate";

/8
proc sgplot data=my_data noautolegend nowall;
scatter x=latest_infected y=latest_deaths / markerattrs=(color=red);
yaxis offsetmin=0 offsetmax=.05 values=(0 to 3500 by 500);
xaxis offsetmin=0 offsetmax=.08 values=(0 to .2 by .05);
run;
*/

/*
proc sgplot data=my_data noautolegend nowall;
scatter x=latest_infected y=latest_deaths / markerattrs=(color=red)
 datalabel=statename datalabelattrs=(color=dodgerblue);
yaxis offsetmin=0 offsetmax=.05 values=(0 to 3500 by 500);
xaxis offsetmin=0 offsetmax=.08 values=(0 to .2 by .05);
run;
*/

/*
proc sgplot data=my_data noautolegend nowall sganno=anno_diagonal;
scatter x=latest_infected y=latest_deaths / markerattrs=(color=red)
 datalabel=statename datalabelattrs=(color=dodgerblue);
yaxis offsetmin=0 offsetmax=.05 values=(0 to 3500 by 500);
xaxis offsetmin=0 offsetmax=.08 values=(0 to .2 by .05);
run;
*/

proc sgplot data=my_data noautolegend nowall sganno=anno_diagonal;
series x=percent_infected y=deaths_this_day_per_million / group=statename
 lineattrs=(pattern=solid thickness=1 color=pink)
 tip=none;
scatter x=latest_infected y=latest_deaths / 
 tip=(statename latest_deaths latest_infected)
 markerattrs=(color=red)
 datalabel=statename datalabelattrs=(color=dodgerblue);
yaxis offsetmin=0 offsetmax=.05 values=(0 to 3500 by 500);
xaxis offsetmin=0 offsetmax=.08 values=(0 to .2 by .05);
run;

proc print data=my_data (where=(latest_infected^=.)) label noobs; 
var statename date deaths_this_day_per_million percent_infected;
run;
/*
*/

/*
proc print data=reported_data (obs=10); run;
proc print data=deaths_data (obs=10); run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
