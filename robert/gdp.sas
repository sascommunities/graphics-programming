%let name=gdp;
filename odsout '.';

/*
Imitation & enhancement of 
http://strangemaps.wordpress.com/2007/06/10/131-us-states-renamed-for-countries-with-similar-gdps/
Which I believe was moved to:
http://bigthink.com/strange-maps/131-us-states-renamed-for-countries-with-similar-gdps

And here's a 2015 version:
http://bigthink.com/strange-maps/us-states-compared-to-countries-with-similar-gdps-2015
*/

data mydata;
input statecode $ 1-2 equivalent_gdp_country $ 8-38;
datalines;
AL     Iran 
AR     Pakistan 
AZ     Thailand 
CA     France 
CO     Finland 
CT     Greece 
DC     New Zealand 
DE     Romania 
FL     Republic of Korea
GA     Switzerland 
IA     Venezuela 
ID     Ukraine 
IL     Mexico 
IN     Denmark 
KS     Malaysia 
KY     Portugal 
LA     Indonesia 
MA     Belgium 
MD     Hong Kong 
ME     Morocco 
MI     Argentina 
MN     Norway 
MO     Poland 
MS     Chile 
MT     Tunisia 
NC     Sweden 
ND     Ecuador 
NE     Czech Republic 
NH     Bangladesh 
NJ     Russia 
NM     Hungary 
NV     Ireland 
NY     Brazil 
OH     Australia 
OK     Philippines 
OR     Israel 
PA     Netherlands 
RI     Vietnam 
SC     Singapore 
SD     Croatia 
TN     Saudi Arabia 
TX     Canada 
UT     Peru 
VA     Austria 
VT     Dominican Rep. 
WA     Turkey 
WI     So. Africa
WV     Algeria 
WY     Uzbekistan 
AK     Belarus
HI     Nigeria
;
run;

/* html mouse-over text */
data mydata; set mydata;
length html $1000;
state=stfips(statecode);
html='title='||quote(trim(left(fipnamel(state)))||' ~= '||trim(left(equivalent_gdp_country)));
run;

/* 
Create an annotate dataset with the state abbreviations, to use to label each of the states.  
*/
data st_anno; set mapsgfk.uscenter;
orig_order+1;
run;
proc sql;
create table st_anno as
select unique st_anno.*, mydata.equivalent_gdp_country, mydata.html
from st_anno left join mydata
on st_anno.state=mydata.state
order by orig_order;
quit; run;
/* this code slightly modified from online help example */
/* The tricky part is that you want some labels to be out over the ocean. */
data st_anno; set st_anno;
length function $8;
xsys='2'; ysys='2'; hsys='3'; when='a';
retain ocean_flag 0;
anno_flag=2;
function='label'; style="albany amt/bold"; color='gray44'; size=2.0; position='5';
text=trim(left(equivalent_gdp_country));
if ocean='Y' then do;
 position='6';
 output;
 function='move';
 ocean_flag=1;
 end;
else if ocean_flag=1 then do;
 function='draw';
 size=.25;
 ocean_flag=0;
 end;
output;
run;
 
data states; set mapsgfk.us;
run;

/* Create an annotate dataset, where each of the states is just a gray
   filled polygon -- when='b' draws this behind/before the real map */
data shadow_anno; set states; 
by state segment notsorted;
length color function $8;
xsys='2'; ysys='2'; when='B';
color='gray88'; style='msolid';
if first.state or first.segment then function='poly';
else function='polycont';
run;
/* Give the shadow a little x & y offset, so it will look like a shadow */
data shadow_anno; set shadow_anno;
x=x+.002; y=y-.002;
run;


goptions device=png;
goptions xpixels=910 ypixels=550;
goptions border;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US States Renamed for Countries with Similar GDPs") 
 style=htmlblue;

goptions ftitle="albany amt/bold" ftext="albany amt" gunit=pct htitle=4.5 htext=2.5 ctext=gray22;

title1 ls=1.5 "US States Renamed for Countries with Similar GDPs";
footnote 
 link='http://bigthink.com/strange-maps/131-us-states-renamed-for-countries-with-similar-gdps'
 c=gray ls=1.0
 "Data source - http://bigthink.com/strange-maps/131-us-states-renamed-for-countries-with-similar-gdps";

pattern1 v=s c=cxFFFFF0;

proc gmap data=mydata map=states anno=shadow_anno; 
id state; 
choro state / levels=1 nolegend
 anno=st_anno coutline=blue
 html=html
 des='' name="&name"; 
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
