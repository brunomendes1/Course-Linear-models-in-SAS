proc import datafile="C:\tmp\orion-price-age-mileage.txt" 
out=multi_orion dbms=tab replace;
        getnames=yes;
run;


proc print data=multi_orion;
run;


proc reg simple corr data=multi_orion;
model price = age miles /clb xpx i;
title 'Regression Analysis of Orion Data';
run;
quit;

/*Residuals*/
/*---------*/

title c=darkpurple h=2 'Residual Plots: Regression Analysis of 
Orion Data';
symbol v=dot h=1 c=red;
proc reg noprint;
model price = age miles/r;
plot r.*p. r.*age r.*miles/nostat modellab='Full Model:' 
ctext=blue caxes=stbg;
plot student.*nqq./noline nostat nomodel;
run;

/* Tests
proc reg data=multi_orion;
model price = age miles;
title 'Regression Analysis of Orion Data';
test age=0;
run;
quit;

proc glm data=multi_orion;
model price = age miles;
title 'Regression Analysis of Orion Data';
contrast 'test age=miles' intercept 0 age 1 miles -1;
estimate 'test age=miles' intercept 0 age 1 miles -1;
run;
quit;
