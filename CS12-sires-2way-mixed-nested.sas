data pigs;
input sire dam @;
do rep=1 to 2;
input gain @;
output;
end;
datalines;
1 1 2.77 2.38
1 2 2.58 2.94
2 1 2.28 2.22
2 2 3.01 2.61
3 1 2.36 2.71
3 2 2.72 2.74
4 1 2.87 2.46
4 2 2.31 2.24
5 1 2.74 2.56
5 2 2.50 2.48
;
run;

proc print data=pigs;
run;

proc glm data=pigs;
class sire dam;
model gain = sire dam(sire);
random dam(sire)/test;
lsmeans sire/stderr;
lsmeans sire/stderr e=dam(sire);
title 'Analysis of Average Daily Gain using PROC GLM';
run;


proc mixed data=pigs noclprint noinfo cl;
class sire dam;
model gain = sire/ddfm=satterth;
random dam(sire);
lsmeans sire;
estimate 'Sire 1 BLUE'
intercept 1 sire 1 0 0 0 0;
estimate 'Sire 1 BLUP'
intercept 2
sire 2 0 0 0 0|
dam(sire) 1 1 0 0 0 0 0 0 0 0/divisor=2;
title 'Analysis of Average Daily Gain using PROC MIXED';
run;


*Brown-Forsythe test for equality of variances

proc sort data=pigs;
by sire;
run;

******** Find median of Y for each level of sire;
proc means noprint data=pigs;
by sire;
var gain;
output out=temp (drop=_TYPE_ _FREQ_)
median=sire_gain;
run;

data combine;
merge pigs temp;
by sire;
run;

proc sort data=combine;
by sire;
data combine;
set combine;
absdev=abs(gain-sire_gain);
run;

proc glm data=combine;
class sire;
model absdev = sire;
run;
quit;

symbol value=dot color=black;
proc gplot data=combine;
   plot absdev*sire;
run; 

* Alternativelly just use SAS 
* hovtest option bf for Brown Forsythe;
* Use the factor in the model statement that you want to 
* test for

* plot=diagnostics should do cool diagnostics graphs

ods graphics on;
proc glm data=combine plot=diagnostics;
class sire dam;
model gain = sire;
means sire / hovtest=bf;
run;
quit;
ods graphics off;