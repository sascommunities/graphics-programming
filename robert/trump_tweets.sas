%let name=trump_tweets;
filename odsout '.';

/*
Imitating this graph:
https://www.reddit.com/r/dataisbeautiful/comments/7gkcqq/trump_tweet_density_vs_fox_friends_airtime_oc/
https://i.imgur.com/XKbBNFc.jpg

Using data from:
http://trumptwitterarchive.com/archive

Subset to the desired date range.
Sort so most recent are at the top.
Clicked Export->CSV  (took about a minute to process)
Then the tweets showed up in a box at top of page, in csv format,
and I copy-n-pasted them into trump_tweets.csv (which can take a while).
*/

/* Used the following to import the data first time */
/*
PROC IMPORT OUT=my_data DATAFILE="trump_tweets.csv" DBMS=CSV REPLACE;
GETNAMES=YES;
DATAROW=2;
guessingrows=all;
RUN;
*/

/* 
Then modified the code it generated in the log, to import data
exactly the way I wanted it.
*/
data my_data;
infile 'trump_tweets.csv' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;
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
run;

/* 
Convert gmt timestamp to Eastern US Time 
http://go.documentation.sas.com/?docsetId=nlsref&docsetTarget=n0px72paaaqx06n1ozps024j78cl.htm&docsetVersion=9.4&locale=en
*/
options timezone='America/New_York';
data my_data; set my_data;
format localtime datetime.;
localtime=tzoneu2s(created_at);
run;

data my_data; set my_data;
format date date9.;
format time timeampm.;
label time='Time';
date=datepart(localtime);
time=timepart(localtime);
year=year(date);
run;

data plot_data; set my_data;
format plot_date date9.;
plot_date=input('03'||put(date,monname3.)||put(date,year4.),date9.);
output;
if put(date,monname3.)='Feb' then 
plot_date=input('27'||put(date,monname3.)||put(date,year4.),date9.);
else 
plot_date=input('29'||put(date,monname3.)||put(date,year4.),date9.);
output;
plot_date=.;
output;
run;

proc sql noprint;
select max(date) format=date9. into :max_date separated by ' ' from my_data;
quit; run;


goptions device=png;
goptions noborder;
 
ODS LISTING CLOSE;
ODS html path=odsout body="&name..htm"
 (title="Trump Tweets") 
 style=htmlblue;

goptions gunit=pct ftitle='albany amt/bold' ftext='albany amt' htitle=4.0 htext=2.2;
goptions ctext=gray33;

symbol1 value=none interpol=join color=A0000ff33;
symbol2 value=none interpol=none color=white;

axis1 label=none order=('00:00:00't to '24:00:00't by '02:00:00't)
 value=(t=7 'Noon' t=13 'Midnight')
 minor=none offset=(0,0);

axis2 label=none order=('01jan2018'd to '01jan2019'd by month) 
 value=(justify=right t=13 '') 
 major=none minor=none offset=(0,0);

title1 ls=1.5 "Donald Trump's Tweets in 2018";

title2 ls=0.8 h=2.5 c=gray
 link='http://trumptwitterarchive.com/archive'
 "Data source: trumptwitterarchive.com (snapshot through &max_date)";
title3 ls=0.8 h=2.5 c=gray
 "GMT timestamps converted to Eastern US time";

proc gplot data=plot_data (where=(year=2018));
format time timeampm5.;
format plot_date monname3.;
plot time*plot_date=1 / skipmiss
 vaxis=axis1 haxis=axis2 /* vreverse */ 
 autohref chref=cxffbbbb frontref
 des='' name="&name._2018";
plot2 time*plot_date=2 / vaxis=axis1;
run;


axis2 label=none order=('01jan2019'd to '01jan2020'd by month) 
 value=(justify=right t=13 '') 
 major=none minor=none offset=(0,0);

title1 ls=1.5 "Donald Trump's Tweets in 2019";

title2 ls=0.8 h=2.5 c=gray
 link='http://trumptwitterarchive.com/archive'
 "Data source: trumptwitterarchive.com (snapshot through &max_date)";
title3 ls=0.8 h=2.5 c=gray
 "GMT timestamps converted to Eastern US time";

proc gplot data=plot_data (where=(year=2019));
format time timeampm5.;
format plot_date monname3.;
plot time*plot_date=1 / skipmiss
 vaxis=axis1 haxis=axis2 /* vreverse */
 autohref chref=cxffbbbb frontref
 des='' name="&name._2019";
plot2 time*plot_date=2 / vaxis=axis1;
run;


axis3 label=none order=('01jan2009'd to '01jan2020'd by year) 
 major=none minor=none value=(justify=right t=12 '') offset=(0,0);

title1 ls=1.5 "Donald Trump's Tweets";

title2 ls=0.8 h=2.5 c=gray
 link='http://trumptwitterarchive.com/archive'
 "Data source: trumptwitterarchive.com (snapshot through &max_date)";
title3 ls=0.8 h=2.5 c=gray
 "GMT timestamps converted to Eastern US time";

ods html anchor='all';

proc gplot data=plot_data;
format time timeampm5.;
format plot_date year4.;
plot time*plot_date=1 / skipmiss
 vaxis=axis1 haxis=axis3 /* vreverse */ 
 autohref chref=cxff8888 frontref
 des='' name="&name";
plot2 time*plot_date=2 / vaxis=axis1;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
