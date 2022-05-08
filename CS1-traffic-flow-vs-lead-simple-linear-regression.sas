data lead1;
input x y;
label x=‘Traffic Flow’ y=‘Lead Content’;
datalines;
8.3 227
8.3 312
12.1 362
12.1 521
17.0 640
17.0 539
17.0 728
24.3 945
24.3 738
24.3 759
33.6 1263
;
run;
proc reg data=lead1;
model y=x/p clb;
plot y*x/ nomodel nostat;
plot r.*x r.*p. student.*nqq.;
title 'Simple Linear Regression of Lead Content Data';
run;

/*Predictions*/
/*-----------*/

data lead2;
input x y;
label x=‘Traffic Flow’ y=‘Lead Content’;
datalines;
8.3 227
8.3 312
12.1 362
12.1 521
17.0 640
17.0 539
17.0 728
24.3 945
24.3 738
24.3 759
33.6 1263
10.0 .
15.0 .
;
run;
legend1 position=(bottom right inside) across=2
cborder=red offset=(0,0) shape=symbol(3,1)
label=none value=(h=.8 f=swissxb);
symbol1 cv=blue v=dot i=none h=1;
symbol2 ci=red r=1;
symbol3 ci=magenta r=2;
symbol4 ci=green r=2;
proc reg data=lead2;
model y=x/clm cli;
plot y*x/pred conf nomodel nostat legend=legend1 ctext=stb caxes=vip;
title c=darkmagenta h=2 f=centx 'Prediction Intervals: Lead Content Data';
run;
