/*pm518 - week 5 - conditional logistic regression */

/*The case and corresponding control have the same ID. */
/*Two prognostic factors are included: Gall (an indicator variable for gall bladder disease) */
/*and Hyper (an indicator variable for hypertension). */
/*The goal of the case-control analysis is to determine the relative risk for gall bladder disease, */
/*controlling for the effect of hypertension.*/

data mydata;
     do ID=1 to 63;
       do Outcome = 1 to 0 by -1;
         input Gall Hyper @@;
         output;
       end;
     end;
     datalines; 
   0 0  0 0    0 0  0 0    0 1  0 1    0 0  1 0    1 0  0 1    
   0 1  0 0    1 0  0 0    1 1  0 1    0 0  0 0    0 0  0 0    
   1 0  0 0    0 0  0 1    1 0  0 1    1 0  1 0    1 0  0 1    
   0 1  0 0    0 0  1 1    0 0  1 1    0 0  0 1    0 1  0 0   
   0 0  1 1    0 1  0 1    0 1  0 0    0 0  0 0    0 0  0 0    
   0 0  0 1    1 0  0 1    0 0  0 1    1 0  0 0    0 1  0 0    
   0 1  0 0    0 1  0 0    0 1  0 0    0 0  0 0    1 1  1 1    
   0 0  0 1    0 1  0 0    0 1  0 1    0 1  0 1    0 1  0 0   
   0 0  0 0    0 1  1 0    0 0  0 1    0 0  0 0    1 0  0 0    
   0 0  0 0    1 1  0 0    0 1  0 0    0 0  0 0    0 1  0 1    
   0 0  0 0    0 1  0 1    0 1  0 0    0 1  0 0    1 0  0 0    
   0 0  0 0    1 1  1 0    0 0  0 0    0 0  0 0    1 1  0 0   
   1 0  1 0    0 1  0 0    1 0  0 0    
;
run;
proc print data = mydata;run;

/*Conditional Analysis Using the STRATA Statement*/
proc logistic data=mydata;
strata ID;
model outcome(event='1')=Gall;
run;

/*add PL to get confidence intervals*/
proc logistic data=mydata;
model outcome=Gall / noint CLODDS=PL;
run;
proc logistic data=mydata;
model outcome=Gall Hyper / noint CLODDS=PL;
run;

/*Exact Analysis Using the STRATA Statement*/
proc logistic data=Data1 exactonly;
strata ID;
model outcome(event='1')=Gall;
exact Gall / estimate=both;
run;

/*read dataset without format*/
/*Example 1: 1-1 Matching*/
OPTIONS nofmterr;
libname library "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\19spring-pm518a";
PROC print DATA=library.lbwt11;
RUN;
data lbwt11;
set library.lbwt11;
run;

proc logistic data = lbwt11 descending;
  model lbwt = lastwt smoke race2 race3 ptd ht ui ;
  strata pairid;
run;

/*Example 2: 1-M matching*/
OPTIONS nofmterr;
libname library "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\19spring-pm518a";
PROC print DATA=library.bbdm13;
RUN;
data mydata;
set library.bbdm13;
run;
proc logistic data = mydata descending;
  model fndx = chk agmn wt mod wid nvmr ;
  strata str;
run;


/*test for log - linearity for conditional logistic regression*/


/*
Description for macro logit_linearity(data, event, y, primvar, c, x)

Use to determine whether use of a continuous variable is appropriate
and whether any other fractional polynomial may provide a better model
fit than a linear function of the variable.

- Fits plot of beta vs. midpoints for quartile indicator variables to check linearity
- Fits plot of logit transformed smoother plot to check linearity
- Prints table of best 1- and 2-term frac poly models compared to linear (same as fp in Stata)

data = data to run analysis on
event = value that indicates an event occurred (i.e. disease = 1 or 0, 1 is disease occurred. Then event = 1)
y = outcome variable of interest
primvar = continuous variable for which you want to check linearity assumption
c = any additional categorical variables you want to include in frac poly models
x = any additional continuous variables you want to include in frac poly models

*/

%macro logit_linearity(data,event,y,primvar,c,x,s);

	proc means data = &data q1 median q3 noprint;
		var &primvar;
		output out = quartiles q1 = q1 median = q2 q3 = q3;
	run;

	data dwithquar; set &data;
		temp = 1;
	run;

	data quartiles; set quartiles;
		temp = 1;
	run;

	data dwithquar (drop = temp);
		merge dwithquar quartiles;
		by temp;
		if not missing (&primvar) AND &primvar >= q1 then do;
			if &primvar < q2 then do;
				quartile = "quart2";
				quart2 = 1;
			end;
			else quart2 = 0;
			if &primvar >= q2 AND &primvar < q3 then do;
				quartile = "quart3";
				quart3 = 1;
			end;
			else quart3 = 0;
			if &primvar >= q3 then do;
				quartile = "quart4";
				quart4 = 1;
			end;
			else quart4 = 0;
		end;
		else if not missing(&primvar) then do;
			quartile = "quart1"; 
			quart2 = 0;
			quart3 = 0;
			quart4 = 0;
		end;
	run;

	ods select ParameterEstimates;

	proc logistic data = dwithquar;
		model &y(event = "&event.") = quart2 quart3 quart4 &c &x;
		strata &s;
		ods output ParameterEstimates = est;
		title "Logistic regression of &y on quartile indicator variables vs. midpoints - Test for Linearity";
	run;

	ods select all;

	data est; 
	set est end=eof;
		if eof then do;
		output;
			estimate = 0;
			variable = "quart1";
		end;
		output;
		keep variable estimate;
		rename variable = quartile;
	run;


	proc sql;
		create table cutpoints as
		select d.quartile, (max(&primvar)+ min(&primvar))/2 as midpoint
		from work.dwithquar as d
		group by quartile;
	quit;

	proc sort data = est; by quartile; run;
	proc sort data = cutpoints; by quartile; run;

	data mid_beta;
		merge est cutpoints;
		by quartile;
	run; 

	proc sgplot data = mid_beta;
		scatter y = estimate x = midpoint;
		series y = estimate x = midpoint;
		title "Plot of beta estimates on quartile midpoints - Test for Linearity";
	run;

	ods select none;

	proc loess data = &data plots = none;
		model &y = &primvar;
		ods output OutputStatistics = MyOutStats; 
	run;

	ods select all;

	data MyOutStats; set MyOutStats;
		if 0 < pred < 1 then logitp = log(pred / (1-pred));
	run;

	proc sgplot data = MyOutStats;
		loess y = logitp x = &primvar;
		title "Logit tranformed smoother of predicted probability against &primvar - Test for Linearity";
	run;

	proc sgplot data = MyOutStats;
		scatter y = pred x = &primvar;
		scatter y = depvar x = &primvar;
		title "Scatter of predicted probability against &primvar - Test for Linearity";
	run;

	data fracpoly; set &data;
		x_neg2 = &primvar**(-2);
		x_neg1 = &primvar**(-1);
		x_negsqrt = &primvar**(-0.5);
		x_sqrt = &primvar**0.5;
		x_log = log(&primvar);
		x_1 = &primvar;
		x_2 = &primvar**2;
		x_3 = &primvar**3;
	run;

	%let powers = x_neg2 x_neg1 x_negsqrt x_log x_sqrt x_1 x_2 x_3;

	ods select none;

	*null model;
	proc logistic data = fracpoly;
		class &c;
		model &y (event = "&event.") = &c &x;
		strata &s;
		ods output FitStatistics = DevianceTable;
	run;

	data DevianceTable; set DevianceTable;
		length &primvar $10 powers $25;
		&primvar = "Omitted";
		df = 0; 
		powers = " ";
		drop equals WithoutCovariates;
		if criterion = "-2 Log L";
	run;

	*linear model;
	proc logistic data = fracpoly;
		class &c;
		model &y (event = "&event.") = &c &primvar &x;
		strata &s;
		ods output FitStatistics = dev;
	run;

	data dev; set dev;
		length powers $25;
		&primvar = "Linear";
		df = 1;
		powers = "1"; 
		if criterion = "-2 Log L";
		drop WithoutCovariates;
	run;

	data DevianceTable;
		set DevianceTable dev;
	run;

	*fit standard set of one and two term power models;
	%do i = 1 %to 8;
		%let p1 = %sysfunc(scan(&powers, &i, _, adk));
		
		%if &i = 6 %then %do;
			proc logistic data = fracpoly;
				class &c;
				model &y (event = "&event.") = &c &p1 &x;
				strata &s;
				ods output FitStatistics = dev1;
			run;

			data dev1; set dev1;
				length powers $25;
				&primvar = "m = 1";
				df = 1;
				powers = "&p1.";
				if criterion = "-2 Log L";
				drop WithoutCovariates;
			run;
		%end;
		%else %do;

		proc logistic data = fracpoly;
				class &c;
				model &y (event = "&event.") = &c &p1 &x;
				strata &s;
				ods output FitStatistics = dev1;
		run;

		data dev1; set dev1;
			length powers $20;
			&primvar = "m = 1";
			df = 2;
			powers = "&p1.";
			if criterion = "-2 Log L";
			drop WithoutCovariates;
		run;
		%end;

		%if &i = 1 %then %do;
			data dev1models;
				length powers $25;
				set dev1;
			run;
		%end;

		%else %do;
			data dev1models;
				length powers $25;
				set dev1models dev1;
			run;
		%end;

		%do j = 1 %to 8;
			%let p2 = %sysfunc(scan(&powers, &j, _, adk));

			%if &i = &j %then %do;
				proc logistic data = fracpoly;
					class &c;
					model &y (event = "&event.") = &c &p1 x_log*&p2 &x;
					strata &s;
					ods output FitStatistics = dev2;
				run;


				data dev2; set dev2;
					length powers $25;
					&primvar = "m = 2";
					df = 4;
					powers = "&p1.  log(x)*&p2.";
					if criterion = "-2 Log L";
					drop WithoutCovariates;
				run;

				%if &i = 1 AND &j = 1 %then %do;
					data dev2models;
						length powers $25;
						set dev2;
					run;
				%end;
	
				%else %do;
					data dev2models;
						length powers $25;
						set dev2models dev2;
					run;
				%end;

			%end;
			%else %if &j > &i %then %do;
				proc logistic data = fracpoly;
					class &c;
					model &y (event = "&event.") = &c &p1 &p2 &x;
					strata &s;
					ods output FitStatistics = Dev2;
				run;

				data dev2; set dev2;
					&primvar = "m = 2";
					df = 4;
					powers = "&p1.  &p2.";
					if criterion = "-2 Log L";
					drop WithoutCovariates;
				run;

				data dev2models;
					set dev2models dev2;
				run;
			%end;
		%end;
	%end;

	ods select all;

	proc sort data = dev1models; by descending WithCovariates; run;
	proc sort data = dev2models; by descending WithCovariates; run;

	data best1; set dev1models end = last;
		if last;
	run;

	data best2; set dev2models end = last;
		if last;
	run;

	data DevianceTable2;
		set DevianceTable best1 best2 end = last;
		if last then call symput('dev2', WithCovariates);
		drop criterion;
		rename WithCovariates = Deviance; 
		label WithCovariates = "Deviance";
	run;

	data DevianceTable3; set DevianceTable2 end = last;
		if last then devdif = 0;
		else devdif = deviance - &dev2;
		if not last then pvalue = 1 - probchi(devdif,4-df);
		powers2 = powers;
		powers3 = powers;

		if &primvar = "m = 1" then do;
			select(strip(scan(powers,1)));
				when("x_neg2") powers2 = "-2";
				when("x_neg1") powers2 = "-1";
				when("x_negsqrt") powers2 = "-0.5";
				when("x_log") powers2 = "0";
				when("x_sqrt") powers2 = "0.5";
				when("x_1") powers2 = "1";
				when("x_2") powers2 = "2";
				when("x_3") powers2 = "3";
			end;
			powers3 = " ";	
		end;

		else if &primvar = "m = 2" then do;
			select(strip(scan(powers,1)));
				when("x_neg2") powers2 = "-2";
				when("x_neg1") powers2 = "-1";
				when("x_negsqrt") powers2 = "-0.5";
				when("x_log") powers2 = "0";
				when("x_sqrt") powers2 = "0.5";
				when("x_1") powers2 = "1";
				when("x_2") powers2 = "2";
				when("x_3") powers2 = "3";
			end;
			select(strip(scan(powers,2)));
				when("x_neg2") powers3 = "-2";
				when("x_neg1") powers3 = "-1";
				when("x_negsqrt") powers3 = "-0.5";
				when("x_log") powers3 = "0";
				when("x_sqrt") powers3 = "0.5";
				when("x_1") powers3 = "1";
				when("x_2") powers3 = "2";
				when("x_3") powers3 = "3";
				otherwise powers3 = powers2;
			end;	
		end;
		else powers3 = " ";

		finalpowers = catx("  ",powers2,powers3);

		label devdif = "Dev. Dif." 
			  finalpowers = "Powers" 
			  deviance = "Deviance"
			  devdif = "Dev. Dif"
			  pvalue = "p-value";

	run;

	proc print data = DevianceTable3 label;
		var &primvar df deviance devdif pvalue finalpowers;
		title "Fractional Polymonial comparisons";
		footnote "p-value is comparison of m = 2 to less complex models";
	run;

	title;
	footnote;

	proc datasets library = work nolist nodetails;
		delete quartiles dwithquar est cutpoints mid_beta myoutstats dev
			   deviancetable dev1 dev1models dev2 dev2models best1 best2
			   deviancetable2;
	run;quit;

%mend logit_linearity;

%logit_linearity(lbwt11,1,lbwt,lastwt, c =smoke   , x =  ,s=pairid )


/*Because of the matching (cases and controls are not independent; i.e., */
/*they are sampled within case-control sets), the Pearson and Hosmer-Lemeshow tests of goodness of fit */
/*are not appropriate (each compares observed */
/*to model-predicted numbers of events within covariate patterns).*/

/*alternative ways: */
/*Model log likelihoods or deviance*/
/*the larger the log likelihood the closer to 0, the better the model fit*/
/*deviance = -2(model log likelihood)*/
/*the smaller the deviance, the better the model fit*/
/*two information citerion measures: BIC, AIC 
smaller is better with AIC and BIC, while larger is better with log likelihood
*/


/*model diagnosis*/
proc logistic data = lbwt11 descending;
  model lbwt = lastwt smoke race2 race3 ptd ht ui/influence ;
  strata pairid;
  output out=b 
pred=p
/*CBAR=mycbar*/
/*DIFCHISQ=mychisq*/
/*DIFDEV=mydev*/
H=MYH
RESCHI=myPres
/*specifies the Pearson (chi-square) residual for identifying observations 
that are poorly accounted for by the model*/
/*RESDEV=mydevres;*/
dfbeta=dflastwt dfsmoke dfrace2 dfrace3 dfptd dfht dfui;
run;

proc sgplot data = b; 
scatter y = myPres x = p / markerchar=pairid; run;; 
run;
proc sgplot data = b; 
scatter y = MYH x = p / markerchar=pairid; run;; 
run;

proc sgplot data = b;
title;
scatter x = p y=dflastwt / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfsmoke / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfrace2 / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfrace3 / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfptd / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfht / markerchar=pairid; run;
proc sgplot data = b;
scatter x = p y=dfui / markerchar=pairid; run;

/*print out the large outliers*/
data check1;
set b;
if mychisq gt 10;
proc print;
run;
