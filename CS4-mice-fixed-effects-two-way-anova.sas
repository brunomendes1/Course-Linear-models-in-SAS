/* From Box et al, Statistics for experimenters, 1978, Wiley */

data mice;
input poison 1. @;

do drug=1 to 4;
 input time 3.2 @;
output;

end;
datalines;
1 31 82 43 45
1 45110 45 71
1 46 88 63 66
1 43 72 76 62
2 36 92 44 56
2 29 61 35102
2 40 49 31 71
2 23124 40 38
3 22 30 23 30
3 21 37 25 36
3 18 38 24 31
3 23 29 22 33
;
run;

proc print data=mice;
 title ‘Analysis of Survival Times of Mice: Original Data’;
run;

proc glm data=mice;
 class poison drug;
 model time = poison drug poison*drug;
 means poison drug/lsd;
run;


/* Interaction plots */

/* first calculate cell means*/
proc means data=mice noprint mean nway;
 class poison drug;
 output out=meandata mean=cellmean;
run;

proc print data=meandata;
run;

title1 c=magenta h=2 'Analysis of Survival Times Data';
title2 c=salmon h=1.5 'Profile Plot of Cell Means';
symbol1 c=red i=join v=square h=1.5 l=2;
symbol2 c=green i=join v=diamond h=1.5 l=3;
symbol3 c=blue i=join v=triangle h=1.5 l=4;
symbol4 c=cyan i=join v=star h=1.5 l=5;
axis1 label=(c=steelblue h=1.5 a=90 'Cell Means (seconds)')
value=(c=blue);
axis2 offset=(.2 in) label=(c=steelblue h=1.5 'Levels of Poison')
value=(c=blue);

proc gplot data=meandata;
  plot cellmean*poison=drug/vaxis=axis1 haxis=axis2 hm=0;
run;

/* The vm= and hm= options in the plot statement changes the number 
   of minor tick marks on the vertical and the horizontal axis, 
   respectively. hm=0 supresses the tick marks along the x-axis */


/* using i=stdmptj, in principle, would superimpose error bars on
   each mean. We need to plot the original response variable values
   instead of its means as was done above */

title1 c=magenta h=2 'Analysis of Survival Times Data';
title2 c=salmon h=1.5 'Profile Plot of Cell Means';
symbol1 c=red i=stdmptj v=square h=0.1 l=2;
symbol2 c=green i=stdmptj v=diamond h=0.1 l=3;
symbol3 c=blue i=stdmptj v=triangle h=0.1 l=4;
symbol4 c=cyan i=stdmptj v=star h=0.1 l=5;
axis1 label=(c=steelblue h=1.5 a=90 'Cell Means (seconds)')
value=(c=blue);
axis2 offset=(.2 in) label=(c=steelblue h=1.5 'Levels of Poison')
value=(c=blue);

proc gplot data=mice;
  plot time*poison=drug/vaxis=axis1 haxis=axis2 hm=0;
run;

/* Residuals */


proc glm data=mice;
class poison drug;
model time = poison drug poison*drug;
output out=new r=res p=yhat;
run;

symbol1 v=dot c=red i=none;
axis1 c=vipr label=(c=blueviolet h=1.5 a=90 f=centx ’Residuals’);
axis2 c=vipr label=(c=blueviolet h=1.5 f=centx ’Predicted’);

proc gplot data=new;
 plot res*yhat/ vaxis=axis1 haxis=axis2 vref=0 cvref=darkgreen  lvref=3;
 title c=steelblue h=2 ‘Residual Analysis of Mice Data’;
run;

/* Finding transformation of data to stabilize variance empirically */
/* For a systematic way to find the transofrmation, see Kutner et al,*/ 
/* pg. 135, which is used below */

proc sort data=mice;
by poison drug;
run;

proc means mean std noprint;
by poison drug;
var time;
output out=new2 mean=meantime std=sdtime;
run;

data trans;
set new2;
logsd=log(sdtime);
logmean=log(meantime);
run;

/* Plot of log of cell sd vs. logarithm of cell mean */

symbol1 v=dot c=red i=none;
symbol2 v=none ci=magenta i=rlclm;
axis1 c=vir label=(c=mob h=1.5 a=90 f=centx 'Logarithm of Cell Standard Deviation');
axis2 c=vir label=(c=mob h=1.5 f=centx 'Logarithm of Cell Mean');
proc gplot data=trans;
plot logsd*logmean=1 logsd*logmean=2/ vaxis=axis1 haxis=axis2 overlay;
title c=steelblue h=2 'Analysis of Mice Data: Power Transformation';
run;

/* estimating the alpha -  one minus alpha = the power transformation for the data (lambda) */

proc reg data=trans;
modellogsd=logmean;
run;

/* alpha is estimated as 1.977, CI (1.39, 2.56) */
/* This means the lambda's CI is (-0.39, -1.56) */
/* According to Marasinghe - pg 337 - this indicates a reciprocal transformation: lambda=-1 */
/* Therefore use 1/time instead of time in the model statement of proc glm */
/* this means that the output variable is now measure in "sruvival rates" */
/* rather than just time */



/* More sytematic way to find a transformation of Y using Box-Cox transformation */
/* best lamdba seems to go to -7.6; a bit extreme and it's advisable to look for 
/* outliers, they can be the cause for this */.
/* taken from http://support.sas.com/rnd/app/da/new/802ce/stat/chap15/sect1.htm */

proc transreg data=mice;
      model BoxCox(time / lambda=-2 to 2 by 0.1
                       parameter=2 geometricmean) =
            identity(poison drug poison*drug);
      output out=results;
run;