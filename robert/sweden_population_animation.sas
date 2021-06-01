%let name=sweden_population_animation;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Creating a population profile animation, similar to:
https://www.reddit.com/r/dataisbeautiful/comments/nm2qjj/oc_animated_demographic_pyramid_of_sweden_18602020/
Using data from:
https://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__BE__BE0101__BE0101A/BefolkningR1860N/
 age, 1 year age classes, select all 111
 sex, select both men & women
 years, select all
 35,742 cells
 Table Layout, Excel (xls), Continue
 0000053A_20210528-153820.xlsx was downloaded
 Renamed to sweden_population.xlsx
 Changed sheet name from 0000053A to Sheet 1
*/

proc import
 file="sweden_population.xlsx"
 out=my_data
 dbms=xlsx replace;
getnames=yes;
range='Sheet 1$A3:FG226';
run;

data my_data (rename=(b=gender) drop=a a_retained); 
 set my_data;
retain a_retained;
if a^='' then a_retained=a;
if a='' then a=a_retained;
a=translate(a,'','+');  /* convert '100+' to '100 */
age=.; age=scan(a,1,' ');
run;

proc transpose data=my_data out=tran_data (rename=(_label_=year) drop=_name_);
by age;
id gender;
run;

data tran_data; set tran_data;
men_surplus=.;
women_surplus=.;
if men>women then do;
 men_surplus=(men-women);
 men=men-men_surplus;
 end;
if women>men then do;
 women_surplus=(women-men);
 women=women-women_surplus;
 end;
run;

proc transpose data=tran_data out=tran_data2 (rename=(_name_=gender col1=people));
by age year;
run;

/* Make the men show up on the left half of the graph */
data tran_data2; set tran_data2;
format people comma10.0;
if gender='men' or gender='men_surplus' then people=people*-1;
/* make the genders print 'prettier' in the legend */
if gender='men' then gender='Men';
if gender='men_surplus' then gender='Men Surplus';
if gender='women' then gender='Women';
if gender='women_surplus' then gender='Women Surplus';
label age='Age';
label people='Population';
year_born=year-age;
run;

/* Extra variables, for 2nd/overlaid plot, of 'shadows' for wars, etc */
data tran_data2; set tran_data2;
if 
 /* Famine */
 year_born in (1869 1868 1867) 
 or
 /* WWI and Spanish Flu */
 year_born in (1919 1918 1917 1916 1915 1914) 
 or
 /* WWII */
 year_born in (1945 1944 1943 1942 1941 1940 1939 1938 1937) 
 then do;
 shadow_people=people;
 end;
run;


proc sort data=tran_data2 out=tran_data2;
by year gender age;
run;

/* User-defined-format to make negative numbers print as positive */
proc format; 
picture posval low-high='000,009'; 
run; 


%macro do_plot(year);

data temp_data; set tran_data2 (where=(year="&year"));
run;

data anno_year;
length label $100 anchor x1space y1space textweight $50;
layer="front";
function="text"; textcolor="gray44"; textsize=30; textweight='bold';
width=100; widthunit='percent'; 
label="&year"; 
y1space='datapercent'; 
x1=80;
y1=95;
anchor='center'; 
output;
run;

proc sql noprint;
create table anno_year_born as
select unique age, year_born, people
from temp_data
where index(gender,'Women')^=0;
create table anno_year_born as
select unique age, year_born, sum(people) as people
from anno_year_born
group by age, year_born;
quit; run;

data anno_year_born; set anno_year_born;
length label $100 anchor x1space y1space $50;
layer="front";
function="text"; textcolor="gray44"; textsize=9; textweight='normal';
width=100; widthunit='percent';
label=trim(left(year_born)); 
if label='1867' then label='Famine';
if label='1914' then label='WW-I';
if label='1918' then label='Spanish flu';
if label='1938' then label='WW-II'; /* fudged the year a little, to get label to fit better */
y1space='datavalue'; 
x1space='datavalue';
y1=age;
x1=people+2000;
anchor='left'; 
if mod(year_born,10)=0 or label^=trim(left(year_born)) then output;
run;

data anno_all; set anno_year anno_year_born;
run;


title1 c=gray33 h=14pt "Sweden Population Profile, by Age and Gender";
title2 c=gray33 h=11pt "Gray/shadowed bars represent declines due to famine, wars, and Spanish flu";

proc sgplot data=temp_data noborder nowall noautolegend pad=(right=10pct) sganno=anno_all;
format people posval.;
/* color order = men, men_surplus, women, women_surplus */
styleattrs datacolors=(cx7abfff blue pink red);
hbarparm category=age response=people / 
 group=gender groupdisplay=stack
 outlineattrs=(color=gray77)
 name='colors' tip=none;
/* gray transparent bar segments, for wars, etc */
hbarparm category=age response=shadow_people /
 group=gender groupdisplay=stack
 outlineattrs=(color=gray77)
 fillattrs=(color=black) transparency=.75
 name='shadow' tip=none;
yaxis display=(noline noticks)
 values=(0 to 110 by 10) reverse type=linear 
 grid gridattrs=(pattern=dot color=gray55)
 offsetmin=0.006;
xaxis 
 values=(-100000 to 100000 by 20000) 
 grid gridattrs=(pattern=dot color=gray55)
 /* minorgrid minorcount=1 minorgridattrs=(pattern=dot color=gray55) */
 offsetmin=0 offsetmax=0;
keylegend 'colors' /*'shadow'*/ / title='' border across=1 opaque 
 position=topleft location=inside;

run;

%mend;


/*
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Sweden Population Animation") 
 style=htmlblue;
ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=800px height=800px noborder; 
*/

options dev=sasprtc printerpath=gif animation=start papersize=('8 in', '8 in') 
/*
 animduration=1.00 animloop=yes noanimoverlay;
*/
 animduration=.20 animloop=yes noanimoverlay;
ods printer file="&name..gif";
ods graphics / width=800px height=800px imagefmt=gif;
options nodate nonumber nobyline;
ods listing select none;

/* animate through the years */
data _null_; 
/*
do year=1860 to 2020 by 10;  
*/
do year=1860 to 2020 by 1;  
 call execute('%do_plot('|| year ||');');
 end;
run;
/* make it stall at the end for a while */
data _null_;
/*
do count=1 to 5;
*/
do count=1 to 20;
 call execute('%do_plot(2020);');
 end;
run;

options printerpath=gif animation=stop;
ods printer close;

quit;
ODS HTML CLOSE;
ODS LISTING;
