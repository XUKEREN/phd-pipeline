/*pm518 - hw 2*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw2\tuyns2.csv" out=tuyns2 dbms=csv replace;
    getnames=yes;
run;
proc contents data=tuyns2;run;
proc print data=tuyns2; run;
/*check for missing data*/
PROC FREQ DATA=tuyns2 ;
  TABLES age_group alcohol tobacco disease numsub ;
RUN ;  
/*dichtomize alochol*/
data tuyns2_new;
set tuyns2;
alcohol_dic=0;
if alcohol=3 or alcohol=4 then alcohol_dic=1;
run;
/*check*/
proc freq data=tuyns2_new;
table alcohol*alcohol_dic;
run;
/*dichtomize tobacco*/
data tuyns2_new;
set tuyns2_new;
tobacco_dic=0;
if tobacco=3 or tobacco=4 then tobacco_dic=1;
run;
/*check*/
proc freq data=tuyns2_new;
table tobacco*tobacco_dic;
run;

/*create formats*/
proc format;
	value age_groupf	1 = '25-34'
		  				2 = '35-44'
						3='45-54'
						4='55-64'
						5='65-74'
						6='75+';

	value alcoholf	1 = '0-39'
					2 = '40-79'
					3 = '80-119'
					4 = '120+';

	value alcohol_dicf	0 = '0-79'
						1 = '80+';

    value tobaccof	1 = '0-9'
					2 = '10-19'
					3 = '20-29'
					4 = '30+';

	value tobacco_dicf	0 = '0-19 '
						1 = '20+';
	value diseasef 	0 = 'Control'
				 	1 = 'Case';
run;

data tuyns2_new;
set tuyns2_new;
	format age_group age_groupf. 
		   alcohol alcoholf.
		   alcohol_dic alcohol_dicf.
		   tobacco tobaccof.
		   tobacco_dic tobacco_dicf.
           disease diseasef.;
	label age_group = 'Age group (years)';
	label alcohol = 'Alcohol (gms/day)';
	label alcohol_dic = 'Dichotomous Alcohol (gms/day)';
	label tobacco = 'Tobacco (gms/day)';
	label tobacco_dic = 'Dichotomous Tobacco (gms/day)';
	label disease = 'Disease';
    label numsub = 'Number of subjects';
run;
proc contents data=tuyns2_new; run;

/*create 2 by 2 table for alcohol and disease*/
proc print data=tuyns2_new;run;
proc sort data=tuyns2_new;
by alcohol_dic disease;
run;
proc means data=tuyns2_new sum;
var numsub;
by alcohol_dic disease;
run;
data tab1; 
input disease $ alcohol_dic $ count; 
cards;
yes 80+ 96 
yes 0-79  104 
no 80+ 109 
no 0-79  666 
;
run;
proc freq data = tab1 order = data; 
table alcohol_dic*disease /relrisk chisq expected; 
exact fisher or;
weight count;
run;


/*create 2 by 2 table for disease by tobacco*/
proc sort data=tuyns2_new;
by tobacco_dic disease;
run;
proc means data=tuyns2_new sum;
var numsub;
by tobacco_dic disease;
run;
data tab2; 
input disease $ tobacco_dic $ count; 
cards;
yes 20+  64 
yes 0-19  136 
no 20+  150 
no 0-19  625
;
run;
proc freq data = tab2 order = data; 
table tobacco_dic*disease /relrisk chisq expected; 
weight count;
run;

/*Q3 2 by K table */
proc print data=tuyns2_new;run;
proc sort data=tuyns2_new;
by alcohol disease;
run;
proc means data=tuyns2_new sum;
var numsub;
by alcohol disease;
run;

data tab3; 
input disease $ alcohol $ count; 
cards;
yes 120+ 45 
yes 80-119 51 
no 120+ 22 
no 80-119 87 
yes 40-79 75 
yes 0-39 29 
no 40-79 280 
no 0-39 386 
;
run;
data tab3; 
input disease $ alcohol  count; 
cards;
yes 4 45 
yes 3 51 
no 4 22 
no 3 87 
yes 2 75 
yes 1 29 
no 2 280 
no 1 386 
;
run;
proc freq data = tab3 order = data; 
table alcohol*disease /relrisk chisq expected cmh exact trend; 
weight count;
run;

proc logistic data = tab3;
model disease (event = "yes") = alcohol;
weight count;
run;


/*global x2 test - general association 158.79 */
/*Cochran-Armitage Trend Test*/

/*3 variables - test the association between treatment and response controlling by gender*/
 data Migraine;
      input Gender $ Treatment $ Response $ Count @@;
      datalines;
   female Active  Better 16   female Active  Same 11
   female Placebo Better  5   female Placebo Same 20
   male   Active  Better 12   male   Active  Same 16
   male   Placebo Better  7   male   Placebo Same 19
   ;
run;
proc freq data=Migraine;
tables Gender*Treatment*Response / cmh; 
weight Count;
title 'Clinical Trial for Treatment of Migraine Headaches';
run;
/*Because this is a prospective study, the relative risk estimate assesses the effectiveness of the new drug; */
/*the "Cohort (Col1 Risk)" values are the appropriate estimates for the first column (the risk of improvement). */
/*The probability of migraine improvement with the new drug is just over two times the probability of */
/*improvement with the placebo.*/

/*The large -value for the Breslow-Day test (0.2218) 
indicates no significant gender difference in the odds ratios.*/

/*Test for trend in proportions*/
/*Suppose Y indicates response or no response, and DOSE is the dose amount of a drug. */
/*You can test that the proportion of responders increases (or decreases) with dose using the Cochran-Armitage test */
/*in the FREQ, MULTTEST, or LOGISTIC procedure.*/
/**/
/*In PROC FREQ, use the TREND option in the TABLES statement to get an asymptotic test of trend as shown below. */
/*For small or sparse samples, you can request an exact test by adding the exact trend; statement. */
/*If the data set is too small or sparse to use the asymptotic test, but too large for the exact algorithm, */
/*you can request Monte-Carlo estimation of the exact p-value by adding the exact trend / mc; statement.*/
/*proc freq;*/
/*   tables dose*y / trend;*/
/*   run;*/
/*In PROC MULTTEST, Y must have values 0 and 1, where 1 indicates response:*/
/*proc multtest;*/
/*   class dose; */
/*   test ca(y);*/
/*   run;*/
/*In PROC LOGISTIC, the score test in the Testing Global Null Hypothesis: */
/*BETA=0 table is equivalent to the Cochran-Armitage test.*/
/*proc logistic;*/
/*   model y=dose;*/
/*   run;*/

/*test the OR for each category vs. the reference group*/
proc sort data=tuyns2_new;
by alcohol;
run;
proc means data=tuyns2_new sum;
var numsub;
by alcohol;
run;

/*transform to the event and total format*/
data tab3_new; 
input alcohol $ event total; 
cards;
120+ 45 67
80-119 51 138
40-79 75 355
0-39 29 415
;
run;
proc logistic data = tab3_new; 
class alcohol(ref = '0-39') / param = ref; 
model event/total = alcohol / cl; 
run;


/*Q4*/
/*dichtomize age*/
proc print data=tuyns2_new;run;

data tuyns2_new;
set tuyns2_new;
age_group_dic=0;
if age_group=4 or age_group=5 or age_group=6 then age_group_dic=1;
run;
proc freq data=tuyns2_new;
table age_group_dic*age_group;
run;

/*test to see if age is a confounder of the association between alcohol and disease*/
/*test for two criteria*/

/*test the association between alcohol and age in control group*/
data tuyns2_new_control;
set tuyns2_new;
if disease=0;
run;
proc sort data=tuyns2_new_control;
by age_group_dic alcohol_dic;
run;
proc means data=tuyns2_new_control sum;
var numsub;
by age_group_dic alcohol_dic;
run;
data tab_control; 
input alcohol_dic $ age_group_dic $ count; 
cards;
80+ 1  45 
80+ 0  64 
0-79 1  258 
0-79 0  408
;
run;
proc freq data = tab_control order = data; 
table age_group_dic*alcohol_dic /relrisk chisq expected; 
weight count;
exact fisher or;
run;

/*test the association between age and disease in unexposed group*/
data tuyns2_new_drinkless;
set tuyns2_new;
if alcohol_dic=0;
run;
proc sort data=tuyns2_new_drinkless;
by age_group_dic disease;
run;
proc means data=tuyns2_new_drinkless sum;
var numsub;
by age_group_dic disease;
run;
data tab_drinkless; 
input disease $ age_group_dic $ count; 
cards;
yes 1  78 
yes 0  26 
no 1  258 
no 0  408
;
run;
proc freq data = tab_drinkless order = data; 
table age_group_dic*disease /relrisk chisq expected; 
weight count;
exact fisher or;
run;

/*test the association between alcohol and disease while adjusting for age*/
/*CMH shows if there is association between alcohol and disease adjusting for age*/
/*breslow day shows if the association between alcohol and disease differs by age group*/
proc sort data=tuyns2_new;
by age_group_dic alcohol_dic disease;
run;
proc means data=tuyns2_new sum;
var numsub;
by age_group_dic alcohol_dic disease;
run;
data tab_Q4; 
input disease $ alcohol_dic $ age_group_dic count; 
cards;
yes 80+ 1  66 
yes 80+ 0  30 
yes 0-79 1  78 
yes 0-79 0  26
no 80+ 1  45 
no 80+ 0  64 
no 0-79 1  258 
no 0-79 0  408
;
run;
proc freq data = tab_Q4 order = data; 
table age_group_dic*alcohol_dic*disease /relrisk chisq expected cmh; 
weight count;
run;



/*Q5 similar analyses to Q4, but for tobacco*/
/*dichtomize age*/
data tuyns2_new_control;
set tuyns2_new;
if disease=0;
run;
proc sort data=tuyns2_new_control;
by age_group_dic tobacco_dic;
run;
proc means data=tuyns2_new_control sum;
var numsub;
by age_group_dic tobacco_dic;
run;
data tab_control; 
input tobacco_dic $ age_group_dic count; 
cards;
20+ 1  49 
20+ 0  101
0-19 1  254 
0-19 0  371
;
run;
proc freq data = tab_control order = data; 
table age_group_dic*tobacco_dic /relrisk chisq expected; 
weight count;
exact fisher or;
run;

data tuyns2_new_smokeless;
set tuyns2_new;
if tobacco_dic=0;
run;
proc sort data=tuyns2_new_smokeless;
by age_group_dic disease;
run;
proc means data=tuyns2_new_smokeless sum;
var numsub;
by age_group_dic disease;
run;

data tab_smokeless; 
input disease $ age_group_dic $ count; 
cards;
yes 1  102 
yes 0  34
no 1  254 
no 0  371
;
run;
proc freq data = tab_smokeless order = data; 
table age_group_dic*disease /relrisk chisq expected; 
weight count;
exact fisher or;
run;

proc sort data=tuyns2_new;
by age_group_dic tobacco_dic disease;
run;
proc means data=tuyns2_new sum;
var numsub;
by age_group_dic tobacco_dic disease;
run;
data tab_Q5; 
input disease $ tobacco_dic $ age_group_dic count; 
cards;
yes 20+ 1  42 
yes 20+ 0  22 
yes 0-19 1  102 
yes 0-19 0  34
no 20+ 1  49 
no 20+ 0  101 
no 0-19 1  254 
no 0-19 0  371
;
run;
proc freq data = tab_Q5 order = data; 
table age_group_dic*tobacco_dic*disease /relrisk chisq expected cmh; 
weight count;
exact fisher or;
run;


