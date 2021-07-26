%let name=us_county_health_insurance;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Creating something similar to:
https://moneywise.com/a/ch-c/x-fascinating-maps-of-the-us/p-4
https://www.cdc.gov/dhdsp/maps/pdfs/sd_insurance.pdf
Using data from:
https://www.census.gov/data/datasets/time-series/demo/sahie/estimates-acs.html
*/

/*
Data file header info ...

Filename:  sahie_2019.csv          
Created:   01MAR21  11:23
Description:                   
 
  Model-based Small Area Health Insurance Estimates (SAHIE) for Counties and States, 2019   
 
  NOTE: VERY LONG .CSV FILES NOT ALWAYS IMPORTED INTO EXCEL CORRECTLY - CHECK FOR TRUNCATION
 
File Layout and Definitions: 
 
    Variable      Format      Description     
       year            4      Year of Estimate
       version         8      Release Version 
                                 Blank   : YEAR other than 2013, Only Version   
                                 Original: 2013 only, Original Version          
                                 Updated : 2013 only, Updated Version (May 2016)
       statefips       2      Unique FIPS code for each state                   
       countyfips      3      Unique FIPS code for each county within a state   
       geocat          2      Geography category             
                                40 - State geographic identifier 
                                50 - County geographic identifier
       agecat          1      Age category        
                                0 - Under 65 years
                                1 - 18 to 64 years
                                2 - 40 to 64 years
                                3 - 50 to 64 years
                                4 - Under 19 years
                                5 - 21 to 64 years
       racecat         1      Race category  
                                0 - All races
                                Only state estimates have racecat=1,2,3 values
                                1 - White alone, not Hispanic
                                2 - Black alone, not Hispanic
                                3 - Hispanic (any race)      
       sexcat          1      Sex category    
                                0 - Both sexes
                                1 - Male      
                                2 - Female    
       iprcat          1      Income category 
                                0 - All income levels          
                                1 - At or below 200% of poverty
                                2 - At or below 250% of poverty
                                3 - At or below 138% of poverty
                                4 - At or below 400% of poverty
                                5 - Between 138% - 400%  of poverty
      NIPR             8      Number in demographic group for <income category>
         nipr_moe      8           MOE  for NIPR
      NUI              8      Number uninsured  
         nui_moe       8           MOE  for NUI 
      NIC              8      Number insured    
         nic_moe       8           MOE  for NIC 
      PCTUI            5.1    Percent uninsured in demographic group for <income category>
         pctui_moe     5.1         MOE  for PCTUI                                 
      PCTIC            5.1    Percent insured in demographic group for <income category>  
         pctic_moe     5.1         MOE  for PCTIC                                 
      PCTELIG          5.1    Percent uninsured in demographic group for all income levels
         pctelig_moe   5.1         MOE  for PCTELIG                                
      PCTLIIC          5.1    Percent insured in demographic group for all income levels  
         pctliic_moe   5.1         MOE  for PCTLIIC                                
      state_name       70     State Name
      county_name      45     County Name
 
  PRIMARY KEY: year version statefips countyfips agecat racecat sexcat iprcat         
 
  Note 1:  A margin of error (MOE) is the difference between an estimate and its upper
  or lower confidence bounds. Confidence bounds can be created by adding the margin   
  of error to the estimate (for an upper bound) and subtracting the margin of error   
  from the estimate (for a lower bound). All published margins of error for the Small 
  Area Health Insurance Estimates program are based on a 90 percent confidence level. 
 
  Note 2:  The number in a demographic group is the number of people in the poverty   
  universe in that age, sex, and race/Hispanic origin group.                          
 
  Note 3:  Values for Kalawao, HI (15-005) should be considered N/A or missing.       
 
  Note 4:  MOEs of zero should be assumed to be <1 for counts and <0.1 for percentages.
 
  General Note:  Details may not sum to totals because of rounding.                    
 
year,version,statefips,countyfips,geocat,agecat,racecat,sexcat,iprcat,NIPR,nipr_moe,NUI,nui_moe,NIC,nic_moe,PCTUI,pctui_moe,PCTIC,pctic_moe,PCTELIG,pctelig_moe,PCTLIIC,pctliic_moe,state_name,county_name,
2019,        ,01,000,40,0,0,0,0, 3946002,       0,  457718,   13633, 3488284,   13633, 11.6,  0.3, 88.4,  0.3, 11.6,  0.3, 88.4,  0.3,Alabama                                                               ,                                             ,
*/

/*
filename datafile "../../sahie_2019.csv";
*/
filename datafile "D:\Public\Census_2019\sahie_2019.csv";
data my_data (keep = statefips countyfips state_name county_name pctui);
infile datafile firstobs=81 dlm=',' dsd;
length state_name $70 length county_name $45;
input year version statefips countyfips geocat agecat racecat sexcat iprcat
 NIPR nipr_moe 
 NUI nui_moe 
 NIC nic_moe 
 PCTUI pctui_moe 
 PCTIC pctic_moe 
 PCTELIG pctelig_moe 
 PCTLIIC pctliic_moe
 state_name county_name
 ;
if 
 geocat=50 and /* county level, not state */
 year=2019 and
 version=. and
 agecat=0 and 
 racecat=0 and 
 sexcat=0 and
 iprcat=0
then output; 
run;

data my_data; set my_data;
format pctui percentn7.1;
pctui=pctui/100;
length id $8;
id='US-'||trim(left(put(statefips,z2.)))||trim(left(put(countyfips,z3.)));
county_name=trim(left(county_name))||', '||trim(left(fipstate(statefips)));
run;


data my_map; set maps.uscounty;
if state=46 and county=113 then county=102;
length id $8;
id='US-'||trim(left(put(state,z2.)))||trim(left(put(county,z3.)));
run;

/* create state borders, with internal county borders removed */
proc gremove data=my_map out=state_outlines;
by state; 
id county;
run;

/* 
Repeat the first obsn of a polygon as the last, so the series plot will 'close' the polygon.
Also insert 'missing' values at the end of each segment, so series line won't be connected
between polygons.
*/
data state_outlines; set state_outlines;
retain x_first y_first;
by state segment notsorted;
output;
if first.state or first.segment or x=. then do;
 x_first=x; y_first=y; 
 end;
if last.state or last.segment or x=. then do;
 x=x_first; y=y_first; output;
 x=.; y=.; output;
 end;
run;

ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US county health insurance")
 style=htmlblue;

ods graphics / border
 noscale /* if you don't use this option, the text will be resized */
 imagefmt=png imagename="&name"
 imagemap tipmax=2500
 width=800px height=600px;


title1 color=gray33 height=16pt "Percent of population under age 65 without Health Insurance (2019)";
title2 color=gray55 height=12pt "Data Source: US Census Bureau, Small Area Health Insurance Estimates (SAHIE)";

proc sgmap mapdata=my_map maprespdata=my_data plotdata=state_outlines;
label pctui='Uninsured';
label county_name='County';
choromap pctui / mapid=id id=id 
 numlevels=5 leveltype=quantile 
 colormodel=(cxf9ece1 cxfbc088 cxfc9036 cxe1540b cxa43800)
 lineattrs=(thickness=1 color=gray88)
 tip=none /* tip=(county_name pctui) */
 name='map';
series x=x y=y / lineattrs=(color=gray55);  /* overlay state outlines */
keylegend 'map' / title='Uninsured (quintile binning)';
run;

/* create a needle/bar plot, to look at the 'spread' of the data */
/*
proc sort data=my_data out=my_data;
by pctui;
run;
data my_data; set my_data;
county_order_num+1;
run;
title;
ods graphics / noborder;
proc sgplot data=my_data;
needle x=county_order_num y=pctui;
refline .162 / axis=y label='16.2%';
run;
*/

title1 color=gray33 height=16pt "Percent of population under age 65 without Health Insurance (2019)";
title2 color=gray55 height=12pt "Data Source: US Census Bureau, Small Area Health Insurance Estimates (SAHIE)";

ods graphics / border;
proc sgmap mapdata=my_map maprespdata=my_data plotdata=state_outlines;
label pctui='Uninsured';
label county_name='County';
choromap pctui / mapid=id id=id
 numlevels=5 leveltype=interval 
 colormodel=(cxf9ece1 cxfbc088 cxfc9036 cxe1540b cxa43800)
 lineattrs=(thickness=1 color=gray88)
 tip=none /* tip=(county_name pctui) */
 name='map';
series x=x y=y / lineattrs=(color=gray55);  /* overlay state outlines */
keylegend 'map' / title='Uninsured (interval binning)';
run;

proc sgmap mapdata=my_map maprespdata=my_data plotdata=state_outlines;
label pctui='Uninsured';
label county_name='County';
choromap pctui / mapid=id id=id
 colormodel=(cxf9ece1 cxfbc088 cxfc9036 cxe1540b cxa43800)
 lineattrs=(thickness=1 color=gray88)
 tip=none /* tip=(county_name pctui) */
 name='map';
series x=x y=y / lineattrs=(color=gray55);  /* overlay state outlines */
gradlegend 'map' / position=right;
run;


/*
proc print data=my_data (obs=20); run;
*/

quit;
ODS HTML CLOSE;
ODS LISTING;
