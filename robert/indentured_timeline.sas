%let name=indentured_timeline;

/* %let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); */
filename odsout '.';

/*
http://www.sesug.org/SESUG2019/DataVisualizationCompetition.php
*/

proc import out=my_data datafile="Indentured Servants.xlsx" dbms=xlsx replace;
getnames=yes;
run;

/* Convert the string date to a proper/numeric date value */
data my_data; set my_data;
length month $15;
/* had to make an assumption on this 1 bad-data obsn. I just set it to January. */
if Servant_s_Date_of_Indenture='19 1725' then Servant_s_Date_of_Indenture='January 19 1725';
Servant_s_Place_of_Origin=tranwrd(Servant_s_Place_of_Origin,'Mddx','Middlesex');
month=scan(Servant_s_Date_of_Indenture,1,' ');
day=.; day=scan(Servant_s_Date_of_Indenture,2,' ');
if day=0 then day=1;
year=.; year=scan(Servant_s_Date_of_Indenture,3,' ');
ddmmmyyyy=put(day,z2.)||substr(month,1,3)||trim(left(year));
format start_date end_date date9.;
start_date=input(ddmmmyyyy,date9.);
end_date=start_date+(365*Servant_s_Length_of_Indenture);
run;

proc sort data=my_data out=my_data;
by start_date Servant_s_Length_of_Indenture Servant_s_Gender;
run;

data my_data; set my_data;
obsnum=_n_;
if Servant_s_Occupation='' then Servant_s_Occupation='unknown';
if Servant_s_Place_of_Origin='Reading, Berks' then do; lat=51.4535753; long=-1.0643709; end;
if Servant_s_Place_of_Origin='Stains, Middlesex' then do; lat=51.4236471; long=-0.5410158; end;
if Servant_s_Place_of_Origin='Worcester' then do; lat=52.1931261; long=-2.2809798; end;
if Servant_s_Place_of_Origin='St. Mary, White Chapple' then do; lat=37.7467118; long=-76.5549111; end;
if Servant_s_Place_of_Origin='St. Peters, Oxford' then do; lat=51.7527168; long=-1.2627612; end;
if Servant_s_Place_of_Origin='Dublin' then do; lat=53.3328498; long=-6.3830407; end;
if Servant_s_Place_of_Origin='St. Giles in the Fields' then do; lat=51.5152329; long=-0.1305469; end;
if Servant_s_Place_of_Origin='Fareham, Hampshire' then do; lat=50.8477033; long=-1.2626854; end;
if Servant_s_Place_of_Origin='Michaelstone, Cornwall' then do; lat=50.5805165; long=-4.7306061; end;
if Servant_s_Place_of_Origin='Goswell St.' then do; lat=51.5267766; long=-0.1024191; end;
if Servant_s_Place_of_Origin='Chere Market, London' then do; lat=51.509594; long=-0.1401777; end;
if Servant_s_Place_of_Origin='Edenburgh' then do; lat=55.9368986; long=-3.3433615; end;
if Servant_s_Place_of_Origin='Cardigan' then do; lat=52.0836506; long=-4.6678964; end;
if Servant_s_Place_of_Origin='Spittlefields, London' then do; lat=51.5132535; long=-0.1635911; end;
if Servant_s_Place_of_Origin='St. Giles in the Fields, Middlesex' then do; lat=51.5151816; long=-0.1310028; end;
if Servant_s_Place_of_Origin='Portsmouth' then do; lat=50.8021111; long=-1.1681433; end;
if Servant_s_Place_of_Origin='Harbury, Herts' then do; lat=52.2335345; long=-1.465283; end;
if Servant_s_Place_of_Origin='Abington, Berks' then do; lat=40.1171225; long=-75.1200736; end;
if Servant_s_Place_of_Origin='Henley Upon Thames' then do; lat=51.5351816; long=-0.9236486; end;
if Servant_s_Place_of_Origin='Exeter' then do; lat=50.7198428; long=-3.5818707; end;
if Servant_s_Place_of_Origin='Dunster, Somerset' then do; lat=51.1833764; long=-3.4502478; end;
if Servant_s_Place_of_Origin='St. James, Clerkenwell' then do; lat=51.523364; long=-0.107916; end;
if Servant_s_Place_of_Origin='Canterbury' then do; lat=51.2769279; long=1.0490031; end;
if Servant_s_Place_of_Origin='St. Pauls, Shadwell' then do; lat=51.5092865; long=-0.0543504; end;
if Servant_s_Place_of_Origin='Goodmansfield London' then do; lat=51.5115824; long=-0.0752404; end;
if Servant_s_Place_of_Origin='Shrewsbury' then do; lat=52.7130332; long=-2.7847063; end;
if Servant_s_Place_of_Origin='St. Mary, Rotherhithe' then do; lat=51.5013479; long=-0.0559626; end;
if Servant_s_Place_of_Origin='Epsom, Surrey' then do; lat=51.3302371; long=-0.33018; end;
if Servant_s_Place_of_Origin='Town Malden Also called West Malling, Kent' then do; lat=42.4264059; long=-71.088632; end;
if Servant_s_Place_of_Origin='Southmolton, Devon' then do; lat=51.0174788; long=-3.8474104; end;
if Servant_s_Place_of_Origin='Sunbury, Middlesex' then do; lat=51.4148558; long=-0.428753; end;
if Servant_s_Place_of_Origin='Dunhead, Wiltshire' then do; lat=51.0182642; long=-2.1516896; end;
if Servant_s_Place_of_Origin='Uppingham' then do; lat=52.5881537; long=-0.7398834; end;
if Servant_s_Place_of_Origin='Spittlefields, Middlesex' then do; lat=51.5165627; long=-0.0789771; end;
if Servant_s_Place_of_Origin='Billiter Lane, London' then do; lat=51.5127013; long=-0.0824687; end;
if Servant_s_Place_of_Origin='Bishops Storford, Herts' then do; lat=51.8734833; long=0.1355779; end;
if Servant_s_Place_of_Origin='St. Botolph, Bishopsgate' then do; lat=51.5153026; long=-0.0812106; end;
if Servant_s_Place_of_Origin='Bristoll' then do; lat=51.4546611; long=-2.5925003; end;
if Servant_s_Place_of_Origin='Horsleydown, (London)' then do; lat=51.5032887; long=-0.0784027; end;
if Servant_s_Place_of_Origin='Wybunbury, Cheshire' then do; lat=53.0475895; long=-2.4709709; end;
if Servant_s_Place_of_Origin='St. Mary Over, Southwark' then do; lat=51.5024489; long=-0.0903738; end;
if Servant_s_Place_of_Origin='St. Lukes, Old St. (London)' then do; lat=51.5251104; long=-0.0961888; end;
if Servant_s_Place_of_Origin='Loughborough, Leics' then do; lat=52.7644122; long=-1.253208; end;
if Servant_s_Place_of_Origin='Winsham, Surrey' then do; lat=50.8379874; long=-2.9841705; end;
if Servant_s_Place_of_Origin='St. Pauls Churchyard' then do; lat=51.5133647; long=-0.1008977; end;
if Servant_s_Place_of_Origin='Taunton, Somerset' then do; lat=51.0191633; long=-3.1347868; end;
if Servant_s_Place_of_Origin='Witham, Essex' then do; lat=51.7996849; long=0.6037038; end;
if Servant_s_Place_of_Origin='St. Mary Overs, Southwark' then do; lat=51.5060074; long=-0.0917845; end;
if Servant_s_Place_of_Origin='Broadfare, St. Lawrence, Reading, Berks' then do; lat=40.3331079; long=-75.9594617; end;
if Servant_s_Place_of_Origin='Bromley, Kent' then do; lat=51.3967432; long=-0.0447005; end;
if Servant_s_Place_of_Origin='St. Margarets, Westminster' then do; lat=51.4997019; long=-0.1288506; end;
if Servant_s_Place_of_Origin='St. Marys, White Chapel' then do; lat=37.7467627; long=-76.5549648; end;
if Servant_s_Place_of_Origin='Whitchurch, Hants' then do; lat=51.2335338; long=-1.3970855; end;
if Servant_s_Place_of_Origin='Kendall, Westmorland' then do; lat=54.3275623; long=-2.7526499; end;
if Servant_s_Place_of_Origin='Malpas, Cheshire' then do; lat=53.0223299; long=-2.7842479; end;
if Servant_s_Place_of_Origin='Wells' then do; lat=51.2089809; long=-2.6643; end;
if Servant_s_Place_of_Origin='Croydon, Surrey' then do; lat=51.3658781; long=-0.1495327; end;
if Servant_s_Place_of_Origin='Tarperley, Cheshire' then do; lat=53.1559217; long=-2.6831932; end;
if Servant_s_Place_of_Origin='Hammersmith, Middlesex' then do; lat=51.4931332; long=-0.2229674; end;
if Servant_s_Place_of_Origin='Sapsud, Herts' then do; lat=51.8371811; long=-0.5497998; end;
if Servant_s_Place_of_Origin='St. Botolphs, Aldersgate, London' then do; lat=51.51553; long=-0.0949387; end;
if Servant_s_Place_of_Origin='Horsington, Lincs' then do; lat=53.2027854; long=-0.2339109; end;
if Servant_s_Place_of_Origin='St. Martins, Leicester' then do; lat=52.6342778; long=-1.137833; end;
if Servant_s_Place_of_Origin='Edinburgh, Scotland' then do; lat=55.936514; long=-3.3419882; end;
if Servant_s_Place_of_Origin='St. George the Martyr, Middlesex' then do; lat=51.5209739; long=-0.1245292; end;
if Servant_s_Place_of_Origin='Market Drayton, Salop' then do; lat=52.9036053; long=-2.5067359; end;
if Servant_s_Place_of_Origin='Chester' then do; lat=53.1913525; long=-2.9218712; end;
if Servant_s_Place_of_Origin='Portsey, Bam, Scotland' then do; lat=57.6803698; long=-2.693382; end;
if Servant_s_Place_of_Origin='St. Butolphs, Bishopsgate, London' then do; lat=51.5153259; long=-0.0810512; end;
if Servant_s_Place_of_Origin='Salisbury' then do; lat=51.0759311; long=-1.8428479; end;
if Servant_s_Place_of_Origin='St. Mary, Lambeth, Surrey' then do; lat=51.496021; long=-0.1146814; end;
if Servant_s_Place_of_Origin='Giddington, Northants' then do; lat=52.4400715; long=-0.7304121; end;
if Servant_s_Place_of_Origin='St. Georges, Bloomsberry, Middlesex' then do; lat=51.5175823; long=-0.1267265; end;
if Servant_s_Place_of_Origin='Wooburn, Beds' then do; lat=51.9875749; long=-0.6283843; end;
if Servant_s_Place_of_Origin='Nun Eaton, Warwicks' then do; lat=52.5173253; long=-1.5469603; end;
if Servant_s_Place_of_Origin='Hackney, Middlesex' then do; lat=51.5463605; long=-0.0515506; end;
if Servant_s_Place_of_Origin='Bennington, Herts' then do; lat=51.8965389; long=-0.1187108; end;
if Servant_s_Place_of_Origin='St. Saviors, Southwark, Surrey' then do; lat=51.4845793; long=-0.1796398; end;
if Servant_s_Place_of_Origin='Southampton' then do; lat=50.9116351; long=-1.4684728; end;
if Servant_s_Place_of_Origin='Pocklington, Yorkshire' then do; lat=53.9301394; long=-0.7955372; end;
if Servant_s_Place_of_Origin='Walsal, Staffs' then do; lat=52.5893696; long=-2.0395445; end;
if Servant_s_Place_of_Origin='Tower Hamlets in Middlesex' then do; lat=51.5165827; long=-0.0790308; end;
if Servant_s_Place_of_Origin='Lidlidge, Dorset' then do; lat=50.7641878; long=-2.569909; end;
if Servant_s_Place_of_Origin='Maxfield, Cheshire' then do; lat=51.5111723; long=-0.0951706; end;
if Servant_s_Place_of_Origin='St. Butolphs, Aldgate, London' then do; lat=51.5139676; long=-0.0786408; end;
if Servant_s_Place_of_Origin='St. Bartholomews by the Exchange, London' then do; lat=51.5181616; long=-0.1021894; end;
if Servant_s_Place_of_Origin='St. Wasenburg, Bristol' then do; lat=51.4615611; long=-2.7273678; end;
if Servant_s_Place_of_Origin='St. Peters, Norwich' then do; lat=52.6277794; long=1.2904679; end;
if Servant_s_Place_of_Origin='Southwark' then do; lat=51.5022983; long=-0.1039601; end;
if Servant_s_Place_of_Origin='Clapham, Yorks' then do; lat=54.117183; long=-2.4088489; end;
if Servant_s_Place_of_Origin='St. Olaves, Southwark, Surrey' then do; lat=51.5108425; long=-0.081455; end;
if Servant_s_Place_of_Origin='St. Anns Aldergate, London' then do; lat=51.5164586; long=-0.0983479; end;
if Servant_s_Place_of_Origin='Petersfield, Hants' then do; lat=51.0052207; long=-0.94971; end;
if Servant_s_Place_of_Origin='Sherborne, Hants' then do; lat=51.1962377; long=-1.4200381; end;
if Servant_s_Place_of_Origin='St. John, Wapping, Middlesex' then do; lat=51.5036535; long=-0.0639968; end;
if Servant_s_Place_of_Origin='St. Anns, Westminster, Middlesex' then do; lat=51.4973433; long=-0.1316874; end;
if Servant_s_Place_of_Origin='Chiswick, Middlesex' then do; lat=51.4857555; long=-0.2526605; end;
if Servant_s_Place_of_Origin='Blackfryers, London' then do; lat=51.5117244; long=-0.1115001; end;
if Servant_s_Place_of_Origin='Shadwell, Middlesex' then do; lat=51.5149371; long=-0.0727732; end;
if Servant_s_Place_of_Origin='Stoke Underham, Somerset' then do; lat=50.9545419; long=-2.7606032; end;
if Servant_s_Place_of_Origin='Newport Pagnell, Buckinghamshire' then do; lat=52.0837179; long=-0.7446743; end;
if Servant_s_Place_of_Origin='St. Faiths, London' then do; lat=51.4573546; long=-0.1736637; end;
if Servant_s_Place_of_Origin='Ludlow, Salop' then do; lat=52.3708295; long=-2.7275179; end;
if Servant_s_Place_of_Origin='St. Sepulchers, London' then do; lat=51.5165719; long=-0.1043571; end;
if Servant_s_Place_of_Origin='Little Milton, Oxon' then do; lat=51.70304; long=-1.1151461; end;
if Servant_s_Place_of_Origin='Lambeth, Surrey' then do; lat=51.4956285; long=-0.1193551; end;
if Servant_s_Place_of_Origin='St. Mary Aldermarry, London' then do; lat=51.512658; long=-0.0956906; end;
if Servant_s_Place_of_Origin='St. Peters, Liverpool' then do; lat=53.3759231; long=-2.8712743; end;
if Servant_s_Place_of_Origin='Deal, Kent' then do; lat=51.221445; long=1.3516424; end;
if Servant_s_Place_of_Origin='Best St., Norwich' then do; lat=52.6313495; long=1.2884269; end;
if Servant_s_Place_of_Origin='St. Andrews, Holbourn, London' then do; lat=51.5170623; long=-0.1089539; end;
if Servant_s_Place_of_Origin='Dublin, Ireland' then do; lat=53.318496; long=-6.3857873; end;
if Servant_s_Place_of_Origin='Nutfield, Surrey' then do; lat=51.2394312; long=-0.1326891; end;
if Servant_s_Place_of_Origin='Perth, Scotland' then do; lat=56.3897008; long=-3.5134552; end;
if Servant_s_Place_of_Origin='Dilston, Northumberland' then do; lat=54.9633623; long=-2.0539598; end;
if Servant_s_Place_of_Origin='St. Giles, Criplegate, London' then do; lat=51.5185884; long=-0.0959106; end;
if Servant_s_Place_of_Origin='Melford, Suffolk' then do; lat=52.0780561; long=0.7046728; end;
if Servant_s_Place_of_Origin='St. Annes Westminster' then do; lat=51.5122652; long=-0.1339575; end;
if Servant_s_Place_of_Origin='Ewell, Surrey' then do; lat=51.3511902; long=-0.2837415; end;
if Servant_s_Place_of_Origin='St. Giles Criplegate, London' then do; lat=51.5186551; long=-0.0958784; end;
if Servant_s_Place_of_Origin='Oxford' then do; lat=51.7501829; long=-1.3152244; end;
if Servant_s_Place_of_Origin='Trinity, Chester' then do; lat=53.1947281; long=-2.8918673; end;
if Servant_s_Place_of_Origin='Broadworthy, Devon' then do; lat=50.9013291; long=-4.393578; end;
if Servant_s_Place_of_Origin='Elsmore, Salop' then do; lat=52.6376773; long=-3.2424655; end;
if Servant_s_Place_of_Origin='Nottingham' then do; lat=52.9502787; long=-1.2308318; end;
if Servant_s_Place_of_Origin='St. Katherine Creed Church, London' then do; lat=51.5133081; long=-0.0809726; end;
if Servant_s_Place_of_Origin='Flemton, Suffolk' then do; lat=52.2968093; long=0.6397824; end;
if Servant_s_Place_of_Origin='St. James, Westminster, Middlesex' then do; lat=51.5072818; long=-0.1397495; end;
if Servant_s_Place_of_Origin='Tingary (?), Beds' then do; lat=52.1249445; long=-0.5095247; end;
if Servant_s_Place_of_Origin='Glasgow, Scotland' then do; lat=55.8469009; long=-4.3725413; end;
if Servant_s_Place_of_Origin='St. Georges, Norwich' then do; lat=52.6312251; long=1.2875391; end;
if Servant_s_Place_of_Origin='Emley Castle, Worcs' then do; lat=52.0695958; long=-2.0410208; end;
if Servant_s_Place_of_Origin='St. Thomas Appotle, London' then do; lat=51.5185521; long=-0.1234047; end;
if Servant_s_Place_of_Origin='Stepney, Middlesex' then do; lat=51.5200685; long=-0.0525924; end;
if Servant_s_Place_of_Origin='St. James, Bristol' then do; lat=51.458543; long=-2.5951787; end;
if Servant_s_Place_of_Origin='Kemble, Wiltshire' then do; lat=51.67406; long=-2.0256625; end;
if Servant_s_Place_of_Origin='Glenyla Shire of Angus, Scotland' then do; lat=56.7018714; long=-3.4466331; end;
if Servant_s_Place_of_Origin='St. Peters in the East, Oxford' then do; lat=51.7525641; long=-1.2628041; end;
if Servant_s_Place_of_Origin='Whitham, Essex' then do; lat=51.8000034; long=0.6018155; end;
if Servant_s_Place_of_Origin='St. Michaels at Coslena (Coslany), Norwich' then do; lat=52.6327839; long=1.2890579; end;
if Servant_s_Place_of_Origin='Kingston, Surrey' then do; lat=51.4150383; long=-0.3233681; end;
if Servant_s_Place_of_Origin='Boston, Lincs' then do; lat=52.9773439; long=-0.0567744; end;
if Servant_s_Place_of_Origin='Sheerness, Kent' then do; lat=51.4345467; long=0.7473256; end;
if Servant_s_Place_of_Origin='St. Brides, Fleet St., London' then do; lat=51.513696; long=-0.1076898; end;
if Servant_s_Place_of_Origin='St. Georges, Southwark, Surrey' then do; lat=51.5011841; long=-0.0947391; end;
if Servant_s_Place_of_Origin='Oakham, Rutland' then do; lat=52.6655384; long=-0.7570984; end;
if Servant_s_Place_of_Origin='Leeds, Yorkshire' then do; lat=53.8006493; long=-1.6737554; end;
if Servant_s_Place_of_Origin='St. Mary Cray, Kent' then do; lat=51.3844378; long=0.0962381; end;
if Servant_s_Place_of_Origin='Freeson, Lincolnshire' then do; lat=53.1253283; long=-0.6709307; end;
if Servant_s_Place_of_Origin='Arieth, Huntingdonshire' then do; lat=52.3606067; long=-0.4961652; end;
if Servant_s_Place_of_Origin='Yexley, Hunts' then do; lat=52.5177383; long=-0.27308; end;
if Servant_s_Place_of_Origin='Linton, Tiviotdele, Scotland' then do; lat=55.5269626; long=-2.3737274; end;
if Servant_s_Place_of_Origin='St. Pauls, Bedford' then do; lat=52.1361232; long=-0.4947057; end;
if Servant_s_Place_of_Origin='St. Albans, Herts' then do; lat=51.7516482; long=-0.3535606; end;
if Servant_s_Place_of_Origin='Thame, Oxon' then do; lat=51.7444852; long=-0.990009; end;
if Servant_s_Place_of_Origin='Southampton, Hampshire' then do; lat=50.9109857; long=-1.4684728; end;
if Servant_s_Place_of_Origin='St. Larence, City of London' then do; lat=51.5140173; long=-0.0969748; end;
if Servant_s_Place_of_Origin='Sheilds, Northumberland' then do; lat=55.3233709; long=-1.9713305; end;
if Servant_s_Place_of_Origin='Richmond(d), Surrey' then do; lat=51.4558506; long=-0.3308202; end;
if Servant_s_Place_of_Origin='Barmin, Kent' then do; lat=51.2618549; long=0.4431505; end;
if Servant_s_Place_of_Origin='Stroud, Glos' then do; lat=51.7408621; long=-2.2591324; end;
if Servant_s_Place_of_Origin='Leatherhead, Surrey' then do; lat=51.2989424; long=-0.3568061; end;
if Servant_s_Place_of_Origin='Keir, Worcs' then do; lat=52.1853458; long=-2.4822514; end;
if Servant_s_Place_of_Origin='Leeds, Yorks' then do; lat=53.797405; long=-1.6751287; end;
if Servant_s_Place_of_Origin='St. Botolph, Aldersgate, London' then do; lat=51.5151027; long=-0.0951533; end;
if Servant_s_Place_of_Origin='Kedlethorp, Lincs' then do; lat=53.2708175; long=-0.7456856; end;
if Servant_s_Place_of_Origin='Soam, Cambridgeshire' then do; lat=52.3349976; long=-0.4190587; end;
if Servant_s_Place_of_Origin='St. James, Clerkenwell, Middlesex' then do; lat=51.5232706; long=-0.1078838; end;
if Servant_s_Place_of_Origin='Christ Church, London' then do; lat=51.5097748; long=-0.1821599; end;
if Servant_s_Place_of_Origin='Penrith, Cumberland' then do; lat=54.6624555; long=-2.7690211; end;
if Servant_s_Place_of_Origin='Farway, Devon' then do; lat=50.7532907; long=-3.1795399; end;
if Servant_s_Place_of_Origin='St. Philips, Birmingham, Warwicks' then do; lat=52.4810731; long=-1.9010448; end;
if Servant_s_Place_of_Origin='Liverpool, Lancs' then do; lat=53.3972747; long=-3.0664392; end;
if Servant_s_Place_of_Origin='Bamton, Oxfordshire' then do; lat=51.7238582; long=-1.5576474; end;
if Servant_s_Place_of_Origin='Greenwich, Kent' then do; lat=51.4916945; long=0.0091064; end;
if Servant_s_Place_of_Origin='White Chappell, Middlesex' then do; lat=51.5165827; long=-0.0790308; end;
if Servant_s_Place_of_Origin='Painswick, Glos' then do; lat=51.7897337; long=-2.2101354; end;
if Servant_s_Place_of_Origin='Birmingham, Warwicks' then do; lat=52.4726694; long=-1.8855638; end;
if Servant_s_Place_of_Origin='Ruston, Norfolk' then do; lat=52.8002499; long=1.4602126; end;
if Servant_s_Place_of_Origin='Whitechappel, Middlesex' then do; lat=51.516556; long=-0.0789771; end;
if Servant_s_Place_of_Origin='Windsor, Berks' then do; lat=51.477514; long=-0.6560285; end;
if Servant_s_Place_of_Origin='Oundell, Northants' then do; lat=52.4841538; long=-0.489449; end;
if Servant_s_Place_of_Origin='St. Andrews, Holbourn, Middlesex' then do; lat=51.5170222; long=-0.1089431; end;
if Servant_s_Place_of_Origin='Chatteris, Isle of Ely, Cambs' then do; lat=52.403712; long=0.250788; end;
if Servant_s_Place_of_Origin='Upton Nr. Slough, Bucks' then do; lat=51.5038781; long=-0.6055424; end;
if Servant_s_Place_of_Origin='Torsely, Kent' then do; lat=51.1795643; long=0.2316592; end;
if Servant_s_Place_of_Origin='Foden Bridge, Hants' then do; lat=51.0452159; long=-1.8378162; end;
if Servant_s_Place_of_Origin='Northallerton, Yorkshire' then do; lat=54.3363049; long=-1.4686653; end;
if Servant_s_Place_of_Origin='Newcastle Upon Tine, Northumberland' then do; lat=54.9737617; long=-1.6425255; end;
if Servant_s_Place_of_Origin='Lynn, Norfolk' then do; lat=52.7500244; long=0.3838155; end;
if Servant_s_Place_of_Origin='Canterbury, Kent' then do; lat=51.2775722; long=1.0496897; end;
if Servant_s_Place_of_Origin='Barwick (Berwick) Upon Tweed' then do; lat=55.7774771; long=-2.0254163; end;
if Servant_s_Place_of_Origin='St. Saviours, Southwark' then do; lat=51.4944422; long=-0.0905946; end;
if Servant_s_Place_of_Origin='Breadhurst, Kent' then do; lat=51.3311585; long=0.5709695; end;
if Servant_s_Place_of_Origin='Newington Buts, Surrey' then do; lat=51.49508; long=-0.1457281; end;
if Servant_s_Place_of_Origin='Cardiff, Glam, Wales' then do; lat=51.4897453; long=-3.177464; end;
if Servant_s_Place_of_Origin='Edmundsbury, Suffolk' then do; lat=52.2168628; long=0.4150253; end;
if Servant_s_Place_of_Origin='Oler, Somerset' then do; lat=51.0650538; long=-2.8946795; end;
if Servant_s_Place_of_Origin='Portsmouth, Hants' then do; lat=50.8113161; long=-1.1292847; end;
if Servant_s_Place_of_Origin='St. Andrew Holbourn, Middlesex' then do; lat=51.5169755; long=-0.1089646; end;
if Servant_s_Place_of_Origin='St. Ives, Hunts' then do; lat=52.3330352; long=-0.0807037; end;
if Servant_s_Place_of_Origin='Dunstable, Beds' then do; lat=51.8850687; long=-0.5548899; end;
if Servant_s_Place_of_Origin='Stow Market, Suffolk' then do; lat=52.1889597; long=0.9813556; end;
if Servant_s_Place_of_Origin='Partnal, Beds' then do; lat=52.137047; long=-0.475672; end;
if Servant_s_Place_of_Origin='Gotam, Notts' then do; lat=52.8674113; long=-1.2143637; end;
if Servant_s_Place_of_Origin='Chessun, Herts' then do; lat=51.698694; long=-0.0609203; end;
if Servant_s_Place_of_Origin='Chelsea, Middlesex' then do; lat=51.4849132; long=-0.1845146; end;
if Servant_s_Place_of_Origin='Stepney, Middlesex' then do; lat=51.5218932; long=-0.0517658; end;
if Servant_s_Place_of_Origin='St. James, Westminster, Middlesex' then do; lat=51.5067876; long=-0.1396422; end;
if Servant_s_Place_of_Origin='St. Leonards, Shoreditch, Middlesex' then do; lat=51.5268137; long=-0.0796459; end;
if Servant_s_Place_of_Origin='Stepney, Middlesex' then do; lat=51.5202955; long=-0.0523778; end;
if Servant_s_Place_of_Origin='Low Layton, Essex' then do; lat=51.5652494; long=-0.0385008; end;
if Servant_s_Place_of_Origin='Bristol' then do; lat=51.4615611; long=-2.7239345; end;
if Servant_s_Place_of_Origin='Walthamstow, Essex' then do; lat=51.588354; long=-0.0385936; end;
if Servant_s_Place_of_Origin='Abbotsbury, Dorset' then do; lat=50.6645278; long=-2.6071032; end;
if Servant_s_Place_of_Origin='St. James Westminster, Middlesex' then do; lat=51.5068811; long=-0.1397495; end;
if Servant_s_Place_of_Origin='Northampton' then do; lat=52.2345074; long=-0.9507812; end;
if Servant_s_Place_of_Origin='Wisbitch Isle of Ely, Cambs' then do; lat=52.6633087; long=0.1486786; end;
if Servant_s_Place_of_Origin='Swansey, Carmarthen, Wales' then do; lat=51.6242886; long=-3.9643048; end;
if Servant_s_Place_of_Origin='Stalbridge, Dorset' then do; lat=50.9584058; long=-2.3857687; end;
if Servant_s_Place_of_Origin='St. James, Colchester, Essex' then do; lat=51.8896825; long=0.9052637; end;
if Servant_s_Place_of_Origin='Wrexham, Denbighshire, Wales' then do; lat=53.0487073; long=-3.0221574; end;
if Servant_s_Place_of_Origin='Sherborn, Dorset' then do; lat=50.9499699; long=-2.5365882; end;
if Servant_s_Place_of_Origin='Preson Goburn, Nr. Shrewsbury, Salop' then do; lat=52.7130332; long=-2.784878; end;
if Servant_s_Place_of_Origin='Chirrell, Wiltshire' then do; lat=51.3158635; long=-2.4778453; end;
if Servant_s_Place_of_Origin='Warwick' then do; lat=52.2780184; long=-1.6155553; end;
if Servant_s_Place_of_Origin='Carlton, Leics' then do; lat=52.6368079; long=-1.4430414; end;
if Servant_s_Place_of_Origin='St. Margarets, Westminster, Middlesex' then do; lat=51.4997553; long=-0.1285716; end;
if Servant_s_Place_of_Origin='Walsam, Norfolk' then do; lat=52.8194313; long=1.3512774; end;
if Servant_s_Place_of_Origin='Aldgate, Middlesex' then do; lat=51.5133981; long=-0.0793277; end;
if Servant_s_Place_of_Origin='Banbury, Oxon' then do; lat=52.0630177; long=-1.3733034; end;
if Servant_s_Place_of_Origin='Bear St., Norwich' then do; lat=52.6314405; long=1.294611; end;
if Servant_s_Place_of_Origin='St. Martins in the Oak, Norwich' then do; lat=52.633806; long=1.2903287; end;
if Servant_s_Place_of_Origin='Amport, Hants' then do; lat=51.1944289; long=-1.5875912; end;
if Servant_s_Place_of_Origin='St. Andrews, Cambridge' then do; lat=52.2034618; long=0.1078462; end;
if Servant_s_Place_of_Origin='Stortford, Herts' then do; lat=51.8736423; long=0.1358354; end;
if Servant_s_Place_of_Origin='St. Giles Cripplegate, London' then do; lat=51.5186084; long=-0.0960179; end;
if Servant_s_Place_of_Origin='Boston, New England' then do; lat=.; long=.; end;
if Servant_s_Place_of_Origin='St. Clement Danes, Middlesex' then do; lat=51.512972; long=-0.1162902; end;
if Servant_s_Place_of_Origin='St. Michaels, Wood St., London' then do; lat=51.5055842; long=-0.15271; end;
if Servant_s_Place_of_Origin='St. James, Westminster' then do; lat=51.5062267; long=-0.1394061; end;
if Servant_s_Place_of_Origin='Ditton, Surrey' then do; lat=51.3892339; long=-0.3526119; end;
if Servant_s_Place_of_Origin='St. Mary Magdalene, Bermondsey, Surrey' then do; lat=51.4983977; long=-0.0829866; end;
if Servant_s_Place_of_Origin='St. Marys, Nottingham' then do; lat=52.9511172; long=-1.1450846; end;
if Servant_s_Place_of_Origin='St. Martins at Ludgate, London' then do; lat=51.5140033; long=-0.1038401; end;
if Servant_s_Place_of_Origin='Casham, Oxon' then do; lat=51.8024211; long=-1.8744392; end;
if Servant_s_Place_of_Origin='Bishopsgate, London' then do; lat=51.5166909; long=-0.0831399; end;
if Servant_s_Place_of_Origin='St. Martins in the Fields, Middlesex' then do; lat=51.5087641; long=-0.1287912; end;
if Servant_s_Place_of_Origin='St. Martins, Worcester' then do; lat=52.1927907; long=-2.2220383; end;
if Servant_s_Place_of_Origin='Wakefield, Yorks' then do; lat=53.6747419; long=-1.5778671; end;
if Servant_s_Place_of_Origin='Margate, Kent' then do; lat=51.3784213; long=1.3528634; end;
if Servant_s_Place_of_Origin='St. Anns Westminster, Middlesex' then do; lat=51.512372; long=-0.1339683; end;
if Servant_s_Place_of_Origin='Aldgate, London' then do; lat=51.5134382; long=-0.0792204; end;
if Servant_s_Place_of_Origin='St. Saviours, Southwark, Surrey' then do; lat=51.2387821; long=-0.577606; end;
if Servant_s_Place_of_Origin='South Betherton, Somerset' then do; lat=50.9480424; long=-2.8109244; end;
run;

%let pink=FF82AB;
%let blue=1E90FF; 
%let other=7BCC70;

data anno_servants; set my_data;
length function $8 color $12;
xsys='2'; ysys='2'; hsys='3'; when='a'; 
if Servant_s_Gender='male' then color="cx&blue";
else if Servant_s_Gender='female' then color="cx&pink";
else color="cx&other";
length occupation_string time_string $100 html $300;
if Servant_s_Occupation^='unknown' then occupation_string=' As a '||trim(left(Servant_s_Occupation));
else occupation_string='';
time_string=trim(left(put(start_date,nldate.)))||
  ' ('||trim(left(Servant_s_Length_of_Indenture))||' years)';
html=
 'title='||quote(
  trim(left(Servant_Name))||'0d'x||
  'From '||trim(left(Servant_s_Place_of_Origin))||'0d'x||
  trim(left(time_string))||'0d'x||
  trim(left(occupation_string))) ||
 ' href='||quote('#'||trim(left(record)));
/* the href drilldown goes to the anchors I've encoded in the table below the map */
function='move'; x=start_date; y=obsnum; output;
function='bar'; x=end_date; y=y+.5; line=0; style='solid'; output;
run;

data anno_years;
length function $8 color $12;
xsys='2'; ysys='1'; hsys='d'; when='a';
function='label'; position='2'; size=10;
do year=1715 to 1765 by 5;
 date_string='01jan'||trim(left(year));
 date=input(date_string,date9.);
 text=put(date,year4.);
 x=date; y=100;
 output;
 end;
run;

/* Annotate the reflines, to overcome a stacking/layering difficulty with greplay */
data anno_reflines;
length function $8 color $12;
do year=1715 to 1765 by 5;
 date_string='01jan'||trim(left(year));
 date=input(date_string,date9.);
 xsys='2'; ysys='1'; when='b';
 x=date; y=0; function='move'; output;
 x=date; y=100; function='draw'; color='graydd'; size=.01; output;
 end;
do count=0 to 320 by 20;
 xsys='1'; ysys='2'; when='b';
 x=0; y=count; function='move'; output;
 x=100; y=count; function='draw'; color='graydd'; size=.01; output;
 end;
run;

data anno_all; set anno_servants anno_years anno_reflines;
run;


goptions nodisplay;
goptions device=png;
goptions xpixels=800 ypixels=1445;
goptions noborder;

goptions gunit=pct htitle=18pt htext=10pt ctext=gray33 ftitle='albany amt/bold' ftext='albany amt';

symbol1 value=dot h=0.2 interpol=none color=cx&pink;
symbol2 value=dot h=0.2 interpol=none color=cx&blue;
symbol3 value=dot h=0.2 interpol=none color=cx&other;

legend1 position=(top left inside) label=none across=1 repeat=1
 order=('male' 'female' 'unknown')
 offset=(3.5,-35.8) cborder=graydd cframe=white;

axis1 label=none style=0
 order=(0 to 320 by 20) value=(t=17 ' ')
 major=none minor=none offset=(0,0);

axis2 label=none style=0
 order=('01jan1715'd to '01jan1765'd by year5) 
 major=none minor=none offset=(0,0);

title1 ls=1.5 "Indentured Servants destined for Virginia during the 1700s";
title2 h=1pt angle=90  ' ';
title3 h=1pt angle=-90 ' ';

proc gplot data=my_data anno=anno_all;
format start_date year4.;
plot obsnum*start_date=Servant_s_Gender / legend=legend1
 noframe
 vaxis=axis1 haxis=axis2 
/*
 autovref cvref=graydd
 autohref chref=graydd 
*/
 des='' name="main";
run;


/* 29%*800=232, 16%*1445=231.2 */
goptions xpixels=232 ypixels=231;
/* Annotate solid background color, to overcome stacking/layering greplay difficulty */
data anno_back;
length function style color $10;
xsys='3'; ysys='3'; when='b';
function='move'; x=0; y=0; output;
function='bar'; x=100; y=100; style='solid'; color='grayfb'; output;
run;
pattern1 v=s c=cx&pink;
pattern2 v=s c=cx&blue;
pattern3 v=s c=cx&other;
goptions htext=10pt;
title1 h=14pt ls=1.5 font='albany amt' "Gender";
proc gchart data=my_data anno=anno_back;
pie Servant_s_Gender / type=percent descending noheading
 value=inside slice=none 
 coutline=gray77
 des='' name="pie";
run;

/* 94-44=50% x 800 = 400, 47.5-4.5=43% x 1445 = 621.35*/
goptions xpixels=400 ypixels=621;
goptions htext=10pt;
data my_data; set my_data;
length occupation $100;
occupation=Servant_s_Occupation;
occupation=tranwrd(occupation,'tayler','tailor');
occupation=tranwrd(occupation,'taylor','tailor');
if occupation='tailor and staymaker' then occupation='tailor';
if index(occupation,'barber')^=0 then occupation='barber';
if index(occupation,'brickmaker')^=0 then occupation='brickmaker / bricklayer';
if index(occupation,'bricklayer')^=0 then occupation='brickmaker / bricklayer';
if index(occupation,'carpenter')^=0 then occupation='carpenter / joyner / sawyer';
if index(occupation,'joyner')^=0 then occupation='carpenter / joyner / sawyer';
if index(occupation,'groom')^=0 then occupation='groom / footman';
occupation=tranwrd(occupation,'schollar','scholar');
occupation=tranwrd(occupation,'schoolmaster','school master');
if index(occupation,'cloth')^=0 then occupation='cloth / cloath worker';
if index(occupation,'cloath')^=0 then occupation='cloth / cloath worker';
if index(occupation,'weaver')^=0 then occupation='weaver';
occupation=tranwrd(occupation,'gardiner','gardener');
occupation=tranwrd(occupation,'gardner','gardener');
if index(occupation,'farmer')^=0 then occupation='gardener / farmer';
if index(occupation,'gardener')^=0 then occupation='gardener / farmer';
if index(occupation,'labourer')^=0 then occupation='laborer';
length my_html $300;
my_html='title='||quote(trim(left(occupation)))||
 ' href='||quote('https://www.google.com/search?q=What was a '||trim(left(occupation))||' in the 1700s');
run;
axis1 label=none value=(justify=right);
axis2 label=none style=0 major=none minor=none offset=(0,0);
/*
pattern1 v=s c=gray99;
*/
pattern1 v=s c=cx&pink;
pattern2 v=s c=cx&blue;
pattern3 v=s c=cx&other;
title1 h=14pt ls=1.5 font='albany amt' "Occupations";
proc gchart data=my_data (where=(occupation^='unknown')) anno=anno_back;
hbar occupation / type=freq nostats descending
 subgroup=Servant_s_Gender nolegend
 maxis=axis1 raxis=axis2 noframe
 autoref cref=graydd clipref
 coutline=gray77 
 html=my_html
 des='' name="bar1";
run;

/* 75-49.5=25.5% x 1445 = 368.475, 94-56=38% x 800 = 394 */
goptions xpixels=304 ypixels=368;
goptions htext=10pt;
data my_map; set mapsgfk.world (where=(
 idname in ('United Kingdom' 'Ireland') 
 and lat<59 and density<=4));
run;
proc gproject data=my_map out=my_map latlong eastlong degrees dupok
 parmout=projparm;
id id;
run;
proc gproject data=my_data out=my_data latlong eastlong degrees dupok
 parmin=projparm parmentry=my_map;
id;
run;
data anno_dots; set my_data (where=(lat^=. and long^=.));
length function $8 color $12 style $35;
xsys='2'; ysys='2'; hays='3'; when='a';
function='pie'; rotate=360; size=0.5; 
style='psolid'; 
/*
color='A00000011'; 
*/
if Servant_s_Gender='male' then color="A&blue.55";
else if Servant_s_Gender='female' then color="A&pink.55";
else color="A&other.55";
output;
length html $300;
html=
 'title='||quote(trim(left(Servant_s_Place_of_Origin)))||
 ' href='||quote('http://maps.google.com/maps/place/'||trim(left(Servant_s_Place_of_Origin))||'/@'||trim(left(lat))||','||trim(left(long))||',12z');
/*
 ' href="http://maps.google.com/maps?ie=UTF8&ll='||trim(left(lat))||','||trim(left(long))||'&z=11"';
*/
style='pempty'; color='gray55'; output;
run;
pattern1 v=s c=white;
title1 ls=1.5 h=14pt font='albany amt' "Where They Came From";
proc gmap data=my_map map=my_map anno=anno_back;
id id;
choro segment / levels=1 nolegend
 anno=anno_dots
 coutline=graybb
 des='' name="ukmap";
run;


/* 65-7=58% x 800 = 464, 92.5-79=13.5% x 1445 = 195.8 */
goptions xpixels=464 ypixels=195.8;
pattern1 v=s c=cx&pink;
pattern2 v=s c=cx&blue;
pattern3 v=s c=cx&other;
axis1 label=none style=0 minor=none offset=(0,0);
axis2 label=none order=(12 to 42 by 1) value=(h=8pt angle=90);
title1 h=2pct ' ';
title2 a=90 h=1pct ' ';
title3 a=-90 h=3pct ' ';
footnote1 h=2pct ' ';
proc gchart data=my_data anno=anno_back;
note h=14pt move=(51,68) "Age Distribution";
vbar Servant_s_age / type=freq discrete
 subgroup=Servant_s_gender nolegend
 raxis=axis1 maxis=axis2 noframe 
 space=0 coutline=gray77
 des='' name='age';
run;


/* ---------------------------------------- */

goptions display;
goptions noborder;
goptions xpixels=800 ypixels=1445;
 
ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Indentured Servants destined for Virginia during the 1700s") 
 style=htmlblue;

proc greplay tc=tempcat nofs igout=work.gseg;
  tdef mygre des='mygre'
   1/llx = 0   lly = 0
     ulx = 0   uly = 100
     urx =100  ury = 100
     lrx =100  lry = 0
     color=graydd /* outer border color */
   2/llx =  7  lly = 62.0
     ulx =  7  uly = 78.0
     urx = 36  ury = 78.0
     lrx = 36  lry = 62.0
     color=graydd
   3/llx = 44  lly = 4.5 
     ulx = 44  uly = 47.5  
     urx = 94  ury = 47.5  
     lrx = 94  lry = 4.5 
     color=graydd
   4/llx = 56  lly = 49.5  
     ulx = 56  uly = 75    
     urx = 94  ury = 75    
     lrx = 94  lry = 49.5  
     color=graydd
   5/llx =  7  lly = 79    
     ulx =  7  uly = 92.5    
     urx = 65  ury = 92.5    
     lrx = 65  lry = 79    
     color=graydd
   ;
template = mygre;
treplay
 1:main
 2:pie
 3:bar1
 4:ukmap
 5:age
 des='' name="&name";
run;

data my_data; set my_data;
length record_with_anchor $100;
record_with_anchor='<a '||'name='||quote(trim(left(record)))||'>'||
 trim(left(record))||'</a>';
run;

title1 c=gray33 h=18pt "Indentured Servants destined for Virginia during the 1700s";
proc print data=my_data label noobs
 style(data)={font_size=11pt}
 style(header)={font_size=11pt};
label Record_with_anchor='Record';
var 
 Record_with_anchor 
 Servant_Name 
 Servant_s_Place_of_Origin 
 Servant_s_Occupation 
 Servant_s_Destination 
 Servant_s_Date_of_Indenture 
 Servant_s_Length_of_Indenture 
 Servant_s_Gender  
 Servant_s_Age 
 Signed_or_Marked 
 Servant_s_Ship
 Agent_s_Name 
 Agent_s_Place_of_Origin 
 Agent_s_Occupation;
run;

quit;
ODS HTML CLOSE;
ODS LISTING;
