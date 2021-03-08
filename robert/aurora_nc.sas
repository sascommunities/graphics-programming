%let name=aurora_nc;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Shapefiles:
https://co.beaufort.nc.us/downloads/gis/gis-data
*/

/* import the shapefile with all the land parcels, and data/info */
proc mapimport datafile="D:\Public\beaufort_county\Parcels.shp" out=county_map;
run;

/* township is the city (city is the city portion of address of the owner) */
data city_map; set county_map (where=(township='13'));
run;

/* This 'deprojects' the X/Y's back to regular lat/long */
proc gproject data=city_map out=city_map from="EPSG:2264" to="EPSG:4326";
id;
run;

/* eliminate one 'outlier' parcel (probably an error) way to the north */
data city_map; set city_map (where=(y<=35.33));
run;

/* create some response data */
proc sql noprint;
create table my_mapdata as
select unique gpinlong, tot_val, calcacres, name1, name2, prop_addr, township, 
 condition, road_type, roof_mater, sq_ft, use_desc, utility, wall, yr_built,
 avg(x) as long_center, avg(y) as lat_center
from city_map
group by gpinlong;
quit; run;

/* add labels for mouse-over text, and create drill-down url */
data my_mapdata; set my_mapdata;

label gpinlong='Parcel ID';
label tot_val='Value';
label prop_addr='Address';
label use_desc='Use';
label wall='Wall material';
label yr_built='Year built';
label roof_mater='Roof material';
/* convert from character to numeric square ft, so I can apply the comma format */
format sq_ft_num comma8.0;
sq_ft_num=.; sq_ft_num=sq_ft;
label sq_ft_num='Square ft';
label condition='Condition';
label calcacres='Acres';
label road_type='Road type';
label utility='Utilities';
label name1='Owner';
label name2='Owner 2';
label township='Township';
format tot_val dollar10.0;

/* 
Both Google maps and Zillow had trouble finding "Main st ex" (extension?),
but could find the addresses without the 'ex', therefore removing the 'ex' part.
*/
prop_addr=tranwrd(prop_addr,'MAIN ST EX','MAIN ST');

/* create urls to use for the drill-down, when you click the parcels */
length lookup_link $300;
if use_desc in ('SINGLE FAMILY RESIDENCE' 'MOBILE HOME' 'MODULAR HOMES') then
 lookup_link='https://www.zillow.com/homes/for_sale/'||translate(lowcase(trim(left(prop_addr))),'-',' ')||',-aurora,-nc_rb/';
else
 lookup_link='https://www.google.com/maps/@'||trim(left(lat_center))||','||trim(left(long_center))||',20z';
landcolor="foo";
run;


data my_mapdata; set my_mapdata;
label yr_built_range='Year built:';
length yr_built_range $20;
if yr_built=. then yr_built_range='NA';
else if yr_built<=1900 then yr_built_range='1800-1900';
else if yr_built<=1950 then yr_built_range='1901-1950';
else if yr_built<=1999 then yr_built_range='1951-1999';
else if yr_built>=2000 then yr_built_range='2000s';
else yr_built_range='NA';
run;

/* sort the data, so the colors will be assigned in the logical order */
proc sort data=my_mapdata out=my_mapdata;
by yr_built_range yr_built;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Properties in Aurora, NC") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 drilltarget="_self"
 imagefmt=png imagename="&name" noborder;
ods graphics / width=1200px height=1000px; 

title1 c=gray33 h=22pt "Properties in Aurora, NC (March 2021 snapshot)";

/* draw the parcel polygons, shaded by age of house, overlaid on a tile-based map */

proc sgmap mapdata=city_map maprespdata=my_mapdata;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base";
styleattrs datacolors=(cxd7191c cxfdae61 cxa6d96a cx1a9641 cxefefef);
choromap yr_built_range / mapid=gpinlong lineattrs=(color=cx333333)
 tip=(gpinlong prop_addr tot_val yr_built use_desc wall roof_mater sq_ft_num calcacres name1 name2)
 url=lookup_link;
keylegend / titleattrs=(size=14) valueattrs=(size=14);
run;

/* Create a couple of alternate versions of the map */

/* satellite image version */
proc sgmap mapdata=city_map maprespdata=my_mapdata noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Imagery";
styleattrs datacolors=(yellow);
choromap landcolor / mapid=gpinlong transparency=.7 lineattrs=(color=red)
 tip=(gpinlong prop_addr tot_val yr_built use_desc wall roof_mater sq_ft_num calcacres name1 name2)
 url=lookup_link;
run;

/* topo map version */
proc sgmap mapdata=city_map maprespdata=my_mapdata noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps";
styleattrs datacolors=(yellow);
choromap landcolor / mapid=gpinlong transparency=.7 lineattrs=(color=red)
 tip=(gpinlong prop_addr tot_val yr_built use_desc wall roof_mater sq_ft_num calcacres name1 name2)
 url=lookup_link;
run;


/* print a table of the data */

/* convert the url to something that will be an active link in the html table */
data my_mapdata; set my_mapdata;
length link $300 href $300;
href='href='||quote(trim(left(lookup_link)));
link = '<a ' || trim(href) || ' target="_self">' || htmlencode(trim(prop_addr)) || '</a>';
run;

proc print data=my_mapdata label
 style(data)={font_size=10pt}
 style(header)={font_size=10pt};
label link='Address';
format calcacres comma8.1;
var yr_built link gpinlong tot_val use_desc wall roof_mater sq_ft_num calcacres name1 name2;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
