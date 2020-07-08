%let name=covid19_deaths;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to:
https://twitter.com/CtzCow/status/1276208834428747776
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

%getdata(time_series_covid19_deaths_global.csv);

filename deadcsv "time_series_covid19_deaths_global.csv";
proc import datafile=deadcsv
 out=reported_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

data reported_data; set reported_data;
run;

proc transpose data=reported_data out=reported_data (rename=(_name_=datestring col1=deaths_cumulative));
by Province_State Country_Region Lat Long notsorted;
run;

data reported_data (drop = month day year datestring /*province_state*/ lat long);
 set reported_data;
Country_Region=trim(left(Country_Region));
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
if deaths_cumulative=0 then deaths_cumulative=.;
format date date9.;
date=mdy(month,day,year);
run;

proc sql noprint;
select max(date) format=date9. into :maxdate from reported_data;
quit; run;

proc sql noprint;
create table reported_data as
select unique country_region, date, sum(deaths_cumulative) as deaths_cumulative
from reported_data
group by country_region, date
order by country_region, date;
quit; run;

data reported_data; set reported_data (where=(deaths_cumulative^=.));
run;

data reported_data; set reported_data;
lag=lag(deaths_cumulative);
run;

data reported_data; set reported_data;
by country_region;
if first.country_region then deaths_this_day=deaths_cumulative;
else deaths_this_day=(deaths_cumulative-lag);
run;

/* this is the 2005 population data */
data population_data; set sashelp.demographics (keep = isoname pop);
if isoname='UNITED STATES' then isoname='US';
if isoname='IRAN, ISLAMIC REPUBLIC OF' then isoname='IRAN';
if isoname='KOREA, REPUBLIC OF' then isoname='KOREA, SOUTH';
if isoname='BRUNEI DARUSSALAM' then isoname='BRUNEI';
if isoname='LIBYAN ARAB JAMAHIRIYA' then isoname='LIBYA';
if isoname='CZECH REPUBLIC' then isoname='CZECHIA';
if isoname='SYRIAN ARAB REPUBLIC' then isoname='SYRIA';
if isoname='RUSSIAN FEDERATION' then isoname='RUSSIA';
if isoname='TANZANIA, UNITED REPUBLIC OF' then isoname='TANZANIA';
if isoname='MOLDOVA, REPUBLIC OF' then isoname='MOLDOVA';
if isoname='' then isoname='';
run;

proc sql noprint;
create table reported_data as
select unique reported_data.*, population_data.pop
from reported_data left join population_data
on upcase(reported_data.country_region) = upcase(population_data.isoname)
order by country_region, date;
quit; run;

data reported_data; set reported_data;
label deaths_this_day_per_million='Daily deaths per million';
deaths_this_day_per_million=deaths_this_day/(pop/1000000);
run;

proc sql noprint;
create table all_countries as
select unique country_region, max(deaths_this_day_per_million) as max
from reported_data
group by country_region;
quit; run;

/* For each country, keep all obsns after the first day of >=1 death per million */
data reported_data; set reported_data;
by country_region;
retain keepflag;
if first.country_region then keepflag='n';
if deaths_this_day_per_million>=1 then keepflag='y'; 
run;

data reported_data; set reported_data (where=(keepflag='y'));
by country_region;
label days="Days since first 1-death-per-million in each country";
if first.country_region then days=1;
else days+1;
run;

proc expand data=reported_data out=reported_data;
by country_region;
label avg_7='Daily deaths per million';
convert deaths_this_day_per_million=avg_7 / method=none transformout=(cmovave 7 trim 3);
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
x1=9; 
x1space='wallpercent'; y1space='graphpercent';
anchor='left';
textcolor='gray33'; textsize=9; textweight='normal';
width=100; widthunit='percent';
url="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv";
y1=8.5; label="Coronavirus &maxdate data downloaded from GitHub (https://raw.githubusercontent.com/CSSEGISandData/COVID-19/)";
output;
url="";
y1=y1-3; label="COVID-19 case data courtesy of the Johns Hopkins University Center for Systems Science and Engineering (CSSE)";
output;
y1=y1-3; label="Lines are smoothed, using 7-day moving average (center-calculated)";
output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Covid-19 deaths trend") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 maxlegendarea=60 ANTIALIASMAX=15600
 width=900px height=550px noborder;

/*
proc sgplot data=reported_data noautolegend pad=(left=3pct right=5pct bottom=14pct) sganno=anno_footnote;;
series y=avg_7 x=days / name='deaths' tip=none group=country_region 
 lineattrs=(color=grayaa pattern=solid);
run;
*/

%macro do_plot(titltext,max,by);

/*
cxe41a1c
cx377eb8
cx4daf4a
cx984ea3
cxff7f00
cxa65628
*/
title1 h=13pt c=gray33 "New Deaths per Day from COVID-19 (select &titltext countries)";
proc sgplot data=reported_data (where=(country_region in (&countries)))
 noautolegend noborder pad=(left=3pct right=5pct bottom=14pct) sganno=anno_footnote;;
styleattrs datacontrastcolors=(
cxe41a1c
cxa65628
cx4daf4a
cx984ea3
cx377eb8
cxff7f00
magenta
gray55
);
series y=avg_7 x=days / name='deaths2' /*tip=none*/
 group=country_region
 lineattrs=(pattern=solid thickness=2px)
 ;
keylegend 'deaths2' / title='' position=topright location=inside 
 valueattrs=(size=9pt weight=normal)
 opaque noborder across=1 outerpad=(right=5pt top=7pt)
 ;
xaxis values=(0 to 110 by 10) offsetmin=0 offsetmax=0
 display=(noline);
yaxis values=(0 to &max by &by) offsetmin=0 offsetmax=0
 display=(noline noticks) 
 grid gridattrs=(pattern=dot color=gray88);
run;

%mend;


/* Australia & New Zealand are under 1 death per million */
/* Belgium counts more things as cv deaths than most other countries */
/* Spain had some negative numbers that look 'odd' in the graph */
/* Portugal seems suspiciously low */
/* Germany's numbers are suspiciously low */
%let countries='US' 'United Kingdom' 'Canada' 'France' 'Italy' 'Sweden';
%do_plot(Western,20,5);

/*
%let countries='Brazil' 'Panama' 'Chile' 'Peru' 'Mexico' 'Colombia' 'Argentina' 'Ecuador';
%do_plot(South and Latin American,16,4);

%let countries='Russia' 'Turkey' 'Romania' 'Bulgaria' 'Ukraine' 'Czechia' 'Poland' 'Belarus';
%do_plot(Eastern European,2,1);
*/

/* these just have too low of values, etc */
/*
%let countries='Iran' 'Iraq' 'Saudi Arabia' 'Egypt' 'Bahrain' 'UAE';
%do_plot(Middle Eastern);

%let countries='China' 'Japan' 'South Korea';
%do_plot(East Asian);

%let countries='India' 'Pakistan';
%do_plot(South Asian);
*/

/*
proc sql noprint;
create table no_match as
select unique country_region, pop
from reported_data
where pop=.;
quit; run;

title "No matching population data";
proc print data=no_match;
run;

title "All countries in the data";
proc print data=all_countries; run;

title "Data";
proc print data=reported_data (obs=200); 
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
