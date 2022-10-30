/*pm518 - hw3 - matched case-control*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw3\leisure.csv" out=leisure dbms=csv replace;
    getnames=yes;
run;
proc contents data=leisure;run;
proc print data=leisure; run;

/*obtain matched odds ratio*/
/*select first control to get 1: 1 ratio*/
data leisure_1;
set leisure;
if cntlnum eq "Case" or cntlnum eq "1st control";
run;
proc print data=leisure_1; run;
proc sort data=leisure_1;
by setid endoca;
run;

proc freq data = leisure_1 order = data; 
table setid*endoca*obese / cmh noprint alpha=0.05;
run;

/*compute exact confidence limits*/
/*formula see hw3*/
/*below the codes to compute p-values*/
data a;
q1=finv(.975,20,38);
q2=finv(.975,40,18);
proc print data=a;
run;


/*compute the matched odds ratio for all 4 controls*/
proc freq data = leisure order = data; 
table setid*endoca*obese / cmh noprint;
run;
