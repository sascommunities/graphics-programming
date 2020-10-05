%let name=nc_voter_timeseries;
filename odsout '.';

/*
Plotting release data from this page:
https://vt.ncsbe.gov/RegStat/
*/

libname here '.';

%let colord=blue;   /* democrat */
%let colorr=red;    /* republican */
%let coloru=cx756bb1; /* unaffiliated */
%let colorl=orange; /* libertarian */

%macro read_data(my_date);

/*
filename rel_url url "http://vt.ncsbe.gov/Voter_Stats/results.aspx?date=&my_date";
*/
filename rel_url url "https://vt.ncsbe.gov/RegStat/Results/?date=&my_date";

data temp;
length whole_line $1000;
infile rel_url lrecl=32000 pad dlm='{}';
input whole_line @@;
if index(whole_line,'"CountyName":')^=0 and index(whole_line,'"Totals"')=0 then output;
run;

data temp (drop = whole_line); set temp;

format date date9.;
date=input("&my_date",mmddyy10.);

length county $50;
county=trim(left(propcase(translate(scan(scan(whole_line,1,','),2,':'),'','"'))));
if county='Mcdowell' then county='McDowell';

Democrats=.;
Democrats=scan(scan(whole_line,2,','),2,':');

Republicans=.;
Republicans=scan(scan(whole_line,3,','),2,':');

Libertarians=.;
Libertarians=scan(scan(whole_line,4,','),2,':');

Green=.;
Green=scan(scan(whole_line,5,','),2,':');

Constitution=.;
Constitution=scan(scan(whole_line,6,','),2,':');

Unaffiliated=.;
Unaffiliated=scan(scan(whole_line,7,','),2,':');

Total=.;
Total=scan(scan(whole_line,-1,','),2,':');

run;

data voter_data; set voter_data temp;
format democrats republicans libertarians unaffiliated comma12.0;
if date^=. then output;
run;

%mend;


/*
Read in each monthly snapshot of the old data, and append it to 'voter_data'
(I use the earliest date from each month, when there are many to choose from.)
Then save it in a permanent dataset (voter_data_old) so you 
won't have to read in all these again.
It took about three minutes 15 seconds to read all the data.
*/

data voter_data; 
run;

/*
%read_data(01/01/2004);
%read_data(05/01/2004);

%read_data(01/01/2005);

%read_data(01/01/2006);
%read_data(04/01/2006);

%read_data(06/02/2007);
%read_data(09/29/2007);

%read_data(01/05/2008);
%read_data(03/01/2008);
%read_data(08/30/2008);
%read_data(10/04/2008);
%read_data(11/04/2008);
%read_data(11/29/2008);
%read_data(12/27/2008);

%read_data(01/03/2009);
%read_data(02/07/2009);
%read_data(03/07/2009);
%read_data(04/04/2009);
%read_data(05/02/2009);
%read_data(06/06/2009);
%read_data(07/04/2009);
%read_data(08/02/2009);
%read_data(09/05/2009);
%read_data(10/03/2009);
%read_data(11/03/2009);
%read_data(12/05/2009);

%read_data(01/02/2010);
%read_data(02/06/2010);
%read_data(03/06/2010);
%read_data(04/03/2010);
%read_data(05/01/2010);
%read_data(06/05/2010);
%read_data(07/03/2010);
%read_data(08/07/2010);
%read_data(09/04/2010);
%read_data(10/02/2010);
%read_data(11/02/2010);
%read_data(12/04/2010);

%read_data(01/01/2011);
%read_data(02/05/2011);
%read_data(03/05/2011);
%read_data(04/02/2011);
%read_data(05/07/2011);
%read_data(06/04/2011);
%read_data(07/02/2011);
%read_data(08/06/2011);
%read_data(09/03/2011);
%read_data(10/01/2011);
%read_data(11/05/2011);
%read_data(12/03/2011);

%read_data(01/07/2012);
%read_data(02/04/2012);
%read_data(03/03/2012);
%read_data(04/07/2012);
%read_data(05/05/2012);
%read_data(06/02/2012);
%read_data(07/07/2012);
%read_data(08/04/2012);
%read_data(09/01/2012);
%read_data(10/06/2012);
%read_data(11/03/2012);
%read_data(12/01/2012);

%read_data(01/05/2013);
%read_data(02/02/2013);
%read_data(03/02/2013);
%read_data(04/06/2013);
%read_data(05/04/2013);
%read_data(06/01/2013);
%read_data(07/06/2013);
%read_data(08/03/2013);
%read_data(09/07/2013);
%read_data(10/05/2013);
%read_data(11/02/2013);
%read_data(12/07/2013);

%read_data(01/01/2014);
%read_data(02/01/2014);
%read_data(03/01/2014);
%read_data(04/05/2014);
%read_data(05/03/2014);
%read_data(06/07/2014);
%read_data(07/05/2014);
%read_data(08/02/2014);
%read_data(09/06/2014);
%read_data(10/04/2014);
%read_data(11/04/2014);
%read_data(12/06/2014);

%read_data(01/03/2015);
%read_data(02/07/2015);
%read_data(03/07/2015);
%read_data(04/04/2015);
%read_data(05/02/2015);
%read_data(06/06/2015);
%read_data(07/04/2015);
%read_data(08/01/2015);
%read_data(09/05/2015);
%read_data(10/03/2015);
%read_data(11/03/2015);
%read_data(12/05/2015);

%read_data(01/01/2016);
%read_data(02/06/2016);
%read_data(03/05/2016);
%read_data(04/02/2016);
%read_data(05/07/2016);
%read_data(06/04/2016);
%read_data(07/02/2016);
%read_data(08/06/2016);
%read_data(09/03/2016);
%read_data(10/01/2016);
%read_data(11/05/2016);
%read_data(12/03/2016);

%read_data(01/01/2017);
%read_data(02/04/2017);
%read_data(03/04/2017);
%read_data(04/01/2017);
%read_data(05/06/2017);
%read_data(06/03/2017);
%read_data(07/01/2017);
%read_data(08/05/2017);
%read_data(09/02/2017);
%read_data(10/07/2017);
%read_data(11/04/2017);
%read_data(12/02/2017);

%read_data(01/01/2018);
%read_data(02/03/2018);
%read_data(03/03/2018);
%read_data(04/07/2018);
%read_data(05/05/2018);
%read_data(06/02/2018);
%read_data(07/07/2018);
%read_data(08/04/2018);
%read_data(09/01/2018);
%read_data(10/06/2018); 
%read_data(11/03/2018); 
%read_data(12/01/2018); 

%read_data(01/01/2019); 
%read_data(02/02/2019); 
%read_data(03/02/2019); 
%read_data(04/06/2019); 
%read_data(05/04/2019); 
%read_data(06/01/2019); 
%read_data(07/06/2019); 
%read_data(08/03/2019); 
%read_data(09/07/2019); 
%read_data(10/05/2019); 
%read_data(11/02/2019); 
%read_data(12/07/2019); 

data here.voter_data_old; set voter_data;
run;
endsas;
*/
/* 
When you read all the old data, just do that separately and 'endsas'.
Otherwise the code will double-count the old data...
*/

/*
Now, read in the more recent data, and combine it with the 
old data, and plot it ...
*/
/*
%read_data(01/04/2020); 
*/
%read_data(01/04/2020); 
%read_data(02/01/2020); 
%read_data(03/07/2020); 
%read_data(04/04/2020); 
%read_data(05/02/2020); 
%read_data(06/06/2020); 
%read_data(07/04/2020); 
%read_data(08/01/2020); 
%read_data(09/05/2020); 
%read_data(10/03/2020); 

/* for trouble-shooting */
data foo; set voter_data; run;

data voter_data; set here.voter_data_old voter_data (drop = Green Total);
if date>="01jan2008"d then output;
run;

/*
Using election dates from links at bottom of this page:
https://en.wikipedia.org/wiki/Off-year_election
*/
data anno_major_elections; 
length text $100;
informat date date9.;
input date candidates $ 11-80;
html='title='||quote(
 'Presidential election day: '||'0d'x||
 trim(left(put(date,nldate20.)))||'0d'x||
 trim(left(candidates)));
xsys='2'; ysys='1'; hsys='3'; when='a';
function='label'; position='2'; color="gray55";
x=date; y=100; 
size=2.0; style='markere'; text='D'; output;
x=date; y=104;
size=2.0; style=''; text="'"||substr(put(date,date9.),8,2); output;
datalines;
04nov2008 Obama / McCain
06nov2012 Obama / Romney
08nov2016 Trump / Hillary
03nov2020 ? / ?
;
run;
/*
02nov2004 Bush / Kerry
*/

data anno_minor_elections;
length text $100;
input date date9.;
html='title='||quote(
 'Off-year election day: '||'0d'x||
 trim(left(put(date,nldate20.))));
xsys='2'; ysys='1'; hsys='3'; when='a';
function='label'; position='2'; color="gray55";
x=date; y=100;
size=2.0; style='markere'; text='D'; output;
datalines;
02nov2010
04nov2014
06nov2018
;
run;
/*
07nov2006
*/

data anno_year_axis;
xsys='2'; ysys='1'; hsys='3'; when='a';
*do year=2004 to 2018;
do year=2008 to 2020;
 date=input('01jul'||trim(left(year)),date9.);
 x=date; y=1.0;
 function='label'; style=''; position='8'; size=2.5; text=trim(left(put(date,year4.)));
 output;
 end;
run;

data anno_stuff; 
length function $8 style $35;
set anno_major_elections anno_minor_elections anno_year_axis;
run;

data my_map; set maps.counties (where=(fipstate(state)='NC' and density<=2));
run;
proc gproject data=my_map out=my_map;
id state county;
run;


%macro do_plot(county);

goptions nodisplay;

/* Map */

data map_data; set maps.cntyname (where=(state=37));
county_name=compress(propcase(countynm));
if county_name=compress("&county") then color_it=1;
else color_it=0;
if color_it=1 then output;
run;

proc sql noprint;
select substr(lowcase(county_name),1,6) into :cname separated by ' ' 
from map_data where color_it=1;
/* anchor name */
select county_name into :aname separated by ' ' 
from map_data where color_it=1;
quit; run;

ods html anchor="&aname";

title1 h=10 ' ';
footnote h=1 ' ';
pattern1 v=s c=black;
goptions xpixels=315 ypixels=110;
proc gmap data=map_data map=my_map all;
id state county;
choro color_it / midpoints = 1 nolegend 
 coutline=same cempty=graybb
 des='' name="m_&cname";
run;

/* Line Plot */

proc sql noprint;
select (democrats+republicans+libertarians+unaffiliated) 
 format=comma20.0 into :totalc separated by ' '
from voter_data 
where county="&county" having date=max(date);
quit; run;

data temp_data (keep = date democrats republicans libertarians unaffiliated); 
 set voter_data (where=(county="&county"));
run;

proc sort data=temp_data out=temp_data;
by date;
run;

proc transpose data=temp_data out=temp_data (rename=(_name_=party col1=voters));
by date;
run;

data anno_parties; set temp_data (where=(date=&maxdate));
length text $50 color $8;
xsys='1'; ysys='2'; hsys='3'; when='a';
function='label'; position='>'; 
x=100; 
y=voters;
text='20'x||trim(left(party));
if party='Democrats' then color="&colord"; 
if party='Republicans' then color="&colorr"; 
if party='Libertarians' then color="&colorl"; 
if party='Unaffiliated' then color="&coloru"; 
run;

proc sort data=temp_data out=temp_data;
by party date;
run;

data temp_data; set temp_data; 
percent_change=(voters-lag(voters))/lag(voters);
length my_html $300;
my_html=
 'title='||quote( 
  trim(left(put(voters,comma10.0)))||' registered '||trim(left(party))||'0d'x||
  'in '||trim(left("&county"))||' County, NC'||'0d'x||
  'on '||trim(left(put(date,nldate20.)))||'0d'x||
  'Percent change since previous data point = '||put(percent_change,percentn7.3)
  )||
 ' href='||quote('https://vt.ncsbe.gov/RegStat/Results/?date='||
  trim(left(put(date,mmddyy10.))));
run;

proc sql noprint;
create table temp_pie as
select * from temp_data
having date=max(date);
create table temp_pie as
select unique party, sum(voters) as voters
from temp_pie
group by party;
create table temp_pie as
select unique party, voters, sum(voters) as total
from temp_pie;
quit; run;
data temp_pie; set temp_pie;
percent=voters/total;
if party='Democrats' then pie_order='a';
if party='Unaffiliated' then pie_order='b';
if party='Libertarians' then pie_order='c';
if party='Republicans' then pie_order='d';
length my_html $300;
my_html='title='||quote(
 trim(left(party))||': '||'0d'x||
 trim(left(put(voters,comma20.0)))||' voters'||'0d'x||
 trim(left(put(percent,percentn7.1)))
 );
run;

symbol1 value=circle height=2.2 interpol=join color=&colord;
symbol2 value=circle height=2.2 interpol=join color=&colorl;
symbol3 value=circle height=2.2 interpol=join color=&colorr;
symbol4 value=circle height=2.2 interpol=join color=&coloru;

axis1 style=0 label=none major=none minor=none offset=(0,0);

axis2 style=0 label=none minor=none offset=(0,0)
 value=(h=2.0 c=white) order=('01jan2008'd to '01jan2021'd by year);
/*
 value=(h=2.0 c=white) order=('01jan2004'd to '01jan2020'd by year);
*/

options nobyline;
title1 ls=2.5 move=(40,+0)
 font='albany amt' c=gray99 "&totalc Registered Voters in ";
title2 ls=3.5 move=(40,+0) height=5
 font='albany amt/bold' c=black "&county" 
 font='albany amt' c=gray99 " County, NC";
title3 h=6 ' ';
title4 a=-90 h=10.0 ' ';

goptions xpixels=900 ypixels=500;
proc gplot data=temp_data anno=anno_parties;
format date year4.;
plot 
 voters*date=party / nolegend vzero
 vaxis=axis1 haxis=axis2 noframe
 autovref cvref=gray77 lvref=33
 autohref chref=gray77 lhref=34
 anno=anno_stuff
 html=my_html
 des='' name="p_&cname";
run;

pattern1 v=s c=&colord;
pattern2 v=s c=&coloru;
pattern3 v=s c=&colorl;
pattern4 v=s c=&colorr;

title h=5 ' '; 
footnote h=5 ' ';
goptions xpixels=117 ypixels=110;
proc gchart data=temp_pie;
pie pie_order / type=sum sumvar=voters noheading
 slice=none value=none percent=none
 angle=90
 coutline=graybb
 html=my_html
 des='' name="x_&cname";
run;

/* Combine map & line plot */
goptions display;

goptions xpixels=900 ypixels=500;
proc greplay nofs igout=work.gseg tc=tempcat;
   tdef two des='2 plot template'
   0/ llx=0       lly=0
      ulx=0       uly=100
      urx=100     ury=100
      lrx=100     lry=0
   1/ llx=5       lly=78
      ulx=5       uly=100
      urx=40      ury=100
      lrx=40      lry=78
   2/ llx=79.5    lly=78
      ulx=79.5    uly=100
      urx=92.5    ury=100
      lrx=92.5    lry=78
   ;
   template two;
   treplay 0:p_&cname 1:basemap 1:m_&cname 2:x_&cname
   des='' name="&name._&county";
run;

%mend;


goptions device=png;
goptions border; 

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="NC Voter Registration, by county") 
 style=htmlblue 
 options(pagebreak='no');

goptions nodisplay;
goptions gunit=pct ftitle='albany amt/bold' ftext='albany amt' htitle=5 htext=2.9;
goptions ctext=gray99;

/* 
This map will be used in all the plots, so only generate it once,
rather than each time the macro is called 
*/
data map_data2; set maps.cntyname (where=(state=37));
county_name=compress(propcase(countynm));
length my_html $300;
my_html=
 'title='||quote(propcase(countynm))||
 ' href='||quote('#'||trim(left(compress(propcase(countynm)))));
color_it=1;
run;

pattern1 v=s c=white;
title1 h=10 ' ';
footnote h=1 ' ';
goptions xpixels=315 ypixels=110;
proc gmap data=map_data2 map=my_map all;
id state county;
choro color_it / midpoints = 1 nolegend 
 coutline=graybb 
 html=my_html
 des='' name="basemap";
run;

/* 
This is a little wasteful to repeat all the code, to do the 
state-level summary ... but it would have made the code 
overly-complex and hard to follow, to try to make the 
county-level macro also produce a state-level graph.
*/

data temp_data (keep = date democrats republicans libertarians unaffiliated); 
 set voter_data;
run;

proc sql noprint;
create table temp_data as
select unique date, sum(democrats) as Democrats, sum(republicans) as Republicans,
 sum(libertarians) as Libertarians, sum(unaffiliated) as Unaffiliated
from temp_data
group by date;
quit; run;

proc sql noprint;
select (democrats+republicans+libertarians+unaffiliated) 
 format=comma20.0 into :totals separated by ' '
from temp_data 
having date=max(date);
quit; run;

proc sort data=temp_data out=temp_data;
by date;
run;

proc transpose data=temp_data out=temp_data (rename=(_name_=party col1=voters));
by date;
run;

data temp_data; set temp_data;
run;

proc sql noprint;
select max(date) into :maxdate separated by ' ' from temp_data;
quit; run;

data anno_parties; set temp_data (where=(date=&maxdate));
length text $50 color $8;
xsys='1'; ysys='2'; hsys='3'; when='a';
function='label'; position='>'; 
x=100; 
y=voters;
text='20'x||trim(left(party));
if party='Democrats' then color="&colord"; 
if party='Republicans' then color="&colorr"; 
if party='Libertarians' then color="&colorl"; 
if party='Unaffiliated' then color="&coloru"; 
run;

proc sort data=temp_data out=temp_data;
by party date;
run;

data temp_data; set temp_data; 
percent_change=(voters-lag(voters))/lag(voters);
length my_html $300;
my_html=
 'title='||quote( 
  trim(left(put(voters,comma10.0)))||' registered '||trim(left(party))||'0d'x||
  'in North Carolina'||'0d'x||
  'on '||trim(left(put(date,nldate20.)))||'0d'x||
  'Percent change since previous data point = '||put(percent_change,percentn7.3)
  )||
 ' href='||quote('https://vt.ncsbe.gov/RegStat/Results/?date='||
  trim(left(put(date,mmddyy10.))));
run;

proc sql noprint;
create table temp_pie as
select * from temp_data
having date=max(date);
create table temp_pie as
select unique party, sum(voters) as voters
from temp_pie
group by party;
create table temp_pie as
select unique party, voters, sum(voters) as total
from temp_pie;
quit; run;
data temp_pie; set temp_pie;
percent=voters/total;
if party='Democrats' then pie_order='a';
if party='Unaffiliated' then pie_order='b';
if party='Libertarians' then pie_order='c';
if party='Republicans' then pie_order='d';
length my_html $300;
my_html='title='||quote(
 trim(left(party))||': '||'0d'x||
 trim(left(put(voters,comma20.0)))||' voters'||'0d'x||
 trim(left(put(percent,percentn7.1)))
 );
run;

symbol1 value=circle height=2.2 interpol=join mode=include color=&colord;
symbol2 value=circle height=2.2 interpol=join mode=include color=&colorl;
symbol3 value=circle height=2.2 interpol=join mode=include color=&colorr;
symbol4 value=circle height=2.2 interpol=join mode=include color=&coloru;

axis1 style=0 label=none order=(0 to 3000000 by 500000) major=none minor=none offset=(0,0);

axis2 style=0 label=none minor=none offset=(0,0)
 value=(h=2.0 c=white) order=('01jan2008'd to '01jan2021'd by year);
/*
 value=(h=2.0 c=white) order=('01jan2004'd to '01jan2020'd by year);
*/

options nobyline;
title1 ls=2.5 move=(40,+0)
 font='albany amt' c=gray99 "&totals Registered Voters in ";
title2 ls=3.5 move=(40,+0) height=5
 font='albany amt/bold' c=black "North Carolina";
title3 h=6 ' ';
title4 a=-90 h=10.0 ' ';

ods html anchor='NC';

goptions xpixels=900 ypixels=500;
proc gplot data=temp_data anno=anno_parties;
format date year4.;
format voters comma12.0;
plot 
 voters*date=party / nolegend vzero
 vaxis=axis1 haxis=axis2 noframe
 autovref cvref=gray77 lvref=33
 autohref chref=gray77 lhref=34
 anno=anno_stuff
 html=my_html
 des='' name="nc_plot";
run;

pattern1 v=s c=&colord;
pattern2 v=s c=&coloru;
pattern3 v=s c=&colorl;
pattern4 v=s c=&colorr;

title h=5 ' ';
footnote h=5 ' ';
goptions xpixels=117 ypixels=110;
proc gchart data=temp_pie;
pie pie_order / type=sum sumvar=voters noheading
 slice=none value=none percent=none
 angle=90
 coutline=graybb
 html=my_html
 des='' name="nc_pie";
run;

goptions display;

goptions xpixels=900 ypixels=500;
proc greplay nofs igout=work.gseg tc=tempcat;
   tdef two des='2 plot template'
   0/ llx=0       lly=0
      ulx=0       uly=100
      urx=100     ury=100
      lrx=100     lry=0
   1/ llx=5       lly=78
      ulx=5       uly=100
      urx=40      ury=100
      lrx=40      lry=78
   2/ llx=79.5    lly=78
      ulx=79.5    uly=100
      urx=92.5    ury=100
      lrx=92.5    lry=78
   ;
   template two;
   treplay 0:nc_plot 1:basemap 2:nc_pie
   des='' name="&name";
run;


proc sql noprint; create table foo as select unique county from voter_data; quit; run;
data _null_; set foo 
 /*
 (where=(county in ('Alamance')))
 (where=(county in ('Wake' 'Mecklenburg' 'Rowan')))
 (where=(county in ('Anson' 'McDowell' 'New Hanover')))
 (obs=1)
 */
 ;
 call execute('%do_plot('|| county ||');');
run;
/*
*/

/*
Create some blanks pace after the last graph, so when you jump to
the Yancey county html anchor, the graph will be at the top of 
the page (rather than in the middle).
*/
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';

/* for trouble-shooting */
/*
proc print data=foo; run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
