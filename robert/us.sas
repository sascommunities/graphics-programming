%let name=us;
filename odsout '.';

/*
Creating a map similar to the old maps.us,
from Natural Earth maps.

Adapted from:
http://support.sas.com/rnd/datavisualization/mapsonline/html/us-project6.html
*/

%let maplib=D:\Public\naturalearthdata\maps_ne;

libname maps_ne "&maplib" outencoding=asciiany;

data usa; set maps_ne.usa;
length statecode $2;
statecode=scan(gn_a1_code,2,'.');
state=.; state=stfips(statecode);
run;

/* Seperate Continental states, Alaska, and Hawaii */

data CONTUALL AKUALL HIUALL; set usa (where=(density<=3));
if statecode='HI' then output HIUALL;
else if statecode='AK' then  output AKUALL;
else output CONTUALL;
run;

/* Project each map separately */

proc gproject data=CONTUALL out=CONTPALL latlong eastlong degrees dupok;
id STATE;
run;

proc gproject data=AKUALL out=AKPALL latlong eastlong degrees dupok longmin=-168.4137104 nodateline;
id STATE;
run;

proc gproject data=HIUALL out=HIPALL latlong eastlong degrees dupok longmin=-160.309348;
id STATE;
run;

/******************* Determine Scaling Factors **********************/

proc sql noprint;
/* Range of Hawaii in projected dataset */
select min(x) into :hixmin from hipall;
select min(y) into :hiymin from hipall;
select max(x) into :hixmax from hipall;
select max(y) into :hiymax from hipall;
/* Range of Alaska in projected dataset */
select min(x) into :akxmin from akpall;
select min(y) into :akymin from akpall;
select max(x) into :akxmax from akpall;
select max(y) into :akymax from akpall;
/* Range of Continental US in projected dataset */
select min(x) into :contxmin from contpall;
select min(y) into :contymin from contpall;
select max(x) into :contxmax from contpall;
select max(y) into :contymax from contpall;
quit; run;


/********************************************************************/
/*              rescale Alaska to fit under California              */
/* --------------------------------------------------------         */
/*   Scale X to (CONTXMIN, CONTXMIN + 0.200 * (CONTXMAX - CONTXMIN))*/
/*   Scale Y to (CONTYMIN, CONTYMIN + 0.285 * (CONTYMAX - CONTYMIN))*/
/* --------------------------------------------------------         */
/********************************************************************/
data akpall (drop = FACT1-FACT2 BX BY AX AY); set akpall;
FACT1 =  &contxmin + 0.200 * (&contxmax - &contxmin);
FACT2 =  &contymin + 0.285 * (&contymax - &contymin);
AX = (FACT1 - &contxmin) / (&akxmax - &akxmin);
AY = (FACT2 - &contymin) / (&akymax - &akymin);
BX = &contxmin - AX * &akxmin;
BY = &contymin - AY * &akymin;
X = X * AX + BX;
Y = Y * AY + BY;
run;


/*****************************************************************/
/*           rescale Hawaii to fit under New Mexico              */
/* -----------------------------------------------------         */
/*   Scale X to (CONTXMIN + 0.200 * (CONTXMAX - CONTXMIN),       */
/*               CONTXMIN + 0.300 * (CONTXMAX - CONTXMIN))       */
/*   Scale Y to (CONTYMIN, CONTYMIN + 0.143 * (CONTYMAX - CONTYMIN))*/
/* -----------------------------------------------------         */
/*****************************************************************/
data hipall (drop = FACT1-FACT3 BX BY AX AY); set hipall;
FACT1 =  &contxmin + 0.200 * (&contxmax - &contxmin);
FACT2 =  &contxmin + 0.300 * (&contxmax - &contxmin);
FACT3 =  &contymin + 0.143 * (&contymax - &contymin) ;
AX = (FACT2 - FACT1) / (&hixmax - &hixmin);
AY = (FACT3 - &contymin) / (&hiymax - &hiymin);
BX = FACT1 - AX * &hixmin;
BY = &contymin - AY * &hiymin;
X = X * AX + BX;
Y = Y * AY + BY;
run;


/********************* Recombine States ****************************/


data us; 
set CONTPALL AKPALL HIPALL;
run;

data us; set us;
original_order=_n_;
run;
proc sort data=us out=us;
by state original_order;
run;


/* save it in the maps_ne library */
data maps_ne.us (label="US - Source NaturalEarthData.com 2019");
length statecode $2;
length state 6.;
length segment 5.;
set us (keep = statecode state segment x y density); 
run;

/* create the us_attr dataset, and dave it */
proc sql noprint;
create table us_attr as
select unique statecode, state, fipnamel(state) as state_name
from maps_ne.us;
quit; run;

data maps_ne.us_attr (label="US - Source NaturalEarthData.com 2019"); 
set us_attr;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
