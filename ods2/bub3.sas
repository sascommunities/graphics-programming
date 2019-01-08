%let name=bub3;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
length color $ 8;
input series $ 1-1 x y value;
datalines;
A 1.0 1.0 .65
A 2.0 0.9 0.3
B 1.4 2.3 .65
B 2.2 1.4 0.3
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Bubble with Transparency") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap;

title1 color=gray33 ls=0.0 h=23pt "Transparent Bubbles";

proc sgplot data=my_data aspect=1 noautolegend;
styleattrs datacolors=(cx9999ff cx993366);
bubble x=x y=y size=value / group=series proportional 
 bradiusmax=70px lineattrs=(color=gray33) transparency=.5;
yaxis 
 values=(0 to 3 by 1) label='Y Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 offsetmin=0 offsetmax=0 grid minor minorcount=1;
xaxis 
 values=(0 to 3 by 1) label='X Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmin=0 offsetmax=0 grid minor minorcount=1;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
