/*pm511b - hw2 - q4*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw2\hw2_4.csv" out=q4 dbms=csv replace;
    getnames=yes;
run;
proc contents data=q4;
run;
proc print data=q4;
run;
/*Standardized residual*/
proc freq data = q4 order = data; 
table weight_cat*days_hospital/chisq expected  CROSSLIST(STDRES); 
weight count;
run;
/*cellchi2- individual contribution to chi-square test*/
proc freq data = q4 order = data; 
table weight_cat*days_hospital/chisq expected  CROSSLIST(STDRES) cellchi2 ; 
weight count;
run;
