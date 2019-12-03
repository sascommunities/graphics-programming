%let name=naturalearth_world;

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

Below, I plot the world map...
*/

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="naturalearthdata.com world map") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=1200px height=600px noborder; 

libname maps_ne 'maps_ne';

title1 color=gray33 height=18pt "naturalearthdata.com world map (excluding Antarctica)";

proc sgmap mapdata=maps_ne.world maprespdata=maps_ne.world_attr_u8 (where=(country^='Antarctica'));
label country='Country';
label continent='Main continent of country';
choromap continent / mapid=country
 /* 
 You must have 9.4m6a or higher, to use the tip= option 
 You must be running SAS with utf8 encoding for the other languages to show up right 
 sdssas -dms -t dev/mva-v940m6a -box laxno -lang u8 -encoding utf-8 naturalearth_world.sas
 */
 tip=(continent country name_de name_fr name_es name_zh name_ja name_ko name_ar name_ru)
 ;
run;

title "naturalearth.com world map - list of countries";
proc print data=here.world_attr_u8; 
run;

/* 
If you want French Guiana to appear as its own country,
rather than part of France, you could do something like this ...
*/
/*
data world; set here.world;
if country='France' and (lat<7 and lat>0) and (long<-51 and long>-58) then do;
 country='French Guiana';
 continent='South America';
 end;
run;
data extras;
country='French Guiana'; continent='South America'; output;
run;
data world_attr_u8; set here.world_attr_u8 extras;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
