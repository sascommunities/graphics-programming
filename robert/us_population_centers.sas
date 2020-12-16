%let name=us_population_centers;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Creating a map similar to:
https://www.reddit.com/r/MapPorn/comments/kdwrw5/population_centers_of_each_us_state_from_19002010/

Using data copy-n-pasted from:
https://www.census.gov/geographies/reference-files/time-series/geo/centers-population/historical-by-year.2010.html
*/

/* Get Rick Langston's code to read in a table from a web page */
%inc '../democd101/readhtml4.sas';

%macro read_data(name,year);

%readhtml2(
 "https://www.census.gov/geographies/reference-files/time-series/geo/centers-population/historical-by-year.&year..html"
 );

data &name (keep = statename year lat long); 
 set table1 (rename=(col1=statename col2=lat_string col3=lon_string) where=(statename^='')); 
year=.; year=&year;

lat_string=tranwrd(lat_string,'c2b0'x,' ');
lat_string=tranwrd(lat_string,'e280b2'x,' ');
lat_string=tranwrd(lat_string,'e280b3'x,' ');
lat_deg=.; lat_deg=scan(lat_string,1,' ');
lat_min=.; lat_min=scan(lat_string,2,' ');
lat_sec=.; lat_sec=scan(lat_string,3,' ');
lat=lat_deg+(lat_min/60)+(lat_sec/60/60);

lon_string=tranwrd(lon_string,'c2b0'x,' ');
lon_string=tranwrd(lon_string,'e280b2'x,' ');
lon_string=tranwrd(lon_string,'e280b3'x,' ');
lon_deg=.; lon_deg=scan(lon_string,1,' ');
lon_min=.; lon_min=scan(lon_string,2,' ');
lon_sec=.; lon_sec=scan(lon_string,3,' ');
long=lon_deg+(lon_min/60)+(lon_sec/60/60);
long=-1*long;

if lat^=. and long^=. then output;
run;

%mend read_data;

%read_data(data_1900,1900);
%read_data(data_1910,1910);
%read_data(data_1920,1920);
%read_data(data_1930,1930);
%read_data(data_1940,1940);
%read_data(data_1950,1950);
%read_data(data_1960,1960);
%read_data(data_1970,1970);
%read_data(data_1980,1980);
%read_data(data_1990,1990);
%read_data(data_2000,2000);
%read_data(data_2010,2010);

data my_data; set 
 data_1900
 data_1910
 data_1920
 data_1930
 data_1940
 data_1950
 data_1960
 data_1970
 data_1980
 data_1990
 data_2000
 data_2010
 ;
run;

proc sort data=my_data out=my_data;
by statename year;
run;

data my_data_cont my_data_ak my_data_hi; set my_data;
if statename not in ('Alaska' 'Hawaii' 'District of Columbia') then output my_data_cont;
if statename='Alaska' then output my_data_ak;
if statename='Hawaii' then output my_data_hi;
run;

data my_map_cont my_map_ak my_map_hi; set mapsgfk.us_states;
if statecode not in ('AK' 'HI' 'DC') then output my_map_cont;
if statecode='AK' then output my_map_ak;
if statecode='HI' then output my_map_hi;
run;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US Population Centers") 
 style=htmlblue;

options center;
ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 border; 

footnote1 h=10pt c=gray77 "Data source: https://www.census.gov/geographies/reference-files/time-series/geo/centers-population/historical-by-year.2010.html";

/* -------------------------------------------------------------- */

/* Do the main map of the 48 contiguous states */

/* project the map */
proc gproject data=my_map_cont out=my_map_cont latlong eastlong degrees dupok
 parmout=projparm;
id statecode;
run;

/* project the point data using the same projection parameters */
proc gproject data=my_data_cont out=my_data_cont latlong eastlong degrees dupok
 parmin=projparm parmentry=my_map_cont;
id;
run;

/* create a special variable for the circle at the end of the line */
data my_data_cont; set my_data_cont;
if year=2010 then do;
 x_2010=x;
 y_2010=y;
 end;
run;

title1 h=16pt "State Population Center Shift (1900-2010)";

ods graphics / width=1000px height=675px;
proc sgmap mapdata=my_map_cont (drop=lat long) plotdata=my_data_cont (drop=lat long) noautolegend;
choromap / discrete mapid=statecode lineattrs=(color=graydd thickness=1px) tip=none;
scatter x=x y=y / markerattrs=(color=gray33 symbol=circlefilled size=4px) tip=(statename year);
series x=x y=y / group=statename lineattrs=(pattern=solid color=dodgerblue thickness=2px) tip=none;
scatter x=x_2010 y=y_2010 / markerattrs=(color=red symbol=circle size=10px) tip=none;
run;


/* -------------------------------------------------------------- */
/* Do Alaska */

proc gproject data=my_map_ak out=my_map_ak latlong eastlong degrees dupok
 parmout=projparm;
id statecode;
run;

proc gproject data=my_data_ak out=my_data_ak latlong eastlong degrees dupok
 parmin=projparm parmentry=my_map_ak;
id;
run;

data my_data_ak; set my_data_ak;
if year=2010 then do;
 x_2010=x;
 y_2010=y;
 end;
run;

proc sql noprint; select min(year) into :minyear separated by ' ' from my_data_ak; quit; run;
title1 h=16pt "Alaska Population Center Shift (&minyear-2010)";
footnote;

ods graphics / width=600px height=500px;
proc sgmap mapdata=my_map_ak (drop=lat long) plotdata=my_data_ak (drop=lat long) noautolegend;
choromap / discrete mapid=statecode lineattrs=(color=graybb thickness=1px) tip=none;
scatter x=x y=y / markerattrs=(color=gray33 symbol=circlefilled size=4px) tip=(statename year);
series x=x y=y / group=statename lineattrs=(pattern=solid color=dodgerblue thickness=2px) tip=none;
scatter x=x_2010 y=y_2010 / markerattrs=(color=red symbol=circle size=10px) tip=none;
run;

/* -------------------------------------------------------------- */
/* Do Hawaii */

proc gproject data=my_map_hi out=my_map_hi latlong eastlong degrees dupok
 longmin=-160.3667035  /* get rid of the small far-western islands */
 parmout=projparm;
id statecode;
run;

proc gproject data=my_data_hi out=my_data_hi latlong eastlong degrees dupok
 parmin=projparm parmentry=my_map_hi;
id;
run;

data my_data_hi; set my_data_hi;
if year=2010 then do;
 x_2010=x;
 y_2010=y;
 end;
run;

proc sql noprint; select min(year) into :minyear separated by ' ' from my_data_hi; quit; run;
title1 h=16pt "Hawaii Population Center Shift (&minyear-2010)";
footnote;

ods graphics / width=600px height=500px;
proc sgmap mapdata=my_map_hi (drop=lat long) plotdata=my_data_hi (drop=lat long) noautolegend;
choromap / discrete mapid=statecode lineattrs=(color=graybb thickness=1px) tip=none;
scatter x=x y=y / markerattrs=(color=gray33 symbol=circlefilled size=4px) tip=(statename year);
series x=x y=y / group=statename lineattrs=(pattern=solid color=dodgerblue thickness=2px) tip=none;
scatter x=x_2010 y=y_2010 / markerattrs=(color=red symbol=circle size=10px) tip=none;
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
