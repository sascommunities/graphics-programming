%let name=us_2020_census_apportionments;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using Census data from:
https://www.census.gov/data/tables/2020/dec/2020-apportionment-data.html
Specifically:
https://www2.census.gov/programs-surveys/decennial/2020/data/apportionment/apportionment-2020-table01.xlsx
*/

/* Import the census data */
proc import
 file="apportionment-2020-table01.xlsx"
 out=my_data (rename=(
  state=state_name 
  var2=apport_population 
  NUMBER_OF_APPORTIONED_REPRESENTA=reps 
  CHANGE_FROM___2010_CENSUS_APPORT=change_reps))
 dbms=xlsx replace;
getnames=yes;
range='Table 1$A4:D54';
run;

/* Merge in the 2-character state code for each state_name */
proc sql noprint;
create table my_data as
select unique my_data.*, us_data.statecode
from my_data left join sashelp.us_data
on my_data.state_name=us_data.statename;
quit; run;

/* Create dataset of the labels to overlay */
data my_labels; set my_data (where=(change_reps^=0));
length change_reps_text $10;
if change_reps>0 then change_reps_text='+'||trim(left(change_reps));
else change_reps_text=trim(left(change_reps));
run;
/* Get the projected x/y centroid, that match up with the mapsgfk.us */
proc sql noprint;
create table my_labels as
select unique my_labels.*, uscenter.x, uscenter.y
from my_labels left join mapsgfk.uscenter
on my_labels.statecode=uscenter.statecode;
quit; run;

/* get the map polygons, excluding DC */
data my_map; set mapsgfk.us (where=(statecode^='DC'));
run;

/* sort the data (this can affect the order of the colors) */
proc sort data=my_data out=my_data;
by change_reps;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="2020 Census Apportionments")
 style=htmlblue;

ods graphics / 
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 imagemap tipmax=2500
 width=900px height=600px;

title1 color=gray33 height=20pt "State Apportionment Changes, based on 2020 Census";

proc sgmap maprespdata=my_data mapdata=my_map plotdata=my_labels noautolegend;
styleattrs datacolors=(cxfdbf6f white cxb2df8a cx33a02c);
choromap change_reps / discrete mapid=statecode lineattrs=(thickness=1 color=gray88)
 tip=(state_name reps change_reps);
text x=x y=y text=change_reps_text / position=center 
 textattrs=(color=gray33 size=14pt weight=bold) tip=none;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
