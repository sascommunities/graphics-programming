%let name=coronavirus_us;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from:
https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
*/

libname robsdata ".";

data confirmed_data; set robsdata.confirmed_data (where=(country_region='US' and confirmed^=0 and confirmed^=.));
length statecode $2;
statecode=scan(trim(left(scan(province_state,2,','))),1,' ');
run;

proc sql noprint;

/* get the data from the most recent day */
create table latest as 
select * from confirmed_data
having snapshot=max(snapshot);

/* sum up all the confirmed cases in each state */
create table us_summary as
select unique statecode, sum(confirmed) as confirmed
from latest
group by statecode;

/* save some values into macro variables, to use in the title */
select sum(confirmed) format=comma10.0 into :total separated by ' ' from latest;
select unique(snapshot) format=nldate20. into :freshness separated by ' ' from latest where snapshot^=.;

quit; run;

data us_summary; 
length statecode $10;
set us_summary;
length my_html $300;
if statecode='' then statecode='Unassigned';
else my_html=
 'title='||quote(trim(left(statecode))||': '||trim(left(put(confirmed,comma10.0)))||' cases')||
 ' href='||quote('#'||trim(left(statecode)));
run;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Coronavirus US Map") 
 style=htmlblue;

goptions ftitle="Albany AMT" ftext="Albany AMT" gunit=pct htitle=16pt htext=11pt;
goptions ctext=gray33;
goptions border;

legend1 label=none shape=bar(.15in,.15in);

pattern1 v=s c=cxfee090;
pattern2 v=s c=cxfdae61;
pattern3 v=s c=cxf46d43;
pattern4 v=s c=cxd73027;
pattern5 v=s c=cxa50026;

title1 ls=1.5 h=18pt "&total Coronavirus (COVID-19) Cases in the US";
title2 ls=1.0
 link='https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series'
 "Data source: Johns Hopkind CSSE (&freshness snapshot)";

proc gmap data=us_summary map=mapsgfk.us all;
label confirmed='Confirmed cases';
id statecode;
choro confirmed / levels=5 legend=legend1 
 coutline=gray33 cempty=graycc
 cdefault=cxF7FFF7
 html=my_html 
 des='' name="&name";
run;

title1 c=gray33 h=20pt font="albany amt" "&total Coronavirus (COVID-19) Cases in the US";
title2 c=gray99 h=12pt 
 link='Data source: https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series'
 "Using &freshness snapshot of the data";
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
run;

data my_map; set mapsgfk.us_counties (where=(statecode="&statecode") drop = x y resolution);
run;

proc gproject data=my_map out=my_map latlong eastlong degrees
 noparmin parmout=projparm;
id state county;
run;

data my_map_data; set mapsgfk.us_counties_attr (where=(statecode="&statecode"));
length my_html $300;
my_html='title='||quote(trim(left(idname))||' county, '||trim(left(statecode)));
run;

data anno_bubbles; set temp_latest (where=(confirmed^=0));
run;
proc sort data=anno_bubbles out=anno_bubbles;
by descending confirmed;
run;

proc gproject data=anno_bubbles out=anno_bubbles latlong eastlong degrees
 parmin=projparm parmentry=my_map;
id;
run;

/* these control the size of the blue bubbles */
%let max_val=100;  /* maximum number of confirmed cases (will correspond to maximum bubble size) */
%let max_area=200; /* maximum bubble size (area) */

data anno_bubbles; set anno_bubbles;
xsys='2'; ysys='2'; hsys='3'; when='a';
function='pie'; rotate=360;
size=.2+sqrt((confirmed/&max_val)*&max_area/3.14);
style='psolid'; color='Aff000099'; output;
length html $300;
html=
 'title='||quote(trim(left(put(confirmed,comma10.0)))||' confirmed cases  in '||trim(left(province_state)))||
 ' href='||quote('http://sww.sas.com/sww-bin/broker94?_service=appdev94&_program=ctntest.coronavirus_substate.sas'||
  '&substate='||trim(left(province_state))||'&lat='||trim(left(lat))||'&long='||trim(left(long))
  );
style='pempty'; color='gray55'; output;
run;


pattern1 v=s c=cxF7FFF7;

proc sql noprint;
select sum(confirmed) format=comma10.0 into :stotal separated by ' ' from temp_latest;
quit; run;

title1 ls=1.5 height=18pt "&stotal Coronavirus (COVID-19) Cases in &statecode";
title2 ls=1.0
 link='https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series'
 "Data source: Johns Hopkins CSSE (&freshness snapshot)";

/*
title1 c=gray33 h=20pt "&stotal Coronavirus (COVID-19) Cases in &statecode";
title2 c=gray99 h=12pt "Using &freshness snapshot of the data";
*/

proc gmap map=my_map data=my_map_data anno=anno_bubbles;
id state county;
choro state / levels=1 nolegend
 coutline=graycc
 html=my_html
 name="&name._&statecode"
 des='';
run;

proc print data=temp_latest 
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
var province_state lat long confirmed;
sum confirmed;
run;

%mend do_map;


proc sql noprint; 
create table loop as
select unique statecode 
from us_summary
where confirmed^=. and confirmed^=0;
quit; run;

data _null_; set loop 
/*
 (where=(statecode in ('CA')))
 (where=(statecode in ('NC')))
 (where=(statecode in ('FL' 'NC')))
*/
 ;
call execute('%do_map(%str('|| trim(left(statecode)) ||'));');
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
