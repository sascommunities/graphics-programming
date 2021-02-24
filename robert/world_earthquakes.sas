%let name=world_earthquakes;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Go here, and enter 2000 as the Min Year, and 2020 as Max Year:
https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/search
Click 'Search' button, and it will get about 1,198 results,here:
https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/event-data?maxYear=2020&minYear=2000
Click the 'download' arrow icon in the 'Year' header (in top/left of table)
This saved a tab-separated-values file, with date/time timestamp in filename:
earthquakes-2021-02-22_08-27-54_-0500.tsv
I renamed it as earthquakes_2000_2020.tsv
The file had a line between column names and data, showing what the query was ...
 "[""2000 <= Year >= 2020""]"
I deleted that line, making the data easier to import.
*/

proc import datafile="earthquakes_2000_2020.tsv" dbms=dlm out=my_data replace;
delimiter='09'x;
getnames=yes;
datarow=2;
guessingrows=all;
run;

data my_data; set my_data (where=(mag>=7.0));
mag_int=int(mag);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Earthquakes 2000-2020") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=1100px height=500px noborder; 

/* Get world map, remove Antarctica, and lower the border complexity a little */
data my_map; set mapsgfk.world (where=(idname^='Antarctica' and density<=1));
run;

/* create some 'fake' data to use to color the choropleth land areas */
data land_data; set mapsgfk.world_attr;
landcolor='foo';
run;

title h=16pt c=gray55 "Major Earthquakes (magnitude 7.x, 8.x, or 9.x) Years 2000-2020";

footnote 
 link='https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/event-data?maxYear=2020&minYear=2000'
 h=10pt c=gray77 "Data source: https://www.ngdc.noaa.gov/hazel/view/hazards/earthquake/search";

proc sgmap plotdata=my_data mapresponsedata=land_data mapdata=my_map noautolegend;
/* bubble group colors */
styleattrs datacontrastcolors=(cxa6d854 cx377eb8 cxe7298a);
/* choropleth land area color */
styleattrs datacolors=(cxffffaa);
/* make all the land areas yellow */
choromap landcolor / mapid=id lineattrs=(color=cxffffaa) tip=none;
bubble x=longitude y=latitude size=mag_int / group=mag_int 
 bradiusmin=5px bradiusmax=15px nofill tip=none;
run;

proc sort data=my_data;
by descending mag descending year descending mo descending dy;
run;
proc print data=my_data;
format mag comma5.1;
var mag year mo dy location_name latitude longitude;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
