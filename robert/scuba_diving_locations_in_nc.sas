%let name=scuba_diving_locations_in_nc;
filename odsout '.';

/* 
Data mainly from ...
http://www.nc-wreckdiving.com/shipwrecks.html

Also consulted several other pages, such as...
http://www.scubadivers.ws/sites.htm
http://www.ncangler.com/forums/f4/wrightsville-beach-area-52.html
http://www.teamlivewire.com/NorthCarolinaGPS.htm
http://www.scubaboard.com/archive/index.php/t-38577.html
http://portal.ncdenr.org/web/mf/artificial-reefs-program
http://www.hotdive.com/en/divemap,map.html
http://www.divebuddy.com/divesites_search.aspx?State=NC

http://portal.ncdenr.org/c/document_library/get_file?uuid=24160156-4b96-49e6-9126-4fa488b49cbb&groupId=38337
*/

filename divedata '../democd5/dive_nc_data.txt';

data dive_data;
infile divedata lrecl=300 pad;
input whole_line $ 1-300;
length site $50 type $30 depth $20 sink_date $200;
site=scan(whole_line,1,':');
type =scan(whole_line,2,':');
latdegrees=.; latdegrees =scan(whole_line,3,':');
latminutes=.; latminutes =scan(whole_line,4,':');
longdegrees=.; longdegrees =scan(whole_line,5,':');
longminutes=.; longminutes =scan(whole_line,6,':');
depth=scan(whole_line,7,':');
sink_date=scan(whole_line,8,':');
lat=latdegrees+(latminutes/60);
/* the -1 converts westlong to eastlong */
long=-1*(longdegrees+(longminutes/60));
/* create a Google search for this diving site */
length search_link $200;
search_link='http://images.google.com/images?q='||trim(left(site))||'+scuba+diving+nc';
run;


data my_map; 
 set mapsgfk.us_counties (where=(density<=2 and statecode in ('NC' 'SC')) drop=resolution);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="North Carolina SCUBA Diving Sites") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=900px height=800 noborder; 

title1 c=gray33 h=16pt "North Carolina SCUBA Diving Sites";

/*
proc sgmap plotdata=dive_data noautolegend;
openstreetmap;
scatter x=long y=lat / markerattrs=(symbol=circlefilled size=5pt color=red);
run;
*/

proc sgmap plotdata=dive_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map";
scatter x=long y=lat / markerattrs=(symbol=circlefilled size=5pt color=red) 
 tip=none;
scatter x=long y=lat / markerattrs=(symbol=circle size=12pt color=yellow) 
 tip=(site type sink_date depth) 
 tiplabel=('Site' 'Type' 'Sank' 'Depth')
 url=search_link;
run;


data dive_data; set dive_data;
length table_link $300 href $300;
href='href='||quote(trim(left(url)));
table_link = '<a ' || trim(href) || ' target="_self">' || htmlencode(trim(site)) || '</a>';
numeric_depth=.; numeric_depth=scan(depth,1,' -f');
run;

proc sort data=dive_data out=dive_data;
by numeric_depth site;
run;

title2 h=10pt c=gray33 "Coordinates are for general location - do not rely on for navigation!";
proc print data=dive_data label noobs
 style(data)={font_size=12pt}
 style(header)={font_size=12pt}
 ; 
format lat long comma8.4;
label table_link='Dive Site/Wreck';
label type='Type';
label sink_date='Date Ship Sank';
label depth='Depth';
label lat='Approximate  Latitude';
label long='Approximate  Longitude';
var depth table_link type sink_date long lat;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
