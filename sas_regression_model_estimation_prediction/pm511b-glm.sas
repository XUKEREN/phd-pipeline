/*pm511b - GLM - hw3*/
data hw3;
input snoring disease count @@;
datalines;
0 1 24 
2 1 35 
4 1 21 
5 1 30 
0 0 1355 
2 0 603 
4 0 192 
5 0 224 
;
run;

/*create formats*/
proc format;
	value snoringf	0 = 'Never'
		  			2 = 'Occasional'
					4='Nearly every night'
					5='Every night';

	value diseasef	1 = 'Yes'
					0 = 'No';
run;

data hw3;
set hw3;
	format snoring snoringf. 
		   disease diseasef.;
run;
proc contents data=hw3; run;

proc freq data=hw3;
table snoring disease count;
run;

/*transfer to the long format*/
data hw3_new (drop=i);
set hw3;
do i = 1 to count;
output;
end;
run;
proc print data=two;
run;
/*check the dataset*/
proc sort data=hw3_new;
by  disease snoring;
run;
proc freq data=hw3_new;
table snoring;
by disease;
run;

proc reg data=hw3_new;
model disease=snoring/clb;
run;

/*method 1*/
data glm; 
input snoring disease total @@; 
datalines; 
0 24 1379 
2 35 638 
4 21 213 
5 30 254 
;
run;
proc genmod; model disease/ total= snoring/ dist= bin link= identity; run;
proc genmod; model disease/ total= snoring/ dist = bin link= logit; run;
proc genmod; model disease/ total= snoring/ dist= bin link= probit;run;

/*method 2*/
proc genmod data=hw3_new descending; model disease= snoring/ dist= bin link= identity;run;
proc genmod data=hw3_new descending; model disease= snoring/ dist = bin link= logit;run;
proc genmod data=hw3_new descending; model disease= snoring/ dist= bin link= probit;run;

/*calculate the probability according to the probit score*/
Data a; y = probnorm(-2.0606);
Proc print; title ‘Pr(Z<-2.0606)’;
run;
Data a; y = probnorm(-2.0606+0.1878*5);
Proc print; title ‘Pr(Z<-2.0606+0.1878*5)’;
run;


/*Q2*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw2\vitals.csv" out=vitals dbms=csv replace;
    getnames=yes;
run;
proc contents data=vitals;
run;
proc print data=vitals;
run;
data vitals;
set vitals;
BMI=703*weight/height**2;
run;

/*check to see if there is missing value*/
proc univariate data=vitals;
var BMI;
run;
data vitals;
set vitals;
if BMI gt 0 and BMI Lt 25 then BMI_dic=0;
if BMI ge 25 then BMI_dic=1;
run;
/*check the results*/
proc sort data=vitals;
by bmi_dic;
run;
proc univariate data=vitals;
var bmi;
by bmi_dic;
run;

/*check to see if there is missing value*/
proc univariate data=vitals;
var sbp;
run;
data vitals;
set vitals;
if sbp LE 140 then sbp_dic=0;
if sbp gt 140 then sbp_dic=1;
run;
/*check the results*/
proc sort data=vitals;
by sbp_dic;
run;
proc univariate data=vitals;
var sbp;
by sbp_dic;
run;
proc freq data=vitals;
table sbp_dic*bmi_dic/chisq expected;
run;
proc print data=vitals;
run;
proc genmod data=vitals descending; model sbp_dic= age/ dist= bin link= probit;run;
proc genmod data=vitals descending; model sbp_dic= BMI_dic/ dist= bin link= probit;run;

proc genmod data=vitals descending; model sbp_dic= age BMI_dic/ dist= bin link= probit;run;

Data a; 
y1 = probnorm(-0.2944);
y2 = probnorm(-1.68);
proc print;
run;

Data a;
y1 = probnorm(-3.7485);
y2 = probnorm(0.0475);
y3= probnorm(0.0405);
y4= probnorm(0.0545);
y5= probnorm(-1.0749);
y6= probnorm(0.2801);
y7= probnorm(0.1457);
y8= probnorm(0.4145);
y9= probnorm(0.3896);
y10= probnorm(0.2467);
y11= probnorm(0.5326);
y12= probnorm(0.0498);
y13= probnorm(0.0426);
y14= probnorm(0.0569);
proc print;
run;
