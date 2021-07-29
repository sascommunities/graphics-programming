%let name=us_annual_deaths;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
2015
https://www.cdc.gov/nchs/products/databriefs/db267.htm
2016
https://www.cdc.gov/nchs/products/databriefs/db293.htm
2017
https://www.cdc.gov/nchs/products/databriefs/db328.htm
2018
https://www.cdc.gov/nchs/products/databriefs/db355.htm
2019
https://www.cdc.gov/nchs/products/databriefs/db395.htm
2020 (provisional)
https://www.cdc.gov/mmwr/volumes/70/wr/mm7014e1.htm
*/

data deaths_data;
format deaths comma10.0;
length link $100;
input year deaths rate_per_100k;
input link;
datalines;
2015 2712630 733.1
https://www.cdc.gov/nchs/products/databriefs/db267.htm
2016 2744248 728.8
https://www.cdc.gov/nchs/products/databriefs/db293.htm
2017 2813503 731.9
https://www.cdc.gov/nchs/products/databriefs/db328.htm
2018 2839205 723.6
https://www.cdc.gov/nchs/products/databriefs/db355.htm
2019 2854838 715.2
https://www.cdc.gov/nchs/products/databriefs/db395.htm
2020 3358814 828.7
https://www.cdc.gov/mmwr/volumes/70/wr/mm7014e1.htm
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Annual US Deaths") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=800px height=600px noborder; 

data anno_note;
length label $100 anchor x1space y1space textweight $50;
layer="front";
function="text"; textcolor="red"; textweight='bold'; 
textsize=80; transparency=.65; rotate=45;
width=130; widthunit='percent'; 
anchor='center'; 
x1space='datapercent';
y1space='datapercent'; 
x1=50;
y1=55;
label="Bad Graph"; 
run;

title1 c=gay33 h=18pt "US Annual Deaths";
proc sgplot data=deaths_data (where=(year<2020)) noborder sganno=anno_note;
vbarparm category=year response=deaths / url=link;
yaxis display=(noline noticks nolabel) 
 values=(2650000 to 2850000 by 50000) offsetmax=.10
 grid gridattrs=(pattern=dot color=gray88);
xaxis display=(noticks nolabel);
run;

data anno_note; set anno_note;
label="Less Bad";
run;

title1 c=gay33 h=18pt "US Annual Deaths";
proc sgplot data=deaths_data (where=(year<2020)) noborder sganno=anno_note;
vbarparm category=year response=deaths / url=link;
yaxis display=(noline noticks nolabel) grid gridattrs=(pattern=dot color=gray88);
xaxis display=(noticks nolabel);
run;

data anno_note; set anno_note;
label="Good Graph";
run;

title1 c=gay33 h=18pt "US Annual Death Rate per 100,000 Population";
proc sgplot data=deaths_data (where=(year<2020)) noborder sganno=anno_note;
vbarparm category=year response=rate_per_100k / url=link;
yaxis display=(noline noticks nolabel) 
 values=(0 to 800 by 200)
 grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;



footnote c=gray "Data source: cdc.gov (note: 2020 data is provisional, as of 09apr2021)";

title1 c=gay33 h=18pt "US Annual Deaths";
proc sgplot data=deaths_data noborder;
vbarparm category=year response=deaths / url=link; 
yaxis display=(noline noticks nolabel) grid gridattrs=(pattern=dot color=gray88);
xaxis display=(noticks nolabel);
run;

title1 c=gay33 h=18pt "US Annual Death Rate per 100,000 Population";
title2 h=10pt 'a0'x;
proc sgplot data=deaths_data noborder;
vbarparm category=year response=rate_per_100k / url=link;
yaxis display=(noline noticks nolabel) grid gridattrs=(pattern=dot color=gray55);
xaxis display=(noticks nolabel);
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
