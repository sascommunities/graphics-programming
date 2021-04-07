%let name=us_black_population;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
length race $10;
input population race;
datalines;
 43984096 Black
284225427 Not-Black
;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US Black Population") 
 style=htmlblue;

ods graphics / imagefmt=png imagename="&name" 
 width=650px height=600px noborder imagemap; 

title1 color=gray33 ls=0.3 h=15pt "Percent of U.S. Population that is Black (2019)";
title2 h=20pt 'a0'x;
footnote h=20pt 'a0'x;

proc sgpie data=my_data;
styleattrs datacolors=(cxa6d854 cxfc8d62);
pie race / response=population 
 startangle=90 direction=clockwise startpos=edge sliceorder=data
 datalabelattrs=(size=14pt color=cx333333)
 datalabeldisplay=(percent category);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
