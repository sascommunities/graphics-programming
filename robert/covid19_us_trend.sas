%let name=covid19_us_trend;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to:
https://www.linkedin.com/feed/update/urn:li:activity:6680763769603403776/
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

%getdata(time_series_covid19_confirmed_global.csv);

filename confcsv "time_series_covid19_confirmed_global.csv";
proc import datafile=confcsv
 out=reported_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

data reported_data; set reported_data (where=(country_region='US'));
run;

proc transpose data=reported_data out=reported_data (rename=(_name_=datestring col1=confirmed_cumulative));
by Province_State Country_Region Lat Long notsorted;
run;

/* The date/timestamp is in a string - parse it apart, and create a real date variable */
data reported_data (drop = month day year datestring province_state lat long);
 set reported_data;
Country_Region=trim(left(Country_Region));
month=.; month=scan(datestring,1,'_');
day=.; day=scan(datestring,2,'_');
year=.; year=2000+scan(datestring,3,'_'); 
if confirmed_cumulative=0 then confirmed_cumulative=.;
format date date9.;
date=mdy(month,day,year);
run;

data reported_data; set reported_data;
cases_this_day=confirmed_cumulative-lag(confirmed_cumulative);
length day_type $30;
if trim(left(put(date,downame.))) in ('Saturday' 'Sunday') then day_type='Daily Cases (weekends)';
else day_type='Daily Cases (weekdays)';
foo=put(date,downame.);
length day $20;
day=put(date,downame.);
run;

proc expand data=reported_data out=reported_data;
label avg_7='7-day moving average (centered)';
convert cases_this_day=avg_7 / method=none transformout=(cmovave 7 trim 3);
run;

%let weeks=15;
proc sql noprint;
select max(date) format=date9. into :maxdate separated by ' ' from reported_data;
select max(date)-(7*&weeks) format=date9. into :mindate separated by ' ' from reported_data;
quit; run;
%let maxdate=%lowcase(&maxdate);
%let mindate=%lowcase(&mindate);

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
textcolor="white"; textsize=9; textweight='normal';
width=100; widthunit='percent';
url="https://raw.githubusercontent.com/CSSEGISandData/COVID-19/";
y1=8.5; label="Raw data downloaded from GitHub (https://raw.githubusercontent.com/CSSEGISandData/COVID-19/)";
output;
url="";
y1=y1-3; label="COVID-19 case data courtesy of the Johns Hopkins University Center for Systems Science and Engineering (CSSE)";
output;
y1=y1-3; label="Data include Puerto Rico, Guam, American Samoa, the US Virgin Islands, and the Northern Mariana Islands";
output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Covid-19 trend") 
 style=raven;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 width=900px height=550px noborder;

title1 c=white h=14pt "United States COVID-19 Daily Reported Cases: &mindate to &maxdate (&weeks weeks)";
title2 c=white h=5pt " ";

proc sgplot data=reported_data noautolegend pad=(left=3pct right=5pct bottom=14pct) sganno=anno_footnote;;
format date date5.;
styleattrs datacontrastcolors=(cx4266ea gray7f);
needle y=cases_this_day x=date / group=day_type name='needles'
 lineattrs=(thickness=4px pattern=solid) tip=none;
scatter y=cases_this_day x=date /
 markerattrs=(color=gray77 symbol=circle)
 tip=(date day cases_this_day) tipformat=(nldate20. auto comma8.0);
series y=avg_7 x=date / name='avg'
 lineattrs=(color=red thickness=3) tip=none;
yaxis display=(nolabel noline noticks) 
 grid gridattrs=(pattern=dot color=white)
 values=(0 to 40000 by 10000)
 valuesformat=comma10.0
 valueattrs=(color=white size=10pt)
 offsetmin=0 offsetmax=.20;
xaxis display=(nolabel) /*type=time */
 values=("&mindate"d to "&maxdate"d by 7)
 valueattrs=(color=white size=9pt)
 offsetmin=.01 offsetmax=.03;
keylegend 'needles' 'avg' / title='' position=topright location=inside 
 valueattrs=(color=white size=11pt weight=normal)
 opaque noborder across=1 outerpad=(right=80pt top=7pt);
run;

/*
proc print data=reported_data; 
var country_region date confirmed_cumulative cases_this_day;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
