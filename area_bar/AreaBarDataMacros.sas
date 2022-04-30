/********************************************************************/
/*    Macros for generating area bar chart data for PROC SGPLOT     */
/********************************************************************/

/***************************************************/
/*  Basic area bar chart                           */
/*  notes:                                         */
/*  - The values for the response and width        */
/*    input variables are summed.                  */
/*  - The response output column contains the      */
/*    response values for labeling.                */
/*  - The width output column contains the width   */
/*    values for labeling.                         */
/*                                                 */
/*  args:                                          */
/*  input - input data set name                    */
/*  output - output data set name                  */
/*  category - category variable for each bar      */
/*  response - variable for the length of each bar */
/*  width - variable for the width of each bar     */
/***************************************************/
%macro genAreaBarDataBasic(input, output, category, response, width);
proc summary data=&input nway;
class &category;
var &response &width;
output out=_out_totals_ sum=;
run;

data &output;
retain x 0;
label x="&width" y="&response" ID="&category";
set _out_totals_;
ID=&category;
response=&response;
width=&width;
y=0;
x=x;
output;
y=&response;
output;
x = x + &width;
output;
y=0;
output;
run;
%mend;

/***************************************************************/
/*  Area bar chart with color response                         */
/*  notes:                                                     */
/*  - The values for the response and width input              */
/*    variables are summed.                                    */
/*  - The color response is summed by default, but supports    */
/*    PROC SUMMARY statistics via the colorStat argument.      */
/*  - The response output column contains the                  */
/*    response values for labeling.                            */
/*  - The width output column contains the width               */
/*    values for labeling.                                     */
/*                                                             */
/*  args:                                                      */
/*  input - input data set name                                */
/*  output - output data set name                              */
/*  category - category variable for each bar                  */
/*  response - variable for the length of each bar             */
/*  width - variable for the width of each bar                 */
/*  colorResp - continuous variable used to represent color    */
/*  colorStat (optional) - the SUMMARY statistic for colorResp */
/***************************************************************/
%macro genAreaBarDataColorResponse(input, output, category, response, width, colorResp, colorStat=sum);
proc summary data=&input nway;
class &category;
var &colorResp;
output out=_out_color_ &colorStat=_colorResponse_;
run;

proc summary data=&input nway;
class &category;
var &response &width;
output out=_out_totals_ sum=;
run;

data _merged_;
merge _out_totals_ _out_color_;
by &category;
run;

data &output;
retain x 0;
label x="&width" y="&response" ID="&category" colorResponse="&colorResp";
set _merged_;
colorResponse=_colorResponse_;
ID=&category;
response=&response;
width=&width;
y=0;
x=x;
output;
y=&response;
output;
x = x + &width;
output;
y=0;
output;
run;
%mend;


/***************************************************/
/*  Area bar chart with subgroups                  */
/*  notes:                                         */
/*  - The values for the response and width        */
/*    variables are summed.                        */
/*  - Use TEXT plot statements to display the      */ 
/*    subgroup labels and bar labels.              */
/*  - The generated subLabel, subLabelX, and       */ 
/*    subLabelY variables can be used to display   */
/*    the subgroup values in each segment.         */
/*  - The generated label, labelX, and labelY      */
/*    variables can be used to display the         */
/*    category values above each bar.              */
/*                                                 */
/*                                                 */
/*  args:                                          */
/*  input - input data set name                    */
/*  output - output data set name                  */
/*  category - category variable for each bar      */
/*  response - variable for the length of each bar */
/*  width - variable for the width of each bar     */
/*  subgroup - variable for the bar segments       */
/***************************************************/

%macro genAreaBarDataSubgroup(input, output, category, response, width, subgroup);
proc summary data=&input nway;
class &category;
var &width;
output out=_out_width_ sum=;
run;

proc summary data=&input nway;
class &category &subgroup;
var &response;
output out=_out_totals_ sum=;
run;

data _merged_;
merge _out_totals_ _out_width_;
by &category;
run;

data &output;
retain curCategory curLabelX curLabelY;
retain x 0 y 0 prevY 0 nextY 0 prevX 0;
label x="&width" y="&response" ID="&subgroup";
set _merged_ end=_last_;
ID=&subgroup;
if (curCategory ne &category) then do;
   if x > 0 then do;
      label = curCategory;
      labelX = curLabelX;
      labelY = curLabelY;
   end;
   curCategory = &category;
   y=0;
   prevY=0;
end;
else do;
   y=nextY;
   prevY = y;
   x=prevX;
end;
output;
labelX=.;
labelY=.;
y = y + &response;
nextY = y;
output;
prevX = x;
x = x + &width;
output;
subLabelX = prevX + ((x-prevX) / 2);
subLabelY = prevY + ((y-prevY) / 2);
subLabel = &response;
curLabelX = prevX + ((x-prevX) / 2);
curLabelY = prevY + (y-prevy);
y=prevY;
output;
subLabelX=.;
sunLabelY=.;
if (_last_) then do;
   x=.;
   y=.;
   label = curCategory;
   labelX = curLabelX;
   labelY = curLabelY;
   output;
end;
run;
%mend;
