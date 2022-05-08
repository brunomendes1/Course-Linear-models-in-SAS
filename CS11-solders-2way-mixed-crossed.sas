data solder;
infile "C:\Documents and Settings\bruno\My Documents\ams202-spring10\data\2way-mixed-crossed\solder.txt";
input operator machine strength;
run;

/* the lsmeans statement estimates the expectation of the
outcome variable y_ijk for each machine, averaged over the levels 
of the random  factor (i.e. operator): 
mu+ alpha_i + B_bar_. + alphaB_bar_i.
This is equivalent to treating operator as a fixed factor */

proc glm data=solder;
class machine operator;
model strength = machine operator machine*operator;
random operator machine*operator /test;
lsmeans machine /stderr;
run;


/* the 'estimate' statement will estimate BLUPS - Best Linear
unbiased predictors */

/* option ddfm=satterth asks glm to use Satterthwaite's approximation
for the degrees of freedom for all effects involving fixed
effects */

proc mixed data=solder noclprint noinfo method=type3 cl;
class machine operator;
model strength = machine /ddfm=satterth;
random operator machine*operator;

/* this statement estimates the mean for machine 1 as mu + alpha_1
 i.e. the unconditional expectation of the observations for 
machine 1. Don't pay attentio nhto the error of this estimate because
glm assumes both operator and machine*operator as fixed effects*/

lsmeans machine;

/* estimates a predictable function  measuring operator 3 solder's 
expected mean strength: mu + alpha_bar_. + B3 + gamaB_bar_.3 
This conditions on operator and machine*operator random effects */
/* the option 'divisor' allows us to use whole numbers in the 
coffiecients, i.e. divide all coefficients by the number stated 
in 'divisor' */

estimate 'BLUP_1: Oper 3'
intercept 4
machine 1 1 1 1|
operator 0 0 4
machine*operator 0 0 1 0 0 1 0 0 1 0 0 1/divisor=4;

/* This estimates the expected result for operator 3 conditioned
on the operator effect only (i.e. averaging the interation over
the population of all operators) mu + alpha_bar_. + B3 
One doesn't see much of a difference in the point estimator because
interaction is small */
estimate 'BLUP_2: Oper 3'
intercept 4
machine 1 1 1 1|
operator 0 0 4/divisor=4;

title 'Analysis of Strength of Solder in Computer Chips using PROC MIXED';
run;

/* notice how the df of the estimates outputs are fractions, this results
from the use of the Satterthwaite's approximation formulas. */


/* should only do this is you are clear about the each of the estimates 
about is doing. */
/* the following 'estimate' statement estimates the predictable
function mu + alpha_1 +B_bar_. + alphaB_bar_1. 
This is the expectation of the observations for machine 1 
conditioned on the observed operators.
It simulates how LSMEANS in proc GLM work, you can compare it 
with the output for GLM and see how similar they are.
The lsmeans in proc mixed are estimated as mu+alpha1 and also tries
to estimate the effect due to machine 1*/

estimate 'LSMEAN for Mach 1'
intercept 3
machine 3 0 0 0|
operator 1 1 1
machine*operator 1 1 1 0 0 0 0 0 0 0 0 0/divisor=3;
