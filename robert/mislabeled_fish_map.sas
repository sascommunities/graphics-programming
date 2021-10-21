%let name=mislabeled_fish_map;
filename odsout '.';

/*
Using data from:
http://oceana.org/sites/default/files/National_Seafood_Fraud_Testing_Results_Highlights_FINAL.pdf
*/

%let sred=cxce1142;   /* solid */
%let tred=Ace1142dd;  /* transparent */

data mydata;
input x_line y_line state $ 11-12 city $ 14-80;
statefips=stfips(state);
datalines;
11.2 92.0 WA Seattle
 8.0 81.5 OR Portland
 6.0 46.0 CA San Francisco
10.5 30.5 CA Los Angeles
15.5 16.5 CO Denver
30.0 20.0 KS Kansas City
 0.0  0.0 MO placeholder  
41.5 14.5 TX Austin
41.5 14.5 TX Houston
61.0 73.5 IL Chicago
72.0 76.0 PA Pittsburgh
83.0 85.0 MA Boston
88.5 60.0 NY New York
87.0 42.5 DC Washington
84.5 23.0 GA Atlanta
73.5 10.0 FL West Palm Beach
run;

proc geocode data=mydata out=mydata lookup=sashelp.zipcode method=CITY;
run;

data anno_dots; set mydata (rename=(state=StateCode));
anno_flag=1;
long=x; lat=y;
if x^=. and y^=. then output;
run;

data mymap (rename=(state=statefips)); 
 set mapsgfk.us_states (where=((density<=3) and (statecode not in ('AK' 'HI' 'PR'))));
run;

/* combine, project, and separate */
data combined; set mymap anno_dots;
run;
proc gproject data=combined out=projected latlong eastlong degrees dupok;
id statefips;
run;
data mymap anno_dots; set projected;
if anno_flag=1 then output anno_dots;
else output mymap;
run;

data anno_dots; set anno_dots;
length function $8 color $12 style $35;
when='a'; hsys='3';
x_pie=x; y_pie=y;

if x_line^=0.0 then do;
xsys='3'; ysys='3';
function='move'; x=x_line; y=y_line; output;
xsys='2'; ysys='2';
function='draw'; x=x_pie; y=y_pie; color='black'; size=.001; output;
end;

xsys='2'; ysys='2';
x=x_pie; y=y_pie;
function='pie'; rotate=360; size=0.7;
style='psolid'; color="&sred"; output;
style='pempty'; color="gray55"; output;
run;

data anno_text;
length function $8 color $12 style $35 text $100;
xsys='3'; ysys='3'; when='a'; hsys='3';

x_bottom_center=7; y_bottom_center=19;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+8.3; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='national average'; output;
y=y+1.6; text='20% higher than'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+10; text='52% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='SOUTHERN CAL.'; output;

x_bottom_center=5.5; y_bottom_center=34;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+6.5; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='34 different times'; output;
y=y+1.6; text='substituted for snapper'; output;
y=y+1.6; text='Rockfish was'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+8.2; text='38% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='NORTHERN CAL.'; output;

x_bottom_center=13; y_bottom_center=4.5;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+8.3; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='black grouper'; output;
y=y+1.6; text='more sustainable'; output;
y=y+1.6; text='was sold as'; output;
y=y+1.6; text='Imperiled Gulf grouper'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+10; text='36% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='DENVER, CO'; output;

x_bottom_center=24.5; y_bottom_center=1.5;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+16.3; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='unsustainable choice'; output;
y=y+1.6; text='orange roughy, another'; output;
y=y+1.6; text='cod was sold as'; output;
y=y+1.6; text='Overfished Atlantic'; output;
y=y+1.6; text='---------------------'; output;
y=y+1.6; text='be escolar'; output;
y=y+1.6; text='tuna was found to'; output;
y=y+1.6; text='the country, white'; output;
y=y+1.6; text='As with the rest of'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+18; text='35% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='KANSAS CITY, MO / KS'; output;

x_bottom_center=36.0; y_bottom_center=1.0;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+11.0; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='sample was mislabeled'; output;
y=y+1.6; text='In Austin, every sushi'; output;
y=y+1.6; text='---------------------'; output;
y=y+1.6; text='mislabeled seafood'; output;
y=y+1.6; text='outlets visited sold'; output;
y=y+1.6; text='48% of the retail'; output;  /* this is "off by 1" from the overall % -- is this correct? */
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+13; text='49% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='AUSTIN / HOUSTON, TX'; output;

x_bottom_center=5.5; y_bottom_center=72;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+6.5; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='sold mislabeled fish'; output;
y=y+1.6; text='retail outlets visited'; output;
y=y+1.6; text='More than 25% of the'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+8.2; text='21% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='PORTLAND, OR'; output;

x_bottom_center=6.0; y_bottom_center=89;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+4.7; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='was mislabeled'; output;
y=y+1.6; text='Every snapper sample'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+6.4; text='18% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='SEATTLE, WA'; output;

x_bottom_center=61.0; y_bottom_center=74.0;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+20.8; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='mislabeled fish'; output;
y=y+1.6; text='sold at least one'; output;
y=y+1.6; text='Every sushi venue'; output;
y=y+1.6; text='---------------------'; output;
y=y+1.6; text='red snapper'; output;
y=y+1.6; text='cod, tuna and'; output;
y=y+1.6; text='familiar species like'; output;
y=y+1.6; text='substituted for more'; output;
y=y+1.6; text='the U.S. were'; output;
y=y+1.6; text='as commonly sold in'; output;
y=y+1.6; text='does not recognize'; output;
y=y+1.6; text='Three fish that the FDA'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+22.5; text='32% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='CHICAGO, IL'; output;

x_bottom_center=72; y_bottom_center=77;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+8.3; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='national trend'; output;
y=y+1.6; text='following a'; output;
y=y+1.6; text='for red snapper,'; output;
y=y+1.6; text='Tilapia was substituted'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+10; text='56% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='PENNSYLVANIA'; output;

x_bottom_center=83; y_bottom_center=86;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+6.3; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='sold mislabeled fish'; output;
y=y+1.6; text='grocery stores visited'; output;
y=y+1.6; text='Nearly 50% of the'; output;
y=y+1.6; text=''; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+7.8; size=1.2; text='(48% including testing by The Boston Globe)'; output;
y=y_bottom_center+10; size=2.1; text='18% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='BOSTON, MA'; output;

x_bottom_center=94.0; y_bottom_center=44.0;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+17.5; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='mislabeled fish'; output;
y=y+1.6; text='Every sushi venue sold'; output;
y=y+1.6; text='---------------------'; output;
y=y+1.6; text='in a small market'; output;
y=y+1.6; text='halibut and red snapper'; output;
y=y+1.6; text='mercury, was sold as'; output;
y=y+1.6; text="FDA's DO NOT EAT"; output;
y=y+1.6; text='Tilefish, a fish on the'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+19.2; text='39% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='NEW YORK, NY'; output;

x_bottom_center=92.0; y_bottom_center=28.0;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+9.4; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='mislabeled fish'; output;
y=y+1.6; text='Every sushi venue sold'; output;
y=y+1.6; text='---------------------'; output;
y=y+1.6; text='was mislabeled'; output;
y=y+1.6; text='Every snapper sample'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+11.4; text='26% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='WASHINGTON, D.C.'; output;

x_bottom_center=90; y_bottom_center=15;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+6.5; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='red snapper'; output;
y=y+1.6; text='that sold a true'; output;
y=y+1.6; text='One of the few cities'; output;
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+8.2; text='25% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='ATLANTA, GA'; output;

x_bottom_center=68.0; y_bottom_center=1.5;
function='move'; x=x_bottom_center-5; y=y_bottom_center; output;
function='bar'; x=x_bottom_center+5; y=y_bottom_center+11.0; line=0; style='solid'; color="&tred"; output;
function='label'; style=''; size=1.2;
color="white"; position='5'; x=x_bottom_center;
y=y_bottom_center+2.0; text='in a grocery store'; output;
y=y+1.6; text='was sold as grouper'; output;
y=y+1.6; text='due to high mercury,'; output;
y=y+1.6; text='list for sensitive groups'; output;
y=y+1.6; text="the FDA's DO NOT EAT"; output;
y=y+1.6; text='King mackerel, a fish on'; output; 
color="&sred"; position='6'; size=2.1; x=x_bottom_center-5;
y=y_bottom_center+13; text='38% Mislabeled'; output;
color="black"; position='6'; size=1.5; x=x_bottom_center-5;
y=y+2; text='SOUTH FLORIDA'; output;

run;


goptions device=png;
goptions xpixels=2000 ypixels=1200;
goptions border cback=white;
 
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Fish Mislabeling in U.S. Cities") 
 style=htmlblue;

goptions gunit=pct htitle=3.0 htext=1.2 ftitle="albany amt/bold" ftext="albany amt/bold";

pattern1 v=s c=cx74ccd4;

title1 h=3.0 " ";
title2 h=8.0 a=90 " ";
title3 h=8.0 a=-90 " ";

footnote h=3 " ";

proc gmap data=mydata map=mymap anno=anno_dots all;
note move=(23,95) h=3.5 "Mislabeled Fish Prevalence";
note move=(90.5,1.5) h=1.2 c=gray font="albany amt" "Data Source: oceana.org";
id statefips;
choro statefips / levels=1
 coutline=gray44 cempty=gray77 cdefault=cxfcf2cc
 anno=anno_text nolegend 
 des='' name="&name";
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
