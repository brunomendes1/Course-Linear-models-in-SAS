data disease;
infile 'c:\tmp\APPENC10.txt';
input case age status sector y other;
x1=age;
if status eq 2 then x2=1; else x2=0;
if status eq 3 then x3=1; else x3=0;
if sector eq 2 then x4=1; else x4=0;
run;

proc print data=disease;
run;

/* lowess curves for each different predictor and the 
response variable */

proc loess data=disease;
 model y = x1 / smooth = 0.4 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results;
run;


/* Produce plot of y vs x and Lowess pred vs x */
proc sort data = results;
 by smoothingparameter pred;
run;

goptions reset=all;

proc gplot data=results;
 by Smoothingparameter;
 symbol1 color=black value=none interpol=join ;
 symbol2 color=black value=circle;
 title 'Scatter Plot and Lowess Curve';
 plot Pred*x1 DepVar*x1 / overlay;
run;

/* Same thing for all the other predictor variables */
/* Not so informative with the indicator variables */



/***************************************************/
/*  Testing if X1 should be dropped from the model */
/***************************************************/

/* Full model */

proc logistic descending data=disease;
 where case<99;
 model y = x1 x2 x3 x4;
run;

-2 log likelihood statistic = 101.054

/* Reduced model */

proc logistic descending data=disease;
 where case<99;
 model y = x2 x3 x4;
run;

-2 log likelihood statistic = 106.204

G2 = 106.204 - 101.054 = 5.15. For alph=0.05 X2(0.95;1)=3.84. 
Since G2 X2 we reject the null and X1 should not be dropped
from the model.

See Kutner's page 158 for automatic selection methods.

We can proceed similarly for the other parameters (you'll see 
that there are some question about socioeconomic status variable)


/**********************************/
/*  Testing for interaction terms */
/**********************************/

/* Full model */

proc logistic descending data=disease;
 where case<99;
 model y = x1 x2 x3 x4 x1*x2 x1*x3 x1*x4 x2*x4 x3*x4;
run;

-2 log likelihood statistic = 93.996

/* Reduced model */

proc logistic descending data=disease;
 where case<99;
 model y = x1 x2 x3 x4;
run;

-2 log likelihood statistic = 101.054

We fail to reject the null that all the interaction terms are zero.

Note: values are not the same quoted by Kutner.

/*****************************************************************/
/* Test model adequacy with Hosmer-Lemeshow goodness of fit test */
/* This test starts by grouping the observations according to 
simmilar fitted values of pi_hat_i with approx the same nr of cases 
in each class; then use the pearson chi-square goodness of fit 
statistic */

proc logistic data = disease descending;
 model y = x1 x2 x3 x4 / lackfit ;
run;

With a p-value of 0.2088 we fail to reject the null that the model is adequate

/********************************/
/* residuals for model adequacy */


proc logistic data = disease descending;
 model y = x1 x2 x3 x4 /influence;
 output out = residuals1 p = phat reschi=chires resdev=devres 
                difchisq=difchisq difdev=difdev;
 ods output influence=residuals2;
run;


data residuals;
 merge residuals1 residuals2;
/* studentized Pearson residual */
 rsp = chires/(sqrt(1-hatdiag));
/* cook distance for logistic regression */
 cookd = ((chires**2)*hatdiag)/(5*(1-hatdiag)**2);
 OBS=_N_ ;
run;

/* a lowess smooth of the plot of the ordinary, Pearson or studentized Pearson
residuals should result approcimately in a horizontal line with zero intercept.
Any deviations form this suggests that the model may be inaquate.
*/

/* Pearson residuals */

proc loess data=residuals;
 model rsp = phat / smooth = 0.2 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results_res1;
run;

proc sort data=Results_res1;
by smoothingparameter phat;
run;

goptions reset=all;

proc gplot data=Results_res1;
 by Smoothingparameter;
 symbol1 color=black value=none interpol=join ;
 symbol2 color=black value=circle;
 title 'Scatter Plot and Lowess Curve';
 plot  pred*phat Depvar*phat / overlay; 
run;

/* my own addition */

proc reg data=residuals;
 model rsp = phat;
 output = out;
run;
quit;



/* Deviances */

proc loess data=residuals;
 model devres = phat / smooth = 0.2 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results_res2;
run;

proc sort data=Results_res2;
by smoothingparameter phat;
run;

proc gplot data=Results_res2;
 by Smoothingparameter;
 symbol1 color=black value=none interpol=join ;
 symbol2 color=black value=circle;
 title 'Scatter Plot and Lowess Curve';
 plot  pred*phat Depvar*phat / overlay; 
run;

/* my own addition */

proc reg data=residuals;
 model devres = phat;
 output = out;
run;
quit;


