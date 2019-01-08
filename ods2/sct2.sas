%let name=sct2;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input x y1 y2;
datalines;
0.5 1.0 3.1 
1.5 2.8 1.3 
2.5 0.5 1.1 
3.5 2.0 3.1 
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Series Plot Lines Without Markers") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=650px height=650px noborder imagemap; 

title1 color=gray33 ls=0.0 h=23pt "Series Plot Lines";
title2 color=gray33 ls=0.2 h=17pt "Without Markers";

proc sgplot data=my_data aspect=1 noautolegend;
styleattrs datacolors=(cx9999ff cx993366);
series x=x y=y1 / lineattrs=(color=navy thickness=3px);
series x=x y=y2 / lineattrs=(color=magenta thickness=3px);
yaxis 
 values=(0 to 4 by 1) label='Y Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 offsetmin=0 offsetmax=0 grid minor minorcount=3;
xaxis 
 values=(0 to 4 by 1) label='X Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmin=0 offsetmax=0 grid minor minorcount=3;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
