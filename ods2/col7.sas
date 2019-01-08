%let name=col7;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input CATEGORY $ 1 AMOUNT;
datalines;
A  5
B  6.8
C  9.2
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Simple Bar Chart") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap; 

title1 color=gray33 ls=0.5 h=23pt "Simple Bar Chart";

proc sgplot data=my_data pad=(left=10% right=15%) noborder;
vbar category / response=amount stat=sum 
 barwidth=.6
 fillattrs=(color=cx9999ff)
 outlineattrs=(color=black) nostatlabel;
yaxis 
 values=(0 to 10 by 2)
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 display=(noticks noline) offsetmax=0 grid;
xaxis 
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 display=(noticks);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
