data shoes;
input campaign period @;
do market=1 to 5;
input sales @;
output;
end;
datalines;
1 1 958 1005 351 549 730
1 2 1047 1122 436 632 784
1 3 933 986 339 512 707
2 1 780 229 883 624 375
2 2 897 275 964 695 436
2 3 718 202 817 599 351
;
run;

proc print data=shoes;
run;

proc glm data=shoes order=data;
class campaign market period;
model sales = campaign market(campaign) period campaign*period;
random market(campaign) /test;
lsmeans campaign /pdiff cl e=market(campaign);
/*lsmeans period/pdiff cl adjust=tukey;*/
title 'Repeated Measures Analysis of Athletic Shoes Sales';
run;

proc mixed data=shoes order=data method=type3 covtest cl;
class campaign market period;
model sales = campaign period campaign*period;
random market(campaign);
lsmeans campaign /pdiff cl adjust=tukey;
title 'Repeated Measures Analysis of Athletic Shoes Sales';
run;

goptions reset=all;
symbol1 v=circle i=join c=rose;
symbol2 v=square i=join c=violet;
symbol3 v=plus i=join c=salmon;
symbol4 v=+ i=join c=steel;
* below just letter m
symbol5 v=triangle i=join c=gray;
proc gplot data=shoes;
by campaign;
title 'Sales vs. period by market for each campaign';
plot sales*period=market;
run;
