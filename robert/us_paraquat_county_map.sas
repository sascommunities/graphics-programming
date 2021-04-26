%let name=us_paraquat_county_map;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Plotting data found at:
https://water.usgs.gov/nawqa/pnsp/usage/maps/compound_listing.php
https://water.usgs.gov/nawqa/pnsp/usage/maps/show_map.php?year=2017&map=PARAQUAT&hilo=L&disp=Paraquat
https://water.usgs.gov/nawqa/pnsp/usage/maps/county-level/
https://www.sciencebase.gov/catalog/item/5e95c12282ce172707f2524e
EPest_county_estimates_2013_2017_v2.txt
*/

%let year=2017;
%let compound=PARAQUAT;

filename tempfile "D:\Public\usgs\chemicals\EPest_county_estimates_2013_2017_v2.txt";
data my_data;
length compound $100;
infile tempfile lrecl=250 firstobs=2 pad dlm='09'x dsd;
input compound year state county epest_low_kg epest_high_kg;
if year=&year and compound="&compound" then output;
run;

/* Create my own custom ranges (or 'buckets') for the legend */

proc format;
value kg_fmt
1='0-100'
2='100-1,000'
3='1,000-5,000'
4='5,000-10,000'
5='>10,000'
;
run;

data my_data; set my_data;
/* sgmap requires a single map id, therefore combine state & county into one id */
length id $10;
id='US-'||trim(left(put(state,z2.)))||trim(left(put(county,z3.)));
/* create my own buckets, rather than letting it auto-scale */
label bucket='kg:';
format bucket kg_fmt.;
if epest_high_kg<=100 then bucket=1;
else if epest_high_kg<=1000 then bucket=2;
else if epest_high_kg<=5000 then bucket=3;
else if epest_high_kg<=10000 then bucket=4;
else if epest_high_kg>10000 then bucket=5;
run;

/* sort the data, so colors are assigned in the desired order */
proc sort data=my_data out=my_data;
by bucket;
run;

/* Get the map, and project it */
data my_map; set mapsgfk.us_counties (where=(density<=2 and statecode not in ('AK' 'HI')));
run;
proc gproject data=my_map out=my_map latlong eastlong degrees
 parmout=projparm;
id id;
run;
/* drop the unprojected lat/long - otherwise sgmap will use them by default */
data my_map; set my_map (drop=lat long);
run;

/* create state borders, with internal county borders removed */
proc gremove data=my_map out=state_outlines;
by statecode notsorted; 
id county;
run;

/* 
Repeat the first obsn of a polygon as the last, so the series plot will 'close' the polygon.
Also insert 'missing' values at the end of each segment, so series line won't be connected
between polygons.
*/
data state_outlines; set state_outlines;
retain x_first y_first;
by statecode segment notsorted;
output;
if first.statecode or first.segment or x=. then do;
 x_first=x; y_first=y; 
 end;
if last.statecode or last.segment or x=. then do;
 x=x_first; y=y_first; output;
 x=.; y=.; output;
 end;
run;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Paraquat") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
/* imagemap tipmax=2500 */
 imagefmt=png imagename="&name"
 width=800px height=600px border; 

title1 h=18pt "Estimated Agricultural Use of Paraquat in 2017 (EPest-High)";
footnote h=10pt c=gray77 "Data source: https://water.usgs.gov/nawqa/pnsp/usage/maps/county-level/";

proc sgmap maprespdata=my_data mapdata=my_map plotdata=state_outlines;
styleattrs datacolors=(cxffffd4 cxfed98e cxfe9929 cxd95f0e cx993404);
choromap bucket / discrete mapid=id id=id lineattrs=(thickness=0)
 tip=none;
/* overlay simple lines for the state outlines, from the plot_data */
series x=x y=y / lineattrs=(color=gray55); 
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
