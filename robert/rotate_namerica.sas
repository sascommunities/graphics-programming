%let name=rotate_namerica;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Creating something similar to:
https://www.reddit.com/r/MapPorn/comments/oj37p8/united_states_map_upside_down/
*/


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Rotated North America")
 style=htmlblue;

ods graphics / noborder
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 imagemap tipmax=2500
 width=800px height=800px;

data namerica; set mapsgfk.namerica (where=(density<=2) drop=resolution);
length unique_id $20;
unique_id=trim(left(id))||'_'||trim(left(segment));
run;

proc gproject data=namerica out=namerica latlong eastlong degrees nodateline
 latmax=55
 latmin=12
 longmin=-130
 longmax=-60
 project=cylindri
 parmout=projparm;
id id;
run;

title1 color=gray33 height=20pt "Unprojected Map long / lat Coordinates";
title2 color=gray33 height=12pt "chopped to the area of interest";
proc sgplot data=namerica;
scatter y=lat x=long / markerattrs=(size=3px color=brown symbol=circlefilled);
run;

title1 color=gray33 height=20pt "Projected Map X / Y Coordinates";
title2 color=gray33 height=12pt "projection=cylindri (plotted as polygons)";
proc sgplot data=namerica;
polygon y=y x=x id=unique_id / fill fillattrs=(color=cornsilk) outline lineattrs=(color=brown);
refline 0 / axis=x lineattrs=(color=gray77);
refline 0 / axis=y lineattrs=(color=gray77);
run;


/* Center of rotation = Walmart headquarters: Bentonville, Arkansas */
%let latcenter=36.4;
%let longcenter=-94.2;
/* Create a dataset with the desired lat/long center of rotation */
data center;
 lat=.; lat=&latcenter;
 long=.; long=&longcenter;
run;
/* Project it the same as the map */
proc gproject data=center out=center latlong eastlong degrees nodateline
 parmin=projparm parmentry=namerica;
id;
run;
/* Save the projected x/y values in macro variables, to use later */
data center; set center;
call symput ('x_center', x);
call symput ('y_center', y);
run;

/* Re-center the map, on the projected x/y (derived from the desired lat/long center) */
data namerica; set namerica;
x=x-&x_center;
y=y-&y_center;
run;

title1 color=gray33 height=20pt "Projected Map X / Y Coordinates";
title2 color=gray33 height=12pt "Re-centered on lat/long (&latcenter,&longcenter)";
proc sgplot data=namerica;
polygon y=y x=x id=unique_id / fill fillattrs=(color=cornsilk) outline lineattrs=(color=brown);
refline 0 / axis=x lineattrs=(color=gray77);
refline 0 / axis=y lineattrs=(color=gray77);
run;

%let angle=30;
data namerica; set namerica;
/* Remember, SAS sin() and cos() functions only work on radians, not degrees */
angle_radians=&angle*(constant("pi")/180);
/* Using equation from https://matthew-brett.github.io/teaching/rotation_2d.html */
x_rotated=cos(angle_radians)*x - sin(angle_radians)*y;
y_rotated=sin(angle_radians)*x + cos(angle_radians)*y;
run;

title1 color=gray33 height=20pt "Projected Map X / Y Coordinates";
title2 color=gray33 height=12pt "Rotated &angle degrees counter-clockwise";
proc sgplot data=namerica;
polygon y=y_rotated x=x_rotated id=unique_id / fill fillattrs=(color=cornsilk) outline lineattrs=(color=brown);
refline 0 / axis=x lineattrs=(color=gray77);
refline 0 / axis=y lineattrs=(color=gray77);
run;

%let angle=180;
data namerica; set namerica;
/* Remember, SAS sin() and cos() functions only work on radians, not degrees */
angle_radians=&angle*(constant("pi")/180);
/* Using equation from https://matthew-brett.github.io/teaching/rotation_2d.html */
x_rotated=cos(angle_radians)*x - sin(angle_radians)*y;
y_rotated=sin(angle_radians)*x + cos(angle_radians)*y;
run;

title1 color=gray33 height=20pt "Projected Map X / Y Coordinates";
title2 color=gray33 height=12pt "Rotated &angle degrees";
proc sgplot data=namerica;
polygon y=y_rotated x=x_rotated id=unique_id / fill fillattrs=(color=cornsilk) outline lineattrs=(color=brown);
refline 0 / axis=x lineattrs=(color=gray77);
refline 0 / axis=y lineattrs=(color=gray77);
run;

/* Overwrite the normal x/y with the rotated x/y */
data namerica; set namerica (drop=lat long);
x=x_rotated;
y=y_rotated;
run;

title1 color=gray33 height=20pt "SGMap of North America";
title2 color=gray33 height=12pt "Rotated &angle degrees";
proc sgmap mapdata=namerica maprespdata=mapsgfk.namerica_attr noautolegend;
choromap idname / mapid=id lineattrs=(thickness=1 color=gray88)
 tip=(idname);
run;

/* Find the x/y center of each country */
%annomac;
%centroid(namerica,namerica_labels,id idname,segonly=1);

data namerica_labels; set namerica_labels 
 (where=(idname in (
  'Canada' 
  'United States' 
  'Mexico' 
  'Cuba' 
  )));
run;

title1 color=gray33 height=20pt "Map of North America";
title2 color=gray33 height=12pt "Rotated &angle degrees";
proc sgmap mapdata=namerica maprespdata=mapsgfk.namerica_attr noautolegend 
 plotdata=namerica_labels;
choromap idname / mapid=id lineattrs=(thickness=1 color=gray88)
 tip=(idname);
text x=x y=y text=idname / textattrs=(size=14pt);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
