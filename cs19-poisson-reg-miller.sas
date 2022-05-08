data miller;
infile 'c:\tmp\CH14TA14.txt';
input y x1 x2 x3 x4 x5;
lx1=log(x1);
run;

proc print data=miller;
run;

/* histogram */
/* The observations with zero counts are problematic */

proc univariate data = miller noprint;
  histogram y / midpoints = 0 to 40 by 1 vscale = count ;
run;


/*********************/
/* Plots of y vs. x1 */

proc sort data=miller;
by x1;
run;

/* proc sort data=miller;
by lx1;
run;
*/

goptions reset=all;

proc gplot data=miller;
 symbol1 color=black value=circle;
 title '';
 plot y*x1;
run;


/* loess */

proc loess;
 model y = x1 / smooth = 0.4 to 0.8 by 0.1 residual;
 ods output OutputStatistics = Results;
run;


proc sort data = results;
 by smoothingparameter x1;
run;

goptions reset=all;

proc gplot;
 by Smoothingparameter;
 symbol1 color=black value=none interpol=join;
 symbol2 color=blue value=circle;
 title 'Scatter Plot and Lowess Curve';
 plot Pred*x1 DepVar*x1 / overlay;
run;


/************/
/* Splines */


proc gam data=miller;
model y = spline(x1);
output out=estimates;
run;

proc print data=estimates;
run;

symbol1 color=red interpol=join value=none line=1;
symbol2 color=blue value=circle line=2;

proc sort data=estimates;
by x1;
title;
proc gplot data=estimates;
plot P_y *x1  y*x1 / overlay;
run;

/****************************************/
/* Fitting the Poisson regression model */
/***************************************/

proc genmod data=miller;
 model y = x1 x2 x3 x4 x5 / link=log dist=poisson;
run;

/************************/
/* plotting fitted data */
/************************/

/*************/
/* Residuals */
/************/

proc genmod data=miller;
  model y = x1-x5 / dist = poisson link   = log;
  output out=temp p=muhati resdev=devi;
run;

/* It is necessary to first create an index variable and graph the devi versus the index. */

data temp;
  set temp;
  id = _n_;
  dispersion = (y-muhati)**2;
run;
 
symbol1 v=dot i=join pointlabel = ("#id") c=blue h = .8;
axis1 label=(angle = 90);
 
proc gplot data = temp;
  plot devi*id/ vaxis = axis1;
run;
quit;

/* Diagnosing under- over-dispersion. 
   Plotting mu_hat vs (y-mu_hat)**2 */

proc sort data=temp;
by muhati;
run;

goptions reset=all;

symbol1 v=dot i=none c=blue h = .8;
axis1 label=(angle = 90);

proc gplot data = temp;
  plot dispersion*muhati/ vaxis = axis1;
run;
quit;

proc reg data=temp;
model dispersion = muhati;
test muhati=1;
OUTPUT OUT=NEW P=PRED;
run;
quit;


axis1 label=(angle = 90);
axis2 label=('muhat');

symbol1 v=circle l=32  c = black;
symbol2 i = join v=star l=32  c = blue;
Legend1 value=(color=black height=1 'Dispersion vs. mu_hat' 'Predicted  vs. muhat' '45 degree line');

PROC GPLOT DATA=new;
PLOT dispersion*muhati PRED*muhati muhati*muhati/ OVERLAY legend=legend1 vaxis=axis1 haxis=axis2;
RUN;
quit;

/* Slope should be 45 degrees. The test statement fails to reject the hypothesis that the slope is 45 degrees. The 45 degree line is shown in red*/


/* Stop here */



/* proc genmod data = miller;
 model  y = x1 x2 x3 x4 x5 / link=log dist=poisson influence;
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
*/

/**********************/
/* Plotting residuals */
/**********************/

/* Residuals for spotting influential measures on the Pearson and 
chi-square statistics */

goptions reset=all;

symbol1 color=black pointlabel = ("#obs") interpol=join ;

proc gplot data=residuals;
 plot  difchisq*obs difdev*obs;
run;

proc sort data=residuals;
by phat;
run;

proc gplot data=residuals;
 plot  difchisq*phat difdev*phat;
run;

/* Cook's distance in logistic regression - in order to find 
influential measures on the fitted linear predictor - pi^hat_i */

proc sort data=residuals;
by obs;
run;

proc gplot data=residuals;
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

axis1 order=(1 to 400 by 10);
axis2 order=(0 to 0.052 by 0.002);

proc gplot data=residuals;
 plot  hatdiag*obs /vaxis=axis2 haxis=axis1;
run;


/********************************/
/* residuals for model adequacy */


/* a lowess smooth of the plot of the ordinary, Pearson or 
studentized Pearson residuals should result approcimately in a 
horizontal line with zero intercept.
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

/* test slope of residuals. If zero, we're good */

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

/* test slope of residuals. If zero, we're good */

proc reg data=residuals;
 model devres = phat;
 output = out;
run;
quit;


