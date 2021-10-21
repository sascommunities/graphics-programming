%let name=hockey;
filename odsout '.';


/* Canada & Mexico */
data mymap1; set mapsgfk.namerica (where=(density<=2 and (idname in ('Canada' 'Mexico'))) drop=resolution);
id=idname;
run;

/* US */
data mymap2; set mapsgfk.us_states (where=(density<=3 and statecode not in ('AK' 'HI' 'PR')) drop=resolution);
id=statecode;
run;

data mymap; set mymap1 mymap2;
run;

data canada_data; 
length country City logo Teamname $50;
x_offset=0; y_offset=0;
country='CA';
City='Montreal'; logo='logos/mon38.gif'; Teamname='Montreal Canadiens'; x_offset=0; y_offset=1; output;
City='Ottawa'; logo='logos/ott38.gif'; Teamname='Ottawa Senators';      x_offset=0; y_offset=0; output;
City='Toronto'; logo='logos/tor38.gif'; Teamname='Toronto Maple Leafs'; x_offset=0; y_offset=1; output;
City='Calgary'; logo='logos/cgy38.gif'; Teamname='Calgary Flames';      x_offset=0; y_offset=0; output;
City='Edmonton'; logo='logos/edm38.gif'; Teamname='Edmonton Oilers';    x_offset=0; y_offset=0; output;
City='Vancouver'; logo='logos/van38.gif'; Teamname='Vancouver Canucks'; x_offset=0; y_offset=0; output;
run;

libname mylib '../democd28';
proc sql;
create table canada_data as
select canada_data.*, worldcts.lat, worldcts.long
from canada_data left join mylib.worldcts on
(canada_data.country = worldcts.country) and
(canada_data.City = worldcts.City);
quit; run;

data us_data;
length country City logo Teamname $50;
x_offset=0; y_offset=0;
country='US';
st='GA'; City='Atlanta'; logo='logos/atl38.gif'; Teamname='Atlanta Thrashers';        x_offset=0; y_offset=0; output;
st='NC'; City='Raleigh'; logo='logos/car38.gif'; Teamname='Carolina Hurricanes';      x_offset=0; y_offset=0; output;
st='NJ'; City='Newark'; logo='logos/n.j38.gif'; Teamname='New Jersey Devils';         x_offset=3; y_offset=0; output;
st='MA'; City='Boston'; logo='logos/bos38.gif'; Teamname='Boston Bruins';             x_offset=1; y_offset=1; output;
st='NY'; City='New York'; logo='logos/nyi38.gif'; Teamname='New York Islanders';      x_offset=1; y_offset=3; output;
st='NY'; City='New York'; logo='logos/nyr38.gif'; Teamname='New York Rangers';        x_offset=0; y_offset=-1; output;
st='NY'; City='Buffalo'; logo='logos/buf38.gif'; Teamname='Buffalo Sabres';           x_offset=1; y_offset=-1; output;
st='FL'; City='Sunrise'; logo='logos/fla38.gif'; Teamname='Florida Panthers';         x_offset=0; y_offset=0; output;
st='PA'; City='Philadelphia'; logo='logos/phi38.gif'; Teamname='Philadelphia Flyers'; x_offset=-1; y_offset=-1; output;
st='FL'; City='Tampa'; logo='logos/t.b38.gif'; Teamname='Tampa Bay Lightning';        x_offset=0; y_offset=0; output;
st='PA'; City='Pittsburgh'; logo='logos/pit38.gif'; Teamname='Pittsburgh Penguins';   x_offset=0; y_offset=0; output;
st='DC'; City='Washington'; logo='logos/wsh38.gif'; Teamname='Washington Capitals';   x_offset=0; y_offset=-2; output;
st='IL'; City='Chicago'; logo='logos/chi38.gif'; Teamname='Chicago Blackhawks';       x_offset=0; y_offset=0; output;
st='CA'; City='Anaheim'; logo='logos/ana38.gif'; Teamname='Anaheim Ducks';            x_offset=0; y_offset=0; output;
st='OH'; City='Columbus'; logo='logos/cmb38.gif'; Teamname='Columbus Blue Jackets';   x_offset=0; y_offset=0; output;
st='CO'; City='Denver'; logo='logos/col38.gif'; Teamname='Colorado Avalanche';        x_offset=0; y_offset=0; output;
st='TX'; City='Dallas'; logo='logos/dal38.gif'; Teamname='Dallas Stars';              x_offset=0; y_offset=0; output;
st='MI'; City='Detroit'; logo='logos/det38.gif'; Teamname='Detroit Red Wings';        x_offset=0; y_offset=0; output;
st='CA'; City='Los Angeles'; logo='logos/l.a38.gif'; Teamname='Los Angeles Kings';    x_offset=-2; y_offset=2; output;
st='TN'; City='Nashville'; logo='logos/nsh38.gif'; Teamname='Nashville Predators';    x_offset=0; y_offset=0; output;
st='MN'; City='Saint Paul'; logo='logos/min38.gif'; Teamname='Minnesota Wild';        x_offset=0; y_offset=0; output;
st='AZ'; City='Phoenix'; logo='logos/phx38.gif'; Teamname='Phoenix Coyotes';          x_offset=0; y_offset=0; output;
st='MO'; City='Saint Louis'; logo='logos/stl38.gif'; Teamname='St. Louis Blues';      x_offset=0; y_offset=0; output;
st='CA'; City='San Jose'; logo='logos/s.j38.gif'; Teamname='San Jose Sharks';         x_offset=0; y_offset=0; output;
run;
proc sql;
create table us_data as
select us_data.*, uscity.lat, uscity.long
from us_data left join maps.uscity on
(us_data.st = uscity.statecode) and
(us_data.city = uscity.city);
quit; run;

/* convert to eastlong (so it will be like the canada_data) */
data us_data; set us_data;
long=-1*long;
run;

data logo_anno; set us_data canada_data;
anno_flag=1;
run;


/* combine, project, and separate */
data combined; set mymap logo_anno; run;
proc gproject data=combined out=combined latlong eastlong degrees dupok westlong project=robinson
 latmax=65 latmin=23;
id id;
run;
data mymap logo_anno; set combined;
if anno_flag=1 then output logo_anno;
else output mymap;
run;

/*
Annotate the team logo images
*/
data logo_anno; set logo_anno (keep = x y x_offset y_offset country city Teamname logo);
length function $8 html $1000;
hsys='3'; when='a'; 
xsys='2'; ysys='2'; function='move'; output;
xsys='9'; ysys='9'; function='move'; 
x=-2.0+x_offset; y=-2.5+y_offset; output;
html=
 'title='||quote(trim(left(Teamname)))||
 ' href='||quote('http://www.google.com/search?&q='||trim(left(Teamname)));
x=2.0*2; y=2.5*2; function='image'; imgpath=logo; style='fit'; output;
run;


goptions device=png;
goptions border;
goptions xpixels=1000 ypixels=630;
goptions cback=cxC6E2FF;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="NHL Hockey Teams 1997") 
 style=htmlblue;

goptions gunit=pct htitle=5 htext=2.75 ftitle="albany amt/bold" ftext="albany amt" ctext=gray55;

pattern1 v=msolid c=cornsilk repeat=100;

proc gmap map=mymap data=mymap;
note move=(80,22) font="albany amt/bold" height=4.5 "NHL";
note move=(73,17) font="albany amt/bold" height=4.5 "Hockey Teams";
note move=(79.5,11) font="albany amt/bold" height=4.5 "1997";
id id; 
choro id / nolegend 
 coutline=grayaa anno=logo_anno
 des='' name="&name";
run;

proc sql noprint;
create table mydata as
select unique Teamname, city
from logo_anno;
quit; run;

quit;
ODS HTML CLOSE;
ODS LISTING;
