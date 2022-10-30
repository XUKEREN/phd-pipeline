/*question 1*/
/*import dataset*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\final project\mydata" out=mydata dbms = dta replace;
run;
proc contents data=mydata;
run;
proc print data=mydata;
run;
/*obtain val=0 estimation sample*/
proc freq data=mydata;
table val;
run;
/*so there are 2789 subjects in estimation sample and 675 in validaton sample*/
data mydata_est;
set mydata;
if val=0;
run;
proc print data=mydata_est;
run;
/*create the descriptive table*/
/*check for missing*/
proc means data=mydata_est NMISS N; 
run;
proc freq data=mydata_est;
table died;
run;
/*check the min and max for continuous variables!!!!*/
proc means data = mydata_est min max;
var age sbp rr gcs;
run;
proc univariate data=mydata_est noprint;
   histogram age sbp rr gcs;
run;
/*some extreme values for sbp and rr, wasn't sure if these are unusual values, let's keep them first*/

/*categorical variable*/
/*categorize gcs*/
/*Severe injury: GCS<9 */
/*Moderate injury: GCS 9-12 */
/*Minor or no injury: GCS>12 gcs_cat=0*/
data mydata_est;
set mydata_est;
gcs_cat=0;
if gcs lt 9 and gcs ge 0 then gcs_cat=2;
if gcs le 12 and gcs ge 9 then gcs_cat=1;
run;
proc sort data=mydata_est;
by gcs_cat;
run;
proc means data=mydata_est n min max;
var gcs;
by gcs_cat;
run;
/*categorical variables: male race gcs_cat*/
/*chi-square test*/
proc sort data=mydata_est;
by died;
run;
proc freq data=mydata_est;
table male*died/ chisq;
table race*died/ chisq;
table gcs_cat*died/ chisq;
table asaps*died/ chisq;
run;
/*continuous variables: age sbp rr gcs*/
/*independent two sample t test with boxplots*/
proc ttest data=mydata_est; 
class died; 
var age; 
run;
ods graphics on;
proc ttest plots=all;
class died; 
var age;
run;
ods graphics off;
ods graphics on;
proc ttest plots=all;
class died; 
var sbp;
run;
ods graphics off;
ods graphics on;
proc ttest plots=all;
class died; 
var rr;
run;
ods graphics off;
proc ttest data=mydata_est;
class died; 
var gcs; 
run;
ods graphics on;
proc ttest plots=all;
class died; 
var gcs;
run;
ods graphics off;
/*logit tansformed lowess curve*/
/* to be done*/

/*transform continuous variables*/
proc means data=mydata_est mean n;
var age;
run;
/*thus, the average mean in the estimation sample is 41.6686985*/

data mydata_est;
set mydata_est;
sbp_120=sbp-120;
age_center=age-41.67;
rr_cat=0;
if rr lt 12 and rr ge 0 then rr_cat=1;
if rr gt 20 then rr_cat=2;
/*rr_cat = 1 when rr is low*/
/*rr_cat=0 when rr is normal*/
/*rr_cat=2 when rr is high*/
run;

/*question 2*/
/*Univariate logistic regression*/
proc logistic data = mydata_est descending; 
model died = age_center/cl;
run;
proc logistic data = mydata_est descending; 
model died = sbp_120/cl;
run;
proc logistic data = mydata_est descending; 
model died = rr/cl;
run;
proc logistic data = mydata_est descending; 
model died = gcs/cl;
run;

proc logistic data = mydata_est descending; 
class male (ref = "0") / param = ref; 
model died = male/cl;
run;
proc logistic data = mydata_est descending; 
class race (ref = "1") / param = ref; 
model died = race/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
model died = gcs_cat/cl;
run;
proc logistic data = mydata_est descending; 
class rr_cat (ref = "0") / param = ref; 
model died = rr_cat/cl;
run;
/*only male has p-value larger than 0.25*/

/*Preliminary main effects model*/
proc logistic data = mydata_est descending; 
class race (ref = "1") / param = ref; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_center sbp_120 rr race gcs_cat/cl;
run;
/* race has p-value greater than 0.05*/
/*race 3 and race 4 have almost identical estimates for OR and CI*/
/*let's drop out race and do LRT*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_center sbp_120 rr gcs_cat/cl;
run;
/*likelihood ratio test*/
   data lrt_pval;
    	LRT = abs(985.492-983.064);
    	df  = 3;
    	p_value = 1 - probchi(LRT,df);
		proc print;
    	run;	
/*LRT = 2.428*/
/*DF=3*/
/*p=0.48844*/

/*try to combine race 3 and race 4*/
data mydata_est;
set mydata_est;
race_cat3=3;
if race=1 then race_cat3=1;
if race=2 then race_cat3=2;
run;
proc logistic data = mydata_est descending; 
class race_cat3 (ref = "1") / param = ref; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_center sbp_120 rr race_cat3 gcs_cat/cl;
run;
/*still no significant difference with the model that includes 4 race groups or no race*/
/*try to combine race 1 and race 2 => to dichotomize race, since we can see that race 1 and race 2 are similar*/
data mydata_est;
set mydata_est;
race_dic=0;
if race=1 then race_dic=1;
if race=2 then race_dic=1;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_center sbp_120 rr race_dic gcs_cat/cl;
run;
/*still no significant difference with the model that includes 4 race groups or race*/
/*the more parsimonious the better => drop race*/
/*sex looks like important, let's still add it back in the multivariate analysis*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_center sbp_120 rr male gcs_cat/cl;
run;
/*sex becomes significant again=> let's keep sex, and the -2loglikelihood (deviance) becomes smaller*/
/*!!! this is my preliminary main effects model !!!*/

/*Model refinement: Check linearity (scale) */

%macro logit_linearity(data,event,y,primvar,c,x);

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
		ods output ParameterEstimates = est;
		title "Logistic regression of &y on quartile indicator variables vs. midpoints - Test for Linearity";
	run;

	ods select all;

	data est; set est;
		if variable = "Intercept" then do;
			estimate = 0;
			variable = "quart1";
		end;
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
		ods output FitStatistics = DevianceTable;
	run;

	data DevianceTable; set DevianceTable;
		length &primvar $10 powers $25;
		&primvar = "Omitted";
		df = 0; 
		powers = " ";
		drop equals interceptonly;
		if criterion = "-2 Log L";
	run;

	*linear model;
	proc logistic data = fracpoly;
		class &c;
		model &y (event = "&event.") = &c &primvar &x;
		ods output FitStatistics = dev;
	run;

	data dev; set dev;
		length powers $25;
		&primvar = "Linear";
		df = 1;
		powers = "1"; 
		if criterion = "-2 Log L";
		drop interceptonly;
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
				ods output FitStatistics = dev1;
			run;

			data dev1; set dev1;
				length powers $25;
				&primvar = "m = 1";
				df = 1;
				powers = "&p1.";
				if criterion = "-2 Log L";
				drop interceptonly;
			run;
		%end;
		%else %do;

		proc logistic data = fracpoly;
				class &c;
				model &y (event = "&event.") = &c &p1 &x;
				ods output FitStatistics = dev1;
		run;

		data dev1; set dev1;
			length powers $20;
			&primvar = "m = 1";
			df = 2;
			powers = "&p1.";
			if criterion = "-2 Log L";
			drop interceptonly;
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
					ods output FitStatistics = dev2;
				run;


				data dev2; set dev2;
					length powers $25;
					&primvar = "m = 2";
					df = 4;
					powers = "&p1.  log(x)*&p2.";
					if criterion = "-2 Log L";
					drop interceptonly;
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
					ods output FitStatistics = Dev2;
				run;

				data dev2; set dev2;
					&primvar = "m = 2";
					df = 4;
					powers = "&p1.  &p2.";
					if criterion = "-2 Log L";
					drop interceptonly;
				run;

				data dev2models;
					set dev2models dev2;
				run;
			%end;
		%end;
	%end;

	ods select all;

	proc sort data = dev1models; by descending InterceptAndCovariates; run;
	proc sort data = dev2models; by descending InterceptAndCovariates; run;

	data best1; set dev1models end = last;
		if last;
	run;

	data best2; set dev2models end = last;
		if last;
	run;

	data DevianceTable2;
		set DevianceTable best1 best2 end = last;
		if last then call symput('dev2', InterceptAndCovariates);
		drop criterion;
		rename InterceptAndCovariates = Deviance; 
		label InterceptAndCovariates = "Deviance";
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

/*use all the original form for the continuous variable instead of the centered one
centered variable can be 0, so log of centered variable could be missing
*/
%logit_linearity(mydata_est,1,died,age, c = male gcs_cat, x = sbp rr)
/*as we can see, m=2 is not significantly better than m=1 or the linear*/
/*however, the linearity is violated based on the eyeball of the grouped smooth graph*/
/*compare m=1 and linear */
/*likelihood ratio test*/
   data lrt_pval;
    	LRT = abs(980.941-977.319);
    	df  = 1;
    	p_value = 1 - probchi(LRT,df);
		proc print;
    	run;	

/*the m=1 model is marginally better than the linear model*/
/*use m=1*/
/*transfer age*/
data mydata_est;
set mydata_est;
age_1=age**2;
run;

/*test for sbp*/
%logit_linearity(mydata_est,1,died,sbp, c = male gcs_cat, x = age_1 rr)
/*m=2 is significantly better than without sbp_120, linear, and m=1*/
/*transfer sbp*/
data mydata_est;
set mydata_est;
sbp_1=sbp**2;
sbp_2=sbp**3;
run;

/*test for rr*/
%logit_linearity(mydata_est,1,died,rr, c = male gcs_cat, x = age_1 sbp_1 sbp_2)
/*m=2 is the best model*/
/*transfer rr*/
data mydata_est;
set mydata_est;
rr_1=rr**(-1);
rr_2=rr**(-0.5);
run;

/*compare rr_1/ rr_2 with rr_cat*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
model died = age_1 sbp_1 sbp_2 rr_1 rr_2 male gcs_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
model died = age_1 sbp_1 sbp_2 rr_cat male gcs_cat/cl;
run;
/* model with rr_cat is better. choose the parimonious one */
/*use centered variable for interpretation*/
data mydata_est;
set mydata_est;
if sbp lt 90 then sbp_cat=0;
if sbp ge 90 and sbp lt 120 then sbp_cat=1;
if sbp ge 120 and sbp lt 130 then sbp_cat=2;
if sbp ge 130 and sbp lt 140 then sbp_cat=3;
if sbp ge 140 and sbp lt 160 then sbp_cat=4;
if sbp ge 160 and sbp lt 180 then sbp_cat=5;
if sbp ge 180 then sbp_cat = 6;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat (ref = "2") / param = ref; 
model died = age_1 sbp_cat rr_cat male gcs_cat/cl;
run;
/*we found that sbp group 1 and 2 have identical estimates
3 and 4 have identical estimates
5 and 6 have identical estimates
*/
data mydata_est;
set mydata_est;
if sbp lt 90 then sbp_cat_new=0;
if sbp ge 90 and sbp lt 130 then sbp_cat_new=1;
if sbp ge 130 and sbp lt 160 then sbp_cat_new=2;
if sbp ge 160 then sbp_cat_new = 3;
run;
proc sort data=mydata_est;
by sbp_cat_new;
run;
proc means data=mydata_est min max n;
var sbp;
by sbp_cat_new;
run;

proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/cl;
run;

/*we went back to check the linearity of age again */
%logit_linearity(mydata_est,1,died,age,c = sbp_cat_new rr_cat male gcs_cat, x= )

/*comparing m=1 and linear model - still marginally significant*/
   data lrt_pval;
    	LRT = abs(949.695-946.720);
    	df  = 1;
    	p_value = 1 - probchi(LRT,df);
		proc print;
    	run;	

/*check for interaction*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat age_1*sbp_cat_new/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat age_1*rr_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat age_1*male/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat age_1*gcs_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat sbp_cat_new*rr_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat sbp_cat_new*male/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat sbp_cat_new*gcs_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat rr_cat*male/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat rr_cat*gcs_cat/cl;
run;
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat male*gcs_cat/cl;
run;

/*did not find any significant interaction*/

/*!!! this is my preliminary final model !!!*/
/*died = age_1 sbp_cat_new rr_cat male gcs_cat*/

/*test for collinearity*/
/*first approach - proc corr*/
/*second approach*/
/*One way to look at it in logistic in SAS is to "fool" the computer into thinking you 
are doing regular regression, */
/*and use the /collin VIF TOL option.  Since collinearity is a relationship among the independent variables, */
/*it's irrelevant that PROC REG is inappropriate for your dependent variable*/


/*question 3*/
/*Assess model GOF*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/aggregate scale=none LACKFIT;
run;
/*pearson and Hosmer and lemeshow gof test both indicate no deviance from fit*/
/*Number of unique profiles: 1036 which is smaller than the number of observations 2789*/
/*thus either test is ok*/

/*question 4 model diagnosis*/

/*Description for macro logitreg_detail(data,event,y,c,x,aggregate,covpattern)*/
/*Use to perform logistic regression and check GOF of model, outliers, and other model diagnostics*/
/*(based on covariate patterns or individuals). */
/*data = dataset to run analysis on*/
/*event = value for positive event (i.e. if y is coded 0/1, enter 1 y = outcome variable*/
/*c = list of categorical variables in model*/
/*x = list of continuous variables and interaction terms in model aggregate = aggregate data into covariate patterns? 1 = Yes covpattern = run analysis using covariate pattern data? 1 = Yes*/
/*To use covpattern = 1, data must already be in event/trial format or use aggregate = 1 */
/*Aggregate = Covpattern = 0 to run on individual data points*/
/*Note: Interaction terms must be created prior to running, cannot use X1*X2 */

%macro logitreg_detail(data,event,y,c,x,aggregate,covpattern);
%if &aggregate = 1 %then %do; 
%let sep1 = %str( ); 
%let cx = %sysfunc(catx(&sep1.,&c.,&x.)); 
%let numwords = %sysfunc(countw(&cx.,,s)); 
%let sep2 = %str(,);
%do i = 1 %to &numwords; 
%if &i = 1 %then %let xvars = %sysfunc(scan(&cx.,&i.,,s)); 
%else %do; 
%let x = %sysfunc(scan(&cx.,&i.,,s)); 
%let xvars = %sysfunc(catx(&sep2.,&xvars.,&x.));
%let xvars = %sysfunc(strip(&xvars.)); 
%end;
%end;
proc sql;
create table event_trial as select distinct &xvars., sum(%sysfunc(strip(&y.))) as events, 
count(%sysfunc(strip(&y.))) as trials from %sysfunc(strip(&data.)) group by &xvars.;
quit;
%end; 
%else %do; 
%let sep1 = %str( ); 
%let cx = %sysfunc(catx(&sep1.,&c.,&x.)); 
data event_trial; 
set &data.;
run; %end;
%if &covpattern = 1 %then %do; 
proc logistic data = event_trial; 
class &c / param = ref ref = first;
model events/trials = &cx / lackfit expb covb clparm = wald outroc = roc1; 
output out = final_model predicted = pred reschi = pear_resid resdev = dev_resid c = dfbeta difchisq = difchisq difdev = difdev h = leverage;
run;
%end; 
%else %do;
proc logistic data = event_trial;
class &c / param = ref ref = first; 
model &y(event = "&event.") = &cx / lackfit expb covb clparm = wald outroc = roc1;
output out = final_model predicted = pred reschi = pear_resid resdev = dev_resid c = dfbeta difchisq = difchisq difdev = difdev h = leverage;
run; 
%end;
data final_model; 
set final_model; 
label leverage = "Leverage" difchisq = "Delta Chi-Square" dfbeta = "Delta Beta";
run;
proc univariate data=final_model normal plots; 
var pear_resid;
id pear_resid; 
title "Univariate analysis of Pearson residuals of &y";
run;
*Create plots of predicted values against influence stats; 
proc sgscatter data = final_model;
plot leverage*pred dfbeta*pred difchisq*pred difdev*pred; 
title " Influence Plots for Model Fit Analysis";
run; 
proc sgplot data = final_model;
bubble y = difchisq x = pred size = dfbeta; 
title "Bubble plot of Delta ChiSq vs. Predicted Value sized by Delta Beta";
run;
proc sort data = final_model out = difchi; 
by descending difchisq;
run;
proc sort data = final_model out = dfbeta; 
by descending dfbeta;
run;
proc print data = difchi (obs = 10); 
title "10 largest Delta Chi Square Observations";
run;
proc print data = dfbeta (obs = 10); 
title "10 largest Delta Beta Observations";
run;
*Create sensitivity vs. specificity plot based on prob cutpoint for prediction model; data roc2;
set roc1;
sens = _SENSIT_; 
spec = 1 - _1MSPEC_;
run; 
proc sgplot data = roc2;
scatter y = sens x = _prob_; 
scatter y = spec x = _prob_; 
title "Sensitivity vs. Specificity based on cutpoint";
run; 
data roc3;
set roc2; 
diff = abs(sens - spec);
run; 
proc sql; 
create table mindiff as select * from roc3 having diff = min(diff); 
quit;
proc print data = mindiff; 
var _PROB_ sens spec; title "Optimal probability cutoff for Sensitivity and Specificity";
run;
proc datasets library = work nolist; 
delete event_trial roc1 difchi dfbeta;
run;quit;
%mend logitreg_detail;
%logitreg_detail(mydata_est,1,died, sbp_cat_new rr_cat male gcs_cat,age_1 ,1,1);
/*need to know how to create interacton terms for this macro*/
/*since we need to create interaction terms first and then put it in the X*/

/*Find out what observations are making the covariate patterns standing out: */
%logitreg_detail(mydata_est,1,died, sbp_cat_new rr_cat male gcs_cat,age_1 ,0,0);
/*let's remove those subjects with Delta chi-square above 40 or 
those with Delta beta above .10 to see how the coefficient estimates of the model would change.*/
data diag_1;
set final_model;
if dfbeta le 0.10;
run;
data diag_2;
set final_model;
if difchisq le 40;
run;
/*compare these models*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/aggregate scale=none LACKFIT;
run;
proc logistic data = diag_1 descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/aggregate scale=none LACKFIT;
run;
proc logistic data = diag_2 descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/aggregate scale=none LACKFIT;
run;

/*question 5 and 6*/
proc logistic data = mydata_est descending; 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/cl;
run;

/*question 7 create an ROC curve*/
ods graphics on;
proc logistic data = mydata_est descending plots = (roc); 
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat/cl;
roc;
run;
ods graphics off;  

/*question 8 validate the model*/
data mydata_val;
set mydata;
if val = 1;
run;

/*transform covariates to make them same as those among prediction dataset*/
data mydata_val;
set mydata_val;
gcs_cat=0;
if gcs lt 9 and gcs ge 0 then gcs_cat=2;
if gcs le 12 and gcs ge 9 then gcs_cat=1;
age_1=age**2;
rr_cat=0;
if rr lt 12 and rr ge 0 then rr_cat=1;
if rr gt 20 then rr_cat=2;
if sbp lt 90 then sbp_cat_new=0;
if sbp ge 90 and sbp lt 130 then sbp_cat_new=1;
if sbp ge 130 and sbp lt 160 then sbp_cat_new=2;
if sbp ge 160 then sbp_cat_new = 3;
ods graphics on;
/*get the ROC in the validation dataset*/
proc logistic data=mydata_est descending;
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
model died = age_1 sbp_cat_new rr_cat male gcs_cat / outroc=troc;
score data=mydata_val out=valpred outroc=vroc;
roc; roccontrast;
ods output ROCassociation=AUC_est;
run;
/*get the confidence interval for the ROC in the validation dataset*/
proc logistic data=valpred;
model died (event="1")=;
roc pred=p_1;
roccontrast;
ods output ROCassociation=AUC_val;
run;
/*take a look at the auc_val dataset*/
proc print data=AUC_val;
run;

/*Single graph with overlaid ROC curves for training and validation data*/
data a; 
set troc(in=mydata_est) vroc;
data="valid"; 
if mydata_est then data="train";
run;
proc sgplot data=a aspect=1;
xaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05; 
yaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05;
lineparm x=0 y=0 slope=1 / transparency=.7;
series x=_1mspec_ y=_sensit_ / group=data;
title "Comparison of ROC curves of training and validation samples";
run;
/*test the difference between train model and valid model*/
data AUC_est;
set AUC_est;
if ROCModel="Model";
run;
data AUC_val;
set AUC_val;
if ROCModel="ROC1";
run;
data roctest;
set AUC_est;
AUC_est=area; s_est=stderr;
set AUC_val;
AUC_val=area; s_val=stderr;
Chisq=(AUC_est - AUC_val)**2/(s_est**2 + s_val**2);
Prob=1-probchi(Chisq,1); 
format Prob pvalue6.; 
Test="AUC_est - AUC_val = 0";
output;
stop;
run;
proc print;
id Test;
var AUC_est AUC_val Chisq Prob;
run;
/*get the classification table for the validation sample with prob=0.045004
Create sensitivity and specificity plot based on prob cutpoint for prediction model
*/
proc print data=valpred;
run;
data valpred;
set valpred;
if P_1 gt 0.045004 then P_1_dic=1;
if P_1 le 0.045004 and P_1 ge 0 then P_1_dic=0;
run;
proc sort data=valpred;
by P_1_dic died;
run;
proc freq data=valpred;
table died*P_1_dic;
run;
/*from Row Pct: we have sensitivity = 76.19, and specificity = 79.78 */

/*question 10a add asaps*/
proc logistic data=mydata_est descending;
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
class asaps (ref="1")/ param=ref;
model died = age_1 sbp_cat_new rr_cat male gcs_cat asaps/ outroc=troc_new;
roc; roccontrast;
ods output ROCassociation=AUC_est_new;
run;
/*test the GOF for this model*/
proc logistic data=mydata_est descending;
class gcs_cat (ref = "0") / param = ref; 
class rr_cat (ref = "0") / param = ref; 
class sbp_cat_new (ref = "1") / param = ref; 
class asaps (ref="1")/ param=ref;
model died = age_1 sbp_cat_new rr_cat male gcs_cat asaps/aggregate scale=none LACKFIT;
run;
/*compare the deviance for two prediction models - LRT*/
   data lrt_pval;
    	LRT = abs(772.567-946.72);
    	df  = 13-9;
    	p_value = 1 - probchi(LRT,df);
		format p_value pvalue6.; 
		proc print;
    	run;	

/*question 10b draw roc for two prediction models*/
data zero;
input models $ _1mspec_ _sensit_;
datalines;
pred 0 0
pred_new 0 0
;
data twoplots;
set zero troc (in=inpred) troc_new (in=inpred_new);
if inpred then models="pred"; 
if inpred_new then models="pred_new";
output;
run;
proc sgplot data=twoplots aspect=1;
xaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05; 
yaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05;
lineparm x=0 y=0 slope=1 / transparency=.7;
series x=_1mspec_ y=_sensit_ / group=models;
title "Comparison of ROC curves of two prediction models";
run;
/*chi-square test to compare these two prediction models*/
data roctest;
set AUC_est;
AUC_est=area; s_est=stderr;
set AUC_est_new;
AUC_est_new=area; s_est_new=stderr;
Chisq=(AUC_est - AUC_est_new)**2/(s_est**2 + s_est_new**2);
Prob=1-probchi(Chisq,1); 
format Prob pvalue6.; 
Test="AUC_pred - AUC_pred_new = 0";
output;
stop;
run;
proc print;
id Test;
var AUC_est AUC_est_new Chisq Prob;
run;

***********************************************************************
************************END*******************************************
***********************************************************************
***********************************************************************
