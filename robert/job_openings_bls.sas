%let name=job_openings_bls;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to graphs in this post by Leonard Kiefer:
https://twitter.com/lenkiefer/status/1115975047078907905
Here's an example of the type of R code he uses:
http://lenkiefer.com/2018/09/11/jolts-update/

Note: This data is no longer available in this location!
Using data from:
https://data.bls.gov/cgi-bin/surveymost?jt
Selected the JTS (seasonally adjusted where available)
 Total nonfarm
 Trade, transportation, and utilities
 Professional and business services
 Education and health services
 Leisure and hospitality
 Manufacturing
 State and local  (Government?)
 Construction
 Other services
 Financial activities
 Information
 Mining and logging
Retrieve data.
Changed the 'from' year to 2000
Clicked 'Go'.
Saved all 9 as .xls (remembering which spreadsheet goes to which series)
(there might be an easier way to do this...)

---

Definition of job openings rate:
https://www.bls.gov/opub/hom/pdf/jlt-20130314.pdf
"The job openings rate is computed by dividing the 
number of job openings by the sum of the number of 
people employed and the number of job openings and
multiplying the resulting quotient by 100."
*/

%macro read_data(xlsfile,survey_title);

/* Read the Excel spreadsheet */
proc import datafile="&xlsfile" dbms=xlsx out=temp_data replace;
range='BLS Data Series$a12:m0';
getnames=yes;
run;

/* turn the month columns into values */
proc transpose data=temp_data out=temp_data;
by year;
run;

/* re-name variables, after the transpose */
data temp_data; set temp_data (where=(job_openings_rate^=.) 
 rename=(_name_=month col1=job_openings_rate) drop=_label_);

/* divide by 100, so I can use % formats */
job_openings_rate=job_openings_rate/100;

/* turn the month variable names into proper date values */
date=input('15'||trim(left(month))||trim(left(year)),date9.);
length survey_title $100;

/* add a variable for the descriptive text (which you passed-in to the macro) */
survey_title="&survey_title";

/* remove rows with missing data */
if job_openings_rate^=. then output;

run;

/* and save the last (most recent) value in the 'latest' variable */
data temp_data; set temp_data;
by survey_title;
if last.survey_title then latest=job_openings_rate;
run;

/* append the temp_data to my_data */
data my_data; set my_data temp_data;
run;
%mend;


/* initialize the main dataset */
data my_data;
stop;
run;

/* Use the macro to read in all the Excel spreadsheets */
%read_data(SeriesReport-20190411072035_0b99d7.xlsx,Total nonfarm);
%read_data(SeriesReport-20190411084943_987910.xlsx,%bquote(Trade, transportation, and utilities));
%read_data(SeriesReport-20190411091327_530482.xlsx,Professional and business services);
%read_data(SeriesReport-20190411091852_3ae78c.xlsx,Education and health services);
%read_data(SeriesReport-20190411092515_a7430e.xlsx,Leisure and hospitality);
%read_data(SeriesReport-20190411092906_c269ba.xlsx,Manufacturing);
%read_data(SeriesReport-20190411093420_c2726b.xlsx,Government);
%read_data(SeriesReport-20190411094247_8b3456.xlsx,Construction);
%read_data(SeriesReport-20190411094638_8479b9.xlsx,Other services);
%read_data(SeriesReport-20190411095010_9fd34a.xlsx,Financial activities);
%read_data(SeriesReport-20190411095445_7d57c5.xlsx,Information);
%read_data(SeriesReport-20190411095643_4052a1.xlsx,Mining and logging);

/* Add a variable containing a value for the latest row for each survey */
proc sort data=my_data out=my_data;
by survey_title date;
run;
data my_data; set my_data;
by survey_title;
if last.survey_title then latest=job_openings_rate;
run;

/*
Since ods graphics footnote does not support url links yet,
annotate the footnote (annotated text supports url links).
*/
data anno_footnote;
length label $200 anchor x1space y1space function $50 textcolor $12;
function='text';
x1space='graphpercent'; y1space='graphpercent';
anchor='center';
textcolor="gray77"; textsize=10; textweight='normal';
width=100; widthunit='percent';
x1=50; y1=2.5;
url="https://data.bls.gov/cgi-bin/surveymost?jt";
label="Data source: U.S. Bureau of Labor Statistics Job Openings and Labor Turnover Survey - Downloaded 11apr2019, values through Feb 2019"; 
output;
/* let's also annotate the title2, so we can get it in normal (non-bold) text */
x1=50; y1=92.5;
url="";
textsize=10;
label="Dashed line  - - -  represents latest value (Feb 2019)"; 
output;
run;

/* Use an attribute map to get total control over what colors are used */
data myattrs;
input fillcolor $ 1-8 value $ 10-80;
linecolor=fillcolor;
id="my_id";
datalines;
cxf77c73 Construction
cxde952a Education and health services
cxbba21a Financial activities
cx89b619 Government
cx10bf44 Information
cx0ac28f Leisure and hospitality
cx0ac1c7 Manufacturing
cx04b5f0 Mining and logging
cx87b3ff Other services
cxc77dff Professional and business services
cxf56de4 Total nonfarm
cxff68b3 Trade, transportation, and utilities
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="U.S. Job Openings Rate (BLS)") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 width=1000px height=800px noborder;

title1 c=gray33 h=12pt "U.S. Job Openings Rate, by Industry";
title2 h=11pt ls=0.5 ' ';
title3 h=5pt ' ';

footnote h=8pt ' ';
/*
footnote1 c=gray77 h=8pt 
 "Data source: U.S. Bureau of Labor Statistics Job Openings and Labor Turnover Survey (JOLTs)";
*/

proc sgpanel data=my_data noautolegend dattrmap=myattrs sganno=anno_footnote;
styleattrs backcolor=white wallcolor=cxfafbfe;
panelby survey_title / columns=4 /*sort=data*/ novarname spacing=6 noborder;
/* 
I'm using a numeric format, rather than date format, so that 
I can replace the values with the valuesdisplay= option.
format date year4.;
*/
format date best12.;
band x=date lower=0 upper=job_openings_rate / fill group=survey_title 
 attrid=my_id transparency=.50 tip=none;
series x=date y=job_openings_rate / group=survey_title attrid=my_id
 tip=(year date job_openings_rate) tipformat=(auto monname3. percentn7.1) tiplabel=('Year' 'Month' 'Rate');
scatter x=date y=latest / markerattrs=(color=gray77 symbol=CircleFilled size=8px)
 tip=(year date job_openings_rate) tipformat=(auto monname3. percentn7.1) tiplabel=('Year' 'Month' 'Latest Rate');
refline latest / axis=y lineattrs=(color=gray77 pattern=shortdash);
rowaxis values=(0 to .08 by .02) display=(nolabel noline noticks) 
 valueattrs=(color=gray33) valuesformat=percent7.0
 grid offsetmin=0 offsetmax=0;
colaxis 
 values=('15jan2000'd to '15jan2020'd by year5) 
 valueattrs=(color=gray33)
 valuesdisplay=(' ' '2005' '2010' '2015' '2020')
 display=(nolabel noline noticks) grid offsetmin=0 offsetmax=0;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
