%let name=california_river_quest_2019;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

filename datafile "california_river_quest_2019.dat";

data raw_data;
infile datafile firstobs=1 pad;
input whole_line $ 1-120;
racer_num=.; racer_num=scan(whole_line,1,';','mo');
length first_name last_name full_name $100;
first_name=scan(whole_line,2,';','mo');
last_name=scan(whole_line,3,';','mo');
full_name=trim(left(first_name))||' '||trim(left(last_name));
event_distance=.; event_distance=scan(whole_line,4,';','mo');
length class $50;
class=scan(whole_line,5,';','mo');
length category $50;
category=scan(whole_line,6,';','mo');
format start_time timeampm7.;
start_time=input(scan(whole_line,7,';','mo'),time.);
format cp1_time timeampm7.;
cp1_time=input(scan(whole_line,8,';','mo'),time.);
format cp2_time timeampm7.;
cp2_time=input(scan(whole_line,9,';','mo'),time.);
format cp3_time timeampm7.;
cp3_time=input(scan(whole_line,10,';','mo'),time.);
format finish_time timeampm7.;
finish_time=input(scan(whole_line,11,';','mo'),time.);
format final_time time5.;
final_time=input(scan(whole_line,12,';','mo'),time.);
length race_distance $50;
race_distance=scan(whole_line,13,';','mo');
race_distance_numeric=.; race_distance_numeric=scan(race_distance,1,' ');

format elapse_25 elapse_50 elapse_75 elapse_100 time5.;
elapse_25=cp1_time-start_time;
elapse_50=cp2_time-start_time;
elapse_75=cp3_time-start_time;
if race_distance='100 Miles' then elapse_100=finish_time-start_time;

run;

data plot_data; set raw_data;
format time time5.;
distance=0; time=0; output;
distance=25; time=elapse_25; output;
distance=50; time=elapse_50; output;
distance=75; time=elapse_75; output;
distance=100; time=elapse_100; output;
run;

data plot_data; set plot_data; 
label full_name='Name';
label class='Class';
label category='Category';
label distance='Distance (miles)';
label time='Time (hh:mm)';
label avg_mph='Avg mph';
format avg_mph comma8.2;
avg_mph=distance/(time/(60*60));
length name_search $300;
name_search='http://images.google.com/search?q='||trim(left(full_name))||', '||trim(left(category))||', paddle race';
run;

proc sort data=plot_data out=plot_data;
by descending race_distance_numeric descending final_time;
run;


/* waypoints to plot on the map */
data checkpoints;
input lat long labeltext $ 25-50;
datalines;
40.5912103 -122.3875669 Start
40.4174706 -122.1947685 25 miles
40.1745591 -122.2285291 50 miles
39.9085391 -122.0914473 75 miles
39.7345816 -121.9580843 100 miles
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="California River Quest 2019") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 noborder; 

ods graphics / width=500px height=1100px;

data checkpoints; set checkpoints;
label labeltext='Checkpoint';
labeltext='a0a0'x||trim(left(labeltext));
length drill_down $300;
drill_down='https://www.google.com/maps/@'||trim(left(lat))||','||trim(left(long))||',16z?hl=en';
run;

title1 h=18pt "California River Quest 2019";
ods html anchor='map';
proc sgmap plotdata=checkpoints noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map";
scatter x=long y=lat / markerattrs=(color=red size=12px symbol=circlefilled)
 url=drill_down tip=(labeltext);
text x=long y=lat text=labeltext / textattrs=(color=red size=11pt weight=bold) position=right
 url=drill_down tip=(labeltext) backlight=1;
run;
 /* backlight= and url= and tip= features need at least 9.4m6a (Viya 3.5) */


ods graphics / width=800px height=650px;

options nobyline;
title1 h=18pt "California River Quest 2019 (#byval(race_distance_numeric) mile race)";

ods html anchor='spaghetti';
proc sgplot data=plot_data noautolegend noborder;
by race_distance_numeric notsorted;
series x=distance y=time / group=racer_num lineattrs=(pattern=solid) 
 markers markerattrs=(symbol=circle size=7px)
 tip=(full_name class category distance time avg_mph) url=name_search;
yaxis display=(noline noticks)
 labelattrs=(size=11pt weight=bold) labelpos=top
 grid gridattrs=(pattern=dot color=gray88)
 valueattrs=(size=11pt) offsetmin=0 offsetmax=0;
xaxis labelattrs=(size=11pt weight=bold)
 values=(0 to 100 by 25) valueattrs=(size=11pt);
run;

ods html anchor='microbar';
proc sgplot data=plot_data noautolegend noborder;
by race_distance_numeric notsorted;
series y=full_name x=time / group=full_name lineattrs=(pattern=solid color=cx49E20E)
 markers markerattrs=(symbol=circlefilled color=cxff4444)
 tip=(full_name class category distance time avg_mph) url=name_search;
xaxis grid gridattrs=(pattern=dot color=gray88) offsetmax=0 valueattrs=(size=10pt);
yaxis display=(nolabel noline noticks) valueattrs=(size=10pt);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
