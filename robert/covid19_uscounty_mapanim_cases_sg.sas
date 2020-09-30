%let name=covid19_uscounty_mapanim_cases_sg;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
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
*/

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

data reported_data (drop = month day year datestring);
 set reported_data;
/* The date/timestamp is in a string - parse it apart, and create a real date variable */
statename=trim(left(statename));
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
format date date9.;
date=mdy(month,day,year);
length county_id $8;
county_id='US-'||trim(left(put(fips,z5.)));
/* Parse the fips into numeric state & county (to use with county map) */
state=.; state=substr(put(fips,z5.),1,2);
county=.; county=substr(put(fips,z5.),3,3);
run;

/* merge in the population from John's data */
/*
libname johndata '/dept/ctn/JohnD/TestDataLAX/coronavirus/data/misc';
*/
libname johndata '\\sashq\root\dept\ctn\JohnD\TestDataLAX\coronavirus\data\misc';
proc sql noprint;
create table reported_data as 
select unique reported_data.*, (us_county_population.population/100000) as population_100k
from reported_data left join johndata.us_county_population
on reported_data.fips=us_county_population.countyfips;
quit; run;

proc sort data=reported_data out=reported_data;
by fips date;
run;

/* Calculate the daily reported cases, from the cumulative values */
data reported_data; set reported_data;
lag=lag(confirmed_cumulative);
run;
data reported_data; set reported_data;
by fips;
if first.fips then cases_this_day=confirmed_cumulative;
else cases_this_day=confirmed_cumulative-lag;
run;

/* Calculate the per-capita values */
data reported_data; set reported_data;
cases_this_day_per_100k=cases_this_day/population_100k;
run;

/* Calculate the 7-day moving average */
proc expand data=reported_data out=reported_data;
by fips;
convert cases_this_day_per_100k=avg / method=none transformout=(cmovave 7 trim 3);
run;

/* get rid of the 3 obsns on each end, that don't have a centered moving average*/
/* because I'm only animating the dates with moving avg values */
data reported_data; set reported_data (where=(avg^=.));
run;

/* Let's just do weekly snapshots */
proc sql noprint;
select max(date) format=downame. into :maxdow separated by ' ' from reported_data;
quit; run;
/*
%let maxdow=Wednesday;
*/
%put maxdow = &maxdow;
data reported_data; set reported_data (where=(
 trim(left(put(date,downame.)))=trim(left("&maxdow"))
 /* to just get 1 per month */
 /* and input(put(date,day.),8.)<=7 */
 ));
run;

/* Get the latest/max date in the data, and save it to a macro variable */
proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from reported_data where avg^=.;
select max(date) format=date9. into :maxdate2 separated by ' ' from reported_data;
quit; run;

/* 
Since controlling colors in the map via attribute maps 
isn't supported until after 9.4m6 (and most users don't
have a version new enough yet, here's the way to control
the colors 'old school' using an ods style...
*/
ods path(prepend) work.templat(update);
proc template;
define style styles.my_style;
 parent=styles.htmlblue;
 class graphcolors / 
  'gdata1'=cx1a9850
  'gdata2'=cx66bd63
  'gdata3'=cxa6d96a
  'gdata4'=cxd9ef8b
  'gdata5'=cxfee08b
  'gdata6'=cxfdae61
  'gdata7'=cxf46d43
  'gdata8'=cxd73027
  ;
 end;
run;


/* this is the 'secret sauce' that creates the gif animation */
options dev=sasprtc printerpath=gif center animduration=1.20 animloop=0 animoverlay=no animate=start;
ods printer file="&name..gif" style=my_style;
ods graphics / width=800px height=600px imagefmt=gif;
options nodate nonumber nobyline;
ods listing select none;

/* set the break points */
%let b1=5;
%let b2=10;
%let b3=15;
%let b4=20;
%let b5=25;
%let b6=30;
%let b7=35;

proc format;
value rng_fmt
1="<&b1"
2="&b1-&b2"
3="&b2-&b3"
4="&b3-&b4"
5="&b4-&b5"
6="&b5-&b6"
7="&b6-&b7"
8=">=&b7"
;
run;

data reported_data; set reported_data;
label range='New cases per 100,000';
format range rng_fmt.;
range=.;
if avg<&b1 then range=1;
else if avg<&b2 then range=2;
else if avg<&b3 then range=3;
else if avg<&b4 then range=4;
else if avg<&b5 then range=5;
else if avg<&b6 then range=6;
else if avg<&b7 then range=7;
else if avg>=&b7 then range=8;
length my_html $300;
my_html='title='||quote(trim(left(statename)));
length my_id $10;
my_id=trim(left(put(state,z2.)))||'_'||trim(left(put(county,z3.)));
run;

proc sort data=reported_data out=reported_data;
by date range;
run;

legend1 label=(position=top h=2.0 j=c 'New cases' j=c 'per 100,000')
 value=(h=2.0 justify=center)
 position=(bottom right) mode=share across=1 order=descending
 shape=bar(.15in,.15in) offset=(0,8);

data my_map; set maps.uscounty;
/* Shannon county, SD */
if state=46 and county=113 then county=102;
length my_id $10;
my_id=trim(left(put(state,z2.)))||'_'||trim(left(put(county,z3.)));
run;

proc gremove data=my_map out=state_outline;
by state notsorted; 
id county;
run;

proc gremove data=my_map out=anno_outline;
by state; 
id county;
run;
data anno_outline; set anno_outline; 
by state segment notsorted;
output;
if last.segment then do;
 x=.; y=.; output;
 end;
run;

/* 
Must have at least 9.4m6a to use attribute map with proc sgmap.
Remember - the 'value' in the attribute map must be the *formatted* value that shows up in the legend.
*/
/*
data my_attrmap;
length value fillcolor $20;
input num_value fillcolor;
value=put(num_value,rng_fmt.);
id='rangecolors';
datalines;
1 cx1a9850
2 cx66bd63
3 cxa6d96a
4 cxd9ef8b
5 cxfee08b
6 cxfdae61
7 cxf46d43
8 cxd73027
;
run;
*/


%macro do_frame(mydate);

data tempdata; set reported_data (where=(date="&mydate"d));
run;

proc sql noprint;
select unique date format=monname20. into :month2 separated by ' ' from tempdata;
select unique date format=day. into :day2 separated by ' ' from tempdata;
select unique date format=year. into :year2 separated by ' ' from tempdata;
select unique date format=downame. into :dow2 separated by ' ' from tempdata;
quit; run;

/* generate some 'fake' data to guarantee every map frame's legend has all color chips */
data guarantee_legend;
my_id='00_000';
range=1; output;
range=2; output;
range=3; output;
range=4; output;
range=5; output;
range=6; output;
range=7; output;
range=8; output;
run;
data tempdata; set tempdata guarantee_legend;
run;

title1 ls=1.0 h=16pt "New Daily Reported COVID-19 Cases per 100,000 Persons";
title2 ls=2.0 c=dodgerblue h=20pt "&dow2 &month2, &day2  &year2";
footnote1 ls=0.8 "Data source: Johns Hopkins University CSSE (7-day centered moving average applied to data)";

proc sgmap 
 mapdata=my_map 
 maprespdata=tempdata 
 /*dattrmap=my_attrmap*/
 plotdata=anno_outline;
choromap range / discrete mapid=my_id lineattrs=(thickness=1 color=gray99) 
 /*attrid=rangecolors*/  /* you need a version higher than 9.4m6 to use attribute maps */
 ;
series x=x y=y / lineattrs=(color=gray55); 
run;

%mend do_frame;

proc sql noprint;
create table loopdata as
select unique put(date,date9.) as datechar
from reported_data
where date>="10mar2020"d
order by date;
quit; run;

data _null_; set loopdata;
call execute('%do_frame(%str('|| datechar ||'));');
run;

/* make the animation appear to 'pause' on the last frame for a little longer */
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
%do_frame(&maxdate);
/*
*/

options printerpath=gif animation=stop;
ods printer close;

quit;
ODS HTML CLOSE;
ODS LISTING;
