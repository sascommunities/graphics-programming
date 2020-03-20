%let name=coronavirus_state.sas;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

/*
Using data from: 
https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/
*/

/*
filename confdata url "https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv";
*/
filename confdata "covid_confirmed_usafacts.csv";
proc import datafile=confdata
 out=confirmed_data dbms=csv replace;
getnames=yes;
guessingrows=all;
run;

/*
Population data copy-n-pasted from...
https://factfinder.census.gov/bkmk/table/1.0/en/PEP/2018/PEPANNCHG.ST05?#
Select North Carolina from the Geography pull-down
copy-n-paste the table below the 'datalines'
(make sure your copy-n-paste preserves the tabs between columns!)
*/

data pop_data (keep = statecode county_name pop_2018);
length county_name $100;
informat pop_2017 pop_2018 change comma12.0;
infile datalines dlm='09'x; /* tab-delimited */
input county_name pop_2017 pop_2018 change change_pct 
 rank_pop_2017 rank_pop_2018 rank_change rank_change_pct;
format change_pct percentn7.1;
change_pct=change_pct/100;
statecode='NC';
datalines;
Alamance County	163,529	166,436	2,907	1.8	17	17	12	11
Alexander County	37,146	37,353	207	0.6	65	65	48	47
Alleghany County	11,023	11,161	138	1.3	94	94	56	28
Anson County	24,878	24,877	-1	0.0	75	75	73	73
Ashe County	26,803	27,109	306	1.1	73	73	44	32
Avery County	17,505	17,505	0	0.0	86	86	72	72
Beaufort County	47,051	47,079	28	0.1	55	55	68	70
Bertie County	19,274	19,026	-248	-1.3	84	84	92	97
Bladen County	33,468	33,190	-278	-0.8	70	70	94	91
Brunswick County	130,735	136,744	6,009	4.6	24	22	4	1
Buncombe County	257,185	259,103	1,918	0.7	7	7	17	44
Burke County	90,127	90,382	255	0.3	32	32	47	61
Cabarrus County	206,724	211,342	4,618	2.2	11	11	6	7
Caldwell County	81,920	82,029	109	0.1	34	34	60	68
Camden County	10,561	10,710	149	1.4	96	96	55	25
Carteret County	68,919	69,524	605	0.9	38	38	37	38
Caswell County	22,632	22,698	66	0.3	78	77	63	59
Catawba County	157,811	158,652	841	0.5	18	18	30	48
Chatham County	71,248	73,139	1,891	2.7	37	36	18	4
Cherokee County	27,980	28,383	403	1.4	71	71	39	23
Chowan County	14,040	14,029	-11	-0.1	89	89	76	76
Clay County	11,001	11,139	138	1.3	95	95	56	27
Cleveland County	97,228	97,645	417	0.4	29	29	38	52
Columbus County	55,987	55,655	-332	-0.6	50	51	95	89
Craven County	102,754	102,912	158	0.2	27	27	54	62
Cumberland County	331,239	332,330	1,091	0.3	5	5	26	56
Currituck County	26,323	27,072	749	2.8	74	74	31	3
Dare County	36,115	36,501	386	1.1	66	66	41	35
Davidson County	165,313	166,614	1,301	0.8	16	16	23	42
Davie County	42,369	42,733	364	0.9	61	61	42	40
Duplin County	58,862	58,856	-6	0.0	48	48	74	75
Durham County	311,888	316,739	4,851	1.6	6	6	5	16
Edgecombe County	52,757	52,005	-752	-1.4	53	53	99	100
Forsyth County	375,724	379,099	3,375	0.9	4	4	10	37
Franklin County	66,033	67,560	1,527	2.3	41	40	19	5
Gaston County	219,819	222,846	3,027	1.4	10	10	11	26
Gates County	11,515	11,573	58	0.5	93	93	65	50
Graham County	8,534	8,484	-50	-0.6	98	98	80	88
Granville County	59,374	60,115	741	1.2	47	47	32	29
Greene County	20,980	21,012	32	0.2	80	80	67	63
Guilford County	529,496	533,670	4,174	0.8	3	3	8	41
Halifax County	51,282	50,574	-708	-1.4	54	54	98	99
Harnett County	132,229	134,214	1,985	1.5	23	23	16	19
Haywood County	61,036	61,971	935	1.5	44	45	27	18
Henderson County	115,457	116,748	1,291	1.1	26	26	25	33
Hertford County	23,926	23,659	-267	-1.1	76	76	93	93
Hoke County	54,141	54,764	623	1.2	52	52	36	31
Hyde County	5,267	5,230	-37	-0.7	99	99	78	90
Iredell County	175,628	178,435	2,807	1.6	15	15	14	13
Jackson County	43,192	43,327	135	0.3	60	60	58	57
Johnston County	196,423	202,675	6,252	3.2	12	12	3	2
Jones County	9,602	9,637	35	0.4	97	97	66	55
Lee County	60,567	61,452	885	1.5	46	46	28	21
Lenoir County	56,641	55,976	-665	-1.2	49	49	97	94
Lincoln County	82,365	83,770	1,405	1.7	33	33	21	12
McDowell County	45,164	45,507	343	0.8	57	56	43	43
Macon County	34,624	35,285	661	1.9	68	67	34	9
Madison County	21,577	21,763	186	0.9	79	79	52	39
Martin County	22,776	22,671	-105	-0.5	77	78	85	85
Mecklenburg County	1,077,311	1,093,901	16,590	1.5	1	1	2	17
Mitchell County	14,979	15,000	21	0.1	87	87	69	65
Montgomery County	27,347	27,271	-76	-0.3	72	72	83	82
Moore County	97,232	98,682	1,450	1.5	28	28	20	20
Nash County	94,012	94,016	4	0.0	30	30	71	71
New Hanover County	228,657	232,274	3,617	1.6	9	9	9	14
Northampton County	19,913	19,676	-237	-1.2	82	83	91	95
Onslow County	194,838	197,683	2,845	1.5	13	13	13	22
Orange County	143,960	146,027	2,067	1.4	19	19	15	24
Pamlico County	12,654	12,670	16	0.1	91	91	70	69
Pasquotank County	39,476	39,639	163	0.4	62	62	53	53
Pender County	60,768	62,162	1,394	2.3	45	43	22	6
Perquimans County	13,460	13,422	-38	-0.3	90	90	79	83
Person County	39,395	39,507	112	0.3	63	63	59	60
Pitt County	178,617	179,914	1,297	0.7	14	14	24	45
Polk County	20,518	20,611	93	0.5	81	81	61	51
Randolph County	143,149	143,351	202	0.1	20	20	49	64
Richmond County	44,825	44,887	62	0.1	58	58	64	66
Robeson County	132,590	131,831	-759	-0.6	22	24	100	87
Rockingham County	90,841	90,690	-151	-0.2	31	31	87	79
Rowan County	140,537	141,262	725	0.5	21	21	33	49
Rutherford County	66,568	66,826	258	0.4	40	41	46	54
Sampson County	63,433	63,626	193	0.3	42	42	50	58
Scotland County	35,172	34,810	-362	-1.0	67	68	96	92
Stanly County	61,451	62,075	624	1.0	43	44	35	36
Stokes County	45,697	45,467	-230	-0.5	56	57	90	86
Surry County	72,118	71,948	-170	-0.2	36	37	89	80
Swain County	14,266	14,245	-21	-0.1	88	88	77	78
Transylvania County	33,825	34,215	390	1.2	69	69	40	30
Tyrrell County	4,183	4,131	-52	-1.2	100	100	81	96
Union County	231,424	235,908	4,484	1.9	8	8	7	8
Vance County	44,312	44,582	270	0.6	59	59	45	46
Wake County	1,071,886	1,092,305	20,419	1.9	2	2	1	10
Warren County	19,869	19,807	-62	-0.3	83	82	82	84
Washington County	12,019	11,859	-160	-1.3	92	92	88	98
Watauga County	55,088	55,945	857	1.6	51	50	29	15
Wayne County	123,257	123,248	-9	0.0	25	25	75	74
Wilkes County	68,464	68,557	93	0.1	39	39	61	67
Wilson County	81,567	81,455	-112	-0.1	35	35	86	77
Yadkin County	37,643	37,543	-100	-0.3	64	64	84	81
Yancey County	17,712	17,903	191	1.1	85	85	51	34
;
run;

%macro do_state(statecode);

%let lcstate=%sysfunc(lowcase(&statecode));

proc sql noprint;
select idname into :stname separated by ' ' from mapsgfk.us_states_attr where statecode="&statecode";
quit; run;

goptions device=png;
goptions xpixels=1000 ypixels=450;

ODS LISTING CLOSE;
ODS HTML path=odsout body="coronavirus_&lcstate..htm"
 (title="Coronavirus in &statecode") 
 style=htmlblue;

goptions gunit=pct htitle=5.5 htext=3.0 ftitle="albany amt" ftext="albany amt";
goptions ctext=gray33 border;

data state_confirmed; set confirmed_data (where=(state="&statecode"));
run;

proc transpose data=state_confirmed out=state_confirmed;
by countyFIPS County_Name State stateFIPS notsorted;
run;

data state_confirmed (drop = year month day datestring); 
 set state_confirmed (rename=(_name_=datestring col1=confirmed));
year=.; year=scan(datestring,-1,'_');
day=.; day=scan(datestring,-2,'_');
month=.; month=scan(datestring,-3,'_');
format date date9.;
date=mdy(month,day,year);
county=.; county=substr(put(countyFIPS,z5.),3,3);
if confirmed>0 then output;
run;

data state_pop; set pop_data (where=(statecode="&statecode"));
run;

proc sql noprint;

/* get the coronavirus data with the latest date */
create table latest_data as
select * from state_confirmed
having date=max(date);

/* merge in the population data */
create table latest_data as
select latest_data.*, state_pop.pop_2018
from latest_data left join state_pop
on latest_data.county_name = state_pop.county_name;

select sum(confirmed) format=comma12.0 into :total  separated by ' ' from latest_data;
select unique(date) format=nldate20. into :datestr separated by ' ' from latest_data;

quit; run;

data latest_data; set latest_data;
format per100k comma10.3;
per100k=confirmed/(pop_2018/100000);
format pct percent12.6;
pct=confirmed/pop_2018;
length my_html $300;
my_html='title='||quote(
 trim(left(county_name))||', '||trim(left("&statecode"))||'0d'x||
 '------------------------------'||'0d'x||
 trim(left(put(confirmed,comma20.0)))||' confirmed cases in '||trim(left(put(pop_2018,comma20.0)))||' residents.'||'0d'x||
 'That is '||trim(left(put(per100k,comma10.3)))||' cases per 100,000 residents,'||'0d'x||
 'or '||trim(left(put(pct,percent12.6)))||' of the county population.'
 );
run;

data my_map; set mapsgfk.us_counties (where=(statecode="&statecode" and density<=4) 
 drop=resolution);
run;

pattern1 v=s c=cxffffb2;
pattern2 v=s c=cxfecc5c;
pattern3 v=s c=cxfd8d3c;
pattern4 v=s c=cxf03b20;
pattern5 v=s c=cxbd0026;

title1 ls=1.5 h=18pt c=gray33 "&total confirmed Coronavirus (COVID-19) cases in " c=blue "&stname";

footnote 
 link='https://usafacts.org/visualizations/coronavirus-covid-19-spread-map/'
 ls=1.2 h=12pt c=gray "Coronavirus data source: usafacts.org (&datestr snapshot)";

legend1 label=(position=top justify=center font='albany amt/bold' 'Cases')
 across=1 position=(bottom left inside) order=descending
 shape=bar(.15in,.15in) offset=(21,5);

proc gmap data=latest_data map=my_map all;
format confirmed comma8.0;
id county;
choro confirmed / midpoints=old levels=5 range 
 coutline=gray22 cempty=graybb
 legend=legend1
 html=my_html
 des='' name="coronavirus_&statecode";
run;

legend2 label=(position=top justify=center font='albany amt/bold' 'Cases per 100,000 Residents')
 across=1 position=(bottom left inside) order=descending
 shape=bar(.15in,.15in) offset=(15,5);

ods html anchor='per100k';
proc gmap data=latest_data map=my_map all;
format confirmed comma8.0;
id county;
choro per100k / midpoints=old levels=5 range
 coutline=gray22 cempty=graybb
 legend=legend2
 html=my_html
 des='' name="coronavirus_&statecode._100k";
run;

proc sort data=latest_data out=latest_data;
by descending confirmed county_name;
run;

proc print data=latest_data label
 style(data)={font_size=11pt}
 style(header)={font_size=11pt}
 style(grandtotal)={font_size=11pt}
 ;
label county_name='County';
label confirmed='Coronavirus cases';
label pop_2018='Population (2018)';
label per100k='Cases per 100,000 residents';
label pct='Percent of residents with Coronavirus';
format pop_2018 comma12.0;
var county_name confirmed pop_2018 per100k pct;
sum confirmed;
run;

proc sql noprint;
create table summarized_series as 
select unique date, sum(confirmed) as confirmed
from state_confirmed
group by date;
quit; run;

proc sql noprint;
select min(date) format=date9. into :mindate from summarized_series;
select max(date) format=date9. into :maxdate from summarized_series;
select max(date)-min(date) into :byval from summarized_series;
quit; run;

axis1 value=(c=gray33 h=11pt) label=none minor=none offset=(0,0);
axis2 value=(c=gray33 h=11pt) label=none order=("&mindate"d to "&maxdate"d by &byval) offset=(1,2);
symbol1 interpol=sm50 line=33 height=8pt width=2 color=red value=square;

ods html anchor='graph';
goptions xpixels=800 ypixels=550 noborder;
proc gplot data=summarized_series;
format confirmed comma12.0;
format date nldate20.;
plot confirmed*date / nolegend
 vaxis=axis1 haxis=axis2
 des='' name="coronavirus_&statecode._map";
run;

quit;
ODS HTML CLOSE;
ODS LISTING;

%mend do_state;

%do_state(NC);

