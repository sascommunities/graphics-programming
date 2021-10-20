%let name=coal_consumption;
filename odsout '.';

/* 
Data from:
https://ourworldindata.org/grapher/coal-consumption-by-country-terawatt-hours-twh
*/

data my_data;
length entity $50 code $20;
infile 'coal-consumption-by-country-terawatt-hours-twh.csv' delimiter=',' MISSOVER DSD lrecl=32767 firstobs=2;
input Entity Code Year Coal_Consumption_TWh;
if year>=1980 and code^='' and entity^='World' then output; /* get rid of the non-country groupings (with no country code) */
run;

%let top_n=6;

/* determine the minimym year, for title */
proc sql noprint;
select min(year) into :minyear separated by ' ' from my_data;
quit; run;

/* calculate the sum for each country */
proc sql noprint;
create table highest as
select unique entity, sum(Coal_Consumption_TWh) as total
from my_data
group by entity;
quit; run;

/* sort them from highest to lowest */
proc sort data=highest out=highest;
by descending total;
run;

/* get the top &top_n */
data highest; set highest (obs=&top_n);
run;


/* subset the data, only keeping the ones that are in the top/highest &top_n */
proc sql noprint;
create table my_data as
select * 
from my_data
where entity in (select unique entity from highest)
order by entity, year;
quit; run;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Coal Consumption") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 width=800px height=600 noborder; 


title1 c=gray33 h=14pt "Annual Coal Consumption in terawatt-hour (TWh) equivalents";
title2 c=gray33 h=12pt "Top &top_n countries, since &minyear";
title3 h=3pt " ";

footnote1 c=gray77 h=10pt "Data source: https://ourworldindata.org/grapher/coal-consumption-by-country-terawatt-hours-twh";

/* plot with lines */
proc sgplot data=my_data noborder;
format coal_consumption_twh comma8.0;
series x=year y=coal_consumption_twh / group=entity lineattrs=(thickness=1px pattern=solid);
yaxis display=(nolabel noline noticks) thresholdmax=1 offsetmin=0 offsetmax=0 grid gridattrs=(pattern=dot color=gray55);
xaxis display=(nolabel noline noticks) grid gridattrs=(pattern=dot color=gray55);
keylegend / position=left outerpad=(left=10pt) noborder location=inside across=1 sortorder=ascending opaque title='';

/* add markers to the lines */
proc sgplot data=my_data noborder;
format coal_consumption_twh comma8.0;
series x=year y=coal_consumption_twh / group=entity lineattrs=(thickness=1px pattern=solid)
 markers markerattrs=(size=6pt);
yaxis display=(nolabel noline noticks) thresholdmax=1 offsetmin=0 offsetmax=0 grid gridattrs=(pattern=dot color=gray55);
xaxis display=(nolabel noline noticks) grid gridattrs=(pattern=dot color=gray55);
keylegend / position=left outerpad=(left=10pt) noborder location=inside across=1 sortorder=ascending opaque title='';
run;

/* add a different marker shape to each line */
ods graphics / attrpriority=none; /* so the plot marker shapes will rotate */

proc sgplot data=my_data noborder;
format coal_consumption_twh comma8.0;
series x=year y=coal_consumption_twh / group=entity lineattrs=(thickness=1px pattern=solid)
 markers markerattrs=(size=6pt); 
yaxis display=(nolabel noline noticks) thresholdmax=1 offsetmin=0 offsetmax=0 grid gridattrs=(pattern=dot color=gray55);
xaxis display=(nolabel noline noticks) grid gridattrs=(pattern=dot color=gray55);
keylegend / position=left outerpad=(left=10pt) noborder location=inside across=1 sortorder=ascending opaque title='';
run;

/* Merge in the 'rank' so you can sort by that, to order how the bars are stacked */

data highest; set highest;
rank=_n_;
run;

proc sql noprint;
create table my_data as
select my_data.*, highest.rank
from my_data left join highest
on my_data.entity = highest.entity;
quit; run;

proc sort data=my_data out=my_data;
by descending rank;
run;

proc sgplot data=my_data noborder;
format coal_consumption_twh comma8.0;
vbarparm category=year response=coal_consumption_twh /
 group=entity groupdisplay=stack barwidth=1.0
 outlineattrs=(color=gray55);
yaxis display=(noline noticks nolabel) thresholdmax=1
 offsetmin=0 offsetmax=0 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(noline nolabel) type=linear
 grid gridattrs=(pattern=dot color=gray11);
keylegend / position=left outerpad=(left=15pt bottom=87pt) noborder
 location=inside across=1 sortorder=reverseauto opaque title='';
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
