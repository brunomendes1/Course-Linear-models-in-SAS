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

/* See littell page 357 too */


/* Slope should be 45 degrees. The test statement fails to reject the hypothesis that the slope is 45 degrees. The 45 degree line is shown in red*/

