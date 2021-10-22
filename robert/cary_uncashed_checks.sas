%let name=cary_uncashed_checks;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Exploring data from:
https://data.townofcary.org/explore/dataset/uncashed-checks/table/?sort=check_date
*/

proc import datafile="D:\public\cary\2021\uncashed-checks.csv" dbms=dlm out=my_data replace;
delimiter=';';
getnames=yes;
datarow=2;
guessingrows=all;
run;


data my_data; set my_data;
Days_Old=today()-check_date;
if days_old>=180 then output;
run;

data my_data 
 (drop=
  Misc_Vendor_Address_1 Misc_Vendor_Address_2 Misc_Vendor_Address_3 Misc_Vendor_City Misc_Vendor_State Misc_Vendor_Zip
  Vendor_Address_1 Vendor_Address_2 Vendor_Address_3 Vendor_City Vendor_State Vendor_Zip
  Check_Status_Flag 
  row);
 set my_data;
format transaction_amount dollar10.2;
if Vendor_Address_1='PLEASE CHANGE TO THE' then Vendor_Address_1='';
if Vendor_Address_1='PLEASE CHANGE TO CORRECT ADDRESS' then Vendor_Address_1='';
if Vendor_Address_2='CORRECT NAME AND ADDRESS' then Vendor_Address_2='';
if index(Vendor_City,'ANYTOWN')^=0 then Vendor_City='';
/* */
length Address1 Address2 City State zip_char $100;
address1=Misc_Vendor_Address_1; 
address2=Misc_Vendor_Address_2;
city=Misc_Vendor_City;
state=Misc_Vendor_State;
zip_char=trim(left(Misc_Vendor_Zip));
/* If they're blank, set them to the other one */
if address1='' then address1=Vendor_Address_1;
if address2='' then address2=Vendor_Address_2;
if city='' then city=Vendor_City;
if state='' then state=Vendor_State;
if zip_char='' or zip_char='.' then zip_char=Vendor_Zip;
if length(zip_char)>5 then zip_char=substr(zip_char,1,5);
Zip=.; zip=zip_char;
run;

data my_data; 
length Misc_Vendor_Name $100;
format Misc_Vendor_Name $100.;
set my_data;
if Misc_Vendor_Name='' then Misc_Vendor_Name=Vendor_Name;
if trim(left(address1))='ATTEN:  MEDAN YAQSHAAN' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='C/O TOMMY BASTON' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='LARRY LIPPINCOTT' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='MCCOY LAURIE' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='THOMPSON ANDY' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='JOSEPH MARQUEZ' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='SAFETY INSPECTION' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='CHARTER SCHOOLS USA / RED' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
if trim(left(address1))='LILES CHRIS' then do;
 Misc_Vendor_Name=trim(left(Misc_Vendor_Name))||', '||trim(left(address1));
 address1=address2;
 address2='';
 end;
run;

/* Some checks are split into multiple data obsns, because they are for multiple invoices. Sum those so there is 1 obsn per check. */
proc sql noprint;
create table my_data as
select unique Misc_Vendor_Name, Check_Date, Check_Number, 
 sum(Transaction_Amount) format=dollar10.2 as Transaction_Amount,
 Vendor_Name, Days_Old, Address1, Address2, City, State, zip_char, Zip
from my_data
group by check_number;
quit; run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Cary - Uncashed Checks") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 noborder; 

title1 j=c c=gray33 h=14pt "Uncashed Checks written by Town of Cary NC (greater than 180 days old)";
title2 j=c c=gray99 h=10pt "Data source: data.townofcary.org/explore/dataset/uncashed-checks/table/ (Oct 22, 2021 snapshot)";

ods graphics / width=1000px height=500px;
proc sgplot data=my_data noborder;
needle x=check_date y=transaction_amount / displaybaseline=off
 lineattrs=(color=cx308014) markers markerattrs=(color=red)
 tip=(Check_Number Check_Date Transaction_Amount Vendor_Name 
   Misc_Vendor_Name address1 city state zip_char);
yaxis values=(0 to 14000 by 2000) display=(noline noticks nolabel) 
 offsetmax=0 grid gridattrs=(pattern=dot color=grayaa);
xaxis display=(nolabel noline noticks)
 offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=grayaa);
run;


title2 j=c c=gray33 h=12pt "Check amount  > $1,000";

ods graphics / width=800px height=450px;
proc sgplot data=my_data (where=(Transaction_Amount>1000)) noautolegend noborder;
format Transaction_Amount dollar10.0;
hbar Misc_Vendor_Name / response=Transaction_Amount stat=sum missing 
 categoryorder=respdesc
 group=check_number groupdisplay=stack seglabel
 fillattrs=(color=cx9AFF9A) outlineattrs=(color=cx308014)
 tip=(Misc_Vendor_Name Transaction_Amount Check_Date Check_Number
   Vendor_Name Days_Old Address1 Address2 City State Zip);
yaxis display=(nolabel noticks);
xaxis display=(nolabel noticks noline)
 grid gridattrs=(pattern=dot color=gray77);
run;


proc geocode data=my_data out=geocoded_data method=street lookupstreet=sashelp.geoexm
 addressvar=address1;
run;

title2 j=c c=gray33 h=12pt "By Location of Recipient";

ods graphics / width=800px height=450px;
proc sgmap plotdata=geocoded_data (where=(x^=.)) noautolegend;
openstreetmap;
scatter x=x y=y / markerattrs=(symbol=circle size=8pt color="red") 
 tip=(Check_Number Check_Date Transaction_Amount Vendor_Name Misc_Vendor_Name 
   address1 address2 city state zip_char);
run;

title2 j=c c=gray33 h=12pt "To people in Cary and Morrisville";

ods graphics / width=800px height=700px;
proc sgmap plotdata=geocoded_data (where=(x^=. and state='NC' and upcase(city) in ('CARY' 'MORRISVILLE'))) noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map";
scatter x=x y=y / markerattrs=(symbol=circle size=7pt color="red") 
 tip=(Check_Number Check_Date Transaction_Amount Vendor_Name Misc_Vendor_Name 
   address1 address2 city state zip_char);
run;

proc sort data=my_data out=my_data;
by check_date check_number;
run;

footnote 
 link='https://data.townofcary.org/explore/dataset/uncashed-checks/table/'
 h=10pt "Data source: data.townofcary.org/explore/dataset/uncashed-checks/table/ (Oct 22, 2021 snapshot)";

proc print data=my_data (drop = zip_char); 
var
 Check_Date
 Days_Old
 Check_Number
 Transaction_Amount
 Misc_Vendor_Name
 Vendor_Name
 Address1
 City
 State
 Zip;
sum Transaction_Amount;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
