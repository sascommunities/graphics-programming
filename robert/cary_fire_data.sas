%let name=cary_fire_data;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/fire-incidents/table/
*/

/*
proc import datafile="D:\public\cary\2021\fire-incidents.csv" dbms=dlm out=incident_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;
*/

data incident_data;
infile 'D:\public\cary\2021\fire-incidents.csv' delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;

/*
According to this doc: https://go.documentation.sas.com/doc/en/pgmsascdc/v_011/leforinforref/n09mk4h1ba9wp1n1tc3e7x0eow8q.htm
I think the timestamp data (2021-01-30T06:18:26-05:00) is E8601DZ35. 
rather than B8601DZ35. informat, because it has dashes and colons.
*/
/*
This is the informat proc import generated ...
   informat AlarmTime B8601DZ35. ;
If I was going to use the gmt/zulu/utc timestamp, I think it should be the 'E8601' rather than 'B8601'
   informat AlarmTime E8601DZ35. ;
See the difference in the doc here:
https://go.documentation.sas.com/doc/en/vdmmlcdc/8.1/nlsref/p1v3byy0te7g9mn1fiwc8i9kmyd9.htm 
But I'm going to handle it a different way ...
*/
   informat AlarmTimeString $35. ;
   informat YEAR best32. ;
   informat IncidentNum $10. ;
   informat Exposure best32. ;
   informat IncidentCode best32. ;
   informat InciTypeDesc $50. ;
   informat Category $22. ;
   informat MajorCategory $10. ;
   informat StreetAddress $34. ;
   informat MutualAid $1. ;
   informat Station $3. ;
   informat Shift $1. ;
   informat District $4. ;
   informat ResponseZone $4. ;
   informat Latitude best32. ;
   informat Longitude best32. ;
   informat GeoPoint $20. ;

/*
   format AlarmTime B8601DZ35. ;
   format AlarmTime E8601DZ35. ;
*/
   format AlarmTimeString $35. ;
   format YEAR best12. ;
   format IncidentNum $10. ;
   format Exposure best12. ;
   format IncidentCode best12. ;
   format InciTypeDesc $50. ;
   format Category $22. ;
   format MajorCategory $10. ;
   format StreetAddress $34. ;
   format MutualAid $1. ;
   format Station $3. ;
   format Shift $1. ;
   format District $4. ;
   format ResponseZone $4. ;
   format Latitude best12. ;
   format Longitude best12. ;
   format GeoPoint $20. ;

input
/*
   AlarmTime
*/
   AlarmTimeString
   YEAR
   IncidentNum  $
   Exposure
   IncidentCode
   InciTypeDesc  $
   Category  $
   MajorCategory  $
   StreetAddress  $
   MutualAid  $
   Station  $
   Shift  $
   District  $
   ResponseZone  $
   Latitude
   Longitude
   GeoPoint  $
;
run;

/* 
There seem to be some 'dups' in the data, such as incident 16-0000119 has 3 obsns.
Let's try to get rid of them by dropping variables I don't use, and then 
using the proc sort noduprecs option to get rid of dups.

With the data I was working on Aug 13 2021, it got rid of 9 dups, for example...
NOTE: There were 50376 observations read from the data set WORK.INCIDENT_DATA.
NOTE: 9 duplicate observations were deleted.
*/
data incident_data; set incident_data (drop = YEAR Exposure IncidentCode MutualAid Shift District ResponseZone GeoPoint);
run;
proc sort data=incident_data out=incident_data noduprecs;
by IncidentNum;
run;

data incident_data; set incident_data (rename=(longitude=incident_long latitude=incident_lat));

/* Just grab the "local time" part, and ignore the gmt/zulu/utc offset part */
format alarm_date date9.;
alarm_date=input(scan(alarmtimestring,1,'T'),yymmdd10.);
format alarm_time timeampm.;
alarm_time=input(scan(scan(alarmtimestring,2,'T'),1,'-'),time.);
format alarm_datetime datetime20.;
alarm_datetime=dhms(alarm_date,0,0,alarm_time);

year=.; year=put(alarm_date,year4.);
month=.; month=put(alarm_date,month.);
year_mon=.; year_mon=year+((month-1)/12);
format hour timeampm5.;
hour=round(alarm_time,3600);
run;

/* Subset it to just the data in the geographical area of interest */
data incident_data; set incident_data 
(where=(
 incident_long^=. and incident_lat^=. and 
 incident_lat>35.68 and incident_lat<35.86 and
 incident_long>-78.94 and incident_long<-78.75 
 and majorcategory='FIRE'
 ));
run;

/* If I was going to make use of the gmt/zulu/utc timestamp data, I might use this option... */
/*
options timezone='America/New_York';
*/

proc sql noprint;
select min(alarm_date) format=date9. into :mindate from incident_data;
select max(alarm_date) format=date9. into :maxdate from incident_data;
quit; run;



data station_data;

length station $3 address $50 city_state_zip $50;
input station $ 1-80;
input address $ 1-80;
input city_state_zip $ 1-80;

length city $50 state $2;
city=scan(city_state_zip,1,',');
state='NC';
zip=.; zip=scan(city_state_zip,-1,' ');

infile datalines pad truncover;
datalines;
001
1501 N Harrison Ave.
Cary, NC 27513
002
601 E. Chatham St.
Cary, NC 27511
003
1807 Kildaire Farm Rd.
Cary, NC 27511
004
1401 Old Apex Rd.
Cary, NC 27511
005
2101 High House Rd.
Cary, NC 27513
006
3609 Ten-Ten Rd.
Cary, NC 27518
007
6900 Carpenter Fire Station Rd.
Cary, NC 27519
008
408 Mills Park Dr.
Cary, NC 27519
009
1427 Walnut St.
Cary, NC 27511
;
run;

proc geocode data=station_data out=station_data (rename=(x=station_long y=station_lat))
 method=street lookupstreet=sashelp.geoexm;
run;


/* get the lat/long of the responding station for each fire, so you can draw a line */
proc sql noprint;
create table line_data as
select unique incident_data.incidentNum, incident_data.station, 
 incident_data.incident_long, incident_data.incident_lat, 
 station_data.station_long, station_data.station_lat
from incident_data left join station_data
on incident_data.station=station_data.station;
quit; run;
/* For each 1 obsn, output 3 obsns (2 to draw the line, and then a 'missing' to lift pen for next line) */
data line_data (keep = incidentnum station line_lat line_long); set line_data;
line_lat=incident_lat; line_long=incident_long; output;
line_lat=station_lat; line_long=station_long; output;
line_lat=.; line_long=.; output;
run;


/* combine all the data (because sgmap must have it all in 1 dataset) */
data all_data; set line_data incident_data station_data;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Fires") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 noborder; 
ods graphics / width=800 height=600px;

footnote1 j=c c=gray77 h=10pt 
 link='https://data.townofcary.org/explore/dataset/fire-incidents/table/'
 "Data source: https://data.townofcary.org/explore/dataset/fire-incidents/table/ (&mindate - &maxdate)";

ods graphics / width=900px height=900px;

title1 j=c c=gray33 h=14pt "Fires in Cary NC (red dots), fire stations (yellow)";

proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
scatter x=incident_long y=incident_lat / markerattrs=(symbol=circlefilled size=3pt color="red") 
 tip=(alarm_date incidentnum incitypedesc streetaddress);
scatter x=station_long y=station_lat / markerattrs=(symbol=circlefilled size=8pt color="yellow")
 tip=(station);
run;

title1 j=c c=gray33 h=14pt "Fires in Cary NC, by responding station";

proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
styleattrs datacontrastcolors=(cxe41a1c cx377eb8 cx4daf4a cx984ea3 cxff7f00 cxffff33 cxa65628 cxf781bf cyan);
series x=line_long y=line_lat / group=station lineattrs=(pattern=solid) tip=none;
scatter x=incident_long y=incident_lat / markerattrs=(symbol=circlefilled size=3pt color=gray11) /*group=station*/
 tip=(alarm_date incidentnum incitypedesc streetaddress station);
scatter x=station_long y=station_lat / markerattrs=(symbol=circlefilled size=8pt color="yellow") tip=none;
scatter x=station_long y=station_lat / markerattrs=(symbol=circle size=8pt color="gray55") tip=(station);
run;


/* 
I'm using a heat map, rather than bar chart, so I can have a 'bar segment' 
for each fire, and still use a color group.  To use the heat map, I have to 
calculate an x/y coordinate for each little box (year_mon and y_position).
*/
proc sort data=incident_data out=incident_data;
by year_mon category;
run;
data incident_data; set incident_data;
by year_mon category;
if first.year_mon then y_position=1;
else y_position+1;
run;

title1 j=c c=gray33 h=14pt "Fires in Cary NC, organized by month";

ods graphics / width=900px height=500px;
proc sgplot data=incident_data noborder;
styleattrs datacolors=(cx66c2a5 cxffd92f cxfc8d62 cxa6d854 cxe78ac3 graycc);
heatmapparm x=year_mon y=y_position colorgroup=category / 
 outline outlineattrs=(color=gray77)
 tip=(alarm_date incidentnum incitypedesc streetaddress);
xaxis display=(noline nolabel) values=(2016 to 2022 by 1)
 grid gridattrs=(pattern=dot color=gray11);
yaxis display=(noline nolabel noticks) offsetmin=0
 grid gridattrs=(pattern=dot color=gray11);
keylegend / title='' position=top;
run;


title1 j=c c=gray33 h=14pt "Fires in Cary NC, organized by hour";

ods graphics / width=1000px height=500px;
proc sgplot data=incident_data noborder;
vbar hour / stat=freq barwidth=1.0 fillattrs=(color=cxEE6363);
yaxis display=(noline noticks nolabel)
 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(nolabel noticks) valueattrs=(size=8);
run;


title1 j=c c=gray33 h=14pt "Fires in Cary NC (&mindate - &maxdate)";

proc sort data=incident_data out=incident_data;
by alarm_datetime;
run;
proc print data=incident_data /*(obs=20)*/;
var alarm_date alarm_time station incidentnum incitypedesc category streetaddress;
run;

/*
proc print data=station_data; run;
proc print data=incident_data (obs=20); run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
