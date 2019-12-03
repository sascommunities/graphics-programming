/*
This code loops through all the countries, and creates a 
map dataset, and _attr dataset, for each.

Run this code with a SAS job with utf8 encoding.
Such as my country.bat DOS batch job:

 u:
 cd web\proj\maps_ne
 sas.exe country.sas -config "C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\sasv9.cfg" 

*/

%let shplib=D:\Public\naturalearthdata\10m_cultural;
%let maplib=D:\Public\naturalearthdata\maps_ne;
libname maps_u8 "&maplib";
libname maps_ne "&maplib" outencoding=asciiany;

/* First, read in all the countries, and save in 'mymap' */
* import the map (this takes a while) ;
proc mapimport out=mymap
 datafile="&shplib.\ne_10m_admin_1_states_provinces_lakes.shp";
run;

data mymap; set mymap (rename=(admin=country name=state_province));
dataset_name=lowcase(trim(left(adm0_a3)));
run;

* create the attribute dataset (1 obsn for each map polygon) ;
* declare the variables, to control the order of the columns in the dataset ;
data mymap_attr; 
length country $25;
set mymap (drop = x y segment);
by country gn_a1_code notsorted;
if first.gn_a1_code then output;
run;
proc sort data=mymap_attr out=mymap_attr;
by country state_province;
run;

* drop the attribute data from the map dataset (this saves a *lot* of space) ;
* (this reduces it from 3.3GB to 160MB) ;
data mymap; 
set mymap (rename=(x=long y=lat) keep = country state_province gn_a1_code x y segment dataset_name);
original_order=_n_;
run;

* Sort by country name, but also keep the data points within the countries in the original order ;
proc sort data=mymap out=mymap (drop=original_order);
by country state_province gn_a1_code original_order;
run;

* Save the datasets with all the countries, in case you want to work with a saved copy later;
data maps_ne.mymap; set mymap;
data maps_ne.mymap_attr; set mymap_attr;
/*
*/

/*-----------------------------------------------------------------*/

/* you could comment out the above code, and work with the saved copy,
   if you're changing/trouble-shooting the code. */
/*
data mymap; set maps_ne.mymap;
data mymap_attr; set maps_ne.mymap_attr;
*/


options mprint source source2;
%macro do_one(name3, proj);

data &name3 (drop=dataset_name); set mymap (where=(dataset_name="&name3"));
run;
data &name3._attr (drop=dataset_name); set mymap_attr (where=(dataset_name="&name3"));
run;

/* Add a projected X/Y to the map */
proc gproject data=&name3 out=&name3 latlong eastlong degrees dupok project=&proj;
id gn_a1_code;
run;

/* Use the 'nodateline' option for Russia, since it crosses the date line */
%if "%UPCASE(&name3)" eq "RUS"  %then %do;
 proc gproject data=&name3 out=&name3 latlong eastlong degrees dupok project=&proj nodateline;
 id gn_a1_code;
 run;
 %end;

/* Use the 'nodateline' option for USA, since it crosses the date line */
%if "%UPCASE(&name3)" eq "USA" %then %do;
 proc gproject data=&name3 out=&name3 latlong eastlong degrees dupok project=&proj nodateline;
 id gn_a1_code;
 run;
 %end;

/* Use a special proj.4 for Antarctica */
%if "%UPCASE(&name3)" eq "ATA" %then %do;
 proc gproject data=&name3 out=&name3 latlong eastlong degrees dupok /*project=&proj*/
  latmax=-64 to="EPSG:3031";
 id gn_a1_code;
 run;
 %end;


/* Add a density variable, so people can reduce the map if they want */
proc greduce data=&name3 out=&name3;
id gn_a1_code;
run;

/* declare the variables, to control the order of the columns in the dataset */
data &name3;
length country $25;
length state_province $44;
length gn_a1_code $10;
length segment 5;
format long lat x y comma8.2;
label state_province='State or Province';
label long='Longitude (East)';
label lat='Latitude';
length density 4;
set &name3;
run;

/* Get the country name, to stuff into the dataset label */
proc sql noprint;
select unique country into :cname separated by ' ' 
from &name3._attr;
quit; run;

/* Move the datasets into place */

/* run the sas session with utf8 encoding, so this libname defaults to utf8 */
proc datasets lib=maps_u8;
 delete &name3._attr_u8;
run;
data maps_u8.&name3._attr_u8 (label="&cname - Source NaturalEarthData.com 2019"); set &name3._attr;
run;

/* drop the variables that might contain localized/nls utf8 text */
data &name3._attr; set &name3._attr
 (drop = NAME_AR NAME_BN NAME_DE 
     NAME_EL NAME_EN NAME_ES NAME_FR NAME_HI NAME_HU 
     NAME_ID NAME_IT NAME_JA NAME_KO NAME_NL NAME_PL 
     NAME_PT NAME_RU NAME_SV NAME_TR NAME_VI NAME_ZH);
run;

proc datasets lib=maps_ne;
 delete &name3;
 delete &name3._attr;
run;

/* use asciiany encoding when you set up the libname (outencoding=asciiany), 
 so regular & utf8 sas sessions can read them */
data maps_ne.&name3 (label="&cname - Source NaturalEarthData.com 2019"); set &name3;
run;
data maps_ne.&name3._attr (label="&cname - Source NaturalEarthData.com 2019"); set &name3._attr;
run;

%mend;


/* Loop through the countries, and generate the country maps & _attr datasets */
proc sql noprint;
 create table loopdata as
 select unique dataset_name, country
 from mymap_attr;
quit; run;
data loopdata; set loopdata;
length projection $20;
projection='mercator';
if country in ('Ecuador') then projection='cylindri';
run;
data _null_; set loopdata
 /*
 (where=(dataset_name in ('and')))
 (where=(dataset_name in ('rus' 'usa')))
 (where=(country in ('Afghanistan' 'El Salvador' 'Ecuador')))
 */
 ;
 call execute('%do_one('|| dataset_name ||', '|| projection ||');');
run;

