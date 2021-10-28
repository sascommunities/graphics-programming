%let name=us_population_shift;
filename odsout '.';

%macro do_map();

proc format;
value binfmt
5 = '>= 15'
4 = '7.5 to 15'
3 = '0 to 7.5'
2 = '-7.5 to 0'
1 = '< -7.5'
;
run;

data us_data; set &mydata;
format bin binfmt.;
&myvar=round(&myvar,.1);
if &myvar<-7.5 then bin=1;
else if &myvar<0 then bin=2;
else if &myvar<7.5 then bin=3;
else if &myvar<15 then bin=4;
else if &myvar>=15 then bin=5;
run;

/* get the label position data, supplied by SAS */
data anno_labels; set mapsgfk.uscenter;
original_order=_n_;
anno_flag=1;
run;

/* merge in your response data */
proc sql noprint;
create table anno_labels as
select unique anno_labels.*, us_data.&myvar
from anno_labels left join us_data
on anno_labels.statecode=us_data.statecode
order by anno_labels.original_order;
quit; run;


/*
Do the continental US
*/
data us_map; set mapsgfk.us_states 
 (where=(density<=3 and statecode not in ('AK' 'HI' 'PR')) drop=resolution);
run;
data anno_us_labels; set anno_labels (where=(statecode not in ('AK' 'HI')));
run;
data combined; set us_map anno_us_labels;
run;
proc gproject data=combined out=combined eastlong degrees latlong dupok;
id statecode;
run;
data anno_us_labels us_map; set combined;
if anno_flag=1 then output anno_us_labels;
else output us_map;
run;


/*
Do Alaska
*/
data ak_map; set mapsgfk.us_states 
 (where=(density<=3 and statecode='AK') drop=resolution);
run;
data anno_ak_labels; set anno_labels (where=(statecode='AK'));
data combined; set ak_map anno_ak_labels;
run;
proc gproject data=combined out=combined eastlong degrees latlong dupok nodateline;
id statecode;
run;
data anno_ak_labels ak_map; set combined;
if anno_flag=1 then output anno_ak_labels;
else output ak_map;
run;
/* re-size & move Alaska */
data ak_map; set ak_map;
x=x*.40; y=y*.40;
x=x-.35; y=y+.35;
run;
data anno_ak_labels; set anno_ak_labels;
x=x*.40; y=y*.40;
x=x-.35; y=y+.35;
run;


/*
Do Hawaii
*/
data hi_map; set mapsgfk.us_states 
 (where=(statecode='HI') drop=resolution);
run;
data anno_hi_labels; set anno_labels (where=(statecode='HI'));
data combined; set hi_map anno_hi_labels;
run;
proc gproject data=combined out=combined eastlong degrees latlong dupok nodateline
 longmin=-160.5;
id statecode;
run;
data anno_hi_labels hi_map; set combined;
if anno_flag=1 then output anno_hi_labels;
else output hi_map;
run;
/* re-size & move Hawaii */
data hi_map; set hi_map;
x=x*.80; y=y*.80;
x=x-.35; y=y-.14;
run;
data anno_hi_labels; set anno_hi_labels;
x=x*.80; y=y*.80;
x=x-.35; y=y-.14;
run;



/* Now, combine the continental US, AK, and HI */
data my_map; set us_map ak_map hi_map;
run;
data anno_labels; set anno_us_labels anno_ak_labels anno_hi_labels;
run;

/* if you need to 'tweak' any positions, you could do it here ... */
data anno_labels; set anno_labels;
if statecode='HI' then x=x-abs(.05*x);
if statecode='HI' then y=y-abs(.07*y);
run;


data anno_labels; set anno_labels;
length color $12;
xsys='2'; ysys='2'; hsys='3'; when='a';
/* print the text label */
if ocean^='N' then do;
 function='label'; size=1.5;
 if ocean='Y' then do; 
  text='a0'x||trim(left(statecode))||'a0a0'x||trim(left(&myvar));
  position='>';
  output;
  end;
 else do;
  text=trim(left(statecode));
  position='b'; output;
  text=trim(left(&myvar));
  position='e'; output;
  end;
 /* position the cursor, in case you have to draw a line to the land */
 function='move'; output;
 end;
/* draw a line to the land, for certain labels in the ocean */
else do;
 function='draw'; size=.01; 
 output;
 end;
run;

/* Add a little extra space on the right, for the labels in the ocean */
title angle=-90 h=3pct ' ';

footnote;

legend1 mode=share across=1 
 position=(top right) offset=(-8pct,-2pct)
 label=(justify=center height=2.5pct font='albany amt/bold' position=top 'Percent Change')
 value=(justify=center height=1.8pct font='albany amt')
 shape=bar(.12in,.12in)
 order=descending;

pattern1 v=s c=cxf7da8c;
pattern2 v=s c=cxf0e6ca;
pattern3 v=s c=cxc7eae5;
pattern4 v=s c=cx80cdc1;
pattern5 v=s c=cx2c8a82;

proc gmap data=us_data map=my_map all anno=anno_labels;
id statecode;
note move=(30pct,72pct) font="albany amt/bold" height=3.5pct "&titltext";
choro bin / midpoints = 1 2 3 4 5
 legend=legend1
 coutline=gray99
 des='' name="&name._&lastyear";
run;


%mend do_map;


goptions device=png;
goptions xpixels=800 ypixels=675;
goptions border;
 
ODS LISTING CLOSE;
ODS html path=odsout body="&name..htm"
 (title="US Population Shift") 
 style=htmlblue;

goptions gunit=pct ftitle='albany amt/bold' ftext='albany amt' htitle=4.3 htext=2.1;

libname here '.';

%let titltext=Population % Change, 2010 to 2020;
%let mydata=here.us_data;
%let myvar=change_2020;
%let lastyear=2020;
%do_map;

%let titltext=Population % Change, 2000 to 2010;
%let mydata=sashelp.us_data;
%let myvar=change_2010;
%let lastyear=2010;
%do_map;

%let titltext=Population % Change, 1990 to 2000;
%let mydata=sashelp.us_data;
%let myvar=change_2000;
%let lastyear=2000;
%do_map;

%let titltext=Population % Change, 1980 to 1990;
%let mydata=sashelp.us_data;
%let myvar=change_1990;
%let lastyear=1990;
%do_map;

%let titltext=Population % Change, 1970 to 1980;
%let mydata=sashelp.us_data;
%let myvar=change_1980;
%let lastyear=1980;
%do_map;

%let titltext=Population % Change, 1960 to 1970;
%let mydata=sashelp.us_data;
%let myvar=change_1970;
%let lastyear=1970;
%do_map;

%let titltext=Population % Change, 1950 to 1960;
%let mydata=sashelp.us_data;
%let myvar=change_1960;
%let lastyear=1960;
%do_map;

%let titltext=Population % Change, 1940 to 1950;
%let mydata=sashelp.us_data;
%let myvar=change_1950;
%let lastyear=1950;
%do_map;

%let titltext=Population % Change, 1930 to 1940;
%let mydata=sashelp.us_data;
%let myvar=change_1940;
%let lastyear=1940;
%do_map;

%let titltext=Population % Change, 1920 to 1930;
%let mydata=sashelp.us_data;
%let myvar=change_1930;
%let lastyear=1930;
%do_map;

%let titltext=Population % Change, 1910 to 1920;
%let mydata=sashelp.us_data;
%let myvar=change_1920;
%let lastyear=1920;
%do_map;

%let titltext=Population % Change, 1900 to 1910;
%let mydata=sashelp.us_data;
%let myvar=change_1910;
%let lastyear=1910;
%do_map;




quit;
ODS HTML CLOSE;
ODS LISTING;
