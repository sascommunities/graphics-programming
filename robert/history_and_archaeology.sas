%let name=history_and_archaeology;

/* 
Set your current-working-directory (to read/write files), if you need to ...
%let rc=%sysfunc(dlgcdir('c:\someplace\public_html')); 
*/
filename odsout '.';

data marker_data;
length ll $50 Description $100;
input ll Description;
lat=.; lat=scan(ll,1,',');
long=.; long=scan(ll,2,',');
length searchlink $300;
searchlink='http://images.google.com/images?q='||trim(left(Description));
infile datalines dlm=':';
datalines;
37.9301957,20.705016:Blue Caves, Zakynthos, Greece
63.4684155,-20.1760062:Tiny house on Ellirey Island (Iceland)
40.1403685,44.8179654:Geghard  Monastery, Armenia
-37.8166591,144.9673729:St Paul Cathedral, Melbourne, Australia
51.5055474,-0.0757337:Tower Bridge, London
29.9772622,31.1309402:Pyramids of Giza, Egypt
58.1975955,-6.7473321:Calanais Megalithic Stones, Scotland
49.2617319,19.3582443:Orava Castle, Slovakia
53.0105471,-6.3277616:St. Kevin's Kitchen (900-year-old church), Wicklow, Ireland
59.9048949,10.68411:viking ship, Oslo, Norway
18.7097802,73.4755923:Lohagad Fort, Maharashtra India
43.7069909,11.9298759:Monte Penna, La Verna cave, Italy
50.878945,4.7011523:Town Hall 15th century, Louvain, Belgium
64.1418587,-21.9274731:Hallgrimskirkja Cathedral, Reykjavik Iceland
34.5594436,112.4674942:Longmen Caves, China
37.5771213,13.7705373:Mussomeli Castle, Sicily
30.9574446,120.1061802:Sheraton Huzhou Hot Spring Resort (donut shaped), Huzhou, Zhejiang
17.2221701,-89.6239516:Mayan temples at Tikal, Guatemala
59.9400832,30.3281607:Cathedral of the Resurrection, St. Petersburg, Russia
40.6287714,14.4814187:Positano, Italy
7.9569973,80.7595076:Sigiriya or Sinhagiri (Lion Rock), Sri Lanka
69.6406354,31.3448773:Ship embedded in rock (open air museum), Liinakhamari, Russia
-13.162839,-72.545155:Machu Picchu mountaintop ruins
48.6356152,-1.5126264:Mont Saint Michel France
34.5563292,38.274324:Palmyra ruins, Syria
39.7129377,21.6353534:Meteora Holy Trinity Monastery, Greece
43.2333558,24.8848842:Devetashka cave, Bulgaria
-14.0877832,-75.764667:Huacachina oasis, Peru
40.7928,17.1012:The Thinking Tree (2000 year old olive tree), Puglia Italy
45.48574,9.1902327:Vertical Forest high-rise complex in Milan, Italy
25.7379035,32.6062985:Hatshepsut Temple, Egypt
10.4619718,-84.7113977:Arenal Volcano, Costa Rica
16.1860804,43.704862:Shahara Bridge, Yemen
48.9993758,20.7655966:Spis Castle, Slovakia
-15.9555141,-5.7210626:Johnathan (~200 year old Seychelles giant tortoise), Saint Helena
36.8258545,28.6212774:Cliff graves near Dalyan, Turkey
38.663785,34.8548382:Cappadocia rock dwellings, Turkey
36.8616301,-111.3749962:Antelope Canyon, Arizona
50.7381489,0.2124902: Belle Tout Lighthouse (Beachy Head, East Sussex, England)
-46.6587184,-72.6290638:Marble Caves, Patagonia, Chile
59.8688283,-1.2920924:Jarlshof archaeological dig, Scotland
32.1225585,-104.5612494:Cave Pearls in Carlsbad Cavern, New Mexico
37.5792182,-1.2057006:Cave de la Higuera
29.0467748,110.4773133:Cliff Skywalk, Tianmen, China
34.6535457,-85.3834703:Ellison's Cave (Fantastic Pit), Georgia
20.6831314,-88.5708002:Step Pyramids, Mexico
41.4881993,-8.0681776:Boulder House in Celorico de Basto, Portugal
-14.7395145,-75.1328959:Nazca Lines geoglyphs, Peru
-19.9489996,-69.6340818:Tarapaca Giant geoglyphs, Chile
-17.9246208,25.8551028:Victoria Falls, Zambia
21.2610025,-157.8139166:Diamond Head, Hawaii
25.1504887,73.5833659:Great Wall of India
34.3962683,64.5135467:Minaret of Jam, Afghanistan
54.203885,-1.7340056:Druid's Temple (built 19th century), Ilton, North Yorkshire3
53.6946431,-6.4758637:Newgrange 1+ acre 3200 B.C. construction
27.9200401,108.6889339:Fanjing Mountain, China
17.0464936,-96.6363965:El Arbol del Tule, Oaxaca, Mexico (old/large/wide cypress)
-27.1439894,-109.3307746:Moai on Easter Island
44.5128186,-64.2888336:Buried Treasure on Oak Island
34.3840728,109.2782847:Terracotta Army, China
36.0119645,-113.8109612:Grand Canyon Skywalk
48.8580711,2.2938975:Eiffel Tower
27.1749798,78.0414175:Taj Mahal
39.4525967,-123.8161379:Glass Beach
44.2784275,-124.1136323:Thor's Well
36.5816887,-118.7515797:Sequoia Forest (General Sherman tree)
44.5250852,-110.839288:Grand Prismatic Spring
40.7690373,-113.925068:Bonneville Salt Flats
58.4406305,-134.5504337:Mendenhall Glacier Caves
40.2524691,58.4394433:Darvaza Gas Crater (Gates of Hell)
69.3959223,30.6069341:Kola Superdeep Borehole
-23.0279802,-67.7550988:Atacama Large Millimeter-submillimeter Array (ALMA) Radio Telescope
19.8227782,-155.4700595:Mauna Kea Observatory
-25.3449783,131.0284125:Uluru sandstone monolith
35.3617067,138.7278669:Mount Fuji
27.9880598,86.9248515:Mount Everest
63.0681191,-151.012281:Denali (mountain)
-20.2500324,44.4175749:Avenue of the Baobab Trees
-0.6714086,-91.5092102:Galapagos Islands
-19.7825106,149.6891045:Great Barrier Reef
-3.0659331,37.3552634:Mount Kilimanjaro
-20.2666201,-68.0440362:Uyuni Salt Flat
12.4504804,53.6333367:Dragon's Blood Trees, Socotra Island
25.1969947,55.272921:Burj Khalifa (tallest building in world)
30.8224222,111.0004691:Three Gorges Hydroelectric Dam
36.7323072,138.4580341:Snow Monkeys in Hot Springs
64.2486495,-21.1610955:Silfra - dive between 2 techtonic plates
16.9325234,33.7283691:Nubian Pyramids of Meroe
19.4930024,-102.2594872:Paricutin Volcano (recently formed)
13.412742,103.8613971:Angkor Wat temple complex
30.3253216,35.4392815:Petra temples carved in rock walls
33.5424884,9.9652524:Matmata troglodyte homes (Luke Skywalker house)
37.1669016,-108.4733356:Mesa Verde cliff dwellings
37.7955146,46.2478122:Kandovan cave dwellings
42.2874523,43.2154961:Katskhi Column and dwelling
39.658359,113.7097444:Hanging Monastery
-37.8723057,175.6825952:Hobbiton Movie Set
55.2410598,-6.5123324:Giant's Causeway hexagonal columns
51.3883758,30.0956705:Chernobyl Nuclear Power Plant
-31.7540036,159.2500232:Ball's Pyramid ('tree lobster' insect rediscovered)
60.9174472,101.946954:Tunguska Blast
26.0872746,4.3916151:Amguid crater
6.4354973,10.2905947:Lake Nyos (with carbon dioxide buildup)
41.726931,-49.948253:Location Titanic sank in 1912
36.0137573,-75.6707737:Wright Brothers' first flight
-25.6755646,28.5127809:Premier Mine (largest diamond)
-36.7656441,143.6429943:Largest Gold Nugget (Welcome Stranger)
-8.5986666,119.4046252:Komodo Dragons
53.2610397,105.5329162:Lake Baikal (deepest lake)
-16.1935993,145.3962878:Daintree Rainforest (oldest - 100-180 million years)
11.5524678,162.3467517:Marshall Islands (US nuclear testing, 1946-58)
9.0131299,-79.614354:Panama Canal
11.7365587,40.8774104:Lucy fossil skull found in Hadar, Ethiopia
51.1788483,-1.8262917:Stonehenge
39.9163817,116.3875832:Forbidden City, China
43.078081,-79.0785583:Niagara Falls
21.4158103,39.8015919:Mecca
45.0537589,1.16329:Lascaux cave paintings
-0.1947386,35.7630582:World Champion marathon runners, from Rift Valley, Kenya
11.3678987,142.5085468:Marianas Trench - Challenger Deep
17.3157814,-87.5381798:The Great Blue Hole (sinkhole in ocean)
49.0777869,-119.5684738:Spotted Lake, Osoyoos, Canada
37.9202685,29.1194503:Pamukkale, Denizli, Turkey (thermal pools)
33.7364901,132.4802516:Cat Island, Japan
35.8632477,23.2331918:Antikythera mechanism (found in shipwreck)
21.1076422,-11.460192:Richat Structure, Eye of Africa
21.1718782,94.8564772:Buddhist temples, Bagan, Myanmar
20.9128789,95.2083825:Taung Kalat Buddhist complex
-7.6080623,110.2034624:Borobudur, Indonesia, Buddhist site
34.8542264,-111.7816203:Energy Vortexes, Sedona, Arizona
-20.796133,134.2342692:Wycliffe Well, Australia (UFO hotspot)
;
run;

/*
These are the bottom-left and top-right corners of the area you want to see 
in the map (otherwise, it will just 'zoom' in on your marker data area).
*/
data map_corners;
lat_corner=-55; long_corner=-180; output;
lat_corner=70; long_corner=180; output;
run;

data all_data; set marker_data map_corners;
run;




ODS LISTING CLOSE;
ODS HTML path=odsout body="&name..htm" 
 (title="Map of History, Archaeology, Art, Nature - Beautiful and Interesting Places") 
 style=htmlblue;

ods graphics /
 noscale /* if you don't use this option, the text will be resized */
 imagemap
 imagefmt=png imagename="&name"
 width=1500px height=850px noborder; 

title1 h=16pt color=cx0c9fbf "History, Archaeology, Art, Nature - Beautiful and Interesting Places!";
/*
title2 h=10pt 'a0'x;
*/

proc sgmap plotdata=all_data noautolegend;
esrimap url="http://services.arcgisonline.com/arcgis/rest/services/World_Terrain_Base";
/* these are the colored markers you want to plot */
scatter x=long y=lat / markerattrs=(symbol=circlefilled size=8pt color="red")
  url=searchlink tip=(Description);
/* these are the bottom/left & top/right corners of your background map area */
scatter x=long_corner y=lat_corner / markerattrs=(symbol=circle size=0pt color="white");
run;


quit;
ODS HTML CLOSE;
ODS LISTING;
