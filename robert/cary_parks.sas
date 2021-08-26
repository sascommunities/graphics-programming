%let name=cary_parks;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/parks-and-recreation-feature-map/table/
https://data.townofcary.org/explore/dataset/greenway-trails/table/
*/

proc import datafile="D:\public\cary\2021\parks-and-recreation-feature-map.csv" dbms=dlm out=park_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;

data park_data; set park_data;
park_lat=.; park_lat=scan(geo_point_2d,1,',');
park_long=.; park_long=scan(geo_point_2d,2,',');
run;

/*
SAS maps must have a numeric segment variable, to identify multiple 'segments' within an id.
But this shapefile also has a 'segment' variable (with the text name of the trail).
Therefore I have to use the rename option to rename the text segment to 'segment_name'
so Proc Mapimport will be able to run.
*/
proc mapimport datafile="D:\public\cary\2021\greenway-trails.shp" out=trail_data contents;
rename segment=segment_description;
run;

/* add a 'density' variable you can use to reduce the resolution */
proc greduce data=trail_data out=trail_data;
id name segment_description segment status;
run;
data trail_data; set trail_data (where=(density<=2));
run;

data trail_data; set trail_data (rename=(x=trail_long y=trail_lat) where=(status^=''));
by name segment_description segment status notsorted;
output;
/* insert a blank 'missing' between each segment, so the pen will be lifted when drawing the series line */
if last.name or last.segment_description or last.segment or last.status then do;
 trail_long=.;
 trail_lat=.;
 output;
 end;
run;

data combined_data; set park_data trail_data;
run;

/* Attribute map, to control the colors in the park markers, and trails, in the map */
data myattrs;
length value $100 markercolor linecolor $12 linepattern $20;
id="some_id";
value='No'; markercolor='cxe7298a'; linecolor=markercolor; output;
value='Yes'; markercolor='cx76EE00'; linecolor=markercolor; output;
markercolor='';
value='Existing'; linecolor='cxff7f00'; linepattern='solid'; output;
value='Proposed'; linecolor='cxfdb462'; linepattern='shortdash'; output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Parks and Trails") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=25000
 imagefmt=png imagename="&name"
 noborder; 
ods graphics / width=900px height=1000px;

/* put this in a variable, so I don't have to re-type it so many times */
%let title2stuff= link='https://data.townofcary.org/pages/homepage/'
 h=10pt c=gray77 "Data source: https://data.townofcary.org/pages/homepage/ (August 2021)";

title1 h=18pt c=gray33 "Cary NC Parks";
title2 &title2stuff;

ods html anchor='parks';
proc sgmap plotdata=park_data noautolegend dattrmap=myattrs;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
/* draw a solid marker at each park */
scatter x=park_long y=park_lat / group=restrooms_available attrid=some_id
 markerattrs=(symbol=circlefilled size=5pt) tip=none name='bathroom';
/* draw a bubble/circle around each park, with the size representing the size of the park */
bubble x=park_long y=park_lat size=size_of_park / bradiusmin=3px bradiusmax=25px outline
 group=restrooms_available attrid=some_id
 tip=(name_of_facility full_address operational_days operational_hours size_of_park restrooms_available)
 url=website;
keylegend 'bathroom' / title='Has bathroom?' autoitemsize;
run;

title1 h=18pt c=gray33 "Cary NC Parks and Trails";
title2 &title2stuff;

/* Add the Existing trails (but don't show the Proposed trails) */
ods html anchor='existing';
proc sgmap plotdata=combined_data (where=(status^='Proposed')) noautolegend dattrmap=myattrs;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
/* draw the trails */
series x=trail_long y=trail_lat / group=status nomissinggroup attrid=some_id 
 tip=(name) /*tip=none*/ name='trails';
/* overlay the parks (so they're visually "on top" of the trails */
scatter x=park_long y=park_lat / group=restrooms_available nomissinggroup attrid=some_id
 markerattrs=(symbol=circlefilled size=5pt) tip=none name='bathroom';
bubble x=park_long y=park_lat size=size_of_park / bradiusmin=3px bradiusmax=25px outline 
 group=restrooms_available attrid=some_id
 tip=(name_of_facility full_address operational_days operational_hours size_of_park restrooms_available)
 url=website;
keylegend 'bathroom' / title='Has bathroom?' autoitemsize;
keylegend 'trails' / title='Trails:';
run;

title1 h=18pt c=gray33 "Cary NC Parks, Trails, and Proposed Trails";
title2 &title2stuff;

/* Show existing and proposed trails */
ods html anchor='proposed';
proc sgmap plotdata=combined_data noautolegend dattrmap=myattrs;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
/* draw the trails */
series x=trail_long y=trail_lat / group=status nomissinggroup attrid=some_id tip=(name) /*tip=none*/ name='trails';
/* overlay the parks (so they're visually "on top" of the trails */
scatter x=park_long y=park_lat / group=restrooms_available nomissinggroup attrid=some_id
 markerattrs=(symbol=circlefilled size=5pt) tip=none name='bathroom';
bubble x=park_long y=park_lat size=size_of_park / bradiusmin=3px bradiusmax=25px outline
 group=restrooms_available attrid=some_id
 tip=(name_of_facility full_address operational_days operational_hours size_of_park restrooms_available)
 url=website;
keylegend 'bathroom' / title='Has bathroom?' autoitemsize;
keylegend 'trails' / title='Trails:';
run;

/* ------------------------------------- */

proc sort data=park_data out=park_data;
by Name_of_Facility;
run;

/* Encode the html links into the proc print table data */
data park_data; set park_data;
length name_link address_link href $300;
href='href='||quote(trim(left(website)));
name_link = '<a ' || trim(href) || ' target="_self">' || trim(left(Name_of_Facility)) || '</a>';
href='href='||quote('https://www.google.com/maps/place/'||trim(left(full_address)));
address_link = '<a ' || trim(href) || ' target="_self">' || trim(left(full_address)) || '</a>';
run;

/* User-defined format, to control the background color in the table, for Restrooms Available */
/* (use the same colors you used for the parks on the map markers) */
proc format;
 value $nfmt 
 'No' = 'cxe7298a'
 'Yes' = 'cx76EE00'
 ;
run;

title1 h=16pt c=gray33 "Cary NC Parks";
title2 &title2stuff;

ods html anchor='table';
proc print data=park_data label
 style(data)={font_size=10pt}
 style(header)={font_size=10pt};
label name_link='Name of Facility';
label address_link='Address';
label Operational_Days='Operational Days';
label Size_of_Park='Size of Park';
label Restrooms_Available='Restrooms Available';
var name_link;
var Restrooms_Available / style(data)=Header{background=$nfmt.};
var address_link Operational_Days Operational_Hours Size_of_Park;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
