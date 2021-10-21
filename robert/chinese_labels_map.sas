%let name=chinese_labels_map;
filename odsout '.';

/*
This example is modeled after the following Tech Support example:
http://support.sas.com/kb/56/546.html

You must start your SAS session using the utf8 encoding,
in order to run this example. I do it by running the following
from the DOS command line:

sas.exe -config "C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\sasv9.cfg"

Actually, I got tired of typing all that, so I set up a .bat file ...
chinese_labels_map.bat, which contains the following:

  u:
  cd u:\public_html\democd90\
  sas.exe chinese_labels_map.sas -config "C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\sasv9.cfg"

I used this map to verify/sanity-check my map:
http://www.nationsonline.org/maps/china-provinces-map-855.jpg
*/

%annomac;


/* First, create the map of China, with borders by province */
/* not using lower-density, because of S1462422 */
data china_map; set mapsgfk.china /*(where=(density<=2) drop=resolution)*/;
run;
proc gproject data=china_map out=china_map eastlong latlong degrees project=cylindri latmin=17;
id id;
run;

proc gremove data=china_map out=china_map;
id id1 id;
by id1 notsorted;
run;

/* Calculate the x/y centroid for each area in the map */
%centroid(china_map,china_centers,id1,segonly=1);

proc sql noprint;

/* Get the province names */
create table province_names as
select unique id1, id1name, id1nameu
from mapsgfk.china_attr
where index(isoname,'TAIWAN')=0;

/* Merge the x/y centers with the text data */
create table province_names as
select unique province_names.*, china_centers.x, china_centers.y
from province_names left join china_centers
on province_names.id1=china_centers.id1;

quit; run;

/* turn the names into annotate commands */
data province_names; set province_names;
/* see defect S1320793 */
if id1='CN-61' then id1name='Shaanxi Sheng'; /* make 1 correction to the GFK data */

/* Shorten down some of the names, taking off 'city', 'province', etc */
id1name=tranwrd(id1name," Sheng",'');
id1name=tranwrd(id1name," Shi",'');
id1name=tranwrd(id1name," Zizhiqu",'');
id1name=tranwrd(id1name," Weiwu'er",'');
id1name=tranwrd(id1name," Zhuangzu",'');
id1name=tranwrd(id1name," Huizu",'');
id1name=tranwrd(id1name,"Tebiexingzhengqu",'');
if id1name='Xianggang' then id1name='Xianggang (Hong Kong)';
id1nameu=tranwrd(id1nameu,"\u7701",''); /* Sheng */
id1nameu=tranwrd(id1nameu,"\u5E02",''); /* Shi */
id1nameu=tranwrd(id1nameu,"\u81EA\u6CBB\u533A",''); /* Zizhiqu */
id1nameu=tranwrd(id1nameu,"\u58EE\u65CF",''); /* Zhuangzu */
id1nameu=tranwrd(id1nameu,"\u56DE\u65CF",''); /* Huizu */
id1nameu=tranwrd(id1nameu,"\u7279\u522B\u884C\u653F\u533A",''); /* extra on AoMen */
id1nameu=tranwrd(id1nameu,"\u7EF4\u543E\u5C14",''); /* extra on Xinjiang */
id1nameu=tranwrd(id1nameu,"\u7279\u5225\u884C\u653F\u5340",''); /* trim last part (Tebiexingzhengqu) off of xianggang (Hong kong) */
id1nameu=tranwrd(id1nameu,"\u4E2D\u83EF\u4EBA\u6C11\u5171\u548C\u570B",''); /* trim first part of xianggang (Hong Kong) */

/* Same thing for the next level down areas */
/* Shorten down some of the names, taking off 'city', 'province', etc */
idname=tranwrd(idname," Sheng",'');
idname=tranwrd(idname," Shi",'');
idname=tranwrd(idname," Zizhiqu",'');
idname=tranwrd(idname," Weiwu'er",'');
idname=tranwrd(idname," Zhuangzu",'');
idname=tranwrd(idname," Huizu",'');
idnameu=tranwrd(idnameu,"\u7701",''); /* Sheng */
idnameu=tranwrd(idnameu,"\u5E02",''); /* Shi */
idnameu=tranwrd(idnameu,"\u81EA\u6CBB\u533A",''); /* Zizhiqu */
idnameu=tranwrd(idnameu,"\u58EE\u65CF",''); /* Zhuangzu */
idnameu=tranwrd(idnameu,"\u56DE\u65CF",''); /* Huizu */

length text $200 color $8 my_html $300;
my_html=
 'title='||quote(
  trim(left(input(id1nameu,$uesc500.)))||'0d'x||
  trim(left(id1name)))||
 ' href='||quote('#'||trim(left(id1)));
xsys='2'; ysys='2'; hsys='d'; when='a';
function='label';
/* this is the chinese character version */
text=trim(left(input(id1nameu, $uesc500.))); 
position='b'; color='gray22'; size=11; output;
/* this is the english version of the text (positioned below the Chinese version) */
text=trim(left(id1name)); 
position='e'; color='gray88'; size=8; output;
run;

/* adjust label positions for a few of the labels */
data province_names; set province_names;
if id1name='Gansu' then do;
 x=x-130;
 y=y+90;
 end;
if id1name='Hebei' then do;
 y=y-55;
 x=x-20;
 end;
if id1name='Tianjin' then do;
 y=y-10;
 x=x+5;
 end;
if id1name='Beijing' then do;
 y=y+9;
 end;
if id1name='Neimenggu' then do;
 y=y-45;
 end;
if id1name='Heilongjiang' then do;
 y=y-45;
 end;
if id1name='Shaanxi' then do;
 y=y-50;
 x=x-30;
 end;
if id1name='Shanxi' then do;
 y=y-40;
 x=x-10;
 end;
run;



/* ------------------------------------------------------------ */

/* Get the map */
data provinces_map; set mapsgfk.china (drop=resolution);
original_id=_n_;
run;



/* Calculate the x/y centroid for each area in the map */
%centroid(provinces_map,centers,id,segonly=1);

proc sql noprint;
create table prefecture_names as
select unique id1, id1name, id1nameu, id, idname, idnameu
from mapsgfk.china_attr
where index(isoname,'TAIWAN')=0;
/* Merge the x/y centers with the text data */
create table prefecture_names as
select unique prefecture_names.*, centers.x, centers.y
from prefecture_names left join centers
on prefecture_names.id=centers.id;
quit; run;

/* turn the prefecture_names into annotate commands */
data prefecture_names; set prefecture_names;
/* see defect S1320793 */
if id1='CN-61' then id1name='Shaanxi Sheng'; /* make 1 correction to the GFK data */

/* Shorten down some of the names, taking off 'city', 'province', etc */
id1name=tranwrd(id1name," Sheng",'');
id1name=tranwrd(id1name," Shi",'');
id1name=tranwrd(id1name," Zizhiqu",'');
id1name=tranwrd(id1name," Weiwu'er",'');
id1name=tranwrd(id1name," Zhuangzu",'');
id1name=tranwrd(id1name," Huizu",'');
id1name=tranwrd(id1name," Tebiexingzhengqu",'');
if id1name='Xianggang' then id1name='Xianggang (Hong Kong)';
id1nameu=tranwrd(id1nameu,"\u7701",''); /* Sheng */
id1nameu=tranwrd(id1nameu,"\u5E02",''); /* Shi */
id1nameu=tranwrd(id1nameu,"\u81EA\u6CBB\u533A",''); /* Zizhiqu */
id1nameu=tranwrd(id1nameu,"\u58EE\u65CF",''); /* Zhuangzu */
id1nameu=tranwrd(id1nameu,"\u56DE\u65CF",''); /* Huizu */
id1nameu=tranwrd(id1nameu,"\u7279\u522B\u884C\u653F\u533A",''); /* extra on AoMen */
id1nameu=tranwrd(id1nameu,"\u7EF4\u543E\u5C14",''); /* extra on Xinjiang */
id1nameu=tranwrd(id1nameu,"\u7279\u5225\u884C\u653F\u5340",''); /* trim last part (Tebiexingzhengqu) off of xianggang (Hong kong) */
id1nameu=tranwrd(id1nameu,"\u4E2D\u83EF\u4EBA\u6C11\u5171\u548C\u570B",''); /* trim first part of xianggang (Hong Kong) */

/* Same thing for the next level down areas */
/* Shorten down some of the names, taking off 'city', 'province', etc */
idname=tranwrd(idname," Sheng",'');
idname=tranwrd(idname," Shi",'');
idname=tranwrd(idname," Zizhiqu",'');
idname=tranwrd(idname," Weiwu'er",'');
idname=tranwrd(idname," Zhuangzu",'');
idname=tranwrd(idname," Huizu",'');
idname=tranwrd(idname," Meng",'');
idname=tranwrd(idname," Zizhizhou",'');
idnameu=tranwrd(idnameu,"\u7701",''); /* Sheng */
idnameu=tranwrd(idnameu,"\u5E02",''); /* Shi */
idnameu=tranwrd(idnameu,"\u81EA\u6CBB\u533A",''); /* Zizhiqu */
idnameu=tranwrd(idnameu,"\u58EE\u65CF",''); /* Zhuangzu */
idnameu=tranwrd(idnameu,"\u56DE\u65CF",''); /* Huizu */
idnameu=tranwrd(idnameu,"\u76DF",''); /* Meng */
idnameu=tranwrd(idnameu,"\u5DDE",''); /* Zizhizhou */


length text $200 color $8 my_html $300;
my_html=
 'title='||quote(
  trim(left(input(idnameu,$uesc500.)))||'0d'x||
  trim(left(idname)))||
 ' href='||quote('#'||trim(left(id1)));
xsys='2'; ysys='2'; hsys='d'; when='a';
function='label';
/* this is the chinese character version */
text=trim(left(input(idnameu, $uesc500.))); 
position='b'; color='gray22'; size=11; output;
/* this is the english version of the text (positioned below the Chinese version) */
text=trim(left(idname)); 
position='e'; color='gray88'; size=8; output;
run;

/* adjust label positions for labels, if necessary */
data prefecture_names; set prefecture_names;
/*
if idname='Sheng Zhixia Jihang Zheng Chan Wie' then y=y-.008;
*/
run;

%macro do_map(prov);

ods html anchor="&prov";

data temp_data; set prefecture_names (where=(id1="&prov"));
run;

data temp_map; set provinces_map (where=(id1="&prov"));
run;

data anno_title; set temp_data (obs=1);
length text $200;
xsys='3'; ysys='3'; hsys='d'; when='a';
function='label'; position='6';
x=2;
y=97; text=input(id1nameu, $uesc500.); color='gray22'; size=16; output;
y=y-4.5; text=trim(id1name); color='gray88'; size=11; output;
run;

title h=5pct ' '; 
footnote;

goptions xpixels=850 ypixels=700;
proc gmap data=temp_data map=temp_map anno=anno_title;
id id;
choro id / nolegend
 coutline=cxDFAE74 anno=temp_data 
 html=my_html
 des='' name="&name._&prov";
run;

/*
proc print data=temp_data  style(data)={font_size=14pt};
var id idname idnameu text;
run;
*/

%mend;


goptions device=png;
goptions border;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm"
 (title="Chinese text labels on sas map") 
 style=htmlblue;

goptions gunit=pct htext=2.25 ftext='albany amt' ctext=gray33;

data anno_title; 
length text $200;
xsys='3'; ysys='3'; hsys='d'; when='a';
function='label'; style='albany amt'; position='5'; color='gray24'; size=32;
x=48;
y=94; text="Mainland China"; output;
y=y-7; text="Provinces"; output;
run;

pattern1 v=s c=cxfdfbf2 repeat=1000;

title; footnote;
goptions xpixels=950 ypixels=800;
proc gmap data=province_names map=china_map anno=anno_title;
id id1;
choro id1 / nolegend
 coutline=cxDFAE74 anno=province_names 
 html=my_html
 des='' name="&name";
run;

/*
proc print data=province_names  style(data)={font_size=14pt};
var id1 id1name id1nameu text;
run;
*/

proc sql noprint;
create table loop as select unique id1 from prefecture_names;
quit; run;

data _null_; set loop;
 call execute('%do_map('|| id1 ||');');
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
