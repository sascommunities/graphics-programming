%let name=mobile_phone_market_share;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/* If the monthly share is less than this percent, it's grouped into 'Other' */
%let minshare=.03;
%let minfmtd=3%;

/*
Data downloaded from:
https://gs.statcounter.com/vendor-market-share/mobile/united-states-of-america/2010
https://gs.statcounter.com/vendor-market-share/mobile/united-states-of-america/2011
and so on...
https://gs.statcounter.com/vendor-market-share/mobile/europe/2010
https://gs.statcounter.com/vendor-market-share/mobile/china/2010
https://gs.statcounter.com/vendor-market-share/mobile/south-america/2010
*/

/* Read 1 year of data (1 csv file) for the specified location */
%macro read_loc_year(loc,location,year);

/* read in the csv file */
filename moblcsv "mobile_data/vendor-&loc.-monthly-&year.01-&year.12.csv";
proc import datafile=moblcsv out=tempdata dbms=csv replace;
getnames=yes;
guessingrows=all;
run;
proc sort data=tempdata out=tempdata;
by date;
run;

/* turn the column header names into values */
proc transpose data=tempdata out=tempdata;
by date;
run;

/* pretty up the data */
data tempdata; 
length vendor $100;
length loc $100 location $100;
loc=upcase("&loc");
location="&location";
format date date9.;
set tempdata (rename=(_name_=vendor col1=market_share));
label vendor='Vendor';
label market_share='Market Share %';
format market_share percent7.0;
market_share=market_share/100;
if market_share=0 then market_share=.;
if vendor='RIM' then vendor='RIM/Blackberry';
month=.; month=month(date);
year=.; year=year(date);
year_decimal=year(date)+(month(date)-1)/12;
/* I create my own 'Other' category */
length vendor_modified $100;
vendor_modified=vendor;
if vendor='Unknown' then vendor_modified='Other/Unknown';
if market_share<&minshare then vendor_modified='Other/Unknown';
run;

/* append this data to the main dataset */
data my_data; set my_data tempdata;
run;

%mend read_loc;


/* Read all years of data for the specified location */
%macro read_loc_all(loc,location);
%read_loc_year(&loc,&location,2010);
%read_loc_year(&loc,&location,2011);
%read_loc_year(&loc,&location,2012);
%read_loc_year(&loc,&location,2013);
%read_loc_year(&loc,&location,2014);
%read_loc_year(&loc,&location,2015);
%read_loc_year(&loc,&location,2016);
%read_loc_year(&loc,&location,2017);
%read_loc_year(&loc,&location,2018);
%read_loc_year(&loc,&location,2019);
%read_loc_year(&loc,&location,2020);
%mend read_loc_all;


/* initialize the main dataset */
data my_data;
stop;
run;

/* read in the data for each location/country/area, and append it to my_data */
%read_loc_all(US,United States);
%read_loc_all(eu,Europe);
%read_loc_all(sa,South America);
%read_loc_all(CN,China);


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Mobile Phone Market Share") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=10000
 imagefmt=png imagename="&name._#byval(loc)"
 width=1000px height=600px noborder; 

/*
I do my own summarization and plot with vbarparm,
rather than using the automatic summarization by vbar.
*/
proc sql noprint;
create table plot_data as
select unique loc, location, date, year, month, year_decimal, vendor_modified, sum(market_share) as market_share_sum
from my_data
group by loc, location, date, year, month, year_decimal, vendor_modified
/*order by loc desc, location desc, vendor_modified, year_decimal;*/ /* descending, so US is first */
order by loc, location, vendor_modified, year_decimal; /* descending, so US is first */
quit; run;


ods html anchor="#byval(loc)";

options nobyline;
title1 h=16pt c=gray33 "Mobile Phone Market Share: #byval(location)";

footnote h=9pt c=gray 
 "Data source: https://gs.statcounter.com/vendor-market-share/mobile/ (monthly values <&minfmtd grouped with 'Other')";

proc sgplot data=plot_data noborder uniform=group;
by loc location notsorted;
format year_decimal comma8.3; /* controls how bars are grouped */
format market_share_sum percent7.0;
vbarparm category=year_decimal response=market_share_sum / 
 group=vendor_modified groupdisplay=stack nooutline
 tip=(year month market_share_sum vendor_modified) 
 tipformat=(auto auto percent7.2 auto);
xaxis display=(nolabel noline) 
 type=linear  /* bar charts are usually discrete axis */
 valuesformat=best8.0   /* overrides the comma8.3 format used for grouping the bars */
 values=(2010 to 2021 by 1) /* controls which tick values are shown (default might be by 2 years) */
 offsetmin=0 offsetmax=.01; 
yaxis display=(noticks noline nolabel) offsetmax=0;
/* use refline instead of grid, to get lines in front of bars */
refline 0 .20 .40 .60 .80 1.00 / axis=y lineattrs=(thickness=1 color=blue pattern=solid);
keylegend / title=' ' position=right noborder sortorder=descending;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
