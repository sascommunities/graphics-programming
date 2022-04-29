ods _all_ close;
ods listing gpath="." image_dpi=200;
ods graphics / reset=all width=450px;


data totals;
input Site $ Quarter Sales Salespersons;
format Sales dollar12.2;
datalines;
Lima 1  4043.97   4
NY   1  8225.26  12
Rome 1  3543.97   6
Lima 2  3723.44   5
NY   2  8595.07  18
Rome 2  5558.29  10
Lima 3  4437.96   8
NY   3  9847.91  24
Rome 3  6789.85  14
Lima 4  6065.57  10
NY   4 11388.51  26
Rome 4  8509.08  16
;
run;

%genAreaBarDataBasic(totals, poly_data, Site, sales, Salespersons);
title "Basic Area Bar Chart";
title2 h=9pt "with Category Labels";

/* Vertical */
ods graphics / imagename="BasicVerticalAB";
proc sgplot data=poly_data noautolegend;
yaxis offsetmin=0;
polygon x=x y=y id=ID / group=ID label=ID fill labelattrs=GraphDataText;
run;

/* Horizontal */
ods graphics / imagename="BasicHorizontalAB";
proc sgplot data=poly_data noautolegend;
xaxis offsetmin=0;
polygon x=y y=x id=ID / group=ID label=ID fill labelattrs=GraphDataText;
run;

%genAreaBarDataColorResponse(totals, poly_data, Site, sales, Salespersons, Sales, colorStat=mean);
title "Basic Area Bar Chart";
title2 h=9pt "with Color Response and Category Labels";

/* Vertical */
ods graphics / imagename="CRVerticalAB";
proc sgplot data=poly_data;
yaxis offsetmin=0;
polygon x=x y=y id=ID / colorResponse=colorResponse label=ID fill
                labelattrs=GraphDataText colormodel=twocolorramp;
run;

/* Horizontal */
ods graphics / imagename="CRHorizontalAB";
proc sgplot data=poly_data;
yaxis offsetmin=0;
polygon x=y y=x id=ID / colorResponse=colorResponse label=ID fill
                labelattrs=GraphDataText colormodel=twocolorramp;
run;


%genAreaBarDataSubgroup(totals, poly_data, Site, sales, Salespersons, quarter);
title "Subgrouped Area Bar Chart";
title2 h=9pt "with Subgroup and Category Labels";

/* Vertical */
ods graphics / imagename="SubgroupVerticalAB";
proc sgplot data=poly_data;
format sublabel f8.2;
yaxis offsetmin=0;
polygon x=x y=y id=ID / group=ID fill;
text x=subLabelX y=subLabelY text=subLabel / contributeoffsets=none;
text x=labelX y=labelY text=label / contributeoffsets=none position=top;
run;

/* Horizontal */
ods graphics / imagename="SubgroupHorizontalAB";
proc sgplot data=poly_data;
format sublabel f8.2;
xaxis offsetmin=0;
polygon x=y y=x id=ID / group=ID fill;
text x=subLabelY y=subLabelX text=subLabel / contributeoffsets=none;
text x=labelY y=labelX text=label / contributeoffsets=(xmax) position=right;
run;
