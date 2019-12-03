/*
Run this code with a SAS job with utf8 encoding.
Such as my world.bat DOS batch job:

 u:
 cd web\proj\ne_maps
 sas.exe world.sas -config "C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\sasv9.cfg" 

*/

%let shplib=D:\Public\naturalearthdata\50m_cultural;
%let maplib=D:\Public\naturalearthdata\maps_ne;

/* import the world map of countries */
proc mapimport out=mymap
 datafile="&shplib.\ne_50m_admin_0_countries_lakes.shp";
run;

data mymap; set mymap (rename=(name=country));
run;

/* create the attribute dataset (1 obsn for each map polygon) */
data mymap_attr; 
/* declare the variables, to control the order of the columns in the dataset */
length country $25;
set mymap (drop = x y segment);
by country notsorted;
if first.country then output;
run;
proc sort data=mymap_attr out=mymap_attr;
by country;
run;

/* drop the attribute data from the map dataset (this saves a *lot* of space) */
data mymap;
set mymap (rename=(x=long y=lat) keep = country x y segment);
original_order=_n_;
run;

/* Sort by country name, but also keep the data points within the countries in the original order */
proc sort data=mymap out=mymap (drop=original_order);
by country original_order;
run;

/* Add a projected X/Y to the map */
proc gproject data=mymap out=mymap latlong eastlong degrees dupok project=cylindri;
id country;
run;

/* Add a density variable, so people can reduce the map if they want */
proc greduce data=mymap out=mymap;
id country;
run;

/* declare the variables, to control the order of the columns in the dataset */
data mymap; 
length country $25;
length segment 5;
format long lat x y comma8.2;
label long='Longitude (East)';
label lat='Latitude';
length density 4;
set mymap;
run;


/* Move the datasets into place */

/* run the sas session with utf8 encoding, so this libname defaults to utf8 */
/* This version of the _attr dataset has nls/localized country names */
libname maps_u8 "&maplib";
proc datasets lib=maps_u8;
 delete world_attr_u8;
run;
data maps_u8.world_attr_u8 (label="World countries - Source NaturalEarthData.com 2019"); 
set mymap_attr;
run;

/* drop the variables that might contain localized/nls utf8 text */
data mymap_attr; 
set mymap_attr
 (drop = NAME_AR NAME_BN NAME_CIAWF NAME_DE 
     NAME_EL NAME_EN NAME_ES NAME_FR NAME_HI NAME_HU 
     NAME_ID NAME_IT NAME_JA NAME_KO NAME_NL NAME_PL 
     NAME_PT NAME_RU NAME_SV NAME_TR NAME_VI NAME_ZH);
run;

/* use asciiany encoding, so regular (non-utf8) sas sessions can read them */
libname maps_ne "&maplib" outencoding=asciiany;

proc datasets lib=maps_ne;
 delete world;
 delete world_attr;
run;

data maps_ne.world (label="World countries - Source NaturalEarthData.com 2019"); 
set mymap;
run;
data maps_ne.world_attr (label="World countries - Source NaturalEarthData.com 2019"); 
set mymap_attr;
run;

/*
title "First 5 obs of maps_ne.world";
proc print data=maps_ne.world (obs=5); run;

title "First 5 obs of maps_ne.world_attr";
proc print data=maps_ne.world_attr (obs=5); run;

title "First 5 obs of maps_ne.world_attr_u8";
proc print data=maps_ne.world_attr_u8 (obs=5); run;
*/

