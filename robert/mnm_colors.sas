%let name=MnM_colors;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_data;
length mnm_color $10;
input mnm_color Count;
datalines;
Green  99
Red    86
Blue  102
Orange 73
Yellow 54
Brown  77
;
run;

proc sql noprint; 
create table my_data as
select unique *, count/sum(count) format=percent7.1 as calculated_percent
from my_data;
quit; run;

data my_data; set my_data;
adjusted_position=count-3;
run;

/* Keep the colors consistent, if data or data order changes */
data myattrs;
length value linecolor markercolor $100;
id="someid";
linecolor="gray99";
fillcolor="cx4cbbe6"; value="Blue"; output;
fillcolor="cx74e059"; value="Green"; output;
fillcolor="cxd22515"; value="Red"; output;
fillcolor="cxfbb635"; value="Orange"; output;
fillcolor="cxf4f25f"; value="Yellow"; output;
fillcolor="cx5d242a"; value="Brown"; output;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title='Frequency of Colors in an M&M Packet') 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=600px height=450px noborder; 

title1 color=gray33 height=17pt 'Frequency of Colors in an M&M Packet';

proc sort data=my_data out=my_data;
by descending count;
run;

/*
proc sgplot data=my_data noborder;
vbarparm category=mnm_color response=count / 
 datalabel=count datalabelattrs=(size=11pt color=gray33 weight=bold)
 barwidth=0.80;
yaxis display=(noticks noline)
 labelpos=top labelattrs=(size=11pt color=gray33)
 values=(0 to 120 by 20)
 valueattrs=(size=11pt color=gray33)
 grid gridattrs=(color=graydd);
xaxis display=(nolabel noticks)
 valueattrs=(size=11pt color=gray33 weight=bold);
run;
*/

/* label outside datalabel */
/*
proc sgplot data=my_data noborder noautolegend dattrmap=myattrs;
vbarparm category=mnm_color response=count / 
 group=mnm_color attrid=someid 
 datalabel=count datalabelattrs=(size=11pt color=gray33 weight=bold) 
 groupdisplay=cluster
 barwidth=0.80;
yaxis display=(noticks noline)
 labelpos=top labelattrs=(size=11pt color=gray33)
 values=(0 to 120 by 20)
 valueattrs=(size=11pt color=gray33)
 grid gridattrs=(color=graydd);
xaxis display=(nolabel noticks)
 valueattrs=(size=11pt color=gray33 weight=bold);
run;
*/

/* label inside seglabel */
/*
proc sgplot data=my_data noborder noautolegend dattrmap=myattrs;
vbarparm category=mnm_color response=count /
 group=mnm_color attrid=someid
 datalabel=calculated_percent datalabelattrs=(size=11pt color=gray33 weight=bold)
 groupdisplay=cluster
 seglabel seglabelattrs=(size=11pt color=gray33 weight=bold)
 barwidth=0.80;
yaxis display=(noticks noline)
 labelpos=top labelattrs=(size=11pt color=gray33)
 values=(0 to 120 by 20)
 valueattrs=(size=11pt color=gray33)
 grid gridattrs=(color=graydd);
xaxis display=(nolabel noticks)
 valueattrs=(size=11pt color=gray33 weight=bold);
run;
*/

/* label inside with backlight */
/*
proc sgplot data=my_data noborder noautolegend dattrmap=myattrs;
vbarparm category=mnm_color response=count /
 group=mnm_color attrid=someid
 datalabel=count datalabelattrs=(size=11pt color=gray33 weight=bold)
 groupdisplay=cluster
 barwidth=0.80;
text x=mnm_color y=adjusted_position text=calculated_percent / 
 strip position=bottom backlight=1.0 
 textattrs=(size=11pt color=gray33 weight=bold);
yaxis display=(noticks noline)
 labelpos=top labelattrs=(size=11pt color=gray33)
 values=(0 to 120 by 20) offsetmin=0
 valueattrs=(size=11pt color=gray33)
 grid gridattrs=(color=graydd);
xaxis display=(nolabel noticks)
 valueattrs=(size=11pt color=gray33 weight=bold);
run;
*/

/* label inside with backfill */
proc sgplot data=my_data noborder noautolegend dattrmap=myattrs;
vbarparm category=mnm_color response=count /
 group=mnm_color attrid=someid
 datalabel=calculated_percent datalabelattrs=(size=11pt color=gray33 weight=bold)
 groupdisplay=cluster
 barwidth=0.80;
text x=mnm_color y=adjusted_position text=count /
 strip position=bottom backfill fillattrs=(color=white transparency=.3)
 textattrs=(size=11pt color=gray33 weight=bold);
yaxis display=(noticks noline)
 labelpos=top labelattrs=(size=11pt color=gray33)
 values=(0 to 120 by 20) offsetmin=0
 valueattrs=(size=11pt color=gray33)
 grid gridattrs=(color=graydd);
xaxis display=(nolabel noticks)
 valueattrs=(size=11pt color=gray33 weight=bold);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
