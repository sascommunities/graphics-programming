%let st=wi;
%let name=coronavirus_&st;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using coronavirus data from: 
https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/
And county population data from:
https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html#par_textimage_739801612
*/

filename confdata url "https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv";
/*
filename confdata "covid_confirmed_usafacts.csv";
*/
proc import datafile=confdata
 out=confirmed_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

/*
Population data copy-n-pasted from xls table here...
https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html#par_textimage_739801612
copy-n-paste the table below the 'datalines'
(make sure your copy-n-paste preserves the tabs between columns!)
*/

data pop_data (keep = statecode county_name pop_2019);
length county_name $100;
informat pop_2019 change comma12.0;
infile datalines dlm='09'x; /* tab-delimited */
input county_name pop_2019;
statecode=upcase("&st");
datalines;
Adams County	20,220
Ashland County	15,562
Barron County	45,244
Bayfield County	15,036
Brown County	264,542
Buffalo County	13,031
Burnett County	15,414
Calumet County	50,089
Chippewa County	64,658
Clark County	34,774
Columbia County	57,532
Crawford County	16,131
Dane County	546,695
Dodge County	87,839
Door County	27,668
Douglas County	43,150
Dunn County	45,368
Eau Claire County	104,646
Florence County	4,295
Fond du Lac County	103,403
Forest County	9,004
Grant County	51,439
Green County	36,960
Green Lake County	18,913
Iowa County	23,678
Iron County	5,687
Jackson County	20,643
Jefferson County	84,769
Juneau County	26,687
Kenosha County	169,561
Kewaunee County	20,434
La Crosse County	118,016
Lafayette County	16,665
Langlade County	19,189
Lincoln County	27,593
Manitowoc County	78,981
Marathon County	135,692
Marinette County	40,350
Marquette County	15,574
Menominee County	4,556
Milwaukee County	945,726
Monroe County	46,253
Oconto County	37,930
Oneida County	35,595
Outagamie County	187,885
Ozaukee County	89,221
Pepin County	7,287
Pierce County	42,754
Polk County	43,783
Portage County	70,772
Price County	13,351
Racine County	196,311
Richland County	17,252
Rock County	163,354
Rusk County	14,178
St. Croix County	90,687
Sauk County	64,442
Sawyer County	16,558
Shawano County	40,899
Sheboygan County	115,340
Taylor County	20,343
Trempealeau County	29,649
Vernon County	30,822
Vilas County	22,195
Walworth County	103,868
Washburn County	15,720
Washington County	136,034
Waukesha County	404,198
Waupaca County	50,990
Waushara County	24,443
Winnebago County	171,907
Wood County	72,999
;
run;


/* ------------------------------------------------------------------- */

%macro do_state(statecode);
%let statecode=%upcase(&statecode);

proc sql noprint;
select idname into :stname separated by ' ' from mapsgfk.us_states_attr where statecode="&statecode";
quit; run;

goptions device=png;
goptions xpixels=800 ypixels=650;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm"
 (title="Coronavirus in &statecode") 
 style=htmlblue;

goptions gunit=pct htitle=4.0 htext=11pt ftitle="albany amt" ftext="albany amt";
goptions ctext=gray33 border;

data state_confirmed; set confirmed_data (where=(state="&statecode"));
run;

proc transpose data=state_confirmed out=state_confirmed;
by countyFIPS County_Name State stateFIPS notsorted;
run;

data state_confirmed (drop = year month day datestring); 
 set state_confirmed (rename=(_name_=datestring col1=confirmed));
year=.; year=scan(datestring,-1,'_');
day=.; day=scan(datestring,-2,'_');
month=.; month=scan(datestring,-3,'_');
format date date9.;
date=mdy(month,day,year);
county=.; county=substr(put(countyFIPS,z5.),3,3);
if confirmed>0 then output;
run;

data state_pop; set pop_data (where=(statecode="&statecode"));
run;

proc sql noprint;

/* get the coronavirus data with the latest date */
create table latest_data as
select * from state_confirmed
having date=max(date);

/* merge in the population data */
create table latest_data as
select latest_data.*, state_pop.county_name as county_name2, state_pop.pop_2019
from latest_data full join state_pop
on latest_data.county_name = state_pop.county_name;

select sum(confirmed) format=comma12.0 into :total  separated by ' ' from latest_data;
select unique(date) format=nldate20. into :datestr separated by ' ' from latest_data where date^=.;

quit; run;

data latest_data; set latest_data;
if county_name='' then county_name=county_name2;
format per100k comma10.3;
per100k=confirmed/(pop_2019/100000);
format pct percent12.6;
pct=confirmed/pop_2019;
length my_html $300;
my_html='title='||quote(
 trim(left(county_name))||', '||trim(left("&statecode"))||'0d'x||
 '------------------------------'||'0d'x||
 trim(left(put(confirmed,comma20.0)))||' confirmed cases in '||trim(left(put(pop_2019,comma20.0)))||' residents.'||'0d'x||
 'That is '||trim(left(put(per100k,comma10.3)))||' cases per 100,000 residents,'||'0d'x||
 'or '||trim(left(put(pct,percent12.6)))||' of the county population.'
 );
run;

data my_map; set mapsgfk.us_counties (where=(statecode="&statecode" and density<=4) 
 drop=resolution);
run;

pattern1 v=s c=cxffffb2;
pattern2 v=s c=cxfecc5c;
pattern3 v=s c=cxfd8d3c;
pattern4 v=s c=cxf03b20;
pattern5 v=s c=cxbd0026;

title1 ls=1.5 h=18pt c=gray33 "&total confirmed Coronavirus (COVID-19) cases in " c=blue "&stname";

footnote 
 link='https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/'
 ls=1.2 h=12pt c=gray "Coronavirus data source: usafacts.org (&datestr snapshot)";


legend1 label=(position=top justify=center font='albany amt/bold' 'Cases (quintile binning)')
 across=1 position=(bottom left inside) order=descending mode=protect
 shape=bar(.15in,.15in) offset=(1,1);

ods html anchor='quintile';
proc gmap data=latest_data map=my_map all;
format confirmed comma8.0;
id county;
choro confirmed / levels=5 range
 coutline=gray22 cempty=graybb
 legend=legend1
 html=my_html
 des='' name="&name._quin";
run;


legend2 label=(position=top justify=center font='albany amt/bold' 'Cases')
 across=1 position=(bottom left inside) order=descending mode=protect
 shape=bar(.15in,.15in) offset=(1,1);

ods html anchor='old';
proc gmap data=latest_data map=my_map all;
format confirmed comma8.0;
id county;
choro confirmed / levels=5 range midpoints=old
 coutline=gray22 cempty=graybb
 legend=legend2
 html=my_html
 des='' name="&name._old";
run;

legend3 label=(position=top justify=center font='albany amt/bold' 'Cases per 100,000 Residents' j=c '(quintile binning)')
 across=1 position=(bottom left inside) order=descending mode=protect
 shape=bar(.15in,.15in) offset=(1,1);

ods html anchor='quin100k';
proc gmap data=latest_data map=my_map all;
format per100k comma8.1;
id county;
choro per100k / levels=5 range
 coutline=gray22 cempty=graybb
 legend=legend3
 html=my_html
 des='' name="&name._100k";
run;

legend4 label=(position=top justify=center font='albany amt/bold' 'Cases per 100,000 Residents')
 across=1 position=(bottom left inside) order=descending mode=protect
 shape=bar(.15in,.15in) offset=(1,1);

ods html anchor='per100k';
proc gmap data=latest_data map=my_map all;
format per100k comma8.1;
id county;
choro per100k / levels=5 range midpoints=old
 coutline=gray22 cempty=graybb
 legend=legend4
 html=my_html
 des='' name="&name._100k";
run;



proc sql noprint;
create table summarized_series as 
select unique date, sum(confirmed) as confirmed
from state_confirmed
group by date;
quit; run;

data summarized_series; set summarized_series;
todays_confirmed=confirmed-lag(confirmed);
length my_html $300;
my_html='title='||quote(
 put(date,weekdate30.)||'0d'x||
 'New cases on this day: '||trim(left(put(todays_confirmed,comma8.0)))||'0d'x||
 'Total cumulative cases: '||trim(left(put(confirmed,comma8.0)))
 );
run;

proc sql noprint;
select min(date) format=date9. into :mindate from summarized_series;
select max(date) format=date9. into :maxdate from summarized_series;
select max(date)-min(date) into :byval from summarized_series;
quit; run;

axis1 value=(c=gray33 h=11pt) label=(angle=90 'Cumulative') minor=none offset=(0,0);
axis2 value=(c=gray33 h=11pt) label=none order=("&mindate"d to "&maxdate"d by &byval) offset=(1,2);
symbol1 interpol=sm50 line=33 height=8pt width=2 color=red value=square;

ods html anchor='graph';
goptions xpixels=800 ypixels=550 noborder;
proc gplot data=summarized_series;
format confirmed comma12.0;
format date nldate20.;
plot confirmed*date=1 / nolegend
 vaxis=axis1 haxis=axis2
 autovref cvref=graydd
 html=my_html
 des='' name="&name._graph";
run;

/* hard-coding the axis range, so it won't show negative/below-zero ticks */
axis3 value=(c=gray33 h=11pt) label=(angle=90 'Daily New Cases') order=(0 to 250 by 50) minor=none offset=(1,0);
symbol2 interpol=needle height=10pt width=3 color=red value=circle mode=include;

ods html anchor='daily';
goptions xpixels=800 ypixels=550 noborder;
proc gplot data=summarized_series;
format todays_confirmed comma12.0;
format date nldate20.;
plot todays_confirmed*date=2 / nolegend
 vaxis=axis3 haxis=axis2
 autovref cvref=graydd
 html=my_html
 des='' name="&name._daily";
run;

proc sort data=latest_data out=latest_data;
by descending confirmed county_name;
run;

ods html anchor='table';
proc print data=latest_data label
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
label county_name='County';
label confirmed='Coronavirus cases';
label pop_2019='Population (2019)';
label per100k='Cases per 100,000 residents';
label pct='Percent of residents with Coronavirus';
format confirmed comma12.0;
format pop_2019 comma12.0;
var county_name confirmed pop_2019 per100k pct;
sum confirmed pop_2019;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;

%mend do_state;

/* Call the macro, for the desired state */
%do_state(&st);

