%let name=coronavirus_us;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from:
https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv
https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv
*/

%let srclink=https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv;

/* local copy works much faster, for the 'proc import' */
filename confdata "time_series_covid19_confirmed_US.csv";
/*
filename confdata url "&srclink";
*/

proc import datafile=confdata
 out=confirmed_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

proc transpose data=confirmed_data out=confirmed_data (rename=(long_=long _name_=datestring col1=confirmed));
by UID iso2 iso3 code3 FIPS Admin2 Province_State Country_Region Lat Long_ Combined_Key notsorted;
run;

data confirmed_data; set confirmed_data (where=(iso2='US'));
format confirmed comma10.0;
state=.; state=substr(put(fips,z5.),1,2);
county=.; county=substr(put(fips,z5.),3,3);
length statecode $2;
statecode=fipstate(state);
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_');
format snapshot date9.;
snapshot=mdy(month,day,year);
if statecode^='' and statecode^='--' then output;
run;

proc sql noprint;

create table latest as 
select * from confirmed_data
having snapshot=max(snapshot);

create table us_summary as
select unique statecode, state, sum(confirmed) format=comma10.0 as confirmed
from latest
group by statecode;

select sum(confirmed) format=comma10.0 into :total separated by ' ' from latest;
select unique(snapshot) format=nldate20. into :freshness separated by ' ' from latest where snapshot^=.;

quit; run;

data us_summary; set us_summary;
length my_html $300;
my_html=
 'title='||quote(trim(left(fipnamel(state)))||': '||trim(left(put(confirmed,comma10.0)))||' cases')||
 ' href='||quote('#'||trim(left(statecode)));
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Coronavirus US Map") 
 style=htmlblue;

goptions ftitle="Albany AMT" ftext="Albany AMT" gunit=pct htitle=16pt htext=11pt;
goptions ctext=gray33;
goptions border;

pattern1 v=s c=cxfee090;
pattern2 v=s c=cxfdae61;
pattern3 v=s c=cxf46d43;
pattern4 v=s c=cxd73027;
pattern5 v=s c=cxa50026;

title1 ls=1.5 h=18pt "&total Confirmed Coronavirus (COVID-19) Cases in US States";
title2 ls=1.0 link="&srclink" "Data source: Johns Hopkins CSSE (&freshness snapshot)";

legend1 label=(position=top justify=left 'Quintile binning (1/5 of states assigned to each color range)') 
 shape=bar(.15in,.15in) across=5;

proc gmap data=us_summary map=mapsgfk.us all;
label confirmed='Confirmed cases';
id statecode;
choro confirmed / levels=5 range legend=legend1 
 coutline=gray33 cempty=graycc
 cdefault=cxF7FFF7
 html=my_html 
 des='' name="&name";
run;

legend2 label=(position=top justify=left 'Nelder binning (another way to look at this data)') 
 shape=bar(.15in,.15in) across=5;

proc gmap data=us_summary map=mapsgfk.us all;
label confirmed='Confirmed cases';
id statecode;
choro confirmed / levels=5 midpoints=old range legend=legend2
 coutline=gray33 cempty=graycc
 cdefault=cxF7FFF7
 html=my_html
 des='' name="&name";
run;


title1 c=gray33 h=20pt font="albany amt" "&total Confirmed Coronavirus (COVID-19) Cases in US States";
title2 link="&srclink" "Data source: Johns Hopkins CSSE (&freshness snapshot)";
footnote;
proc sort data=us_summary out=us_summary;
by descending confirmed;
run;
proc print data=us_summary (where=(confirmed^=.))
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
label statecode='State';
label confirmed='Confirmed cases';
var statecode confirmed;
sum confirmed;
run;



%macro do_map(statecode);
ods html anchor="&statecode";

data temp_latest; set latest (where=(statecode="&statecode"));
length my_html $300;
my_html='title='||quote(
 trim(left(put(confirmed,comma10.0)))||' confirmed cases in '||'0d'x||
 trim(left(combined_key))
 );
if confirmed=0 then confirmed=.;
run;

data my_map; set mapsgfk.us_counties (where=(statecode="&statecode") drop = x y resolution);
run;

proc gproject data=my_map out=my_map latlong eastlong degrees dupok nodateline
 noparmin parmout=projparm;
id state county;
run;

data anno_bubbles; set temp_latest (where=(confirmed^=0));
run;
proc sort data=anno_bubbles out=anno_bubbles;
by descending confirmed;
run;

proc gproject data=anno_bubbles out=anno_bubbles latlong eastlong degrees dupok nodateline
 parmin=projparm parmentry=my_map;
id;
run;

/* these control the size of the blue bubbles */
/*%let max_val=100;*/  /* maximum number of confirmed cases (will correspond to maximum bubble size) */
proc sql noprint;
select max(confirmed) into :max_val from temp_latest;
quit; run;
%let max_area=200; /* maximum bubble size (area) */

data anno_bubbles; set anno_bubbles;
if confirmed=. then confirmed=0;
if confirmed^=0 then do;
 xsys='2'; ysys='2'; hsys='3'; when='a';
 function='pie'; rotate=360;
 size=.2+sqrt((confirmed/&max_val)*&max_area/3.14);
 style='psolid'; 
 color='Aff000099'; output;
 length html $300;
 html=
  'title='||quote(trim(left(put(confirmed,comma10.0)))||' confirmed cases  in '||trim(left(combined_key)))||
  ' href='||quote('http://sww.sas.com/sww-bin/broker94?_service=appdev94&_program=ctntest.coronavirus_substate.sas'||
   '&substate='||trim(left(combined_key))||'&lat='||trim(left(lat))||'&long='||trim(left(long))
   );
 style='pempty'; color='gray55'; output;
 end;
run;


pattern1 v=s c=grayee;

proc sql noprint;
select sum(confirmed) format=comma10.0 into :stotal separated by ' ' from temp_latest;
quit; run;

title1 ls=1.5 c=gray33 h=20pt font="albany amt" "&stotal Confirmed Coronavirus Cases in &statecode";
title2 ls=1.0 link="&srclink" "Data source: Johns Hopkins CSSE (&freshness snapshot)";

goptions border;
proc gmap map=my_map data=temp_latest anno=anno_bubbles;
id state county;
choro confirmed / levels=1 nolegend
 cdefault=cxF7FFF7
 coutline=graybb
 html=my_html
 name="&name._map_&statecode"
 des='';
run;


proc sql noprint;
create table temp_series as
select unique snapshot, sum(confirmed) as confirmed
from confirmed_data
where statecode="&statecode"
group by snapshot
order by snapshot;
quit; run;

data temp_series; set temp_series;
by snapshot;
daily_confirmed=confirmed-lag(confirmed);
length my_html $300;
my_html='title='||quote(
 put(daily_confirmed,comma10.0)||' new confirmed cases on '||trim(left(put(snapshot,nldate20.)))
 );
run;

symbol1 value=circle height=8pt cv=gray88 interpol=needle ci=orange width=2;

axis1 label=none minor=none offset=(1,0);
axis2 label=none;

title1 ls=1.5 c=gray33 h=20pt font="albany amt" "Confirmed New Coronavirus Cases in &statecode, each day";
title2 ls=1.0 link="&srclink" "Data source: Johns Hopkins CSSE (&freshness snapshot)";

goptions noborder;
proc gplot data=temp_series;
format daily_confirmed comma10.0;
plot daily_confirmed*snapshot=1 /
 vaxis=axis1 autovref cvref=graydd 
 haxis=axis2
 html=my_html
 name="&name._plot_&statecode"
 des='';
run;

/*
length my_html $300;
my_html='title='||quote(
 trim(left(put(confirmed,comma10.0)))||' confirmed cases in '||'0d'x||
 trim(left(combined_key))
 );
*/

title1 c=gray33 h=20pt font="albany amt" "&stotal Confirmed Coronavirus (COVID-19) Cases in &statecode Counties";
title2 link="&srclink" "Data source: Johns Hopkins CSSE (&freshness snapshot)";

proc sort data=temp_latest out=temp_latest;
by descending confirmed;
run;
proc print data=temp_latest label
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
label combined_key='County';
label confirmed='Confirmed Cases';
var combined_key confirmed;
sum confirmed;
run;


%mend do_map;


proc sql noprint; 
create table loop as
select unique statecode 
from us_summary;
quit; run;

data _null_; set loop 
/*
 (where=(statecode in ('CA')))
 (where=(statecode in ('NC')))
 (where=(statecode in ('NY' 'WI' 'FL' 'NC')))
 (where=(statecode in ('FL' 'NC')))
*/
 ;
call execute('%do_map(%str('|| trim(left(statecode)) ||'));');
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
