%let name=nc_county_covid_percent;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';


/* You could download the data ... */
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

/* Or you could point to the data location on the web ... */
/*
filename confcsv "\\sashq\root\u\realliso\public_html\ods10\time_series_covid19_confirmed_US.csv";
*/

filename confcsv "time_series_covid19_confirmed_US.csv";

proc import datafile=confcsv out=raw_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;



%macro do_map(state);

proc sql noprint;
select statename into :stname separated by ' ' from sashelp.us_data where statecode="&state";
quit; run;

data state_map; set mapsgfk.us_counties (where=(statecode="&state" and density<=3));
run;

proc gproject data=state_map latlong eastlong degrees dupok out=state_map (drop=lat long);
id statecode;
run;

/* limit it to just the selected state's counties */
data reported_data (
  drop = uid iso2 iso3 code3 admin2 country_region lat long_ combined_key 
  rename=(province_state=statename)
  ); 
 set raw_data (where=(
 iso2='US' and 
 fips^=. and 
 fips not in (80037 90037) and
 province_state="&stname"
 ));
run;

proc transpose data=reported_data out=reported_data (rename=(_name_=datestring col1=reported_cumulative));
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

/* Limit it to just the latest date's cumulative value */
proc sql noprint;
select max(date) format=date9. into :maxdate from reported_data;
select min(date) format=date9. into :mindate from reported_data;
quit; run;
data latest_reported_data; set reported_data (where=(date="&maxdate"d));
run;

/* merge in the population for each county */
/*
Each state csv file downloaded from here:
https://data.ers.usda.gov/reports.aspx?ID=17827
And then the 2018 (latest) population was used.
*/
libname johndata '\\sashq\root\dept\ctn\JohnD\TestDataLAX\coronavirus\data\misc';
proc sql noprint;
create table latest_reported_data as 
select unique latest_reported_data.*, us_county_population.county_name, us_county_population.population
from latest_reported_data left join johndata.us_county_population
on latest_reported_data.fips=us_county_population.countyfips;
quit; run;

/* Calculate the percent of population that reported positive for covid */
data latest_reported_data; set latest_reported_data;
label county_name='County';
label reported_cumulative='Cases reported';
label population='Population';
label percent_reported_positive='% of population reported positive';
format reported_cumulative comma10.0;
format population comma10.0;
format percent_reported_positive percent8.1;
percent_reported_positive=round(reported_cumulative/population,.001);
run;

/* 
Manually assign the % values to discrete legend 'buckets'
to do a discrete map, rather than continuous color ramp.
*/
proc format;
   value bkt_fmt
   1='0-1%'
   2='1-2%'
   3='2-3%'
   4='3-4%'
   5='>4%'
   ;
run;

data latest_reported_data; set latest_reported_data;
label legend_bucket='% of population reported positive';
format legend_bucket bkt_fmt.;
     if percent_reported_positive<=.01 then legend_bucket=1;
else if percent_reported_positive<=.02 then legend_bucket=2;
else if percent_reported_positive<=.03 then legend_bucket=3;
else if percent_reported_positive<=.04 then legend_bucket=4;
else legend_bucket=5;
run;

/* 
Insert some 'fake data' to make sure the legend always shows
all colors/ranges, even if the data doesn't have them all.
*/
data fake_data; 
county=.;
legend_bucket=1; output;
legend_bucket=2; output;
legend_bucket=3; output;
legend_bucket=4; output;
legend_bucket=5; output;
run;

data latest_reported_data; set latest_reported_data fake_data;
run;




title1 c=gray33 h=14pt "&stname: Percent of population reporting positive COVID-19 results";
title2 c=gray77 h=12pt ls=0.8 "Using data from Johns Hopkins CSSE (&mindate - &maxdate)";

/*
proc sgmap mapdata=state_map maprespdata=latest_reported_data;
choromap percent_reported_positive / mapid=county;
run;

proc sgmap mapdata=state_map maprespdata=latest_reported_data;
choromap percent_reported_positive / mapid=county
 numlevels=5 leveltype=interval;
run;
*/

/* sort the data, to control the order of the legend */
proc sort data=latest_reported_data out=latest_reported_data;
by legend_bucket;
run;

proc sgmap mapdata=state_map maprespdata=latest_reported_data;
styleattrs datacolors=(cx4dac26 cxb8e186 cxfffff0 cxf1b6da cxd01c8b);
choromap legend_bucket / discrete mapid=county 
 lineattrs=(thickness=1 color=grayaa)
 tip=(County_name reported_cumulative population percent_reported_positive)
 ;
run;

/* Overlay % values on each county */
%annomac;
%centroid(state_map,overlay_text,county,segonly=1);

proc sql noprint;
create table overlay_text as
select unique overlay_text.*, latest_reported_data.percent_reported_positive format=percent7.1
from overlay_text left join latest_reported_data
on overlay_text.county=latest_reported_data.county;
quit; run;

proc sgmap mapdata=state_map maprespdata=latest_reported_data plotdata=overlay_text;
styleattrs datacolors=(cx4dac26 cxb8e186 cxfffff0 cxf1b6da cxd01c8b);
choromap legend_bucket / discrete mapid=county
 lineattrs=(thickness=1 color=grayaa)
 tip=(County_name reported_cumulative population percent_reported_positive)
 ;
text x=x y=y text=percent_reported_positive / textattrs=(color=black) tip=none;
run;



proc sort data=latest_reported_data (where=(county^=. and county_name^=''))
 out=latest_reported_data;
by county_name;
run;

proc print data=latest_reported_data label; 
var County_name reported_cumulative population percent_reported_positive;
run;

%mend do_map;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="County Covid Percent") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=900px height=525px noborder; 

%do_map(NC);
/*
%do_map(NY);
%do_map(TX);
%do_map(VA);
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
