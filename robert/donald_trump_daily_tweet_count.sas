%let name=donald_trump_daily_tweet_count;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from:
http://trumptwitterarchive.com/archive

Subset to the desired date range.
Sort so most recent are at the top.
Clicked Export->CSV  (took about a minute to process)
Then the tweets showed up in a box at top of page, in csv format,
and I copy-n-pasted them into ../democd96/trump_tweets.csv (which can take a while).
*/

/*
Then modified the code it generated in the log, to import data
exactly the way I wanted it.
*/
data my_data;
infile '../democd96/trump_tweets.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;
   informat source $138.;
   informat text $312.;
   informat created_at anydtdtm19.;
   informat retweet_count best32.;
   informat favorite_count best32.;
   informat is_retweet $18.;
   informat id_str $100.;
   format source $138.;
   format text $312.;
   format created_at datetime.;
   format retweet_count comma12.0;
   format favorite_count comma12.0;
   format is_retweet $18.;
   format id_str $100.;
input
   source $
   text $
   created_at
   retweet_count
   favorite_count
   is_retweet $
   id_str $;
format date date9.;
date=datepart(created_at);
if date^=. then output;
run;

proc sql noprint;
create table summarized_data as
select unique date, count(*) as daily_tweet_count
from my_data
group by date;
quit; run;

proc sql noprint;
select max(date) format=date9. into :max_date separated by ' ' from my_data;
quit; run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Donald Trump Daily Tweet Count") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=10000 
 imagefmt=png imagename="&name"
 width=1200px height=600px noborder; 

title1 c=gray33 height=18pt "Donald Trump's Number of Tweets Per Day";
footnote c=gray height=12pt "Data source: trumptwitterarchive.com (through &max_date)";

proc sgplot data=summarized_data noborder;
scatter y=daily_tweet_count x=date / 
 markerattrs=(color=cx0276FD size=7px) transparency=.40;
xaxis display=(nolabel noline) offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=gray88);
yaxis display=(nolabel noline noticks) offsetmin=0 offsetmax=0
 values=(0 to 175 by 25)
 grid gridattrs=(pattern=dot color=gray88);
run;

data summarized_data; set summarized_data;
month_date_string='15'||put(date,monname3.)||put(date,year4.);
format month_date mmyys10.;
month_date=input(month_date_string,date9.);
run;

/*
title2 c=gray33 h=14pt "Grouped by Month";
proc sgplot data=summarized_data noborder;
scatter y=daily_tweet_count x=month_date /
 markerattrs=(color=cx0276FD size=7px) transparency=.40;
xaxis display=(nolabel noline) offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=gray88);
yaxis display=(nolabel noline noticks) offsetmin=0 offsetmax=0
 values=(0 to 175 by 25)
 grid gridattrs=(pattern=dot color=gray88);
run;
*/

/*
title2 c=gray33 h=14pt "Grouped by Month";
proc sgplot data=summarized_data noborder;
vbox daily_tweet_count / category=month_date
 outlierattrs=(color=cx0276FD size=7px);
xaxis display=(nolabel noline) offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=gray88);
yaxis display=(nolabel noline noticks) offsetmin=0 offsetmax=0
 values=(0 to 175 by 25)
 grid gridattrs=(pattern=dot color=gray88);
run;
*/

ods html anchor='box';
title2 c=gray33 h=14pt "Grouped by Month";
proc sgplot data=summarized_data noborder;
vbox daily_tweet_count / category=month_date
 outlierattrs=(color=cx0276FD size=7px);
xaxis display=(nolabel noline) offsetmin=0 offsetmax=0
 grid gridattrs=(pattern=dot color=gray88)
 type=time;
yaxis display=(nolabel noline noticks) offsetmin=0 offsetmax=0
 values=(0 to 175 by 25)
 grid gridattrs=(pattern=dot color=gray88);
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
