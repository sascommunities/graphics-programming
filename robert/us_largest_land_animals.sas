%let name=us_largest_land_animals;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Designed after:
https://www.reddit.com/r/dataisbeautiful/comments/mugjb4/oc_largest_land_animal_species_by_weight_in_each/
*/

data my_data;

length statecode $2;
length animal $25;
length weight $20;
length state_name $50;
label state_name='State' animal='Animal' weight='Weight';

infile datalines dlm=':';
input statecode animal weight;
state_name=fipnamel(stfips(statecode));

datalines;
WA:Northern Elephant Seal:5,100 lbs
OR:Northern Elephant Seal:5,100 lbs
CA:Northern Elephant Seal:5,100 lbs
AK:Northern Elephant Seal:5,100 lbs
ID:American Bison:2,599 lbs
MT:American Bison:2,599 lbs
ND:American Bison:2,599 lbs
MN:American Bison:2,599 lbs
UT:American Bison:2,599 lbs
AZ:American Bison:2,599 lbs
NM:American Bison:2,599 lbs
WY:American Bison:2,599 lbs
CO:American Bison:2,599 lbs
IA:American Bison:2,599 lbs
MO:American Bison:2,599 lbs
IL:American Bison:2,599 lbs
TX:American Bison:2,599 lbs
SD:American Bison:2,599 lbs
NE:American Bison:2,599 lbs
KS:American Bison:2,599 lbs
OK:American Bison:2,599 lbs
FL:American Bison:2,599 lbs
NV:Moose:1,543 lbs
WI:Moose:1,543 lbs
MI:Moose:1,543 lbs
NY:Moose:1,543 lbs
VT:Moose:1,543 lbs
NH:Moose:1,543 lbs
ME:Moose:1,543 lbs
MA:Moose:1,543 lbs
CT:Moose:1,543 lbs
NC:Elk:1,096 lbs
TN:Elk:1,096 lbs
KY:Elk:1,096 lbs
VA:Elk:1,096 lbs
WV:Elk:1,096 lbs
PA:Elk:1,096 lbs
SC:American Alligator:770 lbs
GA:American Alligator:770 lbs
AL:American Alligator:770 lbs
MS:American Alligator:770 lbs
LA:American Alligator:770 lbs
AR:American Alligator:770 lbs
MD:Gray Seal:680 lbs
DE:Gray Seal:680 lbs
NJ:Gray Seal:680 lbs
RI:Gray Seal:680 lbs
HI:Hawaiian Monk Seal:600 lbs
OH:Black Bear:551 lbs
IN:White-Tailed Deer:300 lbs
;
run;

data land_labels; set mapsgfk.uscenter (where=(ocean='' and statecode^='DC'));
if statecode='HI' then do;
 x=x-.01;
 y=y-.01;
 end;
land_x_text=x; 
land_y_text=y;
run;
proc sql noprint;
create table land_labels as
select unique land_labels.*, my_data.state_name, my_data.animal, my_data.weight
from land_labels left join my_data
on land_labels.statecode=my_data.statecode;
quit; run;

data water_labels; set mapsgfk.uscenter (where=(ocean='Y' and statecode^='DC'));
water_x_text=x; 
water_y_text=y;
run;
proc sql noprint;
create table water_labels as
select unique water_labels.*, my_data.state_name, my_data.animal, my_data.weight
from water_labels left join my_data
on water_labels.statecode=my_data.statecode;
quit; run;

data lines; set mapsgfk.uscenter (where=(ocean^='' and statecode^='DC'));
by statecode notsorted;
x_line=x; 
y_line=y;
output;
if last.statecode then do;
 x_line=.;
 y_line=.;
 output;
 end;
run;

data my_labels; set land_labels lines water_labels;
run;

data my_map; set mapsgfk.us (where=(statecode^='DC'));
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Largest Land Animals in US")
 style=htmlblue;

ods graphics / 
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 imagemap tipmax=2500
 width=900px height=600px;

title1 color=gray33 height=20pt "Largest Land Animal (by Weight) in Each US State";
footnote color=gray77 height=10pt "Based on iNaturalist Data of Non-Domesticated Animals";

proc sgmap maprespdata=my_data mapdata=my_map plotdata=my_labels noautolegend;
styleattrs datacolors=( cx8dd3c7 cxffffb3 cxbebada 
 cxfb8072 cx80b1d3 cxfdb462 cxb3de69 cxfccde5 cxd9d9d9);
choromap animal / mapid=statecode lineattrs=(thickness=1 color=gray88)
 tip=(state_name animal weight);
text x=land_x_text y=land_y_text text=animal / position=center 
 textattrs=(color=gray33 size=8pt) tip=none splitchar=' -';
text x=water_x_text y=water_y_text text=animal / position=right contributeoffsets=none
 textattrs=(color=gray33 size=8pt) tip=(state_name animal weight);
series x=x_line y=y_line / lineattrs=(color=gray33);
run;

proc sort data=my_data out=my_data;
by state_name;
run;

proc print data=my_data label noobs;
label state_name='State' animal='Animal' weight='Weight';
var state_name animal weight;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
