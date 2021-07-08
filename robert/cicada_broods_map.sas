%let name=cicada_broods_map;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
https://www.reddit.com/r/dataisbeautiful/comments/o8o9j3/oc_periodical_cicada_emergences_from_1900_2100/
https://www.fs.fed.us/foresthealth/docs/CicadaBroodStaticMap.pdf
*/


%include 'cicada_data.sas';

/* cbn = Color for Brood 'n' */
%let cb1=cx3371b9;
%let cb2=cxff3333;
%let cb3=cx868686;
%let cb4=cxb9b933;
%let cb5=cx8d69a1;
%let cb6=cxb93333;
%let cb7=cxff33d1;
%let cb8=cx33ebba;
%let cb9=cxffbb33;
%let cb10=cxffff33;
%let cb13=cx8f7033;
%let cb14=cx70eb33;
%let cb19=cx8fc1ff;
%let cb22=cxff9999;
%let cb23=cx708f33;

/* multiple simultaneous broods */
%let cmult=black;
/* outline color for counties (potentially) with cicadas */
%let coutline=gray55;
/* outline color for counties with no cicadas */
%let cempty=graydd;


/* create text version of brood (brood=8 produces brood_roman='Brood XIII') */
data cicada_data; set cicada_data;
length brood_roman $20;
brood_roman='Brood '||trim(left(put(brood,roman.)));
run;


data county_map; set mapsgfk.us_counties (where=(statecode not in ('HI' 'AK') and density<=2));
original_order=_n_;
run;
/* re-project, without Hawaii & Alaska, to get the look I want */
proc gproject data=county_map out=county_map latlong eastlong degrees;
id state county;
run;
/* after projecting, then remove the west coast states (again, to get the look I want) */
data county_map; set county_map (where=(statecode not in ('CA' 'OR' 'WA' 'NV' 'AZ' 'ID' 'MT' 'WY' 'UT' 'CO' 'NM')));
run;
/* create response data for this subset */
proc sql noprint;
create table county_data as
select *
from mapsgfk.us_counties_attr
where id in (select unique id from county_map);
quit; run;
data county_data; set county_data;
length my_html $100;
my_html='title='||quote(
 trim(left(statecode))||'0d'x||
 trim(left(county)));
fake=1;
run;

/* get map polygons for just the counties that are in a brood */
proc sql noprint;
create table anno_county_outlines as
select *
from county_map
where id in (select unique id from cicada_data)
order by original_order;
quit; run;

/* convert the map polygons to annotate polygons, of the desired color */
data anno_county_outlines; set anno_county_outlines;
by id segment;
length function $8 color $20 style $30;
xsys='2'; ysys='2'; hsys='3'; when='a';
style='empty'; color="&coutline";
if first.segment then function='poly';
else function='polycont';
run;


proc gremove data=county_map out=anno_state_outlines;
by state; 
id county;
run;
data anno_state_outlines; set anno_state_outlines; 
by state segment notsorted;
length function $8 color $8 style $30;
style='empty'; when='a'; xsys='2'; ysys='2';
color='gray88'; 
color='black'; 
if first.segment then function='poly';
else function='polycont';
run;


/* 
Create the choro colors annotate dataset for this brood, 
and append it to anno_color_polygons.
*/
options mprint source;
%macro create_color_overlay(brood);

data this_brood_counties; set cicada_data (where=(brood=&brood));
run;

/* get map polygons for just the counties in this brood */
proc sql noprint;
create table temp_map as
select *
from county_map
where id in (select unique id from this_brood_counties)
order by original_order;
quit; run;

/* convert the map polygons to annotate polygons, of the desired color */
data temp_map; set temp_map;
by id segment;
length function $8 color $20 style $30;
xsys='2'; ysys='2'; hsys='3'; when='a';
style='solid';
if first.segment then function='poly';
else function='polycont';
color='pink';  /* default color - should never show up */
if &brood=1 then color="&cb1";
if &brood=2 then color="&cb2";
if &brood=3 then color="&cb3";
if &brood=4 then color="&cb4";
if &brood=5 then color="&cb5";
if &brood=6 then color="&cb6";
if &brood=7 then color="&cb7";
if &brood=8 then color="&cb8";
if &brood=9 then color="&cb9";
if &brood=10 then color="&cb10";
if &brood=11 then color="black"; /* extinct */
if &brood=12 then color="black"; /* extinct */
if &brood=13 then color="&cb13";
if &brood=14 then color="&cb14";
if &brood=19 then color="&cb19";
if &brood=22 then color="&cb22";
if &brood=23 then color="&cb23";
run;

/* append this annotate dataset to the main one */
data anno_color_polygons; set anno_color_polygons temp_map;
run;

%mend create_color_overlay;



%macro do_all;

/* input brood cycle example_year; */

data temp_data; set cicada_data;
test='y';
run;

/* add a count variable to show how many active broods in each county right now */
proc sql noprint;
create table temp_data as
select unique *, count(*) as count
from temp_data
group by id;
quit; run;

proc sql noprint;
create table active_broods as
select unique brood, brood_roman
from temp_data;
quit; run;

/*
We're going to annotate the county choro colors as polygons, so we can overlap them.
Call this macro for each brood that's active this year, and append its 
anno_color_polygons dataset to the main annotate dataset...
*/
/* initialize the dataset, with zero observations */
data anno_color_polygons;
length id $20;
stop; 
run;
/* for each active brood, generate the colored county polygons, and append them to anno_color_polygons */
data _null_; set active_broods;
 call execute('%create_color_overlay('|| brood ||');');
run;

/* For the counties with multiple simultaneous broods, create a hatch-pattern polygon, rather than solid color fill */
data anno_color_polygons; set anno_color_polygons;
original_order=_n_;
run;
/* merge in the 'count' of how many simultaneous broods in each county */
proc sql noprint;
create table anno_color_polygons as
select anno_color_polygons.*, temp_data.count
from anno_color_polygons left join temp_data
on anno_color_polygons.id=temp_data.id
order by original_order;
quit; run;
data anno_mult_polygons; set anno_color_polygons (where=(count>1));
color='black';
run;


data anno_legend;
length function $8 style $30 text $100;
xsys='3'; ysys='3'; hsys='3'; when='a';
function='label'; size=1.5;
linespace=2.1;
y_anchor=39;

x=87; position='6';
y=y_anchor;    text='Brood I (2029)'; output;
y=y-linespace; text='Brood II (2030)'; output;
y=y-linespace; text='Brood III (2031)'; output;
y=y-linespace; text='Brood IV (2032)'; output;
y=y-linespace; text='Brood V (2033)'; output;
y=y-linespace; text='Brood VI (2034)'; output;
y=y-linespace; text='Brood VII (2035)'; output;
y=y-linespace; text='Brood VIII (2036)'; output;
y=y-linespace; text='Brood IX (2037)'; output;
y=y-linespace; text='Brood X (2021)'; output;
y=y-linespace; text='Brood XIII (2024)'; output;
y=y-linespace; text='Brood XIV (2025)'; output;
y=y-linespace;
y=y-(linespace/2);
y=y-linespace; text='Brood XIX (2024)'; output;
y=y-linespace; text='Brood XXII (2027)'; output;
y=y-linespace; text='Brood XXIII (2028)'; output;
y=y-(linespace/2);
y=y-linespace; text='Multiple'; output;

y=y_anchor+linespace; x=84.5; text='17-Year Cicadas'; style='albany amt/bold'; output;
y=y_anchor-12.5*linespace; x=84.5; text='13-Year Cicadas'; style='albany amt/bold'; output;

/* color chicklets */
text='';
style='solid';
color="&cb1"; function='poly'; x=84.5; y=y_anchor-(linespace/3); output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb2"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb3"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb4"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb5"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb6"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb7"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb8"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb9"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb10"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb13"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb14"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
y=y-linespace;
y=y-(linespace/2);
color="&cb19"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb22"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
color="&cb23"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
y=y-(linespace/2);
color="&cmult"; function='poly'; x=84.5; y=y-linespace; output; function='polycont'; x=x+1.5; output; y=y+1.2; output; x=x-1.5; output; y=y-1.2; output;
run;

/* draw outlines around the legend color chicklets */
data anno_legend_outlines; set anno_legend (where=(index(function,'poly')^=0));
style='empty'; color="&coutline";
run;



title;
footnote;
/* title1 ls=1.5 "Cicada Broods in the US"; */
data anno_title;
length function $8 style $30 text $100;
xsys='3'; ysys='3'; hsys='3'; when='a';
function='label'; 
/*
x=68; y=95; position='5'; size=4.0; color='gray33'; style='albany amt/bold';
*/
x=30; y=12; position='6'; size=4.0; color='gray33'; style='albany amt/bold';
text="Cicada Broods the US"; output;
x=50; y=2.0; position='5'; size=1.5; color='gray77'; style='albany amt';
text="Based on: https://www.fs.fed.us/foresthealth/docs/CicadaBroodStaticMap.pdf"; output;
run;

data anno_all; 
length function $8 color $20 style $30;
 set 
 anno_title 
 anno_color_polygons anno_mult_polygons 
 anno_county_outlines anno_state_outlines 
 anno_legend anno_legend_outlines;
run;

legend1 position=(bottom right) across=1 label=(position=top) mode=share;

/* 
Make the actual map polygond with broods white, and then annotate the colors later 
(so you can overlay multiple transparent colors, etc) 
*/
pattern1 v=s c=cornsilk;
pattern1 v=s c=white;


proc gmap data=county_data map=county_map all anno=anno_all;
id statecode county;
choro fake / nolegend
 /*coutline=dodgerblue*/ /* outline color for counties */
 coutline=&cempty /* outline color for counties in general (ovarlaid later with cicada county outlines) */
/*
 html=my_html
*/
 des='' name="&name";
run;

%mend do_all;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" (title="US Cicada Broods") style=minimal;
goptions gunit=pct htitle=5 htext=3.0 ftitle="albany amt/bold" ftext="albany amt";
goptions ctext=gray33 border;
/*
goptions device=png;
*/
goptions xpixels=950 ypixels=850;

%do_all();

quit;
ODS HTML CLOSE;
ODS LISTING;
