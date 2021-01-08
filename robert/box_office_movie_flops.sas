%let name=box_office_movie_flops;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Graphical visualization of list from:
https://scientificfeed.com/stories/45-expensive-box-office-flops-ever-made/
*/

data my_data;
label title='Movie';
label date='Release Date';
label loss_millions='Millions Lost';
length title $100;
format date date9.;
format loss_millions dollar20.0;
infile datalines dlm='|';
input date date9. loss_millions title;
text_y=-3;
drill="http://www.google.com/search?q="||trim(left(title))||', '||trim(left(put(date,year4.)));
datalines;
16jun2000|100|Titan A.E.
15aug2002|96|The Adventures of Pluto Nash
06feb2015|90|Jupiter Ascending
27may2016|70|Alice Through the Looking Glass
01mar2013|125|Jack the Giant Slayer
25dec2013|98|47 Ronin
17dec2010|85|How Do You Know
22jun2013|100|The Lone Ranger
23feb2017|120|Monster Trucks
12dec2008|39|Delgo
07aug2015|80|Fantastic Four
19jun2013|100|R.I.P.D.
29jul2011|63|Cowboys and Aliens
19aug2016|76|Ben-Hur
28sep2016|60|Deepwater Horizon
22may2015|80|Tomorrowland
11sep2016|94|The Promise
27nov2018|174.8|Mortal Engines
22dec1995|89|CutThroat Island
20sep2015|130|Pan
08apr2005|78|Sahara
09mar2012|200|John Carter
08may2017|150|King Arthur: Legend of the Sword
02jul2003|125|Sinbad: Legend of the Seven Seas
03jun2016|75|Teenage Mutant Ninja Turtles: Out of the Shadows
22mar2017|76|Power Rangers
11mar2011|100|Mars Needs Moms
09may2008|73|Speed Racer
01aug2003|72|Gigli
29jul2005|96|Stealth
25nov2015|85|The Good Dinosaur
22jun2007|88|Evan Almighty
09jun2017|95|The Mummy
11dec1998|68|Jack Frost
24jul2015|75|Pixels
11jul2016|75|Ghostbusters
02jul2001|94|Final Fantasy: The Spirits Within
23nov2011|92|Hugo
12feb2010|76|The Wolfman
07aug2001|63|Osmosis Jones
21nov2012|87|Rise of the Guardians
27apr2001|85|Town and Country
27nov2002|85|Treasure Planet
17dec2014|85|Seventh Son
25dec2001|63|Ali
14jan2000|83|Supernova
09nov2016|75|Allied
24nov2004|71|Alexander
15jun2011|98|Green Lantern
26feb2016|79|Gods of Egypt
31mar2006|32|Basic Instinct 2
12apr2019|40|Hellboy
03oct2019|75|Gemini Man
10nov2000|93|Red Planet
19jul2002|94|K-19: The Widowmaker
24nov2010|95|The Nutcracker in 3D
02sep2005|96|A Sound of Thunder
26feb2018|130|A Wrinkle in Time
23oct2019|110|Terminator: Dark Fate
12apr2019|100|Missing Link
20jun2017|100|Transformers: The Last Knight
20nov2018|83|Robin Hood (2018)
21jul2017|82|Valerian and the City of a Thousand Planets
07jun2019|79|Dark Phoenix
06oct2017|80|Blade Runner 2049
08feb2019|79|The Lego Movie 2: The Second Part
10may2018|76|Solo: A Star Wars Story
05dec2016|75|The Great Wall
30jun2016|71|The BFG
20dec2019|71|Cats
;
run;

/*
The article didn't report $ on these, like they did the other,
therefore I'm leaving them out...
15jun2018|1.6|Gotti
15nov2017|1|Justice League
And this one was a couple decades before the others...
24jun1977|42|Sorcerer
*/

proc sort data=my_data out=my_data;
by date loss_millions;
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Box Office Flops") 
 style=htmlblue;

ods graphics /
 imagemap tipmax=2500 
 imagefmt=png imagename="&name"
 width=900px height=600px noborder; 

title1 h=16pt c=gray33 "Box Office Movie Flop Losses (In Million US$)";

footnote1 
 link="https://scientificfeed.com/stories/45-expensive-box-office-flops-ever-made/"
 h=10pt c=gray "Using data from: https://scientificfeed.com/stories/45-expensive-box-office-flops-ever-made/";

proc sgplot data=my_data noautolegend noborder;
needle x=date y=loss_millions / lineattrs=(color=red) markers markerattrs=(color=red)
 url=drill tip=(title loss_millions date);
text x=date y=text_y text=title / position=right rotate=90 contributeoffsets=(ymin) 
 textattrs=(color=blue size=8pt)
 url=drill tip=(title loss_millions date);
yaxis display=(nolabel noticks noline) reverse grid gridattrs=(pattern=dot color=gray88);
xaxis display=(nolabel);
run;

/*
proc sgplot data=my_data noautolegend noborder;
needle x=date y=loss_millions / lineattrs=(color=red) markers markerattrs=(color=red)
 url=drill tip=(title loss_millions date);
text x=date y=text_y text=title / position=right rotate=90 contributeoffsets=(ymin) 
 textattrs=(color=blue size=8pt)
 url=drill tip=(title loss_millions date);
yaxis display=(nolabel noticks noline) reverse grid gridattrs=(pattern=dot color=gray88);
xaxis display=(nolabel noticks noline novalues) type=discrete;
run;
*/

data my_data; set my_data;
order=_n_;
run;

proc sgplot data=my_data noautolegend noborder;
needle x=order y=loss_millions / lineattrs=(color=red) markers markerattrs=(color=red)
 url=drill tip=(title loss_millions date);
text x=order y=text_y text=title / position=right rotate=90 contributeoffsets=(ymin) 
 textattrs=(color=blue size=8pt)
 url=drill tip=(title loss_millions date);
yaxis display=(nolabel noticks noline) reverse grid gridattrs=(pattern=dot color=gray88);
xaxis display=(nolabel noticks noline novalues) type=discrete;
run;

proc sort data=my_data out=my_data;
by descending date;
run;

data my_data; set my_data;
length link $300 href $300;
href='href='||quote(trim(left(drill)));
label link='Movie';
link = '<a ' || trim(href) || ' target="_self">' || htmlencode(trim(title)) || '</a>';
run;

proc print data=my_data label noobs
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
var date loss_millions link;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
