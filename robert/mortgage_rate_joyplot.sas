%let name=mortgage_rate_joyplot;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Similar to Len Kiefer's plot:
https://twitter.com/lenkiefer/status/1319631667062071296

Which is similar to Joy Division's album cover:
https://www.youtube.com/watch?v=7vUDCZ6NePg
Which is a graph of pulsar data:
https://www.radiox.co.uk/artists/joy-division/cover-joy-division-unknown-pleasures-meaning/

Using data from:
http://www.freddiemac.com/pmms/#
http://www.freddiemac.com/pmms/docs/historicalweeklydata.xls
*/

/* Import the older/historical data, and the latest-year data from the 2 spreadsheets */

proc import datafile="../ods4/historicalweeklydata.xls" dbms=xls out=historical_data;
range='Full History$a8:b0';
getnames=no;
run;

proc import datafile="../ods4/historicalweeklydata.xls" dbms=xls out=data_2020;
range='1PMMS2020$a8:b0';
getnames=no;
run;

/* Combine the two datasets */
data my_data; set historical_data (rename=(a=date b=rate)) data_2020 (rename=(a=date b=rate));
year=.; year=year(date);
rate_rounded=round(rate,.1);
if date^=. then output;
run;

/* 
Create a summary/frequency count, of how many weeks (each data point is a weekly value)
of each year were spent at each interest rate.
*/
proc sql noprint;
create table summary as 
select unique year, rate_rounded, count(*) as frequency
from my_data
group by year, rate_rounded;
quit; run;

/* Generate a grid of all possible combinations of year & interest rate */
data all_x;
do year=1971 to 2020;
 do rate_rounded=0 to 20 by .1;
  output;
  end;
 end;
run;

/* 
Merge the summary frequency count with the grid of all possible values
(otherwise your plot wouldn't have the long/flat lines representing 
frequency county of zero)
*/
proc sql noprint;
create table plot_data as
select unique all_x.*, summary.frequency
from all_x left join summary
/*
on all_x.year=summary.year and all_x.rate_rounded=summary.rate_rounded;
*/
/* the rounded values weren't exact matches, so comparing integer values instead */
on all_x.year=summary.year and int(all_x.rate_rounded*10)=int(summary.rate_rounded*10);
quit; run;

/* 
Add an offset to each frequency plot, so each line starts at that 'year' on the axis.
(we subtract the frequency, because we're going to 'reverse' the axis)
Also scale the lines, to 'fit' the graph (I chose the scaling factor by trial & error.
*/
%let scaling=.2;
data plot_data; set plot_data;
format rate_rounded percent7.0;
rate_rounded=rate_rounded/100;
if frequency=. then frequency=0;
frequency_with_offset=year-(frequency*&scaling);
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Mortgage Rate 'Joyplot'") 
 style=raven;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=700px height=800px noborder; 

title1 h=16pt "Distribution over weekly mortgage rates by year";
title2 h=12pt "Curves are densities fit to weekly observations for each year";

footnote1 c=gray99 h=11pt "Data Source: Freddie Mac Primary Mortgage Market Survey";
footnote2 c=gray99 h=11pt "Note: 2020 represents partial year of data, through Oct 22, 2020";

proc sgplot data=plot_data noautolegend noborder;
label rate_rounded='30-year fixed mortgage rate';
band x=rate_rounded upper=2020 lower=frequency_with_offset / group=year 
 fill fillattrs=(color=black)
 outline lineattrs=(color=cxe5e5e5 thickness=1px pattern=solid);
yaxis display=(noline noticks nolabel) reverse offsetmin=.10
 values=(1970 to 2020 by 5)
 valuesdisplay=(' ' '1975' '1980' '1985' '1990' '1995' '2000' '2005' '2010' '2015' '2020');
xaxis display=(noline) 
 values=(0 to .20 by .01);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
