/*set library*/
libname library 'C:\Users\xuker\Downloads\@USC\18fall-PM511A- Data Analysis\final project-pm511';
run;
/*take a look at the dataset*/
data mydata;
set library.nhanes2000_326;
run;

proc print data=mydata; run;
proc contents data=mydata; run;

/*check missing data for categorical variable*/
%macro freq(categorical); 
proc freq data=mydata;
table &categorical;
run; 
%mend freq;
/*call the freq macro*/
%freq(male race wtEndDigit educ smoke);

/*check missing for continous variable*/
%macro meanmissing(continuous); 
proc means data = mydata n nmiss;
var &continuous;
run; 
%mend meanmissing;
/*call the meanmissing macro*/
%meanmissing(age htin wtlbs htErr wtErr BPsys bmi bmiRep educ);

/*check the max and min for continous variable*/
%macro meanmaxmin(continuous); 
proc means data = mydata n p25 p50 p75 qrange min max;
var &continuous;
run; 
%mend meanmaxmin;
/*call the meanmaxmin macro*/
%meanmaxmin(age htin wtlbs htErr wtErr BPsys bmi bmiRep educ);

/*make plot to check if there are extreme values*/
title 'Box Plot for Weight'; 
proc sgplot data=kids; 
vbox wt; 
yaxis label = "Weight, lbs";
run;
proc univariate data=kids; 
var wt; 
histogram; 
title 'Histogram for Weight'; 
run;

/*if there are obviously abnormal values, such as age smaller than 0, then delete
if the value is extreme or is not apparenet, then still include in the sample, 
do not exclude at this early stage. */


/*keep only observations non-missing on variables of interest*/
data mydata; 
set mydata; 
if wheeze ^= . AND ets ^= . AND asthma ^= . AND fev ^= .;
run;


/*MISSPRINT*/
/*displays missing value frequencies in frequency or crosstabulation tables */
/*but does not include them in computations of percentages or statistics.*/
/**/
/*MISSING*/
/*treats missing values as a valid nonmissing level for all TABLES variables. */
/*Displays missing levels in frequency and crosstabulation tables and includes them */
/*in computations of percentages and statistics.*/
