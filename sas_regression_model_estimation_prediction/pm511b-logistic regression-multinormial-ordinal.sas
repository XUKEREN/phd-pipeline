/*R square does not convey the same information as the logistic regression simple*/

/*pm511b - hw5*/
/* prepare dataset*/
data hw5; 
input therapy $11. gender $ response & $19. counts; 
cards;
sequential male progressive  28
sequential female progressive  4
alternating male progressive  41
alternating female progressive  12
sequential male no_change  45
sequential female no_change  12
alternating male no_change  44
alternating female no_change  7
sequential male partial  29 
sequential female partial  5 
alternating male partial  20 
alternating female partial  3 
sequential male complete  26 
sequential female complete  2
alternating male complete  20
alternating female complete  1
;
run;

proc contents data=hw5;
run;
proc print data=hw5;
run;

data hw5 (drop=i);
set hw5;
do i = 1 to counts;
output;
end;
run;
proc print data=hw5;
run;

/*question 1 unordered logistic regression*/
ods graphics on;
proc logistic data = hw5 plots=all; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response (ref = 'no_change')/ param = ref; 
model response = therapy gender;
run;
ods graphics off;

proc logistic data = hw5;
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response (ref = 'no_change')/ param = ref; 
model response = therapy gender / link = glogit ;
output out = final_model predicted = pred reschi = pear_resid 
resdev = dev_resid c = dfbeta difchisq = difchisq difdev = difdev h = leverage;
run; 
proc print data = final_model;
run;

/*example 1: test that all beta coefficients 
associated with a particular outcome = 0*/


/*example 2: test that regression coefficients are equal across outcomes*/


/*example 3: test that the coefficients for a specific independent variable
are equivalent across outcomes*/

/*predicted probabilities from the model*/
/*use the fitted model to obtain predicted probabilities for each of the outcomes
for given covariate patterns*/


/*use both equal and unequal or just change a reference group? */

proc logistic data = hw5; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response (ref = 'no_change')/ param = ref; 
model response = therapy gender / link = glogit unequalslopes;
gendertest: test gendermale_complete=gendermale_partial;
treatmenttest: test therapysequential_complete=therapysequential_partial;
gendertreatmenttest: test gendermale_complete=therapysequential_complete=0;
test4 : test therapysequential_progressive =0;
run;


proc logistic data = hw5; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response (ref = 'no_change')/ param = ref; 
model response = therapy gender therapy*gender/ link = glogit;
run;

proc logistic data = hw5; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response (ref = 'no_change')/ param = ref; 
model response = therapy gender therapy*gender/ link = glogit;
oddsratio therapy / at(gender='male');
oddsratio therapy / at(gender='female');
run;



 data lrt_pval;
        LRT = 786.036-783.489;
        df  = 3;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;


/*ordinal logistic regression*/
/*pay attention to the reference group*/
proc logistic data = hw5 order=data; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response(ref='complete');
model response = therapy gender/cl;
run;

proc logistic data = hw5 order=data; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response(ref='complete');
model response = therapy gender therapy*gender/cl;
oddsratio therapy / at(gender='male');
oddsratio therapy / at(gender='female');
run;

 data lrt_pval;
        LRT = 789.057-788.010;
        df  = 1;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;




proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw4\vitals.csv" out=vitals dbms=csv replace;
    getnames=yes;
run;
proc contents data=vitals;
run;
proc print data=vitals;
run;

data vitals;
set vitals;
if sbp LE 120 then sbp_dic=0;
if sbp LE 140 and SBP GT 120 then sbp_dic=1;
if sbp gt 140 then sbp_dic=2;
run;


/*check the log-linear assumption*/
/*sex becomes significant again=> let's keep sex, and the -2loglikelihood (deviance) becomes smaller*/
/*!!! this is my preliminary main effects model !!!*/

/*Model refinement: Check linearity (scale) */

%macro fracpoly_unordered(data,ref,y,primvar,c,x); 
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
		class &y (ref = "&ref.")/ param = ref; 
		model &y = &c &x / link = glogit;
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
		class &y (ref = "&ref.")/ param = ref; 
		model &y  = &c &primvar &x / link = glogit ;
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
				class &y (ref = "&ref.")/ param = ref; 
				model &y  = &c &p1 &x / link = glogit; 
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
				class &y (ref = "&ref.")/ param = ref; 
				model &y  = &c &p1 &x / link = glogit;
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
					class &y (ref = "&ref.")/ param = ref; 
					model &y   = &c &p1 x_log*&p2 &x / link = glogit;
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
					class &y (ref = "&ref.")/ param = ref; 
					model &y   = &c &p1 &p2 &x / link = glogit;
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

%mend fracpoly_unordered;

/*use all the original form for the continuous variable instead of the centered one
centered variable can be 0, so log of centered variable could be missing
*/
%fracpoly_unordered(vitals,0,sbp_dic,dbp, c = , x =  )


/*sex becomes significant again=> let's keep sex, and the -2loglikelihood (deviance) becomes smaller*/
/*!!! this is my preliminary main effects model !!!*/

/*Model refinement: Check linearity (scale) */

proc logistic data = hw5 order=data; 
class therapy (ref = 'alternating') / param = ref; 
class gender (ref = 'female') / param = ref; 
class response(ref='complete');
model response = therapy gender/cl;
run;

%macro fracpoly_ordered(data,ref,y,primvar,c,x);
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
	proc logistic data = fracpoly order=data;
		class &c;
		class &y (ref = "&ref." );
		model &y  = &c &x;
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
	proc logistic data = fracpoly order=data;
		class &c;
		class &y (ref = "&ref." );
		model &y  = &c &primvar &x;
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
			proc logistic data = fracpoly order=data;
				class &c;
				class &y (ref = "&ref." );
				model &y  = &c &p1 &x;
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

		proc logistic data = fracpoly order=data;
				class &c;
				class &y (ref = "&ref." );
				model &y  = &c &p1 &x;
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
				proc logistic data = fracpoly order=data;
					class &c;
					class &y (ref = "&ref." );
					model &y   = &c &p1 x_log*&p2 &x;
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
				proc logistic data = fracpoly order=data;
					class &c;
					class &y (ref = "&ref." );
					model &y   = &c &p1 &p2 &x;
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

%mend fracpoly_ordered;

%fracpoly_ordered(vitals,0,sbp_dic,dbp, c =  , x = weight sbp weight*sbp )

proc logistic data = vitals order=data; 
class sbp_dic(ref='0');
model sbp_dic = dbp_1 dbp_2 weight sbp weight*sbp/cl;
run;

proc logistic data = event_trial;
class &c / param = ref ref = first; 
model &y(event = "&event.") = &cx  ;
output out = final_model predicted = pred reschi = pear_resid resdev = dev_resid c = dfbeta difchisq = difchisq difdev = difdev h = leverage;
run; 


data vitals;
set vitals;
dbp_1=dbp**3;
dbp_2=dbp**3*log(dbp);
run;


