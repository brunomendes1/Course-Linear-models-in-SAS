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

proc print;
title ‘Analysis of Soybean Yields’;
run;


/* the option order=data says SAs to override the default
   of using alphabetical order in the data */
/* The statement 'means' makes estimates for the marginal
   means at each level of treatment; if you add lsd it will
   also look at pairwise differences and if you in addition
   use cldiff, you'll have estiamtes for the differences*/

/* The contrast statement makes a pre-planned comparison 
   between the average of treatment levels and control */

/* comment out the different statements, one at a time
   in order to establish which corresponds to which */

proc glm order=data;
 class trt rep;
 model yield = trt rep;
 means trt/lsd cldiff alpha=.05;
 contrast 'Control vs Others' trt 4 -1 -1 -1 -1;
run;
quit;