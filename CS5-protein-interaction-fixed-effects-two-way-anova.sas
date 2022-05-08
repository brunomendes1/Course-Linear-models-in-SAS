/* From Snedecor and Cochran, Statistical Methods, 1989, 8th ed. Iowa State Univ Press */

data protein;
 input level source @;
 do i=1 to 10;
  input wt @;
 output;
end;
cards;
1 1 73 102 118 104 81 107 100 87 117 111
1 2 98 74 56 111 95 88 82 77 86 92
1 3 94 79 96 98 102 102 108 91 120 105
2 1 90 76 90 64 86 51 72 90 95 78
2 2 107 95 97 80 98 74 74 67 89 58
2 3 49 82 73 86 81 97 106 70 61 82
;
run;


/* Main effects*/


proc glm data=protein;
 class level source;
 model wt = level source level*source;

contrast ‘animal vs. vegetable’
source 1 -2 1;
contrast ‘beef vs. pork’
source 1 0 -1;

run;

/* Notice how the interaction terms are not included, this is because SAS 
   recognizes the main effects comparison and completes level*source .5 -1 .5 .5 -1 .5 ; for us */
/* I recommend we use it anyway */


/* Simple effects */

proc glm data=protein;
 class level source;
 model wt = level source level*source;

contrast ‘an. vs. veg. x level’
level*source 1 -2 1 -1 2 -1;
contrast ‘bf. vs. pk. x level’
level*source 1 0 -1 -1 0 1;
run;

/* Getting more detail about the simple effects of animal vs. vegetable protein */

estimate ‘an. vs. veg. at low’
source 1 -2 1 level*source 1 -2 1 0 0 0;
estimate ‘an. vs. veg. at high’
source 1 -2 1 level*source 0 0 0 1 -2 1;


/* Testing paired differences at different levels of level */

lsmeans level*source/slice=level 

/* Testing and CI's for all possible differences */

lsmeans level*source/cl pdiff adjust=tukey; 

/* Interaction plots with error bars */

title1 c=magenta h=2 'Analysis of Weight Data';
title2 c=salmon h=1.5 'Profile Plot of Cell Means';
symbol1 c=red i=stdmptj v=square h=0.1 l=2;
symbol2 c=green i=stdmptj v=diamond h=0.1 l=3;
symbol3 c=blue i=stdmptj v=triangle h=0.1 l=4;
symbol4 c=cyan i=stdmptj v=star h=0.1 l=5;
axis1 label=(c=steelblue h=1.5 a=90 'Cell Means')
value=(c=blue);
axis2 offset=(.2 in) label=(c=steelblue h=1.5 'Levels of Poison')
value=(c=blue);

proc gplot data=protein;
  plot wt*source=level/vaxis=axis1 haxis=axis2 hm=0;
run;