%let name=minard;
filename odsout '.';

/* Written by Robert Allison (Robert.Allison@sas.com) */

/*
Reproduction of Minard's famous map of Napoleon's march on Moscow,
similar to the following...

Links:
http://www.math.yorku.ca/SCS/Gallery/re-minard.html  (links to many versions)

http://www.spss.com/research/wilkinson/TheGrammarOfGraphics/minard.txt    <-- data
http://www.spss.com/research/wilkinson/TheGrammarOfGraphics/GOG.html

http://www.math.yorku.ca/SCS/Gallery/minard/
http://www.math.yorku.ca/SCS/Gallery/minard/Minard-IML.jpg (lat/long!)
http://www.math.yorku.ca/SCS/Gallery/minard/NapoleonsMarch.iml (iml code w/ lat/long)
http://www.math.yorku.ca/SCS/Gallery/minard/march-animated.gif
http://www.math.yorku.ca/SCS/Gallery/minard/minard-nvizn.gif
http://www.math.yorku.ca/SCS/Gallery/minard/minard-odt.jpg

http://www.edwardtufte.com/tufte/posters
http://www.edwardtufte.com/tufte/minard
http://www.csiss.org/classics/content/58
*/

data my_map; set mapsgfk.world (where=(density<=3) drop=resolution);
 country=id;  /* This just makes the code easier to follow */
 length country_name $20;
 country_name=idname;
run;

proc sql;
 create table countries as 
 select unique country, country_name
 from my_map;
quit; run;

data countries; set countries;
length my_html $300;
my_html= 
 'title='||quote(trim(left(country_name)))||
 ' href='||quote('minard_info.htm');;
run;


/*
Got data from...
http://www.spss.com/research/wilkinson/TheGrammarOfGraphics/minard.txt

I added one extra obsn for group=2 during the river-crossing, so it
was more evident that the 2 groups combined...
28.3  54.4   28000  R  2
*/
data armyline;
length direc $1;
length direction $10;
input long lat surviv direc group ;
  n+1;
  if direc eq 'A' then direction='advance';
  else if direc eq 'R' then direction='retreat';
datalines;
24.0  54.9  340000  A  1
24.5  55.0  340000  A  1
25.5  54.5  340000  A  1
26.0  54.7  320000  A  1
27.0  54.8  300000  A  1
28.0  54.9  280000  A  1
28.5  55.0  240000  A  1
29.0  55.1  210000  A  1
30.0  55.2  180000  A  1
30.3  55.3  175000  A  1
32.0  54.8  145000  A  1
33.2  54.9  140000  A  1
34.4  55.5  127100  A  1
35.5  55.4  100000  A  1
36.0  55.5  100000  A  1
37.6  55.8  100000  A  1
37.5  55.7   98000  R  1
37.0  55.0   97000  R  1
36.8  55.0   96000  R  1
35.4  55.3   87000  R  1
34.3  55.2   55000  R  1
33.3  54.8   37000  R  1
32.0  54.6   24000  R  1
30.4  54.4   20000  R  1
29.2  54.4   20000  R  1
28.5  54.3   20000  R  1
28.3  54.4   20000  R  1
24.0  55.1   60000  A  2
24.5  55.2   60000  A  2
25.5  54.7   60000  A  2
26.6  55.7   40000  A  2
27.4  55.6   33000  A  2
28.7  55.5   30000  A  2
29.2  54.3   30000  R  2
28.5  54.2   30000  R  2
28.3  54.3   28000  R  2
28.3  54.4   28000  R  2
27.5  54.5   20000  R  2
26.8  54.3   12000  R  2
26.4  54.4   14000  R  2
24.6  54.5    8000  R  2
24.4  54.4    4000  R  2
24.2  54.4    4000  R  2
24.1  54.3    4000  R  2
24.0  55.2   22000  A  3
24.5  55.3   22000  A  3
24.6  55.8    6000  A  3
24.2  54.4    6000  R  3
24.1  54.3    6000  R  3
;
run;

proc sort data=armyline out=armyline;
 by group n;
run;

%let maxwidth=3;   /* Maximum width of line */
%let maxdot=1.5;   /* Maximum size (radius) of vertex fill-in dot */
data armyline; set armyline;
length function color $12 style $30 text $20 html $500;
xsys='2'; ysys='2'; hsys='3'; when='a';
by group;
  anno_flag=1;
  if first.group then do;
    function='move';
    output;
    end;
  else do;
    if direc eq 'A' then color='cxaddd8e';
    else if direc eq 'R' then color='cxfe0000';
    function='draw';
    size=(surviv/340000) * &maxwidth;
    output;
    /* Vertex fill-in dot -- this gives smoother transition between line segments, like a kneecap/elbow, 
       and also gives a place for html charttips (since line segments don't support charttips) */
    size=(surviv/340000) * &maxdot;
    function='pie'; style='psolid'; rotate=360; 
    length html $100;
    html= 
     'title='||quote(trim(left(put(surviv,comma7.0))||' survivors during '||trim(left(direction)) ))||
     ' href='||quote('minard_info.htm');;
    output;
    end;
run;

data drillbox;
length function color $12 style $30 position $1 text $20 html $500;
xsys='2'; ysys='2'; hsys='3'; when='a';
anno_flag=6;
size=.1; line=2; color='black';
html= 
 'title='||quote('zoom in')||
 ' href='||quote('zoom.htm');;
function='poly';
long=23.4;
lat=52.0;
output;
function='polycont';
long=39.0;
lat=52.0;
output;
long=39.0;
lat=56.5;
output;
long=23.4;
lat=56.5;
output;
run;


data cities;
input long lat city $ 11-41;
datalines;
24.0 55.0 Kowno          
25.3 54.7 Wilna         
26.4 54.4 Smorgoni     
26.8 54.3 Molodexno   
27.7 55.2 Gloubokoe      
28.5 54.3 Studienska   
28.7 55.5 Polotzk     
29.2 54.4 Bobr       
30.2 55.3 Witebsk                  
30.4 54.5 Orscha                  
32.0 54.8 Smolensk              
33.2 54.9 Dorogobouge          
34.3 55.2 Wixma               
34.4 55.5 Chjat              
36.0 55.5 Mojaisk           
37.6 55.8 Moscou           
36.6 55.3 Tarantino       
36.5 55.0 Malo-jarosewli 
;
run;

/* 
Annotate a black dot/pie at each city, with mouseover html charttip
showing the city name.  (This variable *must* be called 'html'.) 
*/
data cities; set cities;
length function color $12 style $30 text $20 html $500;
xsys='2'; ysys='2'; hsys='3'; when='a';
anno_flag=2;
length html $ 100;
html=
 'title='||quote(trim(left(city)))||
 ' href='||quote('minard_info.htm');;
function='pie'; color='black'; style='psolid'; position='5'; rotate=360; size=.3;
run;

/* Blue rectangle behind map area (ie, water) */
/* Along certain edges, I had to use these .01 offsets,
   because gproject clipping was trimming off the edge otherwise */
data blue_anno;
length function style color $8;
xsys='2'; ysys='2'; hsys='3'; when='b';
anno_flag=3;
 color='cx35b2e0';
 style='msolid';
 function='poly';
  long=5; lat=39+.01; output;
 function='polycont';
 lat=39+.01;
 do long=5 to 40 by 5;
   output;
 end;
 long=39.99;
 do lat=39+5 to 60 by 5;
   output;
 end;
 lat=60;
 do long=40 to 5 by -5;
   output;
 end;
 long=5;
 do lat=60 to 5+5 by -5;
   output;
 end;
 long=5; lat=39+.01; output;
run;


data names;
input long lat country_name $ 11-31;
datalines;
32.0 57.5 Russia                
 6.4 48.8 France                
10.0 51.5 Germany               
19.0 52.5 Poland                
27.5 53.2 Belarus               
24.0 56.0 Lithuania             
;
run;

data names; set names;
length function style color $12 text $20 html $300;
xsys='2'; ysys='2'; hsys='3'; when='a';
function='label'; color='black'; style='albany amt'; position='5'; size=3;
text=trim(left(country_name));
anno_flag=4;
run;


data combined;
 set 
 my_map
 armyline
 cities
 blue_anno
 names
 drillbox
 ;
run;

proc gproject data=combined out=combined dupok
  latlong eastlong degrees
  project=cylindri
  latmax=60
  latmin=39
  longmin=5
  longmax=40
  ;
  id country;
run;

data my_map armyline cities blue_anno names drillbox;
  set combined;
  if anno_flag=1 then output armyline;
  else if anno_flag=2 then output cities;
  else if anno_flag=3 then output blue_anno;
  else if anno_flag=4 then output names;
  else if anno_flag=6 then output drillbox;
  else output my_map;
run;


data anno1; 
 set blue_anno drillbox armyline cities names;
run;


goptions device=png;
goptions xpixels=700 ypixels=600;
goptions noborder;
 
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm"
 (title="Napoleon's March 50,000-mile view (on modern map)") 
 style=sasweb gtitle nogfootnote;

goptions gunit=pct htitle=4.5 htext=3 ftitle="albany amt/bold" ftext="albany amt";

pattern1 v=s c=tan repeat=500;

title1 ls=1.0 "Napoleon's Russian Campaign, 1812";
title2 "Plotted on a modern map";

footnote h=10pt f="albany amt" "Mouse over dots, campaign path, and countries to see more info";

proc gmap map=my_map data=countries anno=anno1;
id country;
choro country / levels=1 nolegend
 stretch /* I normally wouldn't 'stretch' the map, but otherwise this area is pretty narrow */
 coutline=gray
 html=my_html
 des='' name="&name";
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
