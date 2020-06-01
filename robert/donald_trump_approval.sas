%let name=donald_trump_approval;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Inspired by:
https://projects.fivethirtyeight.com/trump-approval-ratings/

Using data from:
https://github.com/fivethirtyeight/data/tree/master/trump-approval-ratings
https://projects.fivethirtyeight.com/trump-approval-data/approval_polllist.csv

License info:
https://github.com/fivethirtyeight/data/blob/master/LICENSE
(Creative Commons, commercial use, modification, etc)
*/

/* ran this proc once, then copied the generated code from the log file... */
/*
PROC IMPORT OUT=my_data DATAFILE="approval_polllist.csv" DBMS=CSV REPLACE;
GETNAMES=YES;
DATAROW=2;
guessingrows=all;
RUN;
*/

filename csvurl url "https://projects.fivethirtyeight.com/trump-approval-data/approval_polllist.csv";
/*
filename csvurl "../democd101/approval_polllist.csv";
*/

data my_data;
infile csvurl delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;
informat president $12. ;
informat subgroup $9. ;
informat modeldate mmddyy10. ;
informat startdate mmddyy10. ;
informat enddate mmddyy10. ;
informat pollster $52. ;
informat grade $2. ;
informat samplesize best32. ;
informat population $2. ;
informat weight best32. ;
informat influence best32. ;
informat approve best32. ;
informat disapprove best32. ;
informat adjusted_approve best32. ;
informat adjusted_disapprove best32. ;
informat multiversions $2. ;
informat tracking $2. ;
informat url $282. ;
informat poll_id best32. ;
informat question_id best32. ;
informat createddate mmddyy10. ;
informat timestamp $20. ;
format president $12. ;
format subgroup $9. ;
format modeldate date9. ;
format startdate date9. ;
format enddate date9. ;
format pollster $52. ;
format grade $2. ;
format samplesize best12. ;
format population $2. ;
format weight best12. ;
format influence best12. ;
format approve best12. ;
format disapprove best12. ;
format adjusted_approve best12. ;
format adjusted_disapprove best12. ;
format multiversions $2. ;
format tracking $2. ;
format url $282. ;
format poll_id best12. ;
format question_id best12. ;
format createddate date9. ;
format timestamp $20. ;
input
 president  $
 subgroup  $
 modeldate
 startdate
 enddate
 pollster  $
 grade  $
 samplesize
 population  $
 weight
 influence
 approve
 disapprove
 adjusted_approve
 adjusted_disapprove
 multiversions  $
 tracking  $
 url  $
 poll_id
 question_id
 createddate
 timestamp  $
;
run;

/*
Their data seems to have 'duplicate' entries for some polls,
with variations for 'All polls', 'Adults', 'Voters', etc.
*/
data my_data; set my_data (where=(subgroup='All polls')
 drop = modeldate grade weight influence adjusted_approve adjusted_disapprove
 multiversions tracking createddate timestamp);
run;

%let min=100;

proc sql noprint;
create table my_data as
select *, count(enddate) as count
from my_data
group by pollster
having count(enddate)>=&min
;
quit; run;

proc sort data=my_data out=my_data;
by pollster enddate;
run;

data my_data; set my_data;
format approve_pct percent7.0;
approve_pct=approve/100;
run;

data my_data; set my_data;
by pollster;
/*
if last.pollster then datelabel=lowcase(put(enddate,date9.))||'a0a0'x;
*/
if last.pollster then datelabel=trim(left(put(enddate,monname3.)))||' '||trim(left(put(enddate,day.)))||'a0a0'x;
run;


data anno_milestones;
length position $1;
input date date9. position text $ 12-80;
datalines;
20jan2017 a Trump sworn into office
27jan2017 d First travel ban executive order
07apr2017 a Placed Gorsuch on Supreme Court
13apr2017 d MOAB bombs dropped on ISIS targets
01jun2017 a Withdrew from Paris Climate Agreement
08aug2017 a Fire and Fury threat to North Korea
23aug2017 a Veterans Appeal / Improv / Modern Act
05sep2017 a Ending DACA
22sep2017 a Trump condemns NFL player protests
17dec2017 a Recognized Jerusalem as capital of Israel
22dec2017 4 Repealed Obamacare individual mandate
01jan2018 d Tax cuts for 2018      
30jan2018 a First state-of-union address
11apr2018 a Bill to shut down sex-trafficking websites
30apr2018 a Black unemployment hit record low 6.6%
01may2018 d Unemployment below 4%
12jun2018 a Peace agreement with North Korea
21jul2018 a Threatens Iran the likes of which few...
30sep2018 a Replaced NAFTA with USMCA
06oct2018 d Placed Kavanaugh on Supreme Court
22dec2018 a Government shutdown started
25jan2019 a Government shutdown ended
24mar2019 a No Russian collusion
20jun2019 a Announces 2020 campaign in Orlando
30jun2019 d Trump walks into North Korea
03sep2019 a Trump funds the wall
18sep2019 d Whistleblower / Russia phone call
13nov2019 a Impeachment hearings start
18dec2019 a House votes impeachment
03jan2020 a Trump bombs Soleimani
05feb2020 a Impeachment acquittal
14mar2020 a Coronavirus hits US  
28may2020 a Race protests/riots  
;
run;

data anno_milestones; set anno_milestones;
length label $300 anchor x1space y1space x2space y2space function textcolor $50;

layer='back';
x1space='datavalue'; y1space='wallpercent';
x2space='datavalue'; y2space='wallpercent';

function='line'; linepattern='dot'; linecolor='dodgerblue'; linethickness=1;
x1=date; y1=0; x2=date; y2=100;
output;

function='text'; textcolor='dodgerblue'; textsize=8; textweight='normal';
width=100; widthunit='percent'; 
label=trim(left(text));
x1=date; y1=99;
anchor='right'; rotate=90;
if position='a' then x1=x1-6;
if position='d' then x1=x1+7;
if position='4' then x1=x1+2;
output;

run;



ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Donald Trump Approval Rating") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=10000 
 imagefmt=png imagename="&name"
 width=1500px height=600px noborder; 

options nobyline;
title1 c=gray33 h=16pt "Donald Trump's Approval Rating";
title2 c=gray99 h=14pt ls=0.5 "Data source: #byval(pollster) (#byval(count) polls)";

ods html anchor="#byval(pollster)";

proc sgplot data=my_data noborder nowall noautolegend sganno=anno_milestones;
format enddate year4.;
by pollster count;
series y=approve_pct x=enddate / 
 markers markerattrs=(color=hotpink)
 lineattrs=(color=hotpink)
 tip=(pollster startdate enddate subgroup approve_pct samplesize)
 tipformat=(auto date9. date9. auto percent7.2 comma8.0);
text y=approve_pct x=enddate text=datelabel / 
 position=bottomleft rotate=90 textattrs=(color=gray33);
yaxis display=(nolabel noline noticks) 
 values=(0 to 1 by .25)
 valueattrs=(color=gray44 size=11pt)
 offsetmin=0 offsetmax=0
 grid;
xaxis display=(nolabel noline)
 values=('01jan2017'd to '01jan2021'd by year)
 valueattrs=(color=gray44)
 offsetmin=0 offsetmax=0;
refline .50 / 
 axis=y lineattrs=(color=gray55 thickness=1px pattern=solid);
refline '01jan2017'd / 
 axis=x lineattrs=(color=graycc thickness=1px pattern=solid);
refline '01jan2021'd / 
 axis=x lineattrs=(color=graycc thickness=1px pattern=solid);
run;

title2 c=gray99 h=14pt ls=0.5 "Polsters with at least 100 polls during this time period";

ods html anchor="all";

proc sgplot data=my_data noborder nowall noautolegend sganno=anno_milestones;
format enddate year4.;
scatter y=approve_pct x=enddate / group=pollster 
 tip=(pollster startdate enddate subgroup approve_pct samplesize)
 tipformat=(auto date9. date9. auto percent7.2 comma8.0);
keylegend / location=inside position=bottomleft across=1 opaque;
yaxis display=(nolabel noline noticks)
 values=(0 to 1 by .25)
 valueattrs=(color=gray44 size=11pt)
 offsetmin=0 offsetmax=0
 grid;
xaxis display=(nolabel noline)
 values=('01jan2017'd to '01jan2021'd by year)
 valueattrs=(color=gray44)
 offsetmin=0 offsetmax=0;
refline .50 /
 axis=y lineattrs=(color=gray55 thickness=1px pattern=solid);
refline '01jan2017'd /
 axis=x lineattrs=(color=graycc thickness=1px pattern=solid);
refline '01jan2021'd /
 axis=x lineattrs=(color=graycc thickness=1px pattern=solid);
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
