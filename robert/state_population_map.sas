%let name=state_population_map;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

proc format;
 value popfmt
 1 = "<=10,000,000"
 2 = "10-20,000,000"
 3 = "20-30,000,000"
 4 = ">30,000,000"
 ;
run;

data state_data; set sashelp.us_data (keep = statecode population_2010);
format population_bucket popfmt.;
/* label for legend */
label population_bucket='Population range:';
/* labels for mouse-over text */
label population_2010='Population:';
label statecode='State';
if population_2010<=10000000 then population_bucket=1;
else if population_2010<=20000000 then population_bucket=2;
else if population_2010<=30000000 then population_bucket=3;
else population_bucket=4;
run;

/* sort the data, so the legend will be in the desired order */
proc sort data=state_data out=state_data;
by population_bucket;
run;


/* 
If you don't have a new enough version of SAS to support
styleattrs in sgmap, you can control the colors by 
modifying the ODS style...
*/
/*
ods path(prepend) work.templat(update);
proc template;
define style styles.pop_style;
 parent=styles.htmlblue;
 class graphcolors / 
  'gdata1'=grayf7
  'gdata2'=graycc
  'gdata3'=gray96
  'gdata4'=gray52
  ;
 end;
run;
*/

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="State Population Map")
 style=htmlblue;

ods graphics / 
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500
 imagefmt=png imagename="&name"
 width=800px height=600px;

title1 color=gray33 height=24pt "State Population in Year 2010";

proc sgmap maprespdata=state_data mapdata=mapsgfk.us;
styleattrs datacolors=(cxf7f7f7 cxcccccc cx969696 cx525252);
choromap population_bucket / discrete mapid=statecode 
 lineattrs=(thickness=1 color=cx555555)
 tip=(statecode population_2010);
keylegend / titleattrs=(size=12pt) valueattrs=(size=12pt);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
