%let name=covid19_uscounty_mapanim_cases;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

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

/* Get the latest/max date in the data, and save it to a macro variable */
proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from reported_data where avg^=.;
select max(date) format=date9. into :maxdate2 separated by ' ' from reported_data;
quit; run;

/* this is the 'secret sauce' that creates the gif animation */
options dev=sasprtc printerpath=gif animduration=.6 animloop=0 
 animoverlay=no animate=start center nobyline;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US Covid-19 animation map") 
 style=htmlblue;

goptions gunit=pct border device=gif
 ctitle=gray33 ctext=gray33 
 ftitle='albany amt' ftext='albany amt'
 htitle=3.7 htext=2.3;

/* create some extra variables I want to be able to access using #byval */
data reported_data; set reported_data;
year2=.; year2=put(date,year4.);
month2=put(date,monname3.);
format day2 z2.;
day2=.; day2=put(date,day.);
run;

proc sort data=reported_data out=reported_data;
by date year2 month2 day2;
run;

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
run;

legend1 label=(position=top h=2.0 j=c 'New cases' j=c 'per 100,000')
 value=(h=2.0 justify=center)
 position=(bottom right) mode=share across=1 order=descending
 shape=bar(.15in,.15in) offset=(0,8);

/*
libname robsmaps '../democd97';
data my_map; set robsmaps.uscounty (where=(density<=1));
original_order=_n_;
run;
*/
data my_map; set maps.uscounty;
/* Shannon county, SD */
if state=46 and county=113 then county=102;
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
length function $8 color $8;
color='gray55'; style='mempty'; when='a'; xsys='2'; ysys='2';
if first.segment then function='poly';
else function='polycont';
run;


pattern1 v=s c=cx1a9850;
pattern2 v=s c=cx66bd63;
pattern3 v=s c=cxa6d96a;
pattern4 v=s c=cxd9ef8b;
pattern5 v=s c=cxfee08b;
pattern6 v=s c=cxfdae61;
pattern7 v=s c=cxf46d43;
pattern8 v=s c=cxd73027;

title1 ls=2.0 "New Daily Reported COVID-19 Cases per 100,000 Persons";
title2 a=-90 h=2 ' ';
options nobyline;

footnote1 
 link="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
 ls=0.8 "Data source: Johns Hopkins University CSSE (7-day centered moving average applied to data)";

%let colordt=dodgerblue;

/* do the big date label as separate pieces via 'note', so won't visually jump around in the animation */

proc gmap map=my_map data=reported_data (where=(date>="10mar2020"d)) anno=anno_outline;
by date year2 month2 day2;
note move=(37.5,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(month2)";
note move=(47,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(day2),";
note move=(54,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(year2)";
id state county;
choro range / midpoints=1 2 3 4 5 6 7 8
 coutline=gray99
 legend=legend1 
 des='' name="&name";
run;

/* repeat the last frame a few times, for a simulated gif animation 'pause' */
proc gmap map=my_map data=reported_data (where=(date="&maxdate"d)) anno=anno_outline;
by date year2 month2 day2;
note move=(37.5,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(month2)";
note move=(47,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(day2),";
note move=(54,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(year2)";
id state county;
choro range / midpoints=1 2 3 4 5 6 7 8
 coutline=gray99
 legend=legend1
 des='' name="&name";
run;
run;
run;
run;
run;
run;
run;
run;
run;
run;
run;
run;
run;

/* put mouse-over text for the states on the very last frame */
data anno_outline; set anno_outline;
length html $100;
html='title='||quote(trim(left(fipnamel(state))));
run;
proc gmap map=my_map data=reported_data (where=(date="&maxdate"d)) anno=anno_outline;
by date year2 month2 day2;
note move=(37.5,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(month2)";
note move=(47,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(day2),";
note move=(54,86) h=5.5 c=&colordt font='albany amt/bold' "#byval(year2)";
id state county;
choro range / midpoints=1 2 3 4 5 6 7 8
 coutline=gray99
 legend=legend1
 des='' name="&name";
run;



/*
proc print data=reported_data (where=(statename='Nebraska'));
format range comma8.0;
var statename date cases_this_day population_mil cases_this_day_per_million avg range;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
