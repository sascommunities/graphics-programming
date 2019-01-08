%let name=col5;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input CATEGORY SERIES $ 3-11 AMOUNT;
datalines;
1 Series A  5.0
2 Series A  6.8
3 Series A  9.2
1 Series B  6.5
2 Series B  6.9
3 Series B  5.6
1 Series C  2.3
2 Series C  3.1
3 Series C  2.3
;
run;

proc sql;
 create table my_data as
 select *, sum(amount) as bartotal
 from my_data
 group by category;
quit; run;

data my_data; set my_data;
format catpct percent6.0;
catpct=amount/bartotal;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot 100% Stacked Bar") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap; 

title1 color=gray33 ls=0.5 h=23pt "100% Stacked Bar";
title2 color=gray33 ls=0.5 h=17pt "Compares the percent each value";
title3 color=gray33 ls=0.5 h=17pt "to a total across categories";

proc sgplot data=my_data noautolegend pad=(left=10% right=15%);
label catpct='PERCENT';
styleattrs datacolors=(cx9999ff cx993366 cxffffcc);
vbar category / response=catpct stat=sum 
 group=series barwidth=.6
 outlineattrs=(color=black) nostatlabel;
yaxis 
 values=(0 to 1 by .2)
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmax=0 grid minor minorcount=1;
xaxis 
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 display=(noticks);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
