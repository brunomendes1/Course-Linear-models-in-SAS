/* Simple arithmetic and use of basic math functions */

data sample;
input x1-x7;
y1 = x1+x2**2;
y2 = abs(x3);
y3 = sqrt(x4);
y4 = log(x7);
datalines;
1 2 3 4 5 6 7
;
run;

proc print;
run;

/* Conditional execution */

data sample2;
input state $;
if state= 'CA' | state= 'OR' then region='Pacific Coast';
else region= 'East Coast';
datalines;
CA
FL
NY
OR
;
run;

proc print; run;

/* The symbol @@ reads values into variable time one at a time until the end
   of the line; it keeps SAS from doing an automatic newline after the 
   first read */

/* A single @ - to appear later in the quarter, asks SAS to do something different;
   it asks SAS to hold the pointer at the current point in the input buffer and
   allows SAS to run another INPUT statement before the deleting the current values
   that werre already read */

data group1;
input age @@;
datalines;
1 3 7 9 12 17 21 26 30 32 36 42 45 51
;
run;

data group2;
set group1;
if 0<=age<10 then agegroup=0;
else if 10<=age<20 then agegroup=10;
else if 20<=age<30 then agegroup=20;
else if 30<=age<40 then agegroup=30;
else if 40<=age<50 then agegroup=40;
else if age >=50 then agegroup=50;
run;
proc print;run;

data group3;
set group1;
agegroup=int(age/10)*10;
run;
proc print; run;


/* Repetitive calculation */
/* run the code a second time with the comment lines "un-commented" */

/*In the array statement we are defining the array scores as containing
  the values of the quiz and test variables. You can refer to quiz1 
  with scores{1}, for example */

data scores;
input quiz1-quiz5 test1-test3;
array scores {8} quiz1-quiz5 test1-test3;
do i= 1 to 8;
if scores{i}= . then scores{i}= 0;
output;
end;

/* drop i; */

datalines;
90 91 89 88 93 78 85 91
/* 79 83 81 . 90 72 88 81 */
;
run;


/* Nested loops */
/* run code without the 'output' statement and print the contents of the data 
   set; you'll see that it will only remember the last assignment to the vars */

data reaction;
length conc $4;
do amount =.9 to .6 by -.1;
do conc = '1%' , '1.5%' , '2%' , '2.5%' , '3%' ;
input time @@;
output;
end;
end;
datalines;
10.9 11.5 9.8 12.7 10.6
9.2 10.3 9.0 10.6 9.4
8.7 9.7 8.2 9.4 8.5
7.2 8.6 7.5 9.7 7.7
;
run;
proc print;
title 'Reaction times for biological substrate';
run;
proc print; run;


/* Input formats */

Suppose that the next code

input id 4. @9 state $2. fert 5.2 +1 percent 3.2 @26 members 4.;

is used to read the following data

0001xxxxIA00504x089xxxxxx1349
^
|
(Location of pointer)

The SAS numeric informat 4. reads the value 0001 for the variable id 
and the pointer is repositioned at column 5 of the input buffer

0001xxxxIA00504x089xxxxxx1349
    ^
    |

The pointer control @9 then causes the pointer to move to column 9:

0001xxxxIA00504x089xxxxxx1349
        ^
        |

The SAS character informat $2 reads the value IA as the value for state
and the pointer moves over those two columns to column 11 of the input 
buffer.

0001xxxxIA00504x089xxxxxx1349
          ^
          |
Next, the SAS numeric informat 5.2 is used to read the value 00504 as the
current value 5.04 of the variable fert and the pointer moves
over five columns:

0001xxxxIA00504x089xxxxxx1349
               ^
               |

The pointer control +1 the moves the pointer one more column:

0001xxxxIA00504x089xxxxxx1349
                ^
                |

Three columns are read using the informat 3.2 to obtain the current value
of the variable percent, and the pointer moves a further three
columns:

0001xxxxIA00504x089xxxxxx1349
                   ^
                   |

The pointer control @26 moves the pointer to column 26: 

0001xxxxIA00504x089xxxxxx1349
                         ^
                         |

At this stage the value 1349 for the variable members is read from the 
input buffer, using the informat 4.. The pointer moves to column 31

0001xxxxIA00504x089xxxxxx1349
                             ^
                             |


/* Organizing and sorting data */

/* the modifier : $8 allows SAS to read values for region that 
   have lengths shorter than 8 characters. If you run this same
   code without the modifier, you will see some messing up of 
   the contents of the variables region and state */
/* the format statement says how the variable's contents should
   be printed. This information is used by proc print. */

data prindata;
input region : $8. state $2. +1 month monyy5. headcnt revenue
expenses;
format month monyy5. revenue dollar12.2;
label region='Sales Region' headcnt='Sales Personnel';
datalines;
SOUTHERN FL JAN78 10 10000 8000
SOUTHERN FL FEB78 10 11000 8500
SOUTHERN FL MAR78 9 13500 9800
SOUTHERN GA JAN78 5 8000 2000
SOUTHERN GA FEB78 7 6000 1200
PLAINS NM MAR78 2 500 1350
NORTHERN MA MAR78 3 1000 1500
NORTHERN NY FEB78 4 2000 4000
NORTHERN NY MAR78 5 5000 6000
EASTERN NC JAN78 12 20000 9000
EASTERN NC FEB78 12 21000 8990
EASTERN NC MAR78 12 20500 9750
EASTERN VA JAN78 10 15000 7500
EASTERN VA FEB78 10 15500 7800
EASTERN VA MAR78 11 16600 8200
CENTRAL OH JAN78 13 21000 12000
CENTRAL OH FEB78 14 22000 13000
CENTRAL OH MAR78 14 22500 13200
CENTRAL MI JAN78 10 10000 8000
CENTRAL MI FEB78 9 11000 8200
CENTRAL MI MAR78 10 12000 8900
CENTRAL IL JAN78 4 6000 2000
CENTRAL IL FEB78 4 6100 2000
CENTRAL IL MAR78 4 6050 2100
;
run;

/* proc sort will overwite the contents of the data set */
proc sort;
by region state month;
run;

proc print;
run;

proc print label;
by region state ;
format expenses dollar10.2 ;
label state= State month= Month revenue='Sales Revenue'
expenses='Overhead Expenses';
id region state;
sum revenue expenses;
sumby region;
title ' Sales report by state and region';
run;


/* Concatenating two data sets  using the set statement */

data first;
input w 1-2 x 3-5 y 6;
datalines;
211023
312034
413045
;
run;

data second;
input x y z;
datalines;
14 5 7862
15 6 6517
16 7 8173
;
run;

data third;
set first second;
run;

proc print;
title 'Combining SAS data sets end-to-end ';
run;


/* Saving data sets permanentely */

/* The concept of a SAS library is easily
understood in the context of running SAS programs under the Windows
environment. */

libname mylib 'C:\Documents and Settings\...\projectA\';

/* A two-level SAS data set name,in general, is a name that 
contain two parts separated by a period of the form libref.membername 
and is used to refer to members of a library libref. */

/* The actual physical name of the file saved is first.sas7bdat */

libname mylib1 'C:\tmp';
data mylib1.first;
input x1-x5;
datalines;
1 2 3 4 5
2 3 4 5 6
6 5 4 3 2
1 2 1 2 1
7 2 55 5 5
;
run;

/* The following libname statement in this program associates the libref 
   mydef1 with the same library where the data set first was saved when 
   the SAS program */

libname mydef1 'C:\tmp';
/* mydef1 now becomes a nickname for the data set stored in the folder 
   above*/

proc print data=mydef1.first; run;

proc means data=mydef1.first; run;

data mydef1.second;
input y1-y3;
datalines;
31 34 38
43 45 47
10 11 12
908 97 96
;
run;

proc contents data=mydef1.first; run;

proc datasets library=mydef1 memtype=data;
contents data=first directory details;
run;


/* Saving output of a procedure in a data set */

data biology;
input id sex $ age year height weight;
datalines;
7389 M 24 4 69.2 132.5
3945 F 19 2 58.5 112.0
4721 F 20 2 65.3 98.6
1835 F 24 4 62.8 102.5
9541 M 21 3 72.5 152.3
2957 M 22 3 67.3 145.8
2158 F 21 2 59.8 104.5
4296 F 25 3 62.5 132.5
4824 M 23 4 74.5 184.4
5736 M 22 3 69.1 149.5
8765 F 19 1 67.3 130.5
5734 F 18 1 64.3 110.2
4529 F 19 2 68.3 127.4
8341 F 20 3 66.5 132.6
4672 M 21 3 72.2 150.7
4823 M 22 4 68.8 128.5
5639 M 21 3 67.6 133.6
6547 M 24 2 69.5 155.4
8472 M 21 2 76.5 205.1
6327 M 20 1 70.2 135.4
8472 F 20 4 66.8 142.6
4875 M 20 1 74.2 160.4
;
run;

/* maxdec defines maximum number of decimal digits to use when printing data */
/* class defines which variables to use as factors in the calculations */

proc means data=biology maxdec=3;
class year sex;
var height weight;
output out=stats mean=av_ht av_wt stderr=se_ht se_wt;
run;

/* the above specifications, in the last line of code, request that the means 
and standard errors of the variables height and weight are to be computed and 
stored in the new variables av ht, av wt, se ht, and se wt, respectively */

proc print data=stats;
title 'Biology Class Data Set: Output Statement';
run;
/* The first line of the output will show average and standard errors for the
   whole dataset; the second and third lines will produce the stats by values
   of the second factor mentioned under CLASS (sex); the next 4 lines produce 
   the statistics by each level of the first factor mentioned in the CLASS 
   statement (year).
   _TYPE_ indicates which combinations of the CLASS variables/factors are used
   to define the group of values for which the statistics are calculated */

/* High resolution graphics */

/* The gplot procedure */
/* The primary action statement in proc gplot is the
   plot statement. The plot statement must have at least one plot-request 
   but may contain multiple plot-requests, followed by plot statement 
   options preceded by a slash. A plot-request can be any of the following 
   forms:
   y * x
   y1 * x1 y2 * x2 . . . 
   y * x = z
   y * x = n
   where x, x1, etc. denote the variables plotted on the horizontal axis 
   and y, y1, etc. denote those plotted on the vertical axes. z is a 
   third variable, usually a classification variable associated with the 
   subjects (or cases) on which the variables x and y have been measured. 
   The number n denotes sequence number of the symbol definition statement 
   associated with the symbol used to plot y against x. */

/* The data taken from Weisberg (1985) consist of atmospheric pressure
   (inches of mercury) and the boiling point of water (in degrees Fahrenheit)
   measured at different altitudes above sea level. 
   A simple linear regression line is to be fitted with the dependent variable 
   y, taken to be 100 times the logarithm of pressure, logpres, with boiling 
   point, bpoint, being the independent variable, x*/

/* Below the targetdevice option acquires some characteristics of the 
   computer in order to produce the best graphics*/

goptions rotate=landscape targetdevice=pscolor
hsize=8 in vsize=6 in;

data forbes;

input bpoint pressure @@;
label bpoint='Boiling Point (deg F)'
pressure= 'Barometric Pressure(in. Hg)';
logpres=100*log(pressure);
datalines;
194.5 20.79 194.3 20.79 197.9 22.40 198.4 22.67 199.4 23.15
199.9 23.35 200.9 23.89 201.1 23.99 201.4 24.02 201.3 24.01
203.6 25.14 204.6 26.57 209.5 28.49 208.6 27.76 210.7 29.04
211.9 29.88 212.2 30.06
;
run;

proc gplot data = forbes;
plot logpres*bpoint;
run;

/* The settings j=c, h=2, f=none, and c=darkviolet for the specified 
   options in the first title definition causes the first line of the 
   title to be plotted centerjustified, with text characters of height 
   2 (in default units) using the default hardware font, and in the 
   predefined SAS color darkviolet. If f=none is omitted from the title 
   statements, the software font named complex will be used for the 
   first title line, instead of the hardware font. */

title1 j=c h=2.0 f=none c=darkviolet
'Analysis of Forbes(1857) data';

/* The lspace=1.5 2 used in the title2 statement specifies the line spacing,
   in default units, between the two title lines, which, by default, is 1, 
   but here is increased by 50% */

title2 j=c h=1.5 f=none c=mediumblue lspace=1.5 2
'on boiling point of water';

/* The footnote statements define the lines to appear in the lower part of the
   graphics output area. The values for options specified in the first
   footnote statement, h=1.5, f=italic, c=blueviolet, and move=(8,+0),
   result in the first text line to be plotted beginning at the coordinate 
   position (8,+0) in the predefined SAS color blueviolet using an italic 
   font and text characters of height 1.5 in default units. */

footnote1 h=1.5 f=italic c=blueviolet move=(8,+0) 3
'Source: S. Weisberg';
footnote2 h=1.3 f=centbi c=darkred move=(16,+0)
'Applied Linear Regression, 2005';

/* The symbol statements define the appearance of the plot symbols of the 
   points plotted and how they are interpolated. */
/* The settings for options in symbol definition 1, c=red v=star i=none h=1.5
   specify that the symbols plotted are red-colored stars of size 1.5 in 
   default units with no interpolation (i.e., the symbols are not connected 
   with lines or line segments) */

symbol1 c=red v=star i=none h=1.5;

/* i=rl v=none on the other hand, specify that the points are to be 
   interpolated by a linear regression line. The v=none option ensures 
   that the points are not plotted a second time. */
symbol2 ci=darkcyan i=rl v=none;

/* Thus, the two symbol definitions result in the overlaying of a linear 
   regression line fitted to the pairs of data values that were previously 
   plotted as a scatter plot. One needs to use the statement overlay in the
   plot statement below. */

/* The axis statements define the appearance of an axis. */
/* In axis definition 1, the label=(c=magenta a=90 h=1 '100x log(pressu
re(in Hg))') option specifies that the given text string be rotated 90
degrees anticlockwise and printed using the color magenta and a character
size of 1 default units. c= a= h= 'text-string' are parameters for
the label option. The value=(c=blue) specifies that the values appearing at
the major tick marks be of color blue. c= is one of the parameters for the
value option. Thus, although the major tick-mark values for the
vertical axis will remain those calculated by proc gplot, the plot color of
those values will be changed to blue. */

axis1 label=(c=magenta a=90 h=1 5 '100x log(pressure(in Hg))') value=(c=blue);

/* Below, order=190 to 215 by 5 overrides the default number of major tick 
marks and the values appearing at those tick marks in plotting both the 
horizontal and the vertical axes */
/* The parameter values set for the keyword option
label=, (c=magenta h=1) specifies the color and size of the text characters
used to print the horizontal axis label */

axis2 order=190 to 215 by 5 label=(c=magenta h=1) value=(c=blue ); 6

proc gplot data = forbes;
plot logpres*bpoint=1
/* the =1 above asks gplot to use symbol1 definitions for this plot */
logpres*bpoint=2/vaxis=axis1 haxis=axis2 overlay; 7
/* the =2 above asks gplot to use symbol2 definitions for this plot */

run;

 