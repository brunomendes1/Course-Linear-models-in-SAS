
proc import datafile="C:\tmp\logistic-reg-programming-data.txt" 
out=programming replace;
        getnames=yes;
run;

proc genmod data=programming;
model Success = Months /dist=binomial link=logit;
run;


data program_fitted;
infile 'c:\tmp\ch14ta01-fitted.txt';
input x y fitted;
run;

/* getting a little ahead of ourselves by plotting previously fitted points 
to a scatterplot of the data */

data graphs;
 set program_fitted;
proc sort;
 by fitted;
proc gplot;
  symbol1 color=black value=none interpol=join ;
  symbol2 color=black value=circle;
  title 'Scatter Plot fitted vs months';
  plot fitted*x y*x;
run;

/*******************************************************/
/* Produce Lowess Curve for data with not fitted values*/

/* proc gam is also a possibility */

proc loess data=programming;
 model success = months / smooth = 0.4 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results;
run;


/* Produce plot of y vs x and Lowess pred vs x */
proc sort data = results;
 by smoothingparameter pred;
run;

goptions reset=all;

/* smoothing parameter equal to 0.7 seems to be best */

proc gplot data=results;
 by Smoothingparameter;
 symbol1 color=black value=none interpol=join ;
 symbol2 color=black value=circle;
 title 'Scatter Plot and Lowess Curve';
 plot Pred*months DepVar*months / overlay;
run;



/**********************************/
/*Run logistic regression analysis*/

/* descending should be used when y=1 is of more interest than y=0. It affects
the calculation of the odds */

proc logistic data = programming descending;
 model success = months / ci ;
 output out = estimates p = pie;
 proc print data = estimates;
run;


/*****************************************************************/
/* Test model adequacy with Hosmer-Lemeshow goodness of fit test */
/* This test starts by grouping the observations according to simmilar fitted values of pi_hat_i with approx the same nr of cases in each class; then use the pearson chi-square goodness of fit statistic */

proc logistic data = programming descending;
 model success = months / lackfit ;
run;



/*Using residuals as diagnostics for model adequacy */
/* p - estimated probability (pi^hat_i)
   reschi - Pearson residual (square root of each part of the pearson chi-square statistic)
   resdev - deviance residual (each part of the deviance statistic)
   difchisq - delta chi-square (the change in the Pearson statistic when the ith case is deleted).
   difdev - delta deviance (the change in the deviance statistics when the ith case is deleted). 
The last two quantities provide measures of the influence of the itth case on each
of those summary statistics.
The distributions for these delta statistics are unknown so we need to resort to 
visual assessements of plots of these quantities. The plots usually plot the 
deltas against case number, agains pi^hat_i or pi^hat'_i.
Extreme plots appear as spikes when plotted agains case number or as outliers in
the upper corners of the plot when plotted agains the pi's.
*/   

proc logistic data = programming descending;
 model success = months /influence;
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

goptions reset=all;


/**********************/
/* plotting residuals */
/*********************/


/* If you have unusual high values for the goodness of fit statistis, it 
migh be a good idea to look for outliers that might be inflating those 
statistics. */

/* Residuals for spotting influential measures on the Pearson and 
chi-square statistics */

goptions reset=all;

symbol1 color=black pointlabel = ("#obs") interpol=join ;

proc gplot data=residuals;
 symbol1 color=black value=none interpol=join ;
 plot  difchisq*obs difdev*obs;
run;

proc sort data=residuals;
by phat;
run;


proc gplot data=residuals;
 plot  difchisq*phat difdev*phat;
run;


/* Cook's distance in logistic regression - in order to find influential measures on the fitted linear predictor - pi^hat_i */

proc sort data=residuals;
by obs;
run;

proc gplot data=residuals;
 symbol1 color=black value=none interpol=join ;
 plot  cookd*obs;
run;

proc sort data=residuals;
by phat;
run;


proc gplot data=residuals;
 plot  cookd*phat;
run;


/* using h_ii to spot outliers in X space */

proc sort data=residuals;
by obs;
run;

proc gplot data=residuals;
 plot  hatdiag*obs;
run;


/********************************/
/* residuals for model adequacy */


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

