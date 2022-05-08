/* Data from Sokal and Rohlf (1995) Biometry: The principles and practice of Statistics in Biological research, 3rd, ed., Freeman */
/* @ means "Don't make a new line" to SAS.*/

/* The outocome variable is measured in terms of ocular length, which can be converted to millimeter by multiplying it by 0.114). */

data peas;
input sugar @;

do i=1 to 10;
 input length @;
output;
end;

drop i;

datalines;
1 75 67 70 75 65 71 67 67 76 68
2 57 58 60 59 62 60 60 57 59 61
3 58 61 56 58 57 56 61 60 57 58
4 58 59 58 61 57 56 58 57 57 59
5 62 66 65 63 64 62 65 65 62 67
;
run;


proc print data=peas;
title ‘ Effect of Sugars on the Growth of Peas’;
run;

proc anova data=peas;
class sugar;
model length=sugar;
means sugar/t cldiff;
run;

proc glm data=peas;
class sugar ;
model length = sugar;
means sugar/lsd alpha = .05;
means sugar/tukey alpha = .05;
contrast 'CONTROL VS. SUGARS' sugar 4 -1 -1 -1 -1;
contrast 'SUGARS VS. MIXED ' sugar 0 1 1 -3 1;
contrast 'GLUCOSE=FRUCTOSE' sugar 0 1 -1 0 0;
contrast 'FRUCTOSE = SUCROSE' sugar 0 1 0 0 -1;
estimate 'CONTROL VS. SUGARS' sugar 4 -1 -1 -1 -1;
estimate 'SUGARS VS. MIXED ' sugar 0 1 1 -3 1;
estimate 'GLUCOSE=FRUCTOSE' sugar 0 1 -1 0 0;
estimate 'FRUCTOSE = SUCROSE' sugar 0 1 0 0 -1;
run;

* You can use means sugar/hovtest to test for
* constant variance

* Check http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_glm_sect056.htm
* for cool diagnostic graphics.