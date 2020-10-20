%let name=nc_early_voting_2020;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from:
https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2016_11_08/absentee_20161108.zip 
https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2020_11_03/absentee_20201103.zip 

You could sanity-check the data a bit in the pdf reports here:
https://dl.ncsbe.gov/?prefix=Press/NC%20Absentee%20Stats%20for%202020%20General%20Election/
*/

/* 2016 Election Data */
filename csvfile "D:\Public\ncsbe\2016\absentee_20161108.csv";
proc import datafile=csvfile out=early_voting_data_2016 dbms=csv replace;
getnames=yes;
/*guessingrows=all;*/
run;
data early_voting_data_2016 (keep = voter_reg_num ballot_req_type date_2016); 
 set early_voting_data_2016 (where=(election_dt='11/08/2016' and ballot_rtn_status='ACCEPTED'));
format date_2016 date9.;
date_2016=input(ballot_rtn_dt,mmddyy10.);
run;
proc sql noprint;
create table early_voting_data_2016 as 
select unique date_2016, count(*) as daily_total_2016
from early_voting_data_2016
group by date_2016
order by date_2016;
quit; run;
data early_voting_data_2016; set early_voting_data_2016;
election_date_2016='08nov2016'd;
days_before_election=(election_date_2016-date_2016)-1;
cumulative_total_2016+daily_total_2016;
if days_before_election>=0 then output;
run;

/* 2020 Election Data */
filename csvfile "D:\Public\ncsbe\2020\absentee_20201103.csv";
proc import datafile=csvfile out=early_voting_data_2020 dbms=csv replace;
getnames=yes;
/*guessingrows=all;*/
run;
data early_voting_data_2020 (keep = voter_reg_num ballot_req_type date_2020);
 set early_voting_data_2020 (where=(election_dt='11/03/2020' and ballot_rtn_status='ACCEPTED'));
format date_2020 date9.;
date_2020=input(ballot_rtn_dt,mmddyy10.);
if date_2020<=date()-1 then output; /* some had dates in the future - probably data errors */
run;
proc sql noprint;
 create table checkit as select unique ballot_req_type, count(*) as count 
 from early_voting_data_2020 group by ballot_req_type; 
create table early_voting_data_2020 as
select unique date_2020, count(*) as daily_total_2020
from early_voting_data_2020
group by date_2020
order by date_2020;
quit; run;
data early_voting_data_2020; set early_voting_data_2020;
election_date_2020='03nov2020'd;
days_before_election=(election_date_2020-date_2020)-1;
cumulative_total_2020+daily_total_2020;
if days_before_election>=0 then output;
run;

/* Combine the 2 datasets */
data early_voting_data; set early_voting_data_2016 early_voting_data_2020;
run;


/*
Annotate the title2, so you can use non-bold text.
Since ods graphics footnote does not support url links yet,
annotate the footnote (annotated text supports url links).
*/
data anno_text;
length label $300 anchor x1space y1space function $50 textcolor $12;
layer='front';
function='text';
textcolor='gray33'; textweight='normal';
width=100; widthunit='percent';

x1space='wallpercent'; y1space='graphpercent';
anchor='center';
textsize=11;

x1=50; y1=91; 
label="Includes civilian, military, and overseas absentee ballots, and one stop early voting";
output;

x1space='graphpercent'; y1space='graphpercent';
anchor='left';
textsize=9;

x1=2; y1=10; 
label="Data sources:";
output;

textcolor='dodgerblue';
y1=y1-3;
url="https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2016_11_08/absentee_20161108.zip";
label=url;
output;

y1=y1-3;
url="https://s3.amazonaws.com/dl.ncsbe.gov/ENRS/2020_11_03/absentee_20201103.zip";
label=url;
output;

run;

/* control the default size of text, similar to "goptions htext=10pt" */
ods path(prepend) work.templat(update);
proc template;
define style styles.my_style;
parent=styles.htmlblue;
style GraphFonts from GraphFonts /
 'GraphvalueFont' = ("Arial",10pt)
 'GraphLabelFont' = ("Arial",10pt)
 ;
 end;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Early Voting in NC") 
 style=my_style;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 attrpriority=none /* so the plot marker shapes will rotate */
 imagemap tipmax=25000 
 imagefmt=png imagename="&name"
 maxlegendarea=60 ANTIALIASMAX=15600
 width=900px height=550px noborder;

title1 h=16pt c=gray33 "Early Voting in North Carolina";

/* I'm annotating the real title2 text, to get it un-bold */
/* (I could have used 'pad' instead) */
title2 h=16pt ' ';

/* I'm annotating the real footnote text, to have a url link on it */
footnote h=32pt ' ';

%let color1=cxb17fd8;
%let color2=cx92d14f;

proc sgplot data=early_voting_data sganno=anno_text noborder;

/* These labels will be used for the 'curvelabel' */
label cumulative_total_2020='2020';
label cumulative_total_2016='2016';

/* This numeric format will be used for values on the y-axis */
format cumulative_total_2020 cumulative_total_2016 comma12.0;

series y=cumulative_total_2020 x=days_before_election / 
 lineattrs=(pattern=solid thickness=2px color=&color1)
 markers markerattrs=(symbol=circle size=7pt color=&color1)
 curvelabel curvelabelattrs=(weight=bold)
 ;
series y=cumulative_total_2016 x=days_before_election / 
 lineattrs=(pattern=solid thickness=2px color=&color2)
 markers markerattrs=(symbol=square size=7pt color=&color2)
 curvelabel curvelabelattrs=(weight=bold)
 ;
yaxis display=(noline noticks)
 label='Cumulative Early Votes Cast'
 values=(0 to 3500000 by 500000)
 grid gridattrs=(pattern=dot color=gray88)
 offsetmin=0 offsetmax=0
 ;
xaxis reverse display=(noticks)
 label='Days Before Election (approximate)'
 values=(0 to 50 by 5)
 grid gridattrs=(pattern=dot color=gray88)
 offsetmin=.05 offsetmax=0
 ;
run;

/*
title2 h=12pt c=gray33 "2020 Early Votes";
proc print data=checkit label noobs; 
label ballot_req_type='Ballot Request Type';
label count='Count';
format count comma12.0;
sum count;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
