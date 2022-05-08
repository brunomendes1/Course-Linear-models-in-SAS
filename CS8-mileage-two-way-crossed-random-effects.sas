data auto;

input driver 1. @;
do car=1 to 5;
 input mpg @;
output;
end;

datalines;
1 25.3 28.9 24.8 28.4 27.1
1 25.2 30.0 25.1 27.9 26.6
2 33.6 36.7 31.7 35.6 33.7
2 32.9 36.5 31.9 35.0 33.9
3 27.7 30.7 26.9 29.7 29.2
3 28.5 30.4 26.3 30.2 28.9
4 29.2 32.4 27.7 31.8 30.3
4 29.3 32.4 28.9 30.7 29.9
;
run;

proc glm data=auto;
class driver car;
model mpg =driver car driver*car;
random driver car driver*car/test;
title 'Study of Variation in Gasoline Consumption';
run;

/* Calculating CI */

data cint;
alpha=.05; n=2; a=4; b=5;
msa= 93.428250; msab=0.203875; sa2=9.3224375;
nu=(n*b*sa2)**2/(msa**2/(a-1)+ msab**2/(a-1)*(b-1));
L= (nu*sa2)/cinv(1-alpha/2,nu);
U= (nu*sa2)/cinv(alpha/2,nu);
put nu= L= U=;
run;

/* Using proc mixed with method of moments (method=type3) */

proc mixed data=auto noclprint noinfo method=type3 cl;
class driver car;
model mpg = /solution;
random driver car driver*car;
run;

/* Using proc mixed with default method of max likelihood */

proc mixed data=auto noinfo noitprint covtest cl ;
class driver car;
model mpg = /solution;
random driver car driver*car;
run;