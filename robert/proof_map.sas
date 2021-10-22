%let name=proof_map;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data my_map; set mapsgfk.world (where=(density<=3) drop=lat long);
run;

data my_data; set mapsgfk.world_attr (where=(idname not in ('Antarctica')));
placeholder='1';
run;

/* estimated these x/y coordinates from sgplot'ing the map coordinates below */
data text_data;
text_x=-17500;
text_y=4800;
my_text="Proof of Concept";
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Proof of Concept map") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=1100px height=500px border; 

proc sgmap maprespdata=my_data mapdata=my_map plotdata=text_data noautolegend;
styleattrs datacolors=(dodgerblue);
choromap placeholder / mapid=id lineattrs=(thickness=1 color=gray77) tips=none;
text x=text_x y=text_y text=my_text / textattrs=(weight=bold color=red size=80pt) 
 rotate=25 contributeoffsets=none transparency=.6;
run;

/* Used this to get a feel for the x/y coordinates, to hard-code the x/y for the overlaid text */
/*
proc sgplot data=my_map;
scatter x=x y=y;
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
