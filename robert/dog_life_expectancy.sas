%let name=dog_life_expectancy;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/* 
My version of this graph:
https://www.reddit.com/r/dataisbeautiful/comments/ony7uc/oc_its_a_dogs_life_smaller_breeds_also_have/

Using https://www.reddit.com/user/the_guruji's data from:
https://pastebin.com/pGLY2Lms
https://pastebin.com/raw/pGLY2Lms
*/

%let markercolor=red;
%let labelcolor=blue;

data my_data;
length breed weight_range_kg $50;
input breed life_expectancy weight_range_kg;
infile datalines dlm=','; 
datalines;
Afghan Hound,12,20-27
Airedale Terrier,11.2,18-23
American Staffordshire Terrier,12.3,23-36
Basset Hound,12.8,25-34
Beagle,13.3,10-11.3
Bearded Collie,12.3,18-27
Bedlington Terrier,14.3,7.7-10.4
Bernese Mountain Dog,7,35-70
Border Collie,13,14-20
Border Terrier,13.8,6.0-7
Boston Terrier,15,3.0-11
Boxer,10.4,29-34
Bull Terrier,12.9,22-38
Bulldog,6.7,24-26
Bullmastiff,8.6,50-59
Cairn Terrier,13.2,4.5-7.3
Cavalier King Charles Spaniel,10.7,5.9-12.7
Chihuahua,15,1.8-2.7
Chow Chow,13.5,18-41
American Cocker Spaniel,12.5,11.0-14
Dachshund,12.2,7.5-14.5
Dalmatian,13,15-32
Doberman Pinscher,9.8,40-45
English Cocker Spaniel,11.8,13-14
English Setter,11.2,29-36
English Springer Spaniel,13,18-27
English Toy Spaniel,10.1,3.6-6.4
Flat-Coated Retriever,9.5,27-36
German Shepherd,10.3,30-40
German Shorthaired Pointer,12.3,25-32
Golden Retrievers,12,29-34
Gordon Setter,11.3,25-36
Great Dane,8.4,50-82
Greyhound,13.2,27-40
Irish Red and White Setter,12.9,23-32
Irish Setter,11.8,29-34
Irish Wolfhound,6.2,54-55
Jack Russell Terrier,13.6,6.0-8
Labrador Retriever,12.6,29-36
Lurcher,12.6,27-32
Miniature Dachshund,14.4,5.0-6
Miniature Pinscher,14.9,3.6-4.5
Miniature Poodle,14.8,12.0-14.0
Newfoundland,10,65-80
Norfolk Terrier,14,5.0-6
Old English Sheepdog,11.8,36-46
Pekingese,13.3,3.2-6.4
Pomeranian,14.5,1.4-3.2
Pug,16,6.0-8.0
Rajapalayam hound,11.2,31-32
Rhodesian Ridgeback,9.1,40-50
Rottweiler,9.8,50-60
Rough Collie,12.2,20-34
Samoyed,11,20-30
Scottish Deerhound,9.5,39-50
Scottish Terrier,12,8.5-10
Shetland Sheepdog,13.3,5-10.9
Shiba Inu,14,9.0-11
Shih Tzu,13.4,4-7.5
Siberian Husky,13.5,20-27
Soft Coated Wheaten Terrier,13.2,14-20
Staffordshire Bull Terrier,14,13-17
Standard Poodle,12,20-32
Tibetan Terrier,14.3,9.5-11
Toy Poodle,14.4,6.5-7.5
Vizsla,12.5,20-30
Weimaraner,10,30-40
Welsh Corgi,11.3,14-17
Welsh Springer Spaniel,11.5,16-20
West Highland White Terrier,12.8,6.8-9.1
Wire Fox Terrier,13,7.7-8.6
Yorkshire Terrier,12.8,2.0-3
;
run;

data my_data; set my_data;
label breed='Breed';
label life_expectancy='Life Expectancy (years)';
label weight_mid_lb='Weight (pounds)';
label weight_range_lb='Weight Range (pounds)';
weight_min_lb=.; weight_min_lb=scan(weight_range_kg,1,'-')*2.2;
weight_max_lb=.; weight_max_lb=scan(weight_range_kg,2,'-')*2.2;
weight_mid_lb=(weight_min_lb+weight_max_lb)/2;
length weight_range_lb $20;
weight_range_lb=trim(left(weight_min_lb))||' - '||trim(left(weight_max_lb));
my_html='http://images.google.com/images?q='||trim(left(breed))||' dogs';
run;


ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Dog Life Expectancy") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap tipmax=2500 drilltarget="_self"
 imagefmt=png imagename="&name"
 width=800px height=800px noborder; 

title1 c=gray33 h=18pt "Dog Life Expectancy, by Breed";
title2 c=gray66 h=12pt ls=.5 "Using data from Wikipedia (compiled by reddit user the_guruji)";
title3 h=3pt 'a0'x;

/*
proc sgplot data=my_data noautolegend;
scatter y=life_expectancy x=weight_mid_lb / markerattrs=(color=&markercolor size=10);
run;
*/

/*
proc sgplot data=my_data noautolegend;
highlow y=life_expectancy low=weight_min_lb high=weight_max_lb / 
 lineattrs=(color=&markercolor);
scatter y=life_expectancy x=weight_mid_lb / markerattrs=(color=&markercolor size=10);
xaxis label='Weight Range (pounds)';
run;
*/

proc sgplot data=my_data noautolegend noborder;
highlow y=life_expectancy low=weight_min_lb high=weight_max_lb / 
 lineattrs=(color=&markercolor);
scatter y=life_expectancy x=weight_mid_lb / 
 markerattrs=(color=&markercolor size=10)
 datalabel=breed datalabelattrs=(color=&labelcolor)
 tip=(breed weight_range_lb life_expectancy) url=my_html;
yaxis display=(noline noticks) offsetmin=0
 values=(6 to 16 by 1)
 labelattrs=(color=gray66 size=12pt weight=bold)
 grid gridattrs=(pattern=dot color=gray88);
xaxis display=(noline noticks) offsetmax=0
 values=(0 to 200 by 25)
 label='Weight Range (pounds)'
 labelattrs=(color=gray66 size=12pt weight=bold) 
 grid gridattrs=(pattern=dot color=gray88);
run;

proc sort data=my_data out=my_data;
by breed;
run;

proc print data=my_data label noobs;
var breed life_expectancy weight_range_lb;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
