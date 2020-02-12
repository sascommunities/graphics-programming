%let name=nuclear_distance;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
My own version of this map:
https://metricmaps.org/2016/07/28/distance-from-nuclear-power-plant/

Using 2014 production data from 923 data files:
http://www.eia.gov/electricity/data/eia923/index.html
EIA923_Schedules_2_3_4_5_M_12_2014_Final_Revision.xlsx
(had to shorten the sheet name from 'Page 1 Generation and Fuel Data$' to 'Generation and Fuel Data$'
*/


PROC IMPORT OUT=production
 DATAFILE="EIA923_Schedules_2_3_4_5_M_12_2014_Final_Revision.xlsx"
 DBMS=XLSX REPLACE;
RANGE="Generation$a6:cs12179";
GETNAMES=YES;
RUN;
data production; set production 
 (rename=(var96=Net_Generation__Megawatthours_));
run;
data nuclear_plants; set production 
 (where=(
  plant_id^=99999 
  and 
  AER__Fuel_Type_Code='NUC' 
  and 
  Net_Generation__Megawatthours_>0
  ));
statecode=plant_state;
run;

/* get the lat/long for each plant */
PROC IMPORT OUT=locations
 DATAFILE="2___Plant_Y2014.xlsx"
 DBMS=XLSX REPLACE;
RANGE="Plant$a2:aj8522";
GETNAMES=YES;
RUN;
data locations; set locations;
lat=.; lat=latitude;
long=.; long=longitude;
run;

/* merge in the lat/long of the nuclear plants */
proc sql noprint;
create table nuclear_plants as
select unique nuclear_plants.plant_id, 
 sum(nuclear_plants.Net_Generation__Megawatthours_) as Net_Generation__Megawatthours_, 
 nuclear_plants.AER__Fuel_Type_Code, nuclear_plants.statecode,
 locations.long, locations.lat,
 locations.Plant_Name, locations.Street_Address, locations.City
from nuclear_plants left join locations
on (nuclear_plants.plant_id=locations.plant_code)
group by plant_id;
quit; run;

data nuclear_plants; set nuclear_plants (where=(lat^=. and long^=.));
anno_flag=1;
run;

/* Get the cities you want to plot */
data cities; set mapsgfk.uscity 
 (where=(pop_type in (/*'under10k'*/ '10-20k' '20-50k' '50-100k' 'over100k')
 and statecode not in ('AK' 'HI' 'PR') ));
state_city=trim(left(statecode))||'_'||trim(left(city));
run;


/* Create a dataset of all pairs of nuclear plants to cities */
proc sql noprint;
create table pairs as select 
a.plant_name, a.lat as lat_plant, a.long as long_plant, 
b.state_city, b.statecode as statecode2, b.city as city2, b.lat as lat_city, b.long as long_city,
geodist(lat_plant, long_plant, lat_city, long_city, 'DM') as distance_miles
from nuclear_plants as a, cities as b;
quit;

/* Determine the closest nuclear plant to each city */
proc sort data=pairs out=pairs;
by state_city distance_miles;
run;
data pairs; set pairs;
by state_city;
if first.state_city then output;
run;


data line_data (keep = long lat plant_name); set pairs;
long=long_plant; lat=lat_plant; output;
long=long_city; lat=lat_city; output;
long=.; lat=.; output; 
run;

data plant_markers (keep = long_plant_marker lat_plant_marker plant_name plant_url); 
 set nuclear_plants (rename=(long=long_plant_marker lat=lat_plant_marker));
length plant_url $300;
plant_url='http://www.google.com/search?&q='||trim(left(plant_name))||' nuclear power plant';
run;

data city_markers (keep = long_city_marker lat_city_marker city statecode plant_name distance_miles);
 set pairs (rename=(long_city=long_city_marker lat_city=lat_city_marker city2=city statecode2=statecode));
run;


data all_data; set line_data plant_markers city_markers;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Nuclear Power Proximity Map") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=5000 
 imagefmt=png imagename="&name"
 width=900px height=600px noborder; 

/*
title1 c=gray33 h=22pt "Nuclear Power Plants";
proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_LIght_Gray_Base";
scatter x=long_plant_marker y=lat_plant_marker / 
 markerattrs=(symbol=circle size=10px color=black);
run;

title1 c=gray33 h=22pt "Nuclear Power Plants and Cities";
proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_LIght_Gray_Base";
scatter x=long_city_marker y=lat_city_marker / 
 markerattrs=(symbol=circle size=8px color=dodgerblue);
scatter x=long_plant_marker y=lat_plant_marker / 
 markerattrs=(symbol=circle size=10px color=black);
run;

title1 c=gray33 h=22pt "Nuclear Power Plants and Cities";
title2 c=gray33 h=22pt "Cities Color-Grouped By Closest Nuclear Plant";
proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_LIght_Gray_Base";
scatter x=long_city_marker y=lat_city_marker / 
 group=plant_name markerattrs=(symbol=circle size=8px);
scatter x=long_plant_marker y=lat_plant_marker / 
 markerattrs=(symbol=circle size=10px color=black);
run;
*/


title1 c=gray33 h=22pt "Which Nuclear Power Plant Is Closest To Your City?";

proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_LIght_Gray_Base";
series x=long y=lat / 
 group=plant_name lineattrs=(pattern=solid) 
 tip=none;
scatter x=long_city_marker y=lat_city_marker / 
 group=plant_name markerattrs=(symbol=circle size=8px)
 tip=(city statecode distance_miles);
scatter x=long_plant_marker y=lat_plant_marker / 
 markerattrs=(symbol=circle size=10px color=black)
 tip=(plant_name) url=plant_url;
run;

/* you'll need at Viya 3.5 for the custom tip= and url= to work */
/* use the code below, if you only have 9.4m6 */
/*
proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_LIght_Gray_Base";
series x=long y=lat / 
 group=plant_name lineattrs=(pattern=solid);
scatter x=long_city_marker y=lat_city_marker / 
 group=plant_name markerattrs=(symbol=circle size=8px);
scatter x=long_plant_marker y=lat_plant_marker / 
 markerattrs=(symbol=circle size=10px color=black);
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
