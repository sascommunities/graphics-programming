%let name=closest_us_state_to_africa;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Verifying comment from:
https://www.reddit.com/r/MapPorn/comments/n6wvrv/brazils_northernmost_point_is_closer_to_every/
"Maine is the US state closest to Africa"
*/

data states; 
length id $100;
set mapsgfk.us_states (where=(density<=1 and statecode not in ('AK' 'HI')) drop = x y);
id=fipnamel(stfips(statecode));
run;

data africa; 
length id $100;
set mapsgfk.africa (where=(density<=1 and idname^=('Cape Verde')) drop = x y);
id=idname;
run;

data both_maps; 
label id='ID';
set states africa;
run;

/* create some 'response data' to plot on the map */
proc sql noprint;
create table both_attr as
select unique id
from both_maps;
quit; run;

/* 
Create dataset with all combinations of points along US state borders,
to all points along Africa country borders.
*/
proc sql noprint;
create table distances as
select unique 
 states.id as id_from, states.lat as lat_from, states.long as long_from,
 africa.id as id_to, africa.lat as lat_to, africa.long as long_to
from states, africa;
quit; run; 

/* Calculate the geodetic distance (in miles) between each pair of points. */
data distances; set distances (where=(lat_from^=. and long_from^=. and lat_to^=. and long_to^=.));
distance_miles=geodist(lat_from, long_from, lat_to, long_to, 'DM');
run;
 
/* 
Determine which pair of points is the shortest distance apart, 
and structure the data so I can plot a line for that distance
to overlay on the map.
*/
proc sort data=distances out=distances;
by distance_miles;
run;
data shortest; set distances (obs=1);
lat=lat_from; long=long_from; output;
lat=lat_to; long=long_to; output;
run;

/* Pull some data out of the dataset, and store in macro variables, to use in title2 */
proc sql noprint;
select unique id_from into :id_from separated by ' ' from shortest;
select unique id_to into :id_to separated by ' ' from shortest;
select unique distance_miles format=comma8.0 into :dist separated by ' ' from shortest;
quit; run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US State Closest to Africa")
 style=htmlblue;

ods graphics / 
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 imagemap tipmax=2500
 width=900px height=600px;

title1 color=gray33 height=20pt "Closest US State to African Continent";
title2 "&id_from to &id_to = &dist miles";

proc sgmap maprespdata=both_attr mapdata=both_maps plotdata=shortest noautolegend;
openstreetmap;
choromap id / discrete mapid=id lineattrs=(thickness=1 color=gray88);
series x=long y=lat / lineattrs=(color=red);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
