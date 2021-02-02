%let name=gasoline_prices_plot;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/* Regular Gasoline (not midgrade or premium), in conventional areas (not reformulated/oxygenated, etc) */

/*
Using Data from here...

http://www.eia.doe.gov/
http://www.eia.gov/dnav/pet/pet_pri_gnd_dcus_nus_w.htm
Regular gasoline, conventional areas:
http://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=PET&s=EMM_EPMR_PTE_NUS_DPG&f=W
Download Data (XLS File) link:
http://www.eia.gov/dnav/pet/hist_xls/EMM_EPMR_PTE_NUS_DPGw.xls

And imitating gasoline graph from here, but for gasoline...
http://www.cssi-consulting.com/images/graph.jpg
*/

/*
This bit of tricky code downloads the xls spreadsheet on-the-fly,
so you don't have to do it manually :)
*/
%let xlsname=EMM_EPMR_PTE_NUS_DPGw.xls;

/*
*/
filename xlsfile url "https://www.eia.gov/dnav/pet/hist_xls/&xlsname";
data _null_;
 n=-1;
 infile xlsfile recfm=s nbyte=n length=len _infile_=tmp;
 input;
 file "&xlsname" recfm=n;
 put tmp $varying32767. len;
run;

proc import out=my_data datafile="&xlsname" dbms=xls replace;
range="Data 1$A4:B0"; 
getnames=NO;
run;

/* only use data after 2001 */
data my_data; set my_data (rename=(a=date b=gasoline_price));
price_range=int(gasoline_price/.50);
if date>='01jan2001'd and gasoline_price^=. then output;
run;

/* create macro variables to use in footnote */
proc sql noprint;
select put(max(date),worddate.) into :max_date separated by ' ' from my_data;
select put(gasoline_price,dollar5.2) into :end_price separated by ' ' from my_data having date=max(date);
quit; run;

/* this puts an 'x' at the ending price */
data my_data; set my_data end=last;
length final_html $100;
format final_price dollar10.2;
if last then do;
 final_price=gasoline_price;
 final_html='title='||quote(trim(left(put(gasoline_price,dollar7.2))));
 end;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="US Regular Gasoline Price (avg weekly price per gallon)") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=950px height=600px noborder; 

/* This attribute map controls the color of the needle lines */
data myattrmap;
length linecolor $9;
input ID $ value linecolor $;
datalines;
myid  1 cxFFFFCC 
myid  2 cxFFEDA0 
myid  3 cxFED976 
myid  4 cxFEB24C 
myid  5 cxFD8D3C 
myid  6 cxFC4E2A 
myid  7 cxE31A1C 
myid  8 cxBD0026 
myid  9 cx800026 
;
run;

title1 ls=0.5 color=gray33
 h=18pt "US Regular Gasoline - Average Retail Price";

footnote1 h=4pt ' ';
footnote2 h=9pt font='albany amt' color=gray77
 "Data source: eia.doe.gov   &max_date (ending price = &end_price)";

proc sgplot data=my_data dattrmap=myattrmap noautolegend;
format date year4.;
label gasoline_price='$/gal';
label final_price='$/gal';
/* draw the needles */
needle x=date y=gasoline_price / group=price_range attrid=myid
 tip=none;
/* draw an 'x' marker on the final price */
scatter y=final_price x=date / y2axis
 markerattrs=(size=7px color=black symbol=X)
 tip=(date final_price)
 tiplabel=('Date: ' 'Price: ')
 tipformat=(MMDDYY10. dollar8.2)
 ;
xaxis display=(nolabel) 
 values=('01jan2001'd to '01jan2022'd by year)
 valueattrs=(size=11pt weight=bold color=gray33)
 grid offsetmin=0 offsetmax=0
 /* If there are no tick collisions, no rotation occurs.  */
 valuesrotate=vertical fitpolicy=rotate notimesplit;
yaxis labelposition=top labelattrs=(weight=bold)
 values=(0 to 5 by .5) 
 valuesformat=dollar8.2
 valueattrs=(size=11pt weight=bold color=gray33)
 grid offsetmin=0 offsetmax=0;
y2axis labelposition=top labelattrs=(weight=bold)
 values=(0 to 5 by .5) 
 valuesformat=dollar8.2
 valueattrs=(size=11pt weight=bold color=gray33)
 grid offsetmin=0 offsetmax=0;
run;

/* And, print a table below the graph */

proc sort data=my_data;
by descending date;
run;

footnote;
proc print data=my_data (where=(date>='01jan1994'd)) noobs
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
var date gasoline_price;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
