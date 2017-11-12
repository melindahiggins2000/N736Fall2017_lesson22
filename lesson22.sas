
* make a copy to WORK;

data helpmkh;
  set library.helpmkh;
  run;

* Encoding: UTF-8.
* =================================================.
* N736 Lesson 22 - repeated measures ANOVA
*
* dated 11/12/2017
* Melinda Higgins, PhD
* =================================================.

* =================================================.
* In the HELP dataset there are 5 time points
* baseline and 4 follow-up time points at 6m, 12m, 18m and 24m
*
* for today's lesson we will be working with the PCS
* physical component score for the SF36 quality of life tool
* let's look at how these 5 PCS measurements are
* correlated across time.
* =================================================;

proc corr data=helpmkh;
  var pcs pcs1 pcs2 pcs3 pcs4;
  run;

* =================================================.
* notice that most of these correlations have r>0.4 indicating
* moderate to large correlation across time
* this makes sense since particpants scores probably
* do not change a lot every 6 months and will tend to be 
* similar to each other WITHIN each particpant
* more so than pcs scores BETWEEN participants
* =================================================.

* repeated measures ANOVA
  add plots=all to get basically
  the proc univariate plots for each
  pcs at each time point
  the printe option gets use the sphericity test;

proc glm data=helpmkh plots=all;
  model pcs pcs1 pcs2 pcs3 pcs4 = ;
  repeated time 5 / mean printe;
  run;

* create an indicator variable
  based on number of missing time points
  and determine who completed all 5 time points
  this variable could be used in future
  to make comparisons on who did and did not
  compelte all 5 time points;

data help2;
  set helpmkh;
  nmisspcs = nmiss(pcs,pcs1,pcs2,pcs3,pcs4);
  pcs_complete = nmisspcs<1;
  run;

