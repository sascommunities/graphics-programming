%let name=area3;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input x y1 y2;
x_total=y1+y2;
datalines;
0 2.0 1.0
1 1.0 1.2
3 2.0 1.7
4 1.0 2.0
5 0.5 2.5
;
run;

data my_data; set my_data;
base1_pct=0; y1_pct=y1/x_total; 
base2_pct=y1_pct; y2_pct=y1_pct+(y2/x_total);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGplot 100% Stacked Area Plot")
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name"
 width=800px height=600px noborder;

title1 color=gray33 ls=0.0 h=23pt "100% Stacked Area Plot";

proc sgplot data=my_data noautolegend;
styleattrs datacolors=(cx993366 cx9999ff);
band x=x lower=base1_pct upper=y1_pct;
band x=x lower=base2_pct upper=y2_pct;
yaxis 
 values=(0 to 1 by .2) label='Y Axis'
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
