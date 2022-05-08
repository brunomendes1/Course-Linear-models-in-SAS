data turnip;
input plant leaf x1-x2;
drop x1-x2;
calcium=x1; output;
calcium=x2; output;
cards;
1 1 3.28 3.09
1 2 3.52 3.48
1 3 2.88 2.80
2 1 2.46 2.44
2 2 1.87 1.92
2 3 2.19 2.19
3 1 2.77 2.66
3 2 3.74 3.44
3 3 2.55 2.55
4 1 3.78 3.87
4 2 4.07 4.12
4 3 3.31 3.31
;
run;

proc glm data=turnip;
class plant leaf;
model calcium= plant leaf(plant);
random plant leaf(plant)/test;
title 'Analysis of a Two-Way Nested Random Model: Turnip Data';
run;


proc mixed data=turnip noclprint noinfo method=type3 cl;
class plant leaf;
model calcium= /solution;
random plant leaf(plant);
title 'Analysis of a Two-Way Nested Random Model: Turnip Data';
run;