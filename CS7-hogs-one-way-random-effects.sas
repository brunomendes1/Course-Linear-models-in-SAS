data hogs;
input litter gain;
datalines;
1 1.18
1 1.11
2 1.36
2 1.65
3 1.37
3 1.40
4 1.07
4 0.90
;
run;

proc print data=hogs;
run;


proc glm data=hogs;
 class litter ;
 model gain = litter ;
 random litter/test;
 title 'Average Daily Gain in Swine';
run;

/* proc glm calculates expected mean squares and perfrom 
f-tests about variance components but lsmeans and estimate,
for example, only work for fixed effects */


/* Using proc mixed */


* you need to list the random factors in the 'random' statement
/* one only mentions fixed factors to the right of '=' in the
  'model' statement */

/* the default estimation procedure is the restricted maximum 
   likelihood, other methods can be requests with the 'method'
   option */
/* the option 'cl' calculates confidence limits for the variance
   components, these are all based on the Satterthwaite 
   approximation for all iterative methods, since these 
   constrain the estimates to always be positive */

/* when the method of moments is used, we need to have large 
   samples (otherwise we might have negative values in the CIs,
   for example */
* -2 res log likelihood is the deviance, to be explained later,
   in logistic models */

* options 'noitprint' and 'noinfo' will supress some of the output

/* the 'solution' option produces predicted values of the litter
   random effects. They are estimates of the BLUPs of the random 
   effect of each litter. The are equivalent to estimates
   estimate 'Litter 1 effect' | litter 1 0 0 0; 
   estimate 'Litter 2 effect' | litter 0 1 0 0; 
   estimate 'Litter 1 effect' | litter 0 0 1 0; 
   estimate 'Litter 1 effect' | litter 0 0 0 1; 

   coefficients associated with random effects have to be stated
   after the '|' sign.
/* you can see that we cannot reject the hypothesis that the 
   effects at each level are zero, as expected */

proc mixed data=hogs cl;
 class litter;
 model gain = ;
 random litter/solution;
 title 'Average Daily Gain in Swine';
run;

/* estimate with the method of moments (not advisable in this
   example because the number of levels is only 4, but it's
   used to show it is done) */

/* option 'method=type3' specifies the type of mean squares and the 
   corresponding expected values that are to be used to estimate
   the variance components (type 1 and type 3 are equivalent in
   case of equal sample sizes */
   
/* Option 'asycov'requests the asymptotic covariance matrix of 
   the estimated variance components (based on asymptotic standard 
   errors of he estimates of the variance components, i.e, normal
   distribution, with the exception of s^2 which uses the chi-square).
   The results will appear under "Asymptotic covariance matrix of 
   estimates */
   */

proc mixed data=hogs noclprint noinfo method=type3 asycov cl;
  class litter ;
  model gain = ;
  random litter/solution;
  title 'Average Daily Gain in Swine';
run;
