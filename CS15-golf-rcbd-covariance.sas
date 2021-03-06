data golf;
input region cultivars $ humidity speed;
datalines;
1 C1 31.6 7.56
1 C2 29.42 8.88
1 C3 89.6 8.2
2 C1 54.12 7.41
2 C2 44.44 8.2
2 C3 37.17 9.15
3 C1 42.34 7.64
3 C2 84.38 7.2
3 C3 37.32 9.24
4 C1 53.82 6.81
4 C2 88.42 7.12
4 C3 89.21 8.31
5 C1 86.7 6.86
5 C2 71.33 8.16
5 C3 58.57 9.42
6 C1 76.27 6.86
6 C2 45.5 8.68
6 C3 66.68 9.26
7 C1 68.66 7.22
7 C2 66.79 8.25
7 C3 82.78 8.93
8 C1 47.27 7.64
8 C2 58.34 8.22
8 C3 29.52 9.89
;
run;

proc print data=golf;
run;

/* Full model */

proc glm data=golf order=data;
 class region cultivars;
 model speed = region cultivars humidity cultivars*humidity;
 title 'Covariance Analysis of Golf Balls Speed Data';
run;
quit;


/* Interaction is not significant */

proc glm data=golf order=data;
 class region cultivars;
 model speed = region cultivars humidity;
/* lsmeans region/stderr cl pdiff; */
 title 'Covariance Analysis of Golf Balls Speed Data';
run;
quit;

/* changing the order of the terms in the linear model will affect
SS of type I */

proc glm data=golf order=data;
 class region cultivars;
 model speed = humidity region cultivars cultivars*humidity;
/* lsmeans region/stderr cl pdiff; */
 title 'Covariance Analysis of Golf Balls Speed Data';
run;
quit;
