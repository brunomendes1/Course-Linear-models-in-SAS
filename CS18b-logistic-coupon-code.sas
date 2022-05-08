data coupon;
/* example of limited use */


infile 'c:\tmp\CH14TA02.DAT';
input x n y pro;
run;


proc print data=coupon;
run;

/* plotting lowess superimposed on data */

proc loess data=coupon;
 model pro = x / smooth = 0.4 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results;
run;

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
 plot Pred*x DepVar*x / overlay;
run;


/* Logistic regression fit */

proc logistic data=coupon;
model y/n = x;
output out=estimates p=pie;
run;

proc print data=estimates;
run;



/**********************************/
/* Tests for goodness of fitness */

/* Pearson chi-square and deviance goodness of fits */

proc logistic;
model y/n = x / aggregate=(x) scale=pearson;
run;



/******************/
/* Residual plots */
/******************/

proc logistic data = coupon descending;
 model y/n = x /influence;
 output out = residuals1 p = phat reschi=chires resdev=devres difchisq=difchisq difdev=difdev;
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


/* Residuals for spotting influential measures on the Pearson and 
chi-square statistics */
/* hard to interpret because the measured quantity is a proportion */

proc gplot data=residuals;
 symbol1 color=black value=none interpol=join ;
 plot  difchisq*obs difdev*obs;
run;

goptions reset=all;

proc gplot data=residuals;
 plot  difchisq*phat difdev*phat;
run;


/* Cook's distance in logistic regression - in order to find inlfuential measures
on the fitted linear predictor - pi^hat_i */

proc gplot data=residuals;
 symbol1 color=black value=none interpol=join ;
 plot  cookd*obs;
run;

goptions reset=all;

proc gplot data=residuals;
 plot  cookd*phat;
run;


/* using h_ii to spot outliers in X space */

proc gplot data=residuals;
 symbol1 color=black value=none interpol=join ;
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

