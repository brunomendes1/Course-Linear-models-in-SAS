goptions hsize=7.5 in vsize= 5.5 in rotate=landscape targetdevice=pscolor;
data peanuts;
input fertilizer $ yield height;
label fertilizer='Fertilizer' yield='Yield' height='Height';
datalines;
C 12.2 45
C 12.4 52
C 11.9 42
C 11.3 35
C 11.8 40
C 12.1 48
C 13.1 60
C 12.7 61
C 12.4 50
C 11.4 33
S 16.6 63
S 15.8 50
S 16.5 63
S 15.0 33
S 15.4 38
S 15.6 45
S 15.8 50
S 15.8 48
S 16.0 50
S 15.8 49
F 9.5 52
F 9.5 54
F 9.6 58
F 8.8 45
F 9.5 57
F 9.8 62
F 9.1 52
F 10.3 67
F 9.5 55
F 8.5 40
;
run;

proc print data=peanuts;
run;

proc glm data=peanuts order=data;
 class fertilizer;
 model yield = fertilizer height;
 lsmeans fertilizer/stderr cl pdiff;
 contrast 'Modified vs. Standard' fertilizer 1 -.5 -.5;
 contrast 'Slow-release vs. Fast-release' fertilizer 0 1 -1;
 title 'Covariance Analysis of Peanut Fertilizer Data';
run;

/* Plot of observed yields at each treatment level */

symbol1 v="C" cv=red f=centb h= 1.5 i=none;
symbol2 v="F" cv=steelblue f=centb h= 1.5 i=none;
symbol3 v="S" cv=magenta f=centb h= 1.5 i=none;
axis1 c=dapk label=(c=blueviolet h=1.5 a=90 f=centb 'Yield');
axis2 c=dapk label=(c=blueviolet h=1.5 f=centb 'Height');
proc gplot data=peanuts;
 plot yield*height=fertilizer/vaxis=axis1 haxis=axis2;
 title c=darkcyan h=2 'Covariance Analysis of Peanut Fertilizer Data';
run;

/* Plot with lines superimposed */

/* First modify model statement to */

model yield = fertilizer height /noint solution;

data lines;
fertilizer='CL';
height=30; yield= 9.52926+0.05581*height; output;
height=70; yield= 9.52926+0.05581*height; output;
fertilizer='SL';
height=30; yield=13.10089+0.05581*height; output;
height=70; yield=13.10089+0.05581*height; output;
fertilizer='FL';
height=30; yield= 6.3851 +0.05581*height; output;
height=70; yield= 6.3851 +0.05581*height; output;
run;

data appended;
set peanuts lines;
run;

proc print data=appended;
run;

symbol1 v="C" cv=red f=centb h= 1.5 i=none ;
symbol2 ci=red v=none i=join ;
symbol3 v="F" cv=magenta f=centb h= 1.5 i=none ;
symbol4 ci=magenta v=none i=join ;
symbol5 v="S" cv=steelblue f=centb h= 1.5 i=none ;
symbol6 ci=steelblue v=none i=join ;
axis1 c=dapk label=(c=blueviolet h=1.5 a=90 f=centb 'Yield');
axis2 c=dapk label=(c=blueviolet h=1.5 f=centb 'Height');
proc gplot data=appended;
plot yield*height=fertilizer/vaxis=axis1 haxis=axis2 nolegend;
run;

/* Testing for different slopes */

proc glm data=peanuts;
 class fertilizer;
 model yield = fertilizer height height*fertilizer;
run;

/* Obtain mean, min, max values of the covariate */
proc means data=peanuts;
run;

/* Treatment means at different values of the covariate */
 
proc glm data=peanuts order=data;
 class fertilizer;
 model yield = fertilizer height height*fertilizer /noint solution;
lsmeans fertilizer/cl tdiff adjust=bon at height=49.9;
lsmeans fertilizer/cl tdiff adjust=bon at height=33;
lsmeans fertilizer/cl tdiff adjust=bon at height=67;
run;