%let name=pie4;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
input NAME $ 1-8 VALUE;
datalines;
Name A  5
Name B  6.8
Name C  9.2
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="SGpie Donut Chart (3D)") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=800px height=600px noborder imagemap; 

title1 color=gray33 ls=0.5 h=23pt "Donut Chart";
title2 color=gray33 ls=0.5 h=17pt "With 3D Shading";

proc sgpie data=my_data;
styleattrs datacolors=(cx9999ff cx993366 cxffffcc);
donut name / response=value startangle=0 startpos=edge ringsize=.5
 holevalue holelabel='Total:' holevalueattrs=(weight=bold)
 datalabelattrs=(size=16pt weight=bold)
 /*outlineattrs=(color=black)*/
 dataskin=gloss  /* <--- basically, added this line! */
 ;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
