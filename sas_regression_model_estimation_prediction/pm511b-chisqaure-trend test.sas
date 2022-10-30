/*pm511b- hw2 -Q4*/
/* d. Conduct an ordinal (M2) test using equally-spaced scores. 
Use the corr command with frequency weights to calculate the test statistic*/
/*H0: there is no association between weight category and length of post-surgical days in hospital. */
/*Or rho=0*/
/*Ha: there is a linear association between weight category and length of post-surgical days in hospital. */
/*Or rho is not equal to 0*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw2\hw2_4.csv" out=q4 dbms=csv replace;
    getnames=yes;
run;
proc contents data=q4;
run;
proc print data=q4;
run;
proc corr data=q4;
var weight_cat days_hospital;
freq count;
run;
data a;
r=0.13745;
n=825;
M2=(n-1)*r**2;
df=1;
y = 1-probchi(M2,df);
Proc print; 
title ‘2-sided P-value for X=15.59  in chi-sq_1 dist’;
run;

/*Check by CMH statistics*/
/*why to use CMH statistics here????*/
proc freq data = q4 order = data; 
table weight_cat*days_hospital/ chisq cmh trend; 
weight count;
run;

/*Special cases of the M2 test:*/
/*i. For 2xJ tables (i.e., 2 group comparisons on an ordinal variable), */
/*the M2 Test using mid-rank scores is the Wilcoxon rank sum or MannWhitney test.*/
/*ii. For Ix2 tables, the M2 Test is called the Cochran-Armitage Trend test.*/
