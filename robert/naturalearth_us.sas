%let name=naturalearth_us;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
People with just Base SAS (not SAS/Graph) have access to Proc SGMap,
but they don't have the SAS mapsgfk library (since that only ships
with SAS/Graph). One alternative they might have for obtaining
free map polygon files might be https://www.naturalearthdata.com

These maps have a very friendly terms-of-use
http://www.naturalearthdata.com/about/terms-of-use/
(you're basically free to use them any way you want!)

This is a special version of the US map, where I have projected/moved/resized
Hawaii & Alaska to be like the old SAS maps.us
*/


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="naturalearthdata.com US map") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=800px height=600px noborder; 

libname maps_ne 'maps_ne';

title1 c=gray33 h=18pt "naturalearthdata.com US map";

proc sgmap mapdata=maps_ne.us maprespdata=maps_ne.us_attr;
choromap state_name / mapid=statecode
 /*
 You must have 9.4m6a or higher, to use the tip= option
 You must be running SAS with utf8 encoding for the other languages to show up right
 sdssas -dms -t dev/mva-v940m6a -box laxno naturalearth_us.sas
 */
 tip=(state statecode state_name)
 ;
run;

title "maps_ne.us_attr";
proc print data=maps_ne.us_attr; run;

quit;
ODS HTML CLOSE;
ODS LISTING;
