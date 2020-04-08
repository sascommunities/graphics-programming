%let st=ga;
%let name=coronavirus_&st;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using coronavirus data from: 
https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/
And county population data from:
https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-total.html#par_textimage_242301767

To change the state: 
Change the 'st=ga;' at the top of the SAS program to your desired state.
Copy-and-paste the new state's population under the 'datalines' section.
Change the xpixels & ypixels, and the legend placement & offset as needed.
*/

/*
filename confdata "covid_confirmed_usafacts.csv";
*/
filename confdata url "https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv";
proc import datafile=confdata
 out=confirmed_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;


data pop_data (keep = statecode county_name pop_2019);
length county_name $100;
informat pop_2019 change comma12.0;
infile datalines dlm='09'x; /* tab-delimited */
input county_name pop_2019;
statecode=upcase("&st");
datalines;
Appling County	18,386
Atkinson County	8,165
Bacon County	11,164
Baker County	3,038
Baldwin County	44,890
Banks County	19,234
Barrow County	83,240
Bartow County	107,738
Ben Hill County	16,700
Berrien County	19,397
Bibb County	153,159
Bleckley County	12,873
Brantley County	19,109
Brooks County	15,457
Bryan County	39,627
Bulloch County	79,608
Burke County	22,383
Butts County	24,936
Calhoun County	6,189
Camden County	54,666
Candler County	10,803
Carroll County	119,992
Catoosa County	67,580
Charlton County	13,392
Chatham County	289,430
Chattahoochee County	10,907
Chattooga County	24,789
Cherokee County	258,773
Clarke County	128,331
Clay County	2,834
Clayton County	292,256
Clinch County	6,618
Cobb County	760,141
Coffee County	43,273
Colquitt County	45,600
Columbia County	156,714
Cook County	17,270
Coweta County	148,509
Crawford County	12,404
Crisp County	22,372
Dade County	16,116
Dawson County	26,108
Decatur County	26,404
DeKalb County	759,297
Dodge County	20,605
Dooly County	13,390
Dougherty County	87,956
Douglas County	146,343
Early County	10,190
Echols County	4,006
Effingham County	64,296
Elbert County	19,194
Emanuel County	22,646
Evans County	10,654
Fannin County	26,188
Fayette County	114,421
Floyd County	98,498
Forsyth County	244,252
Franklin County	23,349
Fulton County	1,063,937
Gilmer County	31,369
Glascock County	2,971
Glynn County	85,292
Gordon County	57,963
Grady County	24,633
Greene County	18,324
Gwinnett County	936,250
Habersham County	45,328
Hall County	204,441
Hancock County	8,457
Haralson County	29,792
Harris County	35,236
Hart County	26,205
Heard County	11,923
Henry County	234,561
Houston County	157,863
Irwin County	9,416
Jackson County	72,977
Jasper County	14,219
Jeff Davis County	15,115
Jefferson County	15,362
Jenkins County	8,676
Johnson County	9,643
Jones County	28,735
Lamar County	19,077
Lanier County	10,423
Laurens County	47,546
Lee County	29,992
Liberty County	61,435
Lincoln County	7,921
Long County	19,559
Lowndes County	117,406
Lumpkin County	33,610
McDuffie County	21,312
McIntosh County	14,378
Macon County	12,947
Madison County	29,880
Marion County	8,359
Meriwether County	21,167
Miller County	5,718
Mitchell County	21,863
Monroe County	27,578
Montgomery County	9,172
Morgan County	19,276
Murray County	40,096
Muscogee County	195,769
Newton County	111,744
Oconee County	40,280
Oglethorpe County	15,259
Paulding County	168,667
Peach County	27,546
Pickens County	32,591
Pierce County	19,465
Pike County	18,962
Polk County	42,613
Pulaski County	11,137
Putnam County	22,119
Quitman County	2,299
Rabun County	17,137
Randolph County	6,778
Richmond County	202,518
Rockdale County	90,896
Schley County	5,257
Screven County	13,966
Seminole County	8,090
Spalding County	66,703
Stephens County	25,925
Stewart County	6,621
Sumter County	29,524
Talbot County	6,195
Taliaferro County	1,537
Tattnall County	25,286
Taylor County	8,020
Telfair County	15,860
Terrell County	8,531
Thomas County	44,451
Tift County	40,644
Toombs County	26,830
Towns County	12,037
Treutlen County	6,901
Troup County	69,922
Turner County	7,985
Twiggs County	8,120
Union County	24,511
Upson County	26,320
Walker County	69,761
Walton County	94,593
Ware County	35,734
Warren County	5,254
Washington County	20,374
Wayne County	29,927
Webster County	2,607
Wheeler County	7,855
White County	30,798
Whitfield County	104,628
Wilcox County	8,635
Wilkes County	9,777
Wilkinson County	8,954
Worth County	20,247
;
run;


/* ------------------------------------------------------------------- */

%macro do_state(statecode);
%let statecode=%upcase(&statecode);

proc sql noprint;
select idname into :stname separated by ' ' from mapsgfk.us_states_attr where statecode="&statecode";
quit; run;

ods path work.template(update) sashelp.tmplmst;
proc template;
 define style styles.blueback;
   parent = styles.htmlblue;
   replace colors /
     "docbg"   = cx103052
     "tablebg" = cx103052
   ;
   replace Output from Container /
      bordercolor = cx103052  
   ;
end;

goptions device=png;
goptions xpixels=700 ypixels=750;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm"
 (title="Coronavirus in &statecode") 
 style=blueback;

goptions gunit=pct htitle=5.5 htext=2.1 ftitle="albany amt" ftext="albany amt";
goptions ctitle=white ctext=white noborder;
goptions cback=cx103052;

data state_confirmed; set confirmed_data (where=(state="&statecode"));
run;
data raw; set state_confirmed; run;

proc transpose data=state_confirmed out=state_confirmed;
by countyFIPS County_Name State stateFIPS notsorted;
run;

data state_confirmed (drop = year month day datestring); 
 set state_confirmed (rename=(_name_=datestring col1=confirmed));
year=.; year=scan(datestring,-1,'_');
day=.; day=scan(datestring,-2,'_');
month=.; month=scan(datestring,-3,'_');
format date date9.;
date=mdy(month,day,year);
county=.; county=substr(put(countyFIPS,z5.),3,3);
/*
if confirmed>0 then output;
*/
run;

data state_pop; set pop_data (where=(statecode="&statecode"));
run;

proc sql noprint;

/* get the coronavirus data with the latest date */
create table latest_data as
select * from state_confirmed
having date=max(date);

/* merge in the population data */
create table latest_data as
select latest_data.*, state_pop.county_name as county_name2, state_pop.pop_2019
from latest_data full join state_pop
on latest_data.county_name = state_pop.county_name;

select sum(confirmed) format=comma12.0 into :total  separated by ' ' from latest_data;
select unique(date) format=nldate20. into :datestr separated by ' ' from latest_data where date^=.;

quit; run;

data latest_data; set latest_data;
if confirmed=. then confirmed=0;
if county_name='' then county_name=county_name2;
format per100k comma10.3;
per100k=confirmed/(pop_2019/100000);
format pct percent12.6;
pct=confirmed/pop_2019;
length my_html $300;
my_html='title='||quote(
 trim(left(county_name))||', '||trim(left("&statecode"))||'0d'x||
 '------------------------------'||'0d'x||
 trim(left(put(confirmed,comma20.0)))||' confirmed cases in '||trim(left(put(pop_2019,comma20.0)))||' residents.'||'0d'x||
 'That is '||trim(left(put(per100k,comma10.3)))||' cases per 100,000 residents,'||'0d'x||
 'or '||trim(left(put(pct,percent12.6)))||' of the county population.'
 );
run;

data my_map; set mapsgfk.us_counties (where=(statecode="&statecode" and density<=3) 
 drop=resolution);
run;

pattern1 v=s c=cxf8f9fa;
pattern2 v=s c=cxbcd9ea;
pattern3 v=s c=cx5ba4cf;
pattern4 v=s c=cx0078bf;
pattern5 v=s c=cx0169a7;
pattern6 v=s c=cx084c72;
pattern7 v=s c=cxbf0c00;


title1 ls=1.5 h=18pt c=white font="albany amt"
 "&total confirmed Coronavirus (COVID-19) cases in " c=dodgerblue "&stname";

footnote 
 link='https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/'
 ls=1.2 h=12pt c=white "Coronavirus data source: usafacts.org (&datestr snapshot)";


legend1 label=(position=top justify=center font='albany amt/bold' j=c 'COVID-19 Cases')
 across=1 position=(top right inside) order=descending mode=protect
 value=(justify=left) shape=bar(.15in,.15in) offset=(-7,-0);

ods html anchor='cases';
proc gmap data=latest_data (where=(county^=0)) map=my_map all;
format confirmed comma8.0;
id county;
choro confirmed / levels=7 midpoints=old range
 coutline=cx103052 cempty=graybb
 legend=legend1
 html=my_html
 des='' name="&name._cases";
run;



legend2 label=(position=top justify=center font='albany amt/bold' j=c 'Cases per 100k Residents')
 across=1 position=(top right inside) order=descending mode=protect
 value=(justify=left) shape=bar(.15in,.15in) offset=(-5,-0);

ods html anchor='per100k';
proc gmap data=latest_data (where=(county^=0)) map=my_map all;
format per100k comma8.0;
id county;
choro per100k / levels=7 midpoints=old range
 coutline=gray22 cempty=graybb
 legend=legend2
 html=my_html
 des='' name="&name._100k";
run;



ods html anchor='table';
footnote;
proc print data=latest_data label
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
label county_name='County';
label confirmed='Coronavirus cases';
label pop_2019='Population (2019)';
label per100k='Cases per 100,000 residents';
label pct='Percent of residents with Coronavirus';
format confirmed comma12.0;
format pop_2019 comma12.0;
var county_name confirmed pop_2019 per100k pct;
sum confirmed pop_2019;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;

%mend do_state;

/* Call the macro, for the desired state */
%do_state(&st);

