%let name=cary_streetlights;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/streetlights/table
*/

/*
proc import datafile="D:\public\cary\2021\streetlights.csv" dbms=dlm out=my_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;
*/

data my_data;
infile 'D:\public\cary\2021\streetlights.csv' 
 delimiter = ';' MISSOVER DSD lrecl=3276732 firstobs=2 ;

 informat Facility_ID $8. ;
 informat Address $34. ;
 informat Location $35. ;
 informat DIS $15. ;
 informat Source $4. ;
 informat Bulb_Type $7. ;
 informat Light_Type $11. ;
 informat Pole $10. ;
 informat Fixture $13. ;
 informat Cable $11. ;
 informat Date_Verified B8601DZ35. ;
 informat last_edited_date B8601DZ35. ;
 informat Year_Added best32. ;
 informat geo_shape $82. ;
 informat geo_point_2d $28. ;

 format Facility_ID $8. ;
 format Address $34. ;
 format Location $35. ;
 format DIS $15. ;
 format Source $4. ;
 format Bulb_Type $7. ;
 format Light_Type $11. ;
 format Pole $10. ;
 format Fixture $13. ;
 format Cable $11. ;
 format Date_Verified B8601DZ35. ;
 format last_edited_date B8601DZ35. ;
 format Year_Added best12. ;
 format geo_shape $82. ;
 format geo_point_2d $28. ;

input
 Facility_ID  $
 Address  $
 Location  $
 DIS  $
 Source  $
 Bulb_Type  $
 Light_Type  $
 Pole  $
 Fixture  $
 Cable  $
 Date_Verified
 last_edited_date
 Year_Added
 geo_shape  $
 geo_point_2d  $
;

run;

data my_data; set my_data;
lat=.; lat=scan(geo_point_2d,1,',');
long=.; long=scan(geo_point_2d,2,',');
label light_type='Light Type';
label bulb_type='Bulb Type';
label cable='Cable Type';
label pole='Pole Type';
if bulb_type='' then bulb_type='Unknown';
if cable='' then cable='Unknown';
if pole='' then pole='Unknown';
if light_type='Streetight' then light_type='Streetlight';
if light_type='Streetlight' then output; /* only use the streetlight data */
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary NC - Streetlights") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 noborder; 

/* just a little sanity check (found 'Streetight' instead of 'Streetlight') */
/*
title1 j=c c=gray33 h=14pt "Streetlights in Cary NC, by light type";
proc sgplot data=my_data noborder noautolegend;
vbar light_type / stat=freq missing datalabel;
yaxis display=(noticks noline) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;
*/

proc sql noprint;
select count(*) format=comma8.0 into :count1 separated by ' ' from my_data where bulb_type^='';
select count(*) format=comma8.0 into :count2 separated by ' ' from my_data where bulb_type^='' and year_added^=.;
select count(*) format=comma8.0 into :count3 separated by ' ' from my_data where cable^='';
select count(*) format=comma8.0 into :count4 separated by ' ' from my_data where pole^='';
quit; run;

%let title2stuff= link='https://data.townofcary.org/explore/dataset/streetlights/table/'
 "Data source: https://data.townofcary.org/explore/dataset/streetlights/table/";

/* sort the data, so the color legend will be in alphabetical order */
proc sort data=my_data out=my_data;
by bulb_type;
run;

title1 j=c h=14pt "&count1 Streetlights in Cary NC, by bulb type";
title2 j=c h=10pt &title2stuff;
ods graphics / width=800px height=1100px;
ods html style=raven;
proc sgmap plotdata=my_data /*noautolegend*/;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
styleattrs datacontrastcolors=(cxFFFCCF cxff0000 cxBF5FFF cxFFCC11 cx00FFFF);
scatter x=long y=lat / group=bulb_type markerattrs=(symbol=circlefilled size=5pt) /*transparency=.50*/;
keylegend / autoitemsize;
run;
ods html style=htmlblue;

ods graphics / width=800px height=500px;
title1 j=c c=gray33 h=14pt "&count1 Streetlights in Cary NC, by bulb type";
title2 j=c c=gray77 h=10pt &title2stuff;
proc sgplot data=my_data noborder noautolegend;
styleattrs datacolors=(cxFFFCCF cxff0000 cxBF5FFF cxFFCC11 cx00FFFF);
vbar bulb_type / stat=freq group=bulb_type datalabel;
yaxis display=(noticks noline) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;

title1 j=c c=gray33 h=14pt "&count2 Streetlights in Cary NC, by year added and bulb type";
title2 j=c c=gray77 h=10pt &title2stuff;
ods graphics / width=700px height=500px;
proc sgplot data=my_data noborder;
styleattrs datacolors=(cxFFFCCF cxff0000 cxBF5FFF cxFFCC11 cx00FFFF);
vbar year_added / stat=freq group=bulb_type seglabel barwidth=.3;
yaxis display=(noticks noline) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;

proc sort data=my_data out=my_data;
by cable;
run;

title1 j=c c=gray33 h=14pt "&count3 Streetlights in Cary NC, by cable type";
title2 j=c c=gray77 h=10pt &title2stuff;
ods graphics / width=800px height=1100px;
proc sgmap plotdata=my_data /*noautolegend*/;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base";
styleattrs datacontrastcolors=(dodgerblue cxFF5721 cxFFEC8B);
scatter x=long y=lat / group=cable markerattrs=(symbol=circlefilled size=5pt /*color="red"*/);
keylegend / autoitemsize;
run;
ods graphics / width=800px height=500px;
proc sgplot data=my_data noborder noautolegend;
styleattrs datacolors=(dodgerblue cxFF5721 cxFFEC8B);
vbar cable / stat=freq group=cable datalabel barwidth=.6;
yaxis display=(noticks noline) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;

proc sort data=my_data out=my_data;
by pole;
run;

title1 j=c c=gray33 h=14pt "&count4 Streetlights in Cary NC, by pole type";
title2 j=c c=gray77 h=10pt &title2stuff;
ods graphics / width=800px height=1100px;
proc sgmap plotdata=my_data /*noautolegend*/;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base";
styleattrs datacontrastcolors=(cx9370DB green gray44 cxFFEC8B cxD43D1A);
scatter x=long y=lat / group=pole markerattrs=(symbol=circlefilled size=5pt /*color="red"*/);
keylegend / autoitemsize;
run;
ods graphics / width=800px height=500px;
proc sgplot data=my_data noborder noautolegend;
styleattrs datacolors=(cx9370DB green gray44 cxFFEC8B cxD43D1A);
vbar pole / stat=freq group=pole datalabel dataskin=pressed barwidth=.7;
yaxis display=(noticks noline) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;


/*
proc sgplot data=my_data;
scatter x=bulb_type y=date_verified / group=bulb_type;
run;
*/

proc print data=my_data (where=(/*year_added^=. and */ cable^='Unknown') obs=20); 
var Facility_ID Address Bulb_Type Light_Type Pole Cable Year_Added lat long;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
