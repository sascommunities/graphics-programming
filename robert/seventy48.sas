%let name=seventy48;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Graphing the results from this event:
https://seventy48.com
*/

proc import datafile="SEVENTY48_Results_Grid.xlsx" dbms=xlsx out=all_data;
getnames=yes;
run;

data finishers dnf dns; set all_data;
if place='DNF' then output dnf;
else if place='DNS' then output dns;
else output finishers;
run;

data finishers (drop=Finish_Time__PDT_); set finishers;
format start_date_time finish_date_time mdyampm.;
finish_date_time=input(Finish_Time__PDT_,mdyampm.);
/* 
Although the spreadsheet says PDT, the times seem to be off by 3 hours,
therefore I assume the values are accidentally in Eastern time.
eg, the spreadsheet says Carter finished at 7:54am, but he really
finished at 4:54am (according to the news article, and I also asked
Carter himself).
Therefore I'm applying a 3 hour offset.
*/
finish_date_time=finish_date_time-'03:00:00't;
start_date_time=input('6/4/2021 7:00pm',mdyampm.);
format total_time time.;
total_time=finish_date_time-start_date_time;
start_date_time_plus=start_date_time+'00:20:00't;
distance_miles=70;
avg_mph=70/(total_time/60/60);
run;

data finishers; set finishers;
format total_time time6.;
label finish_date_time='Finish Date & Time';
label total_time='Race Time (hh:mm)';
label distance_miles='Distance (miles)';
label avg_mph='Average Speed (mph)';
format avg_mph comma8.1;
run;

data anno_time;
format datetime datetime20.;
format time time.;
do datetime = '04jun2021:19:00:00'dt to '06jun2021:19:00:00'dt by 43200;
 time=datetime-'04jun2021:19:00:00'dt;
 label=substr(put(time,time.),1,5);
 output;
 end;
run;

data anno_time; set anno_time;
length label $100 anchor x1space y1space function $50 textcolor $12;
function='text'; textcolor="gray33"; textsize=9; textweight='normal';
width=50; widthunit='percent';
x1space='datavalue'; y1space='layoutpercent';
anchor='bottom';
y1=100;
x1=datetime; 
output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Seventy48 Paddling Race Results - 2021") 
 style=htmlblue;

ods graphics / imagemap tipmax=2500 drilltarget="_self" imagefmt=png noborder; 
ods graphics / width=800px height=800px imagename="&name"; 

title1 c=gray33 "SEVENTY48 Paddling Race Results (2021)";
title2 c=gray77 "70 miles in less than 48 hours";
title3 h=10pt 'a0'x;

proc sgplot data=finishers noautolegend sganno=anno_time;
hbarparm category=team_name response=finish_date_time /
 barwidth=1.0 fillattrs=(color=dodgerblue) transparency=.4
 outlineattrs=(color=gray55)
 tip=(Place Team_Name Paddler Boat_Model Vessel_Type finish_date_time distance_miles total_time avg_mph)
 url=photo_url;
text y=team_name x=finish_date_time text=total_time / position=right tip=none;
text y=team_name x=start_date_time_plus text=boat_model / position=right tip=none;
xaxis display=(nolabel)
 values=('04jun2021:19:00:00'dt to '06jun2021:19:00:00'dt by 86400)
 offsetmax=0
 grid gridattrs=(pattern=dot color=gray66)
 minorgrid minorgridattrs=(pattern=dot color=gray66);
yaxis display=(nolabel noticks) fitpolicy=none;
run;


data finishers; 
length paddleguruurl $300;
set finishers;

label team_link='Team Name';
length team_link team_href $300;
team_href='href='||quote(trim(left(photo_url)));
team_link = '<a ' || trim(team_href) || ' target="_self">' || htmlencode(trim(team_name)) || '</a>';

label model_link='Boat Model';
length model_link model_href $300;
model_href='href='||quote('http://images.google.com/images?q='||
 trim(left(boat_model))||' '||trim(left(vessel_type)));
model_link = '<a ' || trim(model_href) || ' target="_self">' || 
 htmlencode(trim(boat_model)) || '</a>';

if paddleguruurl='' then paddleguruurl='http://google.com/search?q='||trim(left(paddler))||' paddler';
label paddler_link='Paddler';
length paddler_link paddler_href $300;
paddler_href='href='||quote(trim(left(PaddleGuruURL)));
paddler_link = '<a ' || trim(paddler_href) || ' target="_self">' ||
 htmlencode(trim(paddler)) || '</a>';

run;

title1 "SEVENTY48 Paddling Race Results (2021) - Finishers!";
proc print data=finishers label noobs; 
var Place team_link paddler_link model_link Vessel_Type finish_date_time distance_miles total_time avg_mph;
run;

title "Did Not Finish";
proc print data=dnf label;
var place team_name;
run;

title "Did Not Start";
proc print data=dns label;
var place team_name;
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
