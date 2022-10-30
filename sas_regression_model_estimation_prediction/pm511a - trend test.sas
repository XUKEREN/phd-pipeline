/*pm511a - p11 - trend test*/
/*continous Y and ordoinal X*/
data a; label y='Reaction time' group='Hour w/ no sleep';
do group=12,24,36,48; 
input y @; 
output;
end; 
datalines; 
20 21 25 26
20 20 23 27
17 21 22 24
19 22 23 27
20 19 20 22
19 20 22 28
21 23 22 26
19 19 23 27
; 
proc print data=a label; 
var group y; 
title 'Dataset a'; run;
proc sort data=a; by group;
proc means data=a noprint; by group; var y; output out=summary mean=meany;
proc gplot data=summary; symbol1 v=dot i=rl; plot meany*group=1; 
title 'Plot mean reaction time by hours of sleep deprivation';
run;
proc glm data=a; class group; model y=group; 
contrast 'Linear trend' group -3 -1 1 3;
contrast 'Quadratic trend' group 1 -1 -1 1; 
contrast 'Cubic trend' group -1 3 -3 1; 
Title 'Test for linear, quadratic, and cubic trends in the sleep data';
run;


/*In PROC FREQ, use the TREND option in the TABLES statement to get an asymptotic test of trend as shown below. For small or sparse samples, you can request an exact test by adding the exact trend; statement. If the data set is too small or sparse to use the asymptotic test, but too large for the exact algorithm, you can request Monte-Carlo estimation of the exact p-value by adding the exact trend / mc; statement.*/
proc freq;
tables dose*y / trend;
run;
/*In PROC MULTTEST, Y must have values 0 and 1, where 1 indicates response:*/
proc multtest;
   class dose; 
   test ca(y);
   run;
/*In PROC LOGISTIC, the score test in the Testing Global Null Hypothesis: BETA=0 table is equivalent to the Cochran-Armitage test.*/
proc logistic;
   model y=dose;
   run;
 
