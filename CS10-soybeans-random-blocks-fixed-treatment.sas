data soybean;
input trt $ @;
do rep=1 to 5;
input yield @;
output;
end;
datalines;
check 8 10 12 13 11
arasan 2 6 7 11 5
spergon 4 10 9 8 10
samesan 3 5 9 10 6
fermate 9 7 5 5 3
;
run;


/* statements means and lsmeans disagree only for
   unbalanced designs - and in that situation we should
   use lsmeans */

proc glm order=data;
class trt rep;
model yield = trt rep;
contrast 'Check vs Chemicals' trt 4 -1 -1 -1 -1;
random rep;
means trt /tukey cldiff;
*lsmeans trt/pdiff cl adjust=tukey;
title 'Analysis of Soybean Yields';
run;


* proc mixed doesn't accept statement 'means'

proc mixed order=data method=type3 covtest cl;
class trt rep;
model yield = trt;
random rep;
lsmeans trt/diff cl adjust=tukey;
contrast 'Check vs Chemicals' trt 4 -1 -1 -1 -1;
title 'Analysis of Soybean Yields';
run;