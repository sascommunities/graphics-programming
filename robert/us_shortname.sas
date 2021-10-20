%let name=us_shortname;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Designed after:
https://twitter.com/simongerman600/status/1380271763767107592
*/

data my_data; set mapsgfk.us_states_attr; 
length colorvar $50;
colorvar='Something';
run;

data land_labels; set mapsgfk.uscenter (where=(ocean=''));
if statecode='HI' then do;
 x=x-.01;
 y=y-.01;
 end;
land_x_text=x; 
land_y_text=y;
run;

data water_labels; set mapsgfk.uscenter (where=(ocean='Y'));
water_x_text=x; 
water_y_text=y;
run;

data lines; set mapsgfk.uscenter (where=(ocean^=''));
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
length statename $100;
statename=fipnamel(state);
statename=substr(statename,2);
statename=propcase(statename);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US States - but the first letter is missing")
 style=htmlblue;

ods graphics / 
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 width=925px height=600px;

title1 color=gray33 height=24pt "US States - but the first letter is missing ...";

proc sgmap maprespdata=my_data mapdata=mapsgfk.us plotdata=my_labels noautolegend;
styleattrs datacolors=(grayef);
choromap colorvar / mapid=statecode lineattrs=(thickness=1 color=graybb);
text x=land_x_text y=land_y_text text=statename / position=center textattrs=(color=gray33 size=9pt);
text x=water_x_text y=water_y_text text=statename / position=right textattrs=(color=gray33 size=9pt) contributeoffsets=none;
series x=x_line y=y_line / lineattrs=(color=gray33);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
