%let name=wuhan_coronavirus_dashboard;
filename odsout '.';

/*
Imitation/variation of Johns Hopkins dashboard:
https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6

https://github.com/CSSEGISandData/2019-nCoV/tree/master/time_series
https://github.com/CSSEGISandData/2019-nCoV/

https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
https://github.com/CSSEGISandData/COVID-19/
*/

/* 
Make a local copy/clone of the GitHub data.
gitfn_clone() needs an empty folder, therefore use a new
folder name each time, with the date & time in the name.
*/
/*
%let gitfolder=./github_clone_&sysdate9._%sysfunc(tranwrd(&systime,:,_));
%let gitfolder=./github_clone_17FEB2020;
*/

%let gitfolder=./github_clone_&sysdate9;
/*
data _null_;
 rc = gitfn_clone("https://github.com/CSSEGISandData/COVID-19/",
   "&gitfolder");
 put rc=;
run;
*/

/* ------------------ Import the confirmed cases data ---------------------- */

/*
filename confdata "./&gitfolder/time_series/time_series_2019-ncov-Confirmed.csv";
*/
filename confdata "./&gitfolder/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv";
proc import datafile=confdata
 out=confirmed_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

proc transpose data=confirmed_data out=confirmed_data (rename=(_name_=datestring col1=confirmed));
by Province_State Country_Region Lat Long notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data confirmed_data (drop = month day year datestring);
 set confirmed_data;
if Country_Region='Others' then Country_Region='Cruise ships, etc';
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
format snapshot date9.;
snapshot=mdy(month,day,year);
run;
/* 
Create a table with just the latest date/timestamp.
You'll use this latest data in all but the timeseries plot.
*/
proc sql noprint;
create table latest_confirmed as
select unique *
from confirmed_data
having snapshot=max(snapshot);
quit; run;

/* Create macro variables with the data & time, to use in the title */
proc sql noprint;
select unique(snapshot) format=nldate20. into :datestr separated by ' ' from latest_confirmed;
quit; run;


/* ------------------ Import the deaths data ---------------------- */

/*
filename deatdata "./&gitfolder/time_series/time_series_2019-ncov-Deaths.csv";
*/
filename deatdata "./&gitfolder/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv";
proc import datafile=deatdata
 out=death_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

proc transpose data=death_data out=death_data (rename=(_name_=datestring col1=deaths));
by Province_State Country_Region Lat Long notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data death_data (drop = month day year datestring);
 set death_data;
if Country_Region='Others' then Country_Region='Cruise ships, etc';
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_');
format snapshot date9.;
snapshot=mdy(month,day,year);
run;

proc sql noprint;
create table latest_deaths as
select unique *
from death_data
having snapshot=max(snapshot);
quit; run;


/* ------------------ Import the recovered cases data ---------------------- */

/*
filename recodata "./&gitfolder/time_series/time_series_2019-ncov-Recovered.csv";
*/
filename recodata "./&gitfolder/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv";
proc import datafile=recodata
 out=recovered_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

proc transpose data=recovered_data out=recovered_data (rename=(_name_=datestring col1=recovered));
by Province_State Country_Region Lat Long notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data recovered_data (drop = month day year datestring);
 set recovered_data;
if Country_Region='Others' then Country_Region='Cruise ships, etc';
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_');
format snapshot dateampm.;
snapshot=mdy(month,day,year);
run;

proc sql noprint;
create table latest_recovered as
select unique *
from recovered_data
having snapshot=max(snapshot);
quit; run;


/* ----------------------------------------------------------------------- */


goptions device=png;
goptions border;
 
ODS LISTING CLOSE;
ODS html path=odsout body="&name..htm"
 (title="Wuhan Coronavirus Dashboard") 
 style=htmlblue;

goptions gunit=pct ftitle='albany amt/bold' ftext='albany amt' htitle=28pt htext=12pt;
goptions cback=black ctext=graycc;

/* Create the individual graphs, but don't display them (yet) */
goptions nodisplay;

/*-------------------------------------------------------------------*/

goptions xpixels=1400 ypixels=700;
data anno_black_background;
length function $8 color $12 style $35;
xsys='3'; ysys='3'; when='b';
function='move'; x=0; y=0; output;
function='bar'; x=100; y=100; style='solid'; color="black"; output;
run;

/* this is the medium graph background used behind each graph */
data anno_gray_background; set anno_black_background;
color="gray22";
run;

/* this is the dark/black background, behind the entire dashboard */
proc gslide anno=anno_black_background
 des='' name='back';
run;

title;


/*-----------------------------title--------------------------------------*/

/* Use annotate & gslide to create a long/skinny title slide */

/* xpixels=(99.5-.5)/100*1400 ypixels=(99-90)/100*700 */
goptions xpixels=1386 ypixels=63;
data anno_title;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d'; 
function='label'; position='6'; color="graycc";
html='title='||quote("Wuhan Coronavirus dashboard - As of &datestr");
size=20; x=2; y=60; text="2019-nCoV Wuhan Coronavirus Global Cases"; output;
size=14; x=44; y=53; text="As of &datestr"; output;
run;
data anno_title; set anno_gray_background anno_title;
run;
proc gslide anno=anno_title des='' name='title';
run;


/*-----------------------------info--------------------------------------*/

/* Use annotated text in a gslide to create the info box in bottom/right corner */

/* xpixels=(99.5-70)/100*1400 ypixels=(15-1)/100*700 */
goptions xpixels=413 ypixels=98;
data anno_info;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; position='6'; 
size=11; 

y=87; html=''; function='label'; 
x=3; color="graycc"; text="Visualization by: "; output;
html='target="cor2" href='||quote('https://blogs.sas.com/content/author/robertallison/');
x=30; color="dodgerblue"; text="Robert Allison using SAS Software"; output;

y=y-24; html='';  
x=3; color="graycc"; text="Designed after: "; output;
html='target="cor2" href='||quote('https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6');
x=29; color="dodgerblue"; text="Johns Hopkins dashboard"; output;

y=y-24; html=''; 
x=3; color="graycc"; text="Data sources: "; output;
html='target="cor2" href='||quote('https://www.who.int/emergencies/diseases/novel-coronavirus-2019/situation-reports');
x=28; color="dodgerblue"; text="WHO,"; output;
html='target="cor2" href='||quote('https://www.cdc.gov/coronavirus/2019-ncov/index.html');
x=x+11; color="dodgerblue"; text="CDC,"; output;
html='target="cor2" href='||quote('https://www.ecdc.europa.eu/en/geographical-distribution-2019-ncov-cases');
x=x+10; color="dodgerblue"; text="ECDC,"; output;
html='target="cor2" href='||quote('http://www.nhc.gov.cn/yjb/s3578/new_list.shtml');
x=x+13; color="dodgerblue"; text="NHC,"; output;
html='target="cor2" href='||quote('https://3g.dxy.cn/newh5/view/pneumonia?scene=2&clicktime=1579582238&enterid=1579582238&from=singlemessage&isappinstalled=0');
x=x+10; color="dodgerblue"; text="and DXY"; output;

y=y-24; html=''; 
x=3; color="graycc"; text="Data: "; output;
html='target="cor2" href='||quote('https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series');
x=14; color="dodgerblue"; text="GitHub"; output;

run;
data anno_info; set anno_gray_background anno_info;
run;
proc gslide anno=anno_info des='' name='info';
run;


/*----------------------------confsum---------------------------------------*/

/* this is the grand sum (large number) over the confirmed table */

/* xpixels=(15-.5)/100*1400  ypixels=(89-75)/100*700 */
goptions xpixels=203 ypixels=98;

proc sql noprint;
create table anno_confirmed_total as 
select sum(confirmed) as sum_confirmed from latest_confirmed;
quit; run;
data anno_confirmed_total; set anno_confirmed_total;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; position='5'; 
style='albany amt/bold'; color="graycc"; size=11;
x=50; y=84; text="Total Confirmed"; output;
html='title='||quote(trim(left(put(sum_confirmed,comma12.0)))||" total confirmed cases of Wuhan Coronavirus worldwide");
style='albany amt/bold'; color="red"; size=40;
x=50; y=50; text=trim(left(put(sum_confirmed,comma12.0))); output;
run;
data anno_confirmed_total; set anno_gray_background anno_confirmed_total;
run;
proc gslide anno=anno_confirmed_total des='' name='confsum';
run;

/*------------------------------deadsum-------------------------------------*/

/* this is the grand sum (large number) over the deaths table */

goptions xpixels=203 ypixels=98;
proc sql noprint;
create table anno_deaths_total as
select sum(deaths) as sum_deaths from latest_deaths;
quit; run;
data anno_deaths_total; set anno_deaths_total;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; position='5';
style='albany amt/bold'; color="graycc"; size=11;
x=50; y=84; text="Total Deaths"; output;
html='title='||quote(trim(left(put(sum_deaths,comma12.0)))||" deaths from Wuhan Coronavirus worldwide");
style='albany amt/bold'; color="white"; size=40;
x=50; y=50; text=trim(left(put(sum_deaths,comma12.0))); output;
run;
data anno_deaths_total; set anno_gray_background anno_deaths_total;
run;
proc gslide anno=anno_deaths_total des='' name='deadsum';
run;


/*------------------------------recosum-------------------------------------*/

/* this is the grand sum (large number) over the recovered table */

goptions xpixels=203 ypixels=98;
proc sql noprint;
create table anno_recovered_total as
select sum(recovered) as sum_recovered from latest_recovered;
quit; run;
data anno_recovered_total; set anno_recovered_total;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; position='5';
style='albany amt/bold'; color="graycc"; size=11;
x=50; y=84; text="Total Recovered"; output;
html='title='||quote(trim(left(put(sum_recovered,comma12.0)))||" recovered from Wuhan Coronavirus worldwide");
style='albany amt/bold'; color="cx71a81e"; size=40;
x=50; y=50; text=trim(left(put(sum_recovered,comma12.0))); output;
run;
data anno_recovered_total; set anno_gray_background anno_recovered_total;
run;
proc gslide anno=anno_recovered_total des='' name='recosum';
run;


/*----------------------------map---------------------------------------*/

/* World map, with annotated red bubbles */

/* xpixels=(69.5-15.5)/100*1400  ypixels=(89-35)/100*700 */
goptions xpixels=756 ypixels=378;

proc sql noprint;
create table map_data as
select unique country_region, avg(lat) as lat, avg(long) as long, sum(confirmed) as confirmed
from latest_confirmed
group by country_region;
quit; run;

data map_data; set map_data;
/* if the average lat/long doesn't land in a good position, hard-code one */
if country_region='Canada' then do;
 lat=52.7765273; long=-107.4818132;
 end;
if country_region='Sweden' then do;
 lat=63.7425748; long=16.5564647;
 end;
if country_region='Russia' then do;
 lat=55.4645521; long=37.3415677;
 end;
length html $300;
html=
 'title='||quote(
  trim(left(country_region))||'0d'x||
  trim(left(put(confirmed,comma12.0)))||' confirmed cases')||
 ' href='||quote('#'||trim(left(country_region)));
run;

/* The country names have to match in the data & map, for the choro map */
data my_map; set mapsgfk.world (where=(density<=2 and idname^='Antarctica') drop=resolution);
length country_region $100;
country_region=idname;
if idname='Russian Federation' then country_region='Russia';
if idname='China' then country_region='Mainland China';
if idname='United States' then country_region='US';
if idname='United Kingdom' then country_region='UK';
if idname='Viet Nam' then country_region='Vietnam';
if idname='China/Taiwan_POC' then country_region='Taiwan';
run;
proc gproject data=my_map out=my_map latlong eastlong degrees 
 project=miller2 parmout=projparm;
id country_region;
run;
/* Project the bubble lat/longs the same way you did the map */
proc gproject data=map_data out=map_data latlong eastlong degrees
 parmin=projparm parmentry=my_map;
id;
run;

/* these control the size of the blue bubbles */
%let max_val=150000;  /* maximum number of confirmed cases (will correspond to maximum bubble size) */
%let max_area=200; /* maximum bubble size (area) */
data anno_bubbles; set map_data;
length function $8 color $12 style $35 text $300 html $300;
xsys='2'; ysys='2'; hsys='3'; when='a';
function='pie'; rotate=360; style='psolid'; color="red"; 
size=.5+sqrt((confirmed/&max_val)*&max_area/3.14);
output;
run;

data anno_bubbles; set anno_gray_background anno_bubbles;
run;
pattern1 v=s c=gray99;
proc gmap data=map_data map=my_map all anno=anno_bubbles;
id country_region;
choro confirmed / levels=1 nolegend 
 cdefault=gray55 coutline=gray77 
 html=html
 des='' name='map';
run;
proc sql noprint;
create table not_in_map as
select unique country_region
from map_data
where country_region not in (select unique country_region from my_map);
quit; run;


/*--------------------------conftab-----------------------------------------*/

/* confirmed table */

/* xpixels=(15-.5)/100*1400 ypixels=(74-1)/100*700 */
goptions xpixels=203 ypixels=511;
proc sql noprint;
create table anno_table_confirmed as
select unique country_region, sum(confirmed) as confirmed
from latest_confirmed
group by country_region;
quit; run;
proc sort data=anno_table_confirmed out=anno_table_confirmed;
by descending confirmed country_region;
run;
data anno_table_confirmed; set anno_table_confirmed (obs=16);
if country_region='United Arab Emirates' then country_region='UAE';
run;
data anno_table_confirmed; set anno_table_confirmed;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; style='albany amt/bold'; size=11;
y=99-(_n_*6);
text=trim(left(put(confirmed,comma12.0))); x=28; position='4'; color="red"; output;
text=trim(left(country_region)); x=x+5; position='6'; color="graycc"; output;
/* annotate an invisible box, for the html= mouse-over text */
html='title='||quote(trim(left(put(confirmed,comma12.0)))||" confirmed cases of Wuhan Coronavirus in "||trim(left(country_region)))||
 ' href='||quote('#'||trim(left(country_region)));
function='move'; x=0; y=y-3; output;
function='bar'; x=100; y=y+5; style='empty'; line=3; size=.001; color="pink"; output;
run;
data anno_table_confirmed; set anno_table_confirmed;
output;
if _n_=1 then do;
 style='albany amt'; color="graycc"; text='- up to top 16 -'; x=50; y=y+5;  position='5'; output;
 end;
run;
data anno_table_confirmed; set anno_gray_background anno_table_confirmed;
run;
proc gslide anno=anno_table_confirmed des='' name='conftab';
run;


/*---------------------------deadtab----------------------------------------*/

/* dead table */

/* xpixels=(84.5-70)/100*1400 ypixels=(74-16)/100*700 */
goptions xpixels=203 ypixels=406;
proc sql noprint;
create table anno_table_deaths as
select unique country_region, sum(deaths) as deaths
from latest_deaths
group by country_region;
quit; run;
proc sort data=anno_table_deaths out=anno_table_deaths;
by descending deaths country_region;
run;
data anno_table_deaths; set anno_table_deaths (where=(deaths>0));
run;
data anno_table_deaths; set anno_table_deaths (obs=13);
if country_region='United Arab Emirates' then country_region='UAE';
run;
data anno_table_deaths; set anno_table_deaths;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; style='albany amt/bold'; size=11;
y=98-(_n_*7);
text=trim(left(put(deaths,comma12.0))); x=28; position='4'; color="white"; output;
text=trim(left(country_region)); x=x+5; position='6'; color="graycc"; output;
/* annotate an invisible box, for the html= mouse-over text */
html='title='||quote(trim(left(put(deaths,comma12.0)))||" deaths from Wuhan Coronavirus in "||trim(left(country_region)))||
 ' href='||quote('#'||trim(left(country_region)));
function='move'; x=0; y=y-3; output;
function='bar'; x=100; y=y+5; style='empty'; line=3; size=.001; color="pink"; output;
run;
data anno_table_deaths; set anno_table_deaths;
output;
if _n_=1 then do;
 style='albany amt'; color="graycc"; text='- up to top 13 -'; x=50; y=y+6;  position='5'; output;
 end;
run;
data anno_table_deaths; set anno_gray_background anno_table_deaths;
run;
proc gslide anno=anno_table_deaths des='' name='deadtab';
run;


/*---------------------------recotab----------------------------------------*/

/* recovered table */

goptions xpixels=203 ypixels=406;
proc sql noprint;
create table anno_table_recovered as
select unique country_region, sum(recovered) as recovered
from latest_recovered
group by country_region;
quit; run;
proc sort data=anno_table_recovered out=anno_table_recovered;
by descending recovered country_region;
run;
data anno_table_recovered; set anno_table_recovered (where=(recovered>0));
run;
data anno_table_recovered; set anno_table_recovered (obs=13);
if country_region='United Arab Emirates' then country_region='UAE';
run;
data anno_table_recovered; set anno_table_recovered;
length function $8 color $12 style $35 text $300 html $300;
xsys='3'; ysys='3'; when='a'; hsys='d';
function='label'; style='albany amt/bold'; size=11;
y=98-(_n_*7);
text=trim(left(put(recovered,comma12.0))); x=28; position='4'; color="cx71a81e"; output;
text=trim(left(country_region)); x=x+5; position='6'; color="graycc"; output;
/* annotate an invisible box, for the html= mouse-over text */
html='title='||quote(trim(left(put(recovered,comma12.0)))||" recovered from Wuhan Coronavirus in "||trim(left(country_region)))||
 ' href='||quote('#'||trim(left(country_region)));
function='move'; x=0; y=y-3; output;
function='bar'; x=100; y=y+5; style='empty'; line=3; size=.001; color="pink"; output;
run;
data anno_table_recovered; set anno_table_recovered;
output;
if _n_=1 then do;
 style='albany amt'; color="graycc"; text='- up to top 13 -'; x=50; y=y+6;  position='5'; output;
 end;
run;
data anno_table_recovered; set anno_gray_background anno_table_recovered;
run;
proc gslide anno=anno_table_recovered des='' name='recotab';
run;


/*---------------------------series----------------------------------------*/

/* time series graph */

/* xpixels=(69.5-15.5)/100*1400 ypixels=(34-1)/100*700 */
goptions xpixels=756 ypixels=231;
data summarized_series; 
length grouping $50;
set confirmed_data;
if index(country_region,'China')^=0 then grouping='Mainland China';
else grouping='Other Locations';
run;
proc sql noprint;
create table summarized_series as
select unique snapshot, grouping, sum(confirmed) as confirmed
from summarized_series
group by snapshot, grouping
order by grouping, snapshot;
quit; run;
data summarized_series; set summarized_series;
length html $300;
html='title='||quote(
 trim(left(grouping))||'0d'x||
 trim(left(put(snapshot,nldate20.)))||'0d'x||
 trim(left(put(confirmed,comma12.0)))||' confirmed cases'
 );
run;
/* 
There seems to be a bug in gplot mouseover text, when used in greplay in this way.
Therefore I'm annotating 'invisible' circles around the gplot markers, 
with the html mouse-over on the annotated circles.
*/
data anno_mouseover; set summarized_series;
length function $8 color $12 style $35 html $300;
xsys='2'; ysys='2'; hsys='3'; when='b';
x=snapshot; y=confirmed;
function='pie'; style='pempty'; size=3; rotate=360; color='gray22';
run;
proc sql noprint;
select min(snapshot) format=date9. into :mindate from summarized_series;
select max(snapshot) format=date9. into :maxdate from summarized_series;
select max(snapshot)-min(snapshot) into :byval from summarized_series;
quit; run;
axis1 value=(c=graycc h=11pt) label=none minor=none offset=(0,0);
axis2 label=none order=("&mindate"d to "&maxdate"d by &byval)
 major=(height=8pt) value=(c=graycc h=11pt font='albany amt');
legend1 value=(c=graycc font="albany amt/bold" h=11pt) shape=symbol(4pct,4pct)
 label=(position=top font="albany amt/bold" h=11pt c=graycc "Total Confirmed Cases") 
 position=(top left inside) mode=share across=1 repeat=2 offset=(3pct, -8pct);
symbol1 interpol=sm50 height=8pt width=2 color=orange value=square;
symbol2 interpol=sm50 height=8pt width=2 color=cyan value=triangle;
title1 h=2pct ' ';
footnote1 h=2pct ' ';
data anno_mouseover; set anno_mouseover anno_gray_background;
run;
proc gplot data=summarized_series anno=anno_mouseover;
format confirmed comma12.0;
format snapshot nldate20.;
plot confirmed*snapshot=grouping / 
 vaxis=axis1 haxis=axis2
 legend=legend1 
 des='' name="series";
run;


/*-------------------------------------------------------------------*/

/* 
turn on display again, and replay all the individual graphs 
into a custom greplay template layout.
*/

goptions display;

%let border=gray44;
goptions xpixels=1400 ypixels=700;
proc greplay nofs igout=work.gseg tc=tempcat;
   tdef dash des='Wuhan Coronavirus Dashboard'
   0/ llx=0       lly=0
      ulx=0       uly=100
      urx=100     ury=100
      lrx=100     lry=0
   1/ llx=.5      lly=90
      ulx=.5      uly=99 
      urx=99.5    ury=99 
      lrx=99.5    lry=90
      color=&border
   2/ llx=.5      lly=75
      ulx=.5      uly=89
      urx=15      ury=89
      lrx=15      lry=75
      color=&border
   3/ llx=.5      lly=1 
      ulx=.5      uly=74
      urx=15      ury=74
      lrx=15      lry=1 
      color=&border
   4/ llx=70      lly=75
      ulx=70      uly=89
      urx=84.5    ury=89
      lrx=84.5    lry=75
      color=&border
   5/ llx=70      lly=16
      ulx=70      uly=74
      urx=84.5    ury=74
      lrx=84.5    lry=16
      color=&border
   6/ llx=85      lly=75
      ulx=85      uly=89
      urx=99.5    ury=89
      lrx=99.5    lry=75
      color=&border
   7/ llx=85      lly=16
      ulx=85      uly=74
      urx=99.5    ury=74
      lrx=99.5    lry=16
      color=&border
   8/ llx=15.5    lly=35
      ulx=15.5    uly=89
      urx=69.5    ury=89
      lrx=69.5    lry=35
      color=&border
   9/ llx=15.5    lly=1 
      ulx=15.5    uly=34
      urx=69.5    ury=34
      lrx=69.5    lry=1 
      color=&border
  10/ llx=70      lly=1 
      ulx=70      uly=15
      urx=99.5    ury=15
      lrx=99.5    lry=1 
      color=&border
   ;
   template dash;
   treplay
    9:series
    0:back
    1:title
    2:confsum
    3:conftab 
    4:deadsum
    5:deadtab
    6:recosum
    7:recotab
    8:map  
   10:info
    des='' name="&name";
run;

/* We don't have Hong Kong and Macau in our world map */
/* That's ok - those polygons would be too small to see anyway */
/* They still get a red bubble. */
/*
title "country_region names not in the map"; 
proc print data=not_in_map; run;
*/

/* -------------------------------------------------------------------- */

/* 
Create drilldown graphs for each country. 
We will jump to these graphs using html 'anchors' (by the name of the country)
*/

proc sql noprint;

create table graph_confirmed as
select unique country_region, snapshot, sum(confirmed) as confirmed
from confirmed_data
group by country_region, snapshot
order by country_region, snapshot;

create table graph_recovered as
select unique country_region, snapshot, sum(recovered) as recovered
from recovered_data
group by country_region, snapshot
having recovered^=0
order by country_region, snapshot;

create table graph_deaths as
select unique country_region, snapshot, sum(deaths) as deaths
from death_data
group by country_region, snapshot
having deaths^=0
order by country_region, snapshot;


create table graph_all as
select unique graph_confirmed.*, graph_recovered.recovered
from graph_confirmed left join graph_recovered
on (graph_confirmed.country_region=graph_recovered.country_region) and (graph_confirmed.snapshot=graph_recovered.snapshot);

create table graph_all as
select unique graph_all.*, graph_deaths.deaths
from graph_all left join graph_deaths
on (graph_all.country_region=graph_deaths.country_region) and (graph_all.snapshot=graph_deaths.snapshot);

quit; run;

data graph_all; set graph_all;
if recovered=. then recovered=0;
if deaths=. then deaths=0;
length my_html $300;
my_html='title='||quote(
 trim(left(put(snapshot,nldate20.)))||'0d'x||
 '-------------------'||'0d'x||
 'Confirmed: '||trim(left(put(confirmed,comma20.0)))||'0d'x||
 'Recovered: '||trim(left(put(recovered,comma20.0)))||'0d'x||
 'Deaths: '||trim(left(put(deaths,comma20.0)))
 );
run;

proc sort data=graph_all out=graph_all;
by country_region snapshot;
run;

goptions xpixels=800 ypixels=600 cback=white ctext=graph33 noborder;

axis1 value=(c=gray33 h=11pt) label=none minor=none offset=(0,1);

axis2 label=none order=("&mindate"d to "&maxdate"d by &byval)
 major=(height=8pt) value=(c=gray33 h=11pt font='albany amt') offset=(1,1);

legend1 value=(c=gray33 font="albany amt/bold" h=11pt) shape=symbol(4pct,4pct)
 label=none order=('confirmed' 'recovered' 'deaths')
 position=(top left inside) mode=share across=1 repeat=1 offset=(3pct, -4pct);

symbol1 interpol=join height=8pt width=2 color=red value=square;
symbol2 interpol=join height=8pt width=2 color=cx71a81e value=triangle;
symbol3 interpol=join height=8pt width=2 color=gray77 value=circle;

options nobyline;
title1 h=18pt font='albany amt/bold' c=gray33 "2019-nCoV Wuhan Coronavirus cases in: #byval(country_region)";
ods html anchor="#byval(country_region)";
proc gplot data=graph_all;
by country_region;
format confirmed comma12.0;
format snapshot nldate20.;
plot confirmed*snapshot=1 recovered*snapshot=2 deaths*snapshot=3 / overlay
 vaxis=axis1 haxis=axis2 vzero
 legend=legend1 
 html=my_html
 des='' name="wuhan_coronavirus_#byval(country_region)";
run;
proc print data=graph_all; run;

quit;
ODS HTML CLOSE;
ODS LISTING;
