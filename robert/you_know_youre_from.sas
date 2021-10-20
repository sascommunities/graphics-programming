%let name=you_know_youre_from;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Building a better map version of:
https://www.countryliving.com/life/g4580/signs-you-grew-up-american/?utm_source=taboola_arb&utm_medium=cpm&utm_campaign=arb_tb_clv_d_g4580g4580
*/

filename datafile "../democd103/you_know_youre_from.txt";

data my_data;
infile datafile lrecl=200 pad firstobs=1;
length state_name $50 fact1 fact2 fact3 $200;
input state_name $ 1-50;
input fact1 $ 1-200;
input fact2 $ 1-200;
input fact3 $ 1-200;
run;

data my_data; set my_data;
fact1=trim(left(translate(fact1,"'",'"')));
fact2=trim(left(translate(fact2,"'",'"')));
fact3=trim(left(translate(fact3,"'",'"')));
fact1=trim(left(substr(fact1,2)));
fact2=trim(left(substr(fact2,2)));
fact3=trim(left(substr(fact3,2)));
length my_tip $1000;
label my_tip='State';
my_tip=
 trim(left(state_name))||'0d'x||
 '------------------------------'||'0d'x||
 trim(left(fact1))||'0d'x||
 trim(left(fact2))||'0d'x||
 trim(left(fact3));
my_drill=
 '#'||trim(left(state_name));
run;

data my_map; set mapsgfk.us_states (where=(statecode not in ('AK' 'HI')) drop = X Y);
state_name=fipnamel(state);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="You know you're from ...") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=800px height=600px noborder; 

title1 c=gray33 h=18pt "What the state you grew up in says about you ...";
title2 c=gray33 h=13pt "(mouse-over or click each state to find out)";

footnote 
/*
 link='https://www.countryliving.com/life/g4580/signs-you-grew-up-american/'
*/
 c=gray h=12pt "Data source: countryliving.com";


/*
Note that tip= and url= are new features in 9.4m6a
*/
proc sgmap maprespdata=my_data noautolegend mapdata=my_map;
openstreetmap;
choromap state_name / mapid=state_name 
 tip=(my_tip) url=my_drill transparency=1.0;
/*
choromap / mapid=state_name;
choromap / mapid=state_name lineattrs=(color=blue);
*/
run;

proc sort data=my_data out=my_data;
by state_name;
run;

proc transpose data=my_data out=my_table;
by state_name;
var fact1 fact2 fact3;
run;

ods html anchor="#byval(state_name)";
options nobyline;
title h=18pt c=gray33 "#byval(state_name)";
footnote;
proc print data=my_table label noobs
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
label col1='What the state you grew up in says about you ...';
by state_name;
var col1;
run;

/* 
Create some blanks pace after the tables, so when you jump to
the Wisconsin or Wyoming html anchor, the state name will be
at the top of the page (rather than in the middle).
*/
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';
ods html text='</br></br></br></br></br></br></br></br></br></br></br></br></br>';

quit;
ODS HTML CLOSE;
ODS LISTING;
