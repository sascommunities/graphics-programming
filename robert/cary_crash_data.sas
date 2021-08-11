%let name=cary_crash_data;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/cpd-crash-incidents/table/
Downloaded Aug 6, 2021
*/

/* 
Ran this code once (which is kinda slow), and then copy-n-pasted
the generated SAS code from the log file.
*/
/*
proc import datafile="cpd-crash-incidents.csv" dbms=dlm out=my_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;
*/

/* code generated from proc import */
data my_data;
infile 'cpd-crash-incidents.csv' delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
   informat tamainid best32. ;
   informat Location_Description $53. ;
   informat Road_Feature $34. ;
   informat Road_Character $21. ;
   informat Road_Class $21. ;
   informat Road_Configuration $39. ;
   informat Road_Surface $16. ;
   informat Road_Conditions $24. ;
   informat Light_Condition $26. ;
   informat Weather $34. ;
   informat Traffic_Control $35. ;
   informat lat best32. ;
   informat lon best32. ;
   informat lon2 best32. ;
   informat lat2 best32. ;
   informat tract $4. ;
   informat Beat $4. ;
   informat Fatality best32. ;
   informat Injury best32. ;
   informat NumPassengers best32. ;
   informat NumPedestrians best32. ;
   informat Contributing_Factor_1 $38. ;
   informat Contributing_Factor_2 $38. ;
   informat Contributing_Factor_3 $38. ;
   informat Contributing_Factor_4 $38. ;
   informat Vehicle1 $36. ;
   informat Vehicle2 $36. ;
   informat Vehicle3 $34. ;
   informat Vehicle4 $29. ;
   informat Vehicle5 $13. ;
   informat Work_Area $45. ;
   informat Records best32. ;
   informat TA_Date yymmdd10. ;
   informat TA_Time time20.3 ;
   informat Crash_Date B8601DZ35. ;
   informat Geo_Location $25. ;
   informat year best32. ;
   informat Fatalities $3. ;
   informat Injuries $3. ;
   informat Month best32. ;
   informat contrfact1 $72. ;
   informat contrfact2 $77. ;
   informat Contributing_Factor $80. ;
   informat vehicleconcat1 $69. ;
   informat vehicleconcat2 $83. ;
   informat vehicleconcat3 $83. ;
   informat Vehicle_Type $85. ;
   format tamainid best12. ;
   format Location_Description $53. ;
   format Road_Feature $34. ;
   format Road_Character $21. ;
   format Road_Class $21. ;
   format Road_Configuration $39. ;
   format Road_Surface $16. ;
   format Road_Conditions $24. ;
   format Light_Condition $26. ;
   format Weather $34. ;
   format Traffic_Control $35. ;
   format lat best12. ;
   format lon best12. ;
   format lon2 best12. ;
   format lat2 best12. ;
   format tract $4. ;
   format Beat $4. ;
   format Fatality best12. ;
   format Injury best12. ;
   format NumPassengers best12. ;
   format NumPedestrians best12. ;
   format Contributing_Factor_1 $38. ;
   format Contributing_Factor_2 $38. ;
   format Contributing_Factor_3 $38. ;
   format Contributing_Factor_4 $38. ;
   format Vehicle1 $36. ;
   format Vehicle2 $36. ;
   format Vehicle3 $34. ;
   format Vehicle4 $29. ;
   format Vehicle5 $13. ;
   format Work_Area $45. ;
   format Records best12. ;
   format TA_Date yymmdd10. ;
   format TA_Time time20.3 ;
   format Crash_Date B8601DZ35. ;
   format Geo_Location $25. ;
   format year best12. ;
   format Fatalities $3. ;
   format Injuries $3. ;
   format Month best12. ;
   format contrfact1 $72. ;
   format contrfact2 $77. ;
   format Contributing_Factor $80. ;
   format vehicleconcat1 $69. ;
   format vehicleconcat2 $83. ;
   format vehicleconcat3 $83. ;
   format Vehicle_Type $85. ;
input
            tamainid
            Location_Description  $
            Road_Feature  $
            Road_Character  $
            Road_Class  $
            Road_Configuration  $
            Road_Surface  $
            Road_Conditions  $
            Light_Condition  $
            Weather  $
            Traffic_Control  $
            lat
            lon
            lon2
            lat2
            tract  $
            Beat  $
            Fatality
            Injury
            NumPassengers
            NumPedestrians
            Contributing_Factor_1  $
            Contributing_Factor_2  $
            Contributing_Factor_3  $
            Contributing_Factor_4  $
            Vehicle1  $
            Vehicle2  $
            Vehicle3  $
            Vehicle4  $
            Vehicle5  $
            Work_Area  $
            Records
            TA_Date
            TA_Time
            Crash_Date
            Geo_Location  $
            year
            Fatalities  $
            Injuries  $
            Month
            contrfact1  $
            contrfact2  $
            Contributing_Factor  $
            vehicleconcat1  $
            vehicleconcat2  $
            vehicleconcat3  $
            Vehicle_Type  $
;
run;

proc sql noprint;
select min(ta_date) format=date9. into :mindate from my_data;
select max(ta_date) format=date9. into :maxdate from my_data;
select min(year) into :minyear from my_data;
select max(year) into :maxyear from my_data;
quit; run;

data my_data; set my_data;
format hour timeampm5.;
hour=round(ta_time,3600);
format ta_date date9.;
month_string=put(ta_date,YYMMD.);
run;

proc sort data=my_data out=my_data;
by ta_date ta_time;
run;

proc sql noprint;

create table my_data as
select unique *, sum(fatality) as daily_fatality_count
from my_data
group by ta_date;

create table needle_daily as
select unique ta_date, count(*) as daily_accident_count, daily_fatality_count
from  my_data
group by ta_date;

quit; run;

data needle_daily; set needle_daily;
length fatality_this_day $3;
if daily_fatality_count>0 then fatality_this_day='Yes';
else fatality_this_day='No';
run;

/* sort so that the fatality marker (red 'x') will be drawn on top and be more easily visible */
proc sort data=needle_daily out=needle_daily;
by daily_fatality_count ta_date;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary - Crash Data") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 attrpriority=none /* to make the sgplot scatter groups= have different symbol & color */
 noborder; 


title1 j=c c=gray33 h=14pt "Hourly number of vehicle crashes, tracked by Cary Police Department";
title2 j=c c=gray99 h=10pt "&mindate - &maxdate";

ods graphics / width=1000px height=500px;
proc sgplot data=my_data noborder;
vbar hour / stat=freq barwidth=1.0;
yaxis display=(noline noticks nolabel)
 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(nolabel noticks) valueattrs=(size=8);
run;

/* Annotate month labels on the bars, so I can get them exactly like I want */
data anno_months; 
format date YYMMD.;
do year=&minyear to &maxyear;
 do month=1 to 12;
  date=mdy(month,15,year);
  if date<="&maxdate"d then output;
  end;
 end;
run;

data anno_months; set anno_months;
length label $300 anchor x1space y1space function textcolor $50;
layer='front';
x1space='datavalue'; y1space='datavalue';
x1=date; y1=5;
function='text'; textcolor='gray22'; textsize=7; 
width=100; widthunit='percent'; 
label=trim(left(put(date,year4.)))||' '||trim(left(put(date,monname3.)));
anchor='left'; rotate=90;
run;

title1 j=c c=gray33 h=14pt "Monthly number of vehicle crashes, tracked by Cary Police Department";
title2 j=c c=gray99 h=10pt "Data source: data.townofcary.org/explore/dataset/cpd-crash-incidents/table/ (&mindate - &maxdate)";

/*
*/
ods graphics / width=1000px height=500px;
proc sgplot data=my_data noautolegend noborder sganno=anno_months;
format ta_date YYMMD.;
vbar ta_date / group=year barwidth=1.0;
yaxis display=(noline noticks nolabel) offsetmax=0
 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(nolabel noline noticks novalues);
run;


title1 j=c c=gray33 h=14pt "Daily number of vehicle crashes, tracked by Cary Police Department";
title2 j=c c=gray99 h=10pt "Data source: data.townofcary.org/explore/dataset/cpd-crash-incidents/table/ (&mindate - &maxdate)";

/*
*/
ods graphics / width=1000px height=500px;
proc sgplot data=needle_daily noborder;
needle x=ta_date y=daily_accident_count / displaybaseline=off lineattrs=(color=graycc);
styleattrs datasymbols=(circle X) datacontrastcolors=(dodgerblue red); /* shapes & colors for the deaths markers */
scatter x=ta_date y=daily_accident_count / group=fatality_this_day name='deaths'
 tip=(ta_date daily_accident_count daily_fatality_count);
yaxis values=(0 to 35 by 5) display=(nolabel noline noticks) 
 offsetmax=0 
 grid gridattrs=(pattern=dot color=gray11);
xaxis display=(nolabel noline noticks)
 offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=gray11);
keylegend 'deaths' / position=topleft location=inside across=2 opaque title='Deaths on this day?';
run;


data my_data; set my_data;
fatality_lat=.; fatality_lon=.;
if fatality>0 then do;
 fatality_lat=lat2;
 fatality_lon=lon2;
 end;
run;

title1 j=c c=gray33 h=14pt "Vehicle Crashes tracked by Cary Police (red X = fatality)";
title2 j=c c=gray99 h=10pt "&mindate - &maxdate";

ods graphics / width=800px height=900px;
proc sgmap plotdata=my_data (where=(
 lon2^=. and lat2^=. and 
 lat2>35.68 and lat2<35.86 and
 lon2>-78.94 and lon2<-78.75 
 )) noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base";
scatter x=lon2 y=lat2 / markerattrs=(symbol=circlefilled size=3pt color="cxFFE303") tip=none transparency=.50;
scatter x=fatality_lon y=fatality_lat / markerattrs=(symbol=X size=11pt color="red")
 tip=(location_description ta_date fatality);
run;



%macro do_plot(var);

proc sql noprint;
create table temp_data as
select unique &var, count(*) as count1
from my_data
group by &var;
quit; run;

proc sort data=temp_data out=temp_data;
by descending count1;
run;
data temp_data; set temp_data;
rank=_n_;
run;

data temp_data; set temp_data;
if rank>7 then &var='OTHER';
/* there were some where the value in the dataset was 'Other*' */
if index(upcase(&var),'OTHER')^=0 then &var='OTHER';
if trim(left(&var))='' then &var='OTHER';
if &var='NONE,NONE' then &var='NONE';
run;

proc sql noprint;
create table temp_data as
select unique &var, sum(count1) format=comma12.0 as count
from temp_data
group by &var
order by count descending;
quit; run;


title1 j=c c=gray33 h=14pt "Cary Vehicle Crashes, by &var";
title2 j=c c=gray99 h=10pt font='albany amt' "&mindate - &maxdate";
/* the f= causes the proc print table title2 to be non-bold (unfortunately not supported in the graph) */

ods graphics / width=600px height=350px;
proc sgplot data=temp_data noborder;
hbarparm category=&var response=count / datalabel datalabelfitpolicy=insidepreferred;
yaxis display=(nolabel noticks);
xaxis display=(nolabel noticks noline) grid gridattrs=(pattern=dot color=gray11);
run;

proc print data=temp_data noobs; 
sum count;
run;

%mend do_plot;

/*
*/
%do_plot(Road_Feature);
%do_plot(Road_Character);
%do_plot(Road_Class);
%do_plot(Road_Configuration);
%do_plot(Road_Surface);
%do_plot(Road_Conditions);
%do_plot(Light_Condition);
%do_plot(Weather);
%do_plot(Traffic_Control);
%do_plot(Work_Area);
%do_plot(Contributing_Factor);
%do_plot(Vehicle_Type);

/*
title;
proc print data=my_data (obs=20); 
run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
