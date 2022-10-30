/*pm518a - hw5 - K-M curve*/

/*The STATA data file NICKEL.DTA contains individual records from the Welsh nickel cohort (679 subjects), and has the following format:*/
/**/
/*	Variable		  	            					  */
/*	icdcode		  	  ICD Code for cause of death*/
/*	dob			              Date of Birth (year of birth to 3 decimal places)*/
/*	afe				  Age at 1st employment */
/*            agestart 			  Age at start of follow-up */
/*            ageend	         			  Age at death or withdrawal*/
/*	expos				  Exposure index*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw5\nickel.csv" out=nickel dbms=csv replace;
    getnames=yes;
run;
proc contents data=nickel;run;
proc print data=nickel; run;

proc univariate data=nickel;
var dob afe;
run;
/*question 1 - format the dataset*/

/*compute the year at first enrollment*/
data nickel;
set nickel;
yfe=dob+afe;
run;

data nickel;
set nickel;
afecat=4;
if afe lt 20 then afecat=1;
if afe le 27.4 and afe ge 20.0 then afecat=2;
if afe le 34.9 and afe ge 27.5 then afecat=3;
yfecat=4;
if yfe ge 1902 and yfe lt 1910 then yfecat=1;
if yfe ge 1910 and yfe lt 1915 then yfecat=2;
if yfe ge 1915 and yfe lt 1920 then yfecat=3;
run;

data nickel;
set nickel;
exposcat=2;
if expos=0 then exposcat=0;
if expos gt 0 and expos le 8.0 then exposcat=1;
run;

data nickel;
set nickel;
agestartdic=0;
if agestart ge 45 then agestartdic=1;
run;


/*question 2: STSET the data*/
data nickel;
set nickel;
time=ageend-agestart;
status=0;
if icdcode=160 then status=1;
run;

/*question 3*/
/*Kaplan-Meier survival curves for 3 exposure group*/
ods graphics on; 
proc lifetest data=nickel method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
strata exposcat; 
run; 
ods graphics off;

proc print data=A;
run;

/*adjust for age group*/

/*method 1 - get K-M curve and do test in each stratum*/
proc sort data=nickel;
by agestartdic;
run;

ods graphics on; 
proc lifetest data=nickel method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
strata exposcat; 
by agestartdic;
run; 
ods graphics off;

/*methods 2 - Stratified Comparison of Survival Curves for time over Group*/
proc lifetest data=nickel notable;
time time*status(0);
strata agestartdic / group=exposcat;
run;

/*test for trend*/

/*not adjusted by age*/
proc lifetest data=nickel method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
strata exposcat/ test=(logrank wilcoxon) trend;
/*by agestartdic; maybe this statement does not work --*/
run; 
/*adjusted by age*/
proc lifetest data=nickel method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
strata agestartdic / group=exposcat test=(logrank wilcoxon) trend;
run;

/*lecture example */
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\cancer.csv" out=cancer dbms=csv replace;
    getnames=yes;
run;
proc contents data=cancer;run;
proc print data=cancer; run;

data cancer;
set cancer;
drug2=1;
if drug=1 then drug2=0;
agegrp=1;
if age lt 55 then agegrp=0;
run;

proc lifetest data=cancer notable;
time studytim*died(0);
strata agegrp / group=drug2;
run;
proc sort data=cancer;
by agegrp;
run;

proc lifetest data=cancer method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time studytim*died(0); 
strata drug2; 
by agegrp;
run; 
