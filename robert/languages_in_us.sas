%let name=languages_in_us;

/* %let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); */
filename odsout '.';

/*
Inspired by:
http://www.slate.com/articles/arts/culturebox/2014/05/language_map_what_s_the_most_popular_language_in_your_state.html

Using data from:
https://www.census.gov/hhes/socdemo/language/data/other/detailed-lang-tables.xls
*/

libname robsdata '.';

/*
data languages_in_us;
run;

%macro do_state(st);
PROC IMPORT OUT=temp_data DATAFILE="detailed-lang-tables.xls" DBMS=XLS REPLACE;
RANGE="&st$A4:E1000";
GETNAMES=YES;
RUN;
%mend;

data temp_data (keep=statecode language speakers); set temp_data (rename=(A=language));
length statecode $2;
statecode="&st";
speakers=.; speakers=number_of_speakers;
if speakers^=. and index(language,'Population')=0 then output;
run;

data languages_in_us; set languages_in_us temp_data;
if speakers^=. then output;
run;

%mend;

proc sql noprint;
create table states as 
select unique statecode 
from mapsgfk.us_states_attr
where statecode^='DC';
quit; run;

data _null_; set states;
 call execute('%do_state('|| statecode ||');');
run;

data robsdata.languages_in_us; set languages_in_us;
run;
*/

data map_data; set robsdata.languages_in_us (where=(
 index(language,'.')^=0 and
 index(upcase(language),'ENGLISH')=0 and 
 index(upcase(language),'SPANISH')=0 and
 index(upcase(language),'LANGUAGES')=0 and
 index(upcase(language),'OTHER')=0 
 ));
run;

proc sql noprint;
create table map_data as
select unique statecode, trim(left(translate(language,'','.'))) as language, speakers
from map_data;
quit; run;

proc sql noprint;
create table map_data as
select unique statecode, language, speakers
from map_data
group by statecode
having speakers=max(speakers);
quit; run;

data map_data; set map_data;
length my_html $300;
my_html='title='||quote(
 trim(left(fipnamel(stfips(statecode))))||' has '||trim(left(put(speakers,comma10.0)))||'0d'x||
 'people who speak '||trim(left(language)));
run;

/* Annotate the languages on the map */
data anno_labels; set mapsgfk.uscenter(where=(statecode not in ('DC')));
original_order=_n_;
run;

proc sql noprint;
create table anno_labels as
select anno_labels.*, map_data.language
from anno_labels left join map_data
on anno_labels.statecode=map_data.statecode;
quit; run;

proc sort data=anno_labels out=anno_labels;
by original_order;
run;

data anno_labels; set anno_labels;
length function $8 color $8;
retain flag 0;
xsys='2'; ysys='2'; hsys='3'; when='a'; 
function='label'; 
style="albany amt/bold"; size=2.2; 
color='gray22';
if ocean^='Y' and flag^=1 then do;
 position='5'; text=trim(left(language)); 
 output;
 end;
else if ocean='Y' then do;                          
 position='6'; 
 text=trim(left(language)); 
 output;    
 function='move';                                                      
 output;
 flag=1;
 end;
else if flag=1 then do;                                                                   
 function='draw'; size=.25;
 output;
 flag=0;
 end;
run;


goptions device=png;
goptions xpixels=900 ypixels=600;
goptions noborder;
 
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Languages in US") 
 style=htmlblue;

goptions gunit=pct ftitle='albany amt/bold' ftext='albany amt' htitle=4.0 htext=2.5;
goptions ctext=gray33;

pattern1 v=s c=cx9c8dbd;
pattern2 v=s c=cx8497c8;
pattern3 v=s c=cxe69cc3;
pattern4 v=s c=cxe7a3c5;
pattern5 v=s c=cxefb087;
pattern6 v=s c=cxeb9c83;
pattern7 v=s c=cxe99fa2;
pattern8 v=s c=cxaece9c;
pattern9 v=s c=cxcbda9d;
pattern10 v=s c=cx95c59d;
pattern11 v=s c=cx8fc9c7;
pattern12 v=s c=cx81a8d5;
pattern13 v=s c=cx8587bd;
pattern14 v=s c=cxf6c691;
pattern15 v=s c=cx85cff4;

title1 ls=1.5 "Most Commonly Spoken Language other than English or Spanish";
title2 a=90 h=.5 ' ';
title3 a=-90 h=10 ' ';

footnote 
 link='https://www.census.gov/hhes/socdemo/language/data/other/detailed-lang-tables.xls'
 c=gray "Data source: US Census Burear American Community Survey (ACS), 2006-2008";

proc gmap data=map_data map=mapsgfk.us anno=anno_labels;
id statecode;
choro language / nolegend
 coutline=white
 html=my_html
 des='' name="&name";
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
