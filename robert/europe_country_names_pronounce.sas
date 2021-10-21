%let name=europe_country_names_pronounce;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to this map:
https://www.reddit.com/r/MapFans/comments/9govo1/what_countries_call_themselves/
but with drilldowns to pronunciation pages

Found text for actual country names on Wikipedia pages.

Copy-n-pasted the country name text here to get the Unicode chars:
https://unicodelookup.com/#Espa%C3%B1a/

Substituted the country name text here to get the pronunciation url:
https://forvo.com/word/espa%C3%B1a/
*/

ods escapechar='^';

data my_data;

length country_us country_native $1000 pronunciation_link $300;

country_us='Russia';
country_native="^{unicode '0420'x}^{unicode '043e'x}^{unicode '0441'x}^{unicode '0441'x}^{unicode '0438'x}^{unicode '044f'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D1%80%D0%BE%D1%81%D1%81%D0%B8%D1%8F/#ru';
lat=57.5017484; long=35.0890984;
output;

country_us='Ireland';
country_native="^{unicode '00c9'x}ire";
unicode='yes';
pronunciation_link='https://forvo.com/word/%C3%A9ire/';
lat=53.3236495; long=-8.0;
output;

country_us='Iceland';
country_native="^{unicode '00cd'x}sland";
unicode='yes';
pronunciation_link='https://forvo.com/word/%C3%ADsland/';
lat=64.7929395; long=-18.4461215;
output;

country_us='Turkey';
country_native="T^{unicode '00fc'x}rkiye";
unicode='yes';
pronunciation_link='https://forvo.com/word/t%C3%BCrkiye/';
lat=39.2022916; long=34.0314069;
output;

country_us='Spain';
country_native="Espa^{unicode '00f1'x}a";
unicode='yes';
pronunciation_link='https://forvo.com/word/espa%C3%B1a/';
lat=39.2625179; long=-3.7622068;
output;

country_us='France';
country_native="R^{unicode '00e9'x}publique fran^{unicode '00e7'x}aise";
unicode='yes';
pronunciation_link='https://forvo.com/search/R%C3%A9publique%20fran%C3%A7aise/';
lat=45.6706989; long=2.2843748;
output;

country_us='Germany';
country_native='Deutschland';
unicode='no';
pronunciation_link='https://forvo.com/word/deutschland/';
lat=51.8; long=10.9189468;
output;

country_us='Ukraine';
country_native="^{unicode '0423'x}^{unicode '043a'x}^{unicode '0440'x}^{unicode '0430'x}^{unicode '0457'x}^{unicode '043d'x}^{unicode '0430'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D1%83%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D0%B0/';
lat=50.0066129; long=30.3141503;
output;

country_us='Belarus';
country_native="^{unicode '0411'x}^{unicode '0435'x}^{unicode '043b'x}^{unicode '0430'x}^{unicode '0440'x}^{unicode '0443'x}^{unicode '0441'x}^{unicode '044c'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D0%B1%D0%B5%D0%BB%D0%B0%D1%80%D1%83%D1%81%D1%8C/';
lat=53.2522807; long=27.4173642;
output;

country_us='Norway';
country_native='Norge';
unicode='no';
pronunciation_link='https://forvo.com/word/norge/';
lat=61.4020914; long=10.0402887;
output;

country_us='Sweden';
country_native='Sverige';
unicode='no';
pronunciation_link='https://forvo.com/word/sverige/';
lat=64.3543965; long=16.9169801;
output;

country_us='Finland';
country_native='Suomi';
unicode='no';
pronunciation_link='https://forvo.com/word/suomi/';
lat=62.3792791; long=25.4445066;
output;

country_us='United Kingdom';
country_native='UK';
unicode='no';
pronunciation_link='https://forvo.com/word/united_kingdom/';
lat=53.0; long=-1.5622334;
output;

country_us='Poland';
country_native='Polska';
unicode='no';
pronunciation_link='https://forvo.com/word/polska/';
lat=52.1594256; long=19.8721301;
output;

country_us='Romania';
country_native="Rom^{unicode '00e2'x}nia";
unicode='yes';
pronunciation_link='https://forvo.com/word/rom%C3%A2nia/';
lat=45.773731; long=24.934295;
output;

country_us='Portugal';
country_native="Rep^{unicode '00fa'x}blica Portuguesa";
unicode='yes';
pronunciation_link='https://forvo.com/search/Rep%C3%BAblica%20Portuguesa/';
lat=40.9299942; long=-7.8656979;
output;

country_us='Italy';
country_native='Italia';
unicode='no';
pronunciation_link='https://forvo.com/word/italia/';
lat=42.3677187; long=13.0457051;
output;

country_us='Estonia';
country_native='Eesti';
unicode='no';
pronunciation_link='https://forvo.com/word/eesti/';
lat=58.8742946; long=25.4488896;
output;

country_us='Latvia';
country_native='Latvija';
unicode='no';
pronunciation_link='https://forvo.com/word/latvija/';
lat=56.9745255; long=24.9012921;
output;

country_us='Lithuania';
country_native='Lietuva';
unicode='no';
pronunciation_link='https://forvo.com/word/lietuva/';
lat=55.6252079; long=24.0465547;
output;

country_us='Bulgaria';
country_native="^{unicode '0411'x}^{unicode '044a'x}^{unicode '043b'x}^{unicode '0433'x}^{unicode '0430'x}^{unicode '0440'x}^{unicode '0438'x}^{unicode '044f'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D0%B1%D1%8A%D0%BB%D0%B3%D0%B0%D1%80%D0%B8%D1%8F/';
lat=42.6926113; long=24.9904321;
output;

country_us='Denmark';
country_native='Danmark';
unicode='no';
pronunciation_link='https://forvo.com/word/danmark/';
lat=56.3388155; long=9.0973988;
output;

country_us='Belgium';
country_native="Belgi^{unicode '00eb'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/belgi%C3%AB/';
lat=50.8818013; long=4.3623776;
output;

country_us='Netherlands';
country_native='Nederland';
unicode='no';
pronunciation_link='https://forvo.com/word/nederland/';
lat=52.6638105; long=5.2387517;
output;

country_us='Czech Republic';
country_native="^{unicode '010c'x}esko";
unicode='yes';
pronunciation_link='https://forvo.com/word/%C4%8Desko/';
lat=49.8714705; long=14.9756897;
output;

country_us='Slovakia';
country_native='Slovensko';
unicode='no';
pronunciation_link='https://forvo.com/word/slovensko/';
lat=48.9102382; long=19.0771417;
output;

country_us='Switzerland';
country_native='Confoederatio Helvetica';
unicode='no';
pronunciation_link='https://forvo.com/word/confoederatio_helvetica/';
lat=47.0230864; long=7.9865305;
output;

country_us='Austria';
country_native="^{unicode '00d6'x}sterreich";
unicode='yes';
pronunciation_link='https://forvo.com/word/%C3%B6sterreich/';
lat=47.6689537; long=14.7380776;
output;

country_us='Slovenia';
country_native='Slovenija';
unicode='no';
pronunciation_link='https://forvo.com/word/slovenija/';
lat=46.245984; long=14.6916228;
output;

country_us='Croatia';
country_native='Hrvatska';
unicode='no';
pronunciation_link='https://forvo.com/word/hrvatska/';
lat=45.1692774; long=15.4033619;
output;

country_us='Bosnia and Herzegovina';
country_native='Bosna i Hercegovina';
unicode='no';
pronunciation_link='https://forvo.com/word/bosna_i_hercegovina/';
lat=44.005846; long=17.0945598;
output;

country_us='Serbia';
country_native="^{unicode '0421'x}^{unicode '0440'x}^{unicode '0431'x}^{unicode '0438'x}^{unicode '0458'x}^{unicode '0430'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D1%81%D1%80%D0%B1%D0%B8%D1%98%D0%B0/';
lat=44.815247; long=20.4683662;
output;

country_us='Hungary';
country_native="Magyarorsz^{unicode '00e1'x}g";
unicode='yes';
pronunciation_link='https://forvo.com/word/magyarorsz%C3%A1g/';
lat=47.0572131; long=18.9916855;
output;

country_us='Montenegro';
country_native="^{unicode '0426'x}^{unicode '0440'x}^{unicode '043d'x}^{unicode '0430'x}^{unicode '0020'x}^{unicode '0413'x}^{unicode '043e'x}^{unicode '0440'x}^{unicode '0430'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%D1%86%D1%80%D0%BD%D0%B0_%D0%B3%D0%BE%D1%80%D0%B0/';
lat=43.0397201; long=18.6658767;
output;

country_us='Greece';
country_native="^{unicode '0395'x}^{unicode '03bb'x}^{unicode '03bb'x}^{unicode '03ac'x}^{unicode '03b4'x}^{unicode '03b1'x}";
unicode='yes';
pronunciation_link='https://forvo.com/word/%CE%B5%CE%BB%CE%BB%CE%AC%CE%B4%CE%B1/';
lat=39.0682827; long=21.9002131;
output;

country_us='Macedonia';
country_native="^{unicode '041c'x}^{unicode '0430'x}^{unicode '043a'x}^{unicode '0435'x}^{unicode '0434'x}^{unicode '043e'x}^{unicode '043d'x}^{unicode '0438'x}^{unicode '0458'x}^{unicode '0430'x}";
unicode='yes';
pronunciation_link='https://forvo.com/search/%D0%9C%D0%B0%D0%BA%D0%B5%D0%B4%D0%BE%D0%BD%D0%B8%D1%98%D0%B0';
lat=41.7183556; long=21.5932999;
output;

country_us='Albania';
country_native="Shqip^{unicode '00eb'x}ria";
unicode='yes';
pronunciation_link='https://forvo.com/word/shqip%C3%ABria/';
lat=40.7387968; long=19.9738828;
output;

country_us='Moldova';
country_native='Moldova';
unicode='no';
pronunciation_link='https://www.macmillandictionary.com/us/pronunciation/american/moldova';
lat=47.3486161; long=28.5408114;
output;

run;

data my_map; set mapsgfk.world (where=(density<=3 and idname not in ('Greenland' 'Svalbard and Jan Mayen')));
if idname='Russian Federation' then idname='Russia';
run;

proc gproject data=my_map out=my_map (drop = lat long) latlong eastlong degrees dupok
 project=miller2
 latmin=34.5 latmax=73
 longmin=-25 longmax=43
 parmout=projparm;
id id;
run;

proc gproject data=my_data out=my_data latlong eastlong degrees dupok
 project=miller2
 parmin=projparm parmentry=my_map;
id;
run;

data anno_names; set my_data;
if country_us in ('Switzerland' 'Austria' 'Slovenia' 'Croatia' 'Macedonia'
 'Bosnia and Herzegovina' 'Serbia' 'Hungary' 'Montenegro' 'Albania') 
 then do;
 x_small=x;
 y_small=y;
 end;
else if country_us in ('Portugal' 'Bulgaria' 'Denmark' 'Belgium' 'Netherlands' 
 'Czech Republic' 'Slovakia' 'Moldova')
 then do;
 x_medium=x;
 y_medium=y;
 end;
else do;
 x_large=x;
 y_large=y;
 end;
run;

data map_data; set anno_names;
colorvar='1';
idname=country_us;
my_html=html;
run;

/* Use this data, if you just want to see the SAS-map name for each country in mouse-over */
/*
data map_data; set mapsgfk.world_attr;
colorvar='1';
if idname='Russian Federation' then idname='Russia';
country_us=idname;
length my_html $300;
my_html='title='||quote(trim(left(idname)));
run;
*/


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="What Countries Call Themselves (Europe)") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=1000px height=700px border; 

title1 c=gray33 h=18pt "What Countries Call Themselves";
title2 c=gray77 h=14pt "click country names to hear pronunciations";

proc sgmap mapdata=my_map maprespdata=map_data noautolegend plotdata=anno_names;
label country_us='Country';
choromap / mapid=idname lineattrs=(color=pink) /*tip=none*/;
styleattrs datacolors=(grayf9) backcolor=cxF0F8FF;
choromap colorvar / mapid=idname lineattrs=(color=graycc) 
 tip=(country_us) url=pronunciation_link;
text x=x_large y=y_large text=country_native / textattrs=(color=blue size=14pt /*weight=bold*/)
 tip=(country_us) url=pronunciation_link;
text x=x_medium y=y_medium text=country_native / textattrs=(color=blue size=11pt)
 tip=(country_us) url=pronunciation_link;
text x=x_small y=y_small text=country_native / textattrs=(color=blue size=8pt)
 tip=(country_us) url=pronunciation_link;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
