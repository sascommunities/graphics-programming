%let name=space_travelers;

/*
For utf8 characters, run this with
space_traveler.bat
*/

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/* Get Rick Langston's code to read in a table from a web page */
%inc '../democd101/readhtml4.sas';


/* 
Read the data table, from the wikipedia website.
This reads in several tables ... the one I'm interested in is table2 
Note that you need to run this sas job with utf8 SAS, to read some 
of the special characters. I wrote a DOS .bat script to make this easier:
military_carriers.bat
*/
%readhtml2("https://en.wikipedia.org/wiki/List_of_space_travellers_by_first_flight");

data my_data; set table2;
name=col2;
country=trim(left(scan(col3,2,';')));
if index(country,'#') then country='';
if country='' then country=trim(left(scan(col2,2,';')));
ship=col5;
format date date9.;
date=col4;
if index(name,'Soviet Union')^=0 then name=col1;
if index(name,'United States')^=0 then name=col1;
if index(name,'Russia')^=0 then name=col1;
if index(name,'Australia')^=0 then name=col1;
if index(name,'Canada')^=0 then name=col1;
if index(name,'Glen de Vries')^=0 then name=col1;
if index(name,'UAE')^=0 then name=col1;
if index(name,'Netherlands')^=0 then name=col1;
if index(name,'West Germany')^=0 then name=col1;
if index(name,'France')^=0 then name=col1;
if index(name,'Mexico')^=0 then name=col1;
if index(name,'Japan')^=0 then name=col1;
if index(name,'United Kingdom')^=0 then name=col1;
if index(name,'Austria')^=0 then name=col1;
if index(name,'Belgium')^=0 then name=col1;
if index(name,'Italy')^=0 then name=col1;
if index(name,'Switzerland')^=0 then name=col1;
if index(name,'Germany')^=0 then name=col1;
if index(name,'Ukraine')^=0 then name=col1;
if index(name,'Israel')^=0 then name=col1;
if index(name,'China')^=0 then name=col1;
if index(name,'South Korea')^=0 then name=col1;
if index(name,'Kazakhstan')^=0 then name=col1;
if index(col1,'Timeline of spaceflight')^=0 then delete;
if index(col1,'Space exploration')^=0 then delete;
if index(col1,'General')^=0 then delete;
if trim(left(col1))='' then delete;
/* these were strike-thru'd in the table */
if index(name,'Michael J. Smith')^=0 then delete;
if index(name,'Gregory Jarvis')^=0 then delete;
if index(name,'Christa McAuliffe')^=0 then delete;
if index(name,'Nick Hague')^=0 and date='11oct2018'd then delete;
run;

data my_data (drop = datelag1 datelag2 datelag3 datelag4); set my_data;
datelag1=lag(date);
datelag2=lag2(date);
datelag3=lag3(date);
datelag4=lag4(date);
if date=. then date=datelag1;
if date=. then date=datelag2;
if date=. then date=datelag3;
if date=. then date=datelag4;
year=year(date);
run;

data my_data; set my_data (keep = name country ship year date);
run;

proc sort data=my_data out=my_data;
by year date name;
run;
data my_data; set my_data;
by year;
if first.year then count_y=1;
else count_y+1;
run;

data my_data; set my_data;
length my_html $300;
my_html='http://images.google.com/images?q='||'astronaut '||trim(left(name))||' '||trim(left(ship));
groupvar='1';
run;


/* Annotate an image behind the graph */
data anno_image;
function='image'; 
layer='back'; 
height=100; width=100; 
drawspace='WallPercent';
image='galaxies2.jpg'; 
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Space Travelers") 
 style=raven;

ods graphics /
 imagemap tipmax=5500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=1000px height=600px noborder; 

options center;

title1 h=19pt "Human Space Travelers";

footnote1 
 link='https://en.wikipedia.org/wiki/List_of_space_travellers_by_first_flight'
 c=graycc h=10pt "Data source: https://en.wikipedia.org/wiki/List_of_space_travellers_by_first_flight";

proc sgplot data=my_data nowall noborder noautolegend 
 pad=(left=5pct right=5pct) sganno=anno_image;
styleattrs datacolors=(cxFFFFAA);
heatmapparm x=year y=count_y colorgroup=groupvar /
 outline outlineattrs=(color=gray55)
 tip=(name country ship date) url=my_html;
yaxis display=(nolabel noticks noline) 
 grid gridattrs=(pattern=dot color=grayaa) 
 offsetmin=0 offsetmax=.08;
xaxis display=(nolabel);
run;


data my_data; set my_data;
length table_link $300 href $300;
href='href='||quote(trim(left(my_html)));
table_link = '<a ' || trim(href) || ' target="_self">' || htmlencode(trim(name)) || '</a>';
run;

title1 h=16pt " ";

proc print data=my_data label 
 style(data)={font_size=12pt}
 style(header)={font_size=12pt}
 ; 
label table_link='name';
var table_link date ship country;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
