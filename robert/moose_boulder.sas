%let name=moose_boulder;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Visualization of geography discussed here:
https://www.atlasobscura.com/articles/moose-boulder-debunked
Lake Superior
 Isle Royale
  Lake Siskiwit 
   Ryan Island
    Moose Flats
     Moose Boulder
*/

data my_data;
x_lat=48.0088000; x_long=-88.7720000;
input description $ 1-14 ll_lat ll_long ur_lat ur_long;
datalines;
Lake Superior  46.3542 -92.9504 49.0539 -83.3559
Isle Royale    47.8147 -89.2564 48.2134 -88.4282
Lake Siskiwit  47.9724 -88.8769 48.0258 -88.7325
Ryan Island    48.0068 -88.7780 48.0123 -88.7658
;
run;

data my_data; set my_data; 
length drillurl $150;
label drillurl='Drill to';
if description='Lake Superior' then drillurl='#Isle_Royale';
if description='Isle Royale' then drillurl='#Lake_Siskiwit';
if description='Lake Siskiwit' then drillurl='#Ryan_Island';
if description='Ryan Island' then drillurl="https://www.google.com/maps/place/48%C2%B000'31.7%22N+88%C2%B046'19.2%22W/@48.0088056,-88.7741887,17z/data=!3m1!4b1!4m5!3m4!1s0x0:0x0!8m2!3d48.0088056!4d-88.772";
run;


ODS LISTING CLOSE;
ODS html path=odsout body="&name..htm"
 (title="Drill Down to Moose Flats and Moose Boulder") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=800px height=600px noborder; 

title1 h=16pt c=gray33 "Lake Superior - largest freshwater lake in the world by area";
title2 h=14pt c=gray33 ls=0.5 "Red 'x' marks location of Isle Royale";
ods html anchor='Lake_Superior';
proc sgmap plotdata=my_data (where=(description="Lake Superior")) noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map";
scatter x=x_long y=x_lat / markerattrs=(symbol=X size=12pt color="red") url=drillurl tip=(drillurl);
scatter x=ll_long y=ll_lat / transparency=1 tip=none;
scatter x=ur_long y=ur_lat / transparency=1 tip=none;
run;

title1 h=16pt c=gray33 "Isle Royale - largest island in Lake Superior";
title2 h=14pt c=gray33 ls=0.5 "Red 'x' marks location of Lake Siskiwit";
ods html anchor='Isle_Royale';
proc sgmap plotdata=my_data (where=(description="Isle Royale")) noautolegend;
Openstreetmap;
scatter x=x_long y=x_lat / markerattrs=(symbol=X size=12pt color="red") url=drillurl tip=(drillurl);
scatter x=ll_long y=ll_lat / transparency=1 tip=none;
scatter x=ur_long y=ur_lat / transparency=1 tip=none;
run;

title1 h=16pt c=gray33 "Lake Siskiwit - largest lake on Isle Royale";
title2 h=14pt c=gray33 ls=0.5 "Red 'x' marks location of Ryan Island";
ods html anchor='Lake_Siskiwit';
proc sgmap plotdata=my_data (where=(description="Lake Siskiwit")) noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps";
scatter x=x_long y=x_lat / markerattrs=(symbol=X size=12pt color="red") url=drillurl tip=(drillurl);
scatter x=ll_long y=ll_lat / transparency=1 tip=none;
scatter x=ur_long y=ur_lat / transparency=1 tip=none;
run;

title1 h=16pt c=gray33 "Ryan Island - largest island in Lake Siskiwit";
title2 h=14pt c=gray33 ls=0.5 "Red 'x' marks location of (debunked) 'Moose Flats' seasonal pond";
ods html anchor='Ryan_Island';
proc sgmap plotdata=my_data (where=(description="Ryan Island")) noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Imagery";
scatter x=x_long y=x_lat / markerattrs=(symbol=X size=12pt color="red") url=drillurl tip=(drillurl);
scatter x=ll_long y=ll_lat / transparency=1 tip=none;
scatter x=ur_long y=ur_lat / transparency=1 tip=none;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
