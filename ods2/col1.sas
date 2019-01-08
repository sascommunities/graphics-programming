%let name=col1;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input CATEGORY SERIES $ 3-11 AMOUNT;
datalines;
1 Series A  5
2 Series A  7.8
1 Series B  9.5
2 Series B  5.9
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Grouped Bar") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap; 

title1 color=gray33 ls=0.5 h=23pt "Grouped Bar";
title2 color=gray33 ls=0.5 h=17pt "Compares values across categories";

proc sgplot data=my_data noautolegend;
styleattrs datacolors=(cx9999ff cx993366);
vbar category / response=amount stat=sum 
 group=series groupdisplay=cluster
 outlineattrs=(color=black) nostatlabel;
yaxis 
 values=(0 to 10 by 2)
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmax=0 grid minor minorcount=1;
xaxis 
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 labelpos=right;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
