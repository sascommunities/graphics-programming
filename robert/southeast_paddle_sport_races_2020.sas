%let name=southeast_paddle_sport_races_2020;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Here is the website:
http://www.sepseries.org/races-registration/
(but I got the current races from an email - website wasn't updated yet)
*/

data my_data;
informat date date9.;
format date date9.;
input date lat long name_location $ 34-100;
input race_url $ 1-100;
length race_name location $100;
race_name=trim(left(scan(name_location,1,'(')));
location=trim(left(scan(name_location,2,'()')));
if race_url='unknown_url' then race_url="http://www.google.com/search?q="||trim(left(race_name))||' '||trim(left(location));
datalines;
21mar2020 34.0813051 -81.4113844 Paddle Bender (Dreher Island State Park, Prosperity, SC)
https://www.paddlesignup.com/Race/SC/Prosperity/PaddleBender
18apr2020 32.3458528 -80.4700014 River Quest (Hunting Island State Park, SC)
https://paddleguru.com/races/HuntingIslandRiverQuest
13jun2020 34.3530807 -83.7932721 Paddle Mania (Olympic Park, Gainesville, GA)
https://fs17.formsite.com/lckc1/form7/index.html
17oct2020 34.3530807 -83.7932721 Paddle Fest (Olympic Park, Gainesville, GA)
https://fs17.formsite.com/lckc1/form7/index.html
27jun2020 35.0790059 -81.8862769 Lake Blalock Paddle Blast (Spartanburg, SC)
https://paddleguru.com/races/LakeBlalockPaddleBlast
25jul2020 30.5154238 -82.9513552 Mere Mortals (Jasper, FL)
unknown_url
10oct2020 35.1011035 -81.1466149 Bon Temps (Lake Wylie, NC)
https://paddleguru.com/races/2ndAnnualBonTempsPaddleBattleonWylie
12sep2020 32.2143125 -80.8043440 Low Country Boil (Hilton Head, SC)
https://paddleguru.com/races/OluKaiLowcountryBoilPaddleBattle2020
19sep2020 32.3673420 -80.7087844 Paddle Battle (Port Royal, SC)
https://paddleguru.com/races/PortRoyalPaddleBattle5KVirtualChallenge
03oct2020 34.9944867 -82.9885518 Paddle Splash (Lake Jocassee, SC) 
https://paddleguru.com/races/LakeJocasseePaddleSplash2020
10oct2020 34.3002398 -83.9100376 SUPCAK (Gainesville, GA)
https://paddleguru.com/races/2020UpperChattSUPCAKRace
21nov2020 32.3458528 -80.4700014 Paddlefest - Virtual 5k (Hunting Island State Park, SC)
https://paddleguru.com/races/HuntingIslandPaddlefest5KVirtualChallenge
run;
/*
09may2020 32.4986529 -80.3321634 Edisto Island Classic (Edisto Beach, SC)
unknown_url
*/

proc sort data=my_data out=my_data;
by location date;
run;

data unique_data; set my_data;
length Info $500 Drill $300;
retain Info;
by location;

if first.location then Info=' '||'0d'x||trim(left(location))||'0d'x||'------------------';

Info=trim(left(Info))||'0d'x||trim(left(race_name))||': '||trim(left(put(date,nldate20.)));

if first.location then Drill=race_url;
else Drill="http://www.google.com/search?q="||trim(left(location))||" 2020 southeast paddle sport championship series";

if last.location then output;
run;


data state_outlines (drop=density resolution); 
 set mapsgfk.us_states (where=(statecode in ('SC' 'GA' 'NC') and density<=6));
 /* I'm leaving out Florida outline, so map won't be so tall */
run;

proc template;
define style Styles.MyStyle;
parent=styles.htmlblue;
style usertext from usertext / foreground=#555555 font_size=12pt;
end;
run;

ODS LISTING CLOSE;
ODS html path=odsout body="&name..htm"
 (title="Southeast Paddle Sport Races 2020") 
 options(pagebreak='no') style=mystyle;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=900px height=800px noborder; 

title1 h=20pt c=gray33 "Southeast Paddle Sport Races 2020";

proc sgmap plotdata=unique_data noautolegend mapdata=state_outlines;
openstreetmap;
choromap / mapid=statecode lineattrs=(color=gray77 thickness=2px);
scatter x=long y=lat / markerattrs=(symbol=circlefilled size=12pt color="cx00ff00")
 tip=none;
scatter x=long y=lat / markerattrs=(symbol=circle size=12pt color='gray33')
 tip=(Info) url=Drill;
/* Put the tip & drilldown on the last marker drawn, so it doesn't get covered. */
/* Note that tip= and url= are new scatter features in 9.4m6a */
run;

proc sort data=my_data out=my_data;
by date;
run;

data my_data; set my_data;
length link $300 href $300;
href='href='||quote(trim(left(race_url)));
link = '<a ' || trim(href) || ' target="_self">' || htmlencode(trim(race_name)) || '</a>';
run;

title;
proc print data=my_data label noobs
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
label link='Race Name';
label date='Date';
label location='Location';
format date nldate20.;
var date link location;
run;

ods text=" ";
ods text="All participants must observe local COVID-19 rules and guidelines. See the race organizer's website for specifics.";
ods text=" ";
ods text="Safety (including compliance with Covid-19 regulations), race course (including safety boats), insurance, website content, and any other matters specific to this race are the sole responsibility of the individual race organizer. SEPSeries administrators are only responsible for scheduling, classes, boat specs, and year end point calculations.";
ods text=" ";
ods text=" ";

quit;
ODS HTML CLOSE;
ODS LISTING;
