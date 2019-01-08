%let name=bar3;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input CATEGORY SERIES $ 3-11 AMOUNT;
datalines;
1 Series A  5
2 Series A  6.8
3 Series A  9.2
1 Series B  6.5
2 Series B  6.9
3 Series B  5.6
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Horizontal Stacked Bar") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap; 

title1 color=gray33 ls=0.5 h=23pt "Horizontal Stacked Bar";
title2 color=gray33 ls=0.5 h=17pt "Compares the contribution of each value";
title3 color=gray33 ls=0.5 h=17pt "to a total across categories";

proc sgplot data=my_data noautolegend;
styleattrs datacolors=(cx9999ff cx993366);
hbar category / response=amount stat=sum 
 group=series /*groupdisplay=cluster grouporder=descending*/
 outlineattrs=(color=black) nostatlabel;
xaxis 
 values=(0 to 16 by 4)
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmax=0 grid minor minorcount=1;
yaxis 
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 display=(noticks);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
