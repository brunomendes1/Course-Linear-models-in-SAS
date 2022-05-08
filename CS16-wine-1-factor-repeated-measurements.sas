data wine;
input wine @;
do judge=1 to 6;
 input score @;
 output;
end;
datalines;
1 20 15 18 26 22 19
2 24 18 19 26 24 21
3 28 23 24 30 28 27
4 28 24 23 30 26 25
;
run;

proc print data=wine;
run;

proc glm data=wine order=data;
class wine judge;
model score = wine judge;
random judge;
lsmeans wine/pdiff cl adjust=tukey;
title 'Repeated Measures Analysis of Wine Tasting Data';
run;

proc mixed data=wine order=data method=type3 covtest cl;
class wine judge;
model score = wine;
random judge;
lsmeans wine/pdiff cl adjust=tukey;
title 'Repeated Measures Analysis of Wine Tasting Data';
run;

* We expect roughly parallel lines between the different subjects

goptions reset=all;
symbol1 v=circle i=join c=rose;
symbol2 v=square i=join c=violet;
symbol3 v=plus i=join c=salmon;
symbol4 v=+ i=join c=steel;
/* below just letter m*/
symbol5 v=m i=join c=gray;
symbol6 v=triangle i=join c=pink;
*symbol7 v=dot i=join c=cream;
*symbol8 v=star i=join c=lime;
proc gplot data=wine;
title 'Scores vs wine by judge';
plot score*wine=judge;
run;
