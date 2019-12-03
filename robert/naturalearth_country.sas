%let name=naturalearth_country;

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

Below, I plot the Australia map, as an example ...
*/


%let country=Australia;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="naturalearthdata.com &country map") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=800px height=600px noborder; 

libname maps_ne 'maps_ne';

title1 c=gray33 h=18pt "naturalearthdata.com &country map";
title2 c=gray33 "excluding Macquarie Island and Lord Howe Island";

proc sgmap mapdata=maps_ne.aus maprespdata=maps_ne.aus_attr_u8 
 (where=(state_province not in ('Macquarie Island' 'Lord Howe Island')));
choromap state_province / mapid=state_province
 /*
 You must have 9.4m6a or higher, to use the tip= option
 You must be running SAS with utf8 encoding for the other languages to show up right
 sdssas -dms -t dev/mva-v940m6a -box laxno -lang u8 -encoding utf-8 naturalearth_country.sas
 */
 tip=(state_province name_de name_fr name_es name_zh name_ja name_ko name_ar name_ru)
 ;
run;

title "&country state/province response data data";
proc print data=maps_ne.aus_attr; run;

quit;
ODS HTML CLOSE;
ODS LISTING;
