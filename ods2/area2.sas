%let name=area2;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input x y1 y2;
base1=0;
base2=y1;
y2_stacked=y2+y1;
datalines;
0 2.0 1.0
1 1.0 1.2
3 2.0 1.7
4 1.0 2.0
5 0.5 2.5
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot Stacked Area Plot")
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name"
 width=800px height=600px noborder;

title1 color=gray33 ls=0.0 h=23pt "Stacked Area Plot";

proc sgplot data=my_data noautolegend;
styleattrs datacolors=(cx993366 cx9999ff);
band x=x lower=base1 upper=y1;
band x=x lower=base2 upper=y2_stacked;
yaxis 
 values=(0 to 4 by 1) label='Y Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33)
 offsetmin=0 offsetmax=0 grid;
xaxis 
 values=(0 to 5 by 1) label='X Axis'
 labelattrs=(size=16pt weight=bold color=gray33) 
 valueattrs=(size=16pt weight=bold color=gray33) 
 offsetmin=0 offsetmax=0 grid;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
