/*pm511a lecture 12 zero-inflated count*/

/*a. truncated count data: certain values of the count variable are not possible*/
/*most common is zero truncation*/
/*example: hospital length of stay: all patients stay at least 1 day*/
/*length of stay in ICU*/
/*for such data, we can use truncated Poisson (zero-truncated Poisson) regression model*/

/*b. zeros occur more frequently than would be expected under the Poisson model*/
/*the excess of zeros reflects an underlying mixture distribution (two random) processes occuring*/
/*binomial probability that the variable is present (count over 0) or absent (count = 0)*/
/*poisson probability that count = Y*/
/*example: days absent from school*/
/*students who do not miss school with some probability pi - this is the binomial part of the model*/
/*students who do miss the school, with a Poisson probability parameter u for number of days missed
- this is the Poisson part of the model*/

/*zero-truncated Poisson*/
/*if it is sas file:*/
/*read dataset without format*/
OPTIONS nofmterr;
libname library "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\19spring-pm511b";
PROC print DATA=library.ztp;
RUN;
/*let's look at the data*/
proc means data=library.ztp;
	var stay;
run;
/*look at the distribution by histogram*/
proc univariate data=library.ztp noprint;
	histogram stay / midpoints = 0 to 80 by 2 vscale = count;
run;

proc freq data=library.ztp;
	tables age hmo died;
run;
/*We supply the last two equations to proc nlmixed to model our data using a zero truncated Poisson distribution. */
/*Additionally, proc nlmixed does not support a class statement, */
/*so categorical variables should be dummy-coded before running the analysis.*/
proc nlmixed data = library.ztp;
	log_lambda = intercept + b_age*age + b_died*died + b_hmo*hmo;
	lambda = exp(log_lambda);
	ll = stay*log_lambda - lambda - log(1-exp(-lambda)) - lgamma(stay+1);
	model stay ~ general(ll);
run;
/*interpretation*/
/*The value of the coefficient for age, -.01444, suggests that the log count of stay decreases by .01444 for each year increase in age. This coefficient is statistically significant.*/
/*The coefficient for hmo, -.1359, is significant and indicates that the log count of stay for HMO patient is .1359 less than for non-HMO patients.*/
/*The log count of stay for patients who died while in the hospital was .20377 less than those of patients who did not die.*/
/*Finally, the value of the constant (intercept), 2..4358 is log count of the stay when age = 0, hmo = 0, and died = 0.*/

/*We can also use estimate statments to help understand our model. */
/*For example we can predict the expected number of days spent at the hospital across age groups */
/*for the two hmo statuses for patients who died. */
/*The estimate statement for proc nlmixed works slightly differently from how it works within other procs.  */
/*Here, each parameter must be explicitly multiplied by the value at which is to be held for that estimate statment.  */
/*Additionally, because we would like to predict actual number of days rather than log number of days, */
/*we need to exponentiate the estimate.*/

proc nlmixed data = library.ztp;
	log_lambda = intercept + b_age*age + b_died*died + b_hmo*hmo;
	lambda = exp(log_lambda);
	ll = stay*log_lambda - lambda - log(1-exp(-lambda)) - lgamma(stay+1);
	model stay ~ general(ll);
	estimate 'age 1 died 1 hmo 0' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 0);
	estimate 'age 1 died 1 hmo 1' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 1);
	estimate 'age 3 died 1 hmo 0' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 0);
	estimate 'age 3 died 1 hmo 1' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 1);
    estimate 'age 5 died 1 hmo 0' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 0);
	estimate 'age 5 died 1 hmo 1' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 1);
	estimate 'age 7 died 1 hmo 0' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 0);
	estimate 'age 7 died 1 hmo 1' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 1);
	estimate 'age 9 died 1 hmo 0' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 0);
	estimate 'age 9 died 1 hmo 1' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 1);
run; 

/*It may be illustrative for us to plot the predicted number of days stayed as a function of age and hmo status*/
ods trace on;
proc nlmixed data = library.ztp;
	log_lambda = intercept + b_age*age + b_died*died + b_hmo*hmo;
	lambda = exp(log_lambda);
	ll = stay*log_lambda - lambda - log(1-exp(-lambda)) - lgamma(stay+1);
	model stay ~ general(ll);
	estimate 'age 1 died 1 hmo 0' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 0);
	estimate 'age 1 died 1 hmo 1' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 1);
	estimate 'age 3 died 1 hmo 0' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 0);
	estimate 'age 3 died 1 hmo 1' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 1);
        estimate 'age 5 died 1 hmo 0' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 0);
	estimate 'age 5 died 1 hmo 1' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 1);
	estimate 'age 7 died 1 hmo 0' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 0);
	estimate 'age 7 died 1 hmo 1' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 1);
	estimate 'age 9 died 1 hmo 0' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 0);
	estimate 'age 9 died 1 hmo 1' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 1);
run;
ods trace off;

ods output AdditionalEstimates = library.addest;
proc nlmixed data = library.ztp;
	log_lambda = intercept + b_age*age + b_died*died + b_hmo*hmo;
	lambda = exp(log_lambda);
	ll = stay*log_lambda - lambda - log(1-exp(-lambda)) - lgamma(stay+1);
	model stay ~ general(ll);
	estimate 'age 1 died 1 hmo 0' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 0);
	estimate 'age 1 died 1 hmo 1' exp(intercept * 1 + b_age * 1 + b_died * 1 + b_hmo * 1);
	estimate 'age 3 died 1 hmo 0' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 0);
	estimate 'age 3 died 1 hmo 1' exp(intercept * 1 + b_age * 3 + b_died * 1 + b_hmo * 1);
        estimate 'age 5 died 1 hmo 0' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 0);
	estimate 'age 5 died 1 hmo 1' exp(intercept * 1 + b_age * 5 + b_died * 1 + b_hmo * 1);
	estimate 'age 7 died 1 hmo 0' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 0);
	estimate 'age 7 died 1 hmo 1' exp(intercept * 1 + b_age * 7 + b_died * 1 + b_hmo * 1);
	estimate 'age 9 died 1 hmo 0' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 0);
	estimate 'age 9 died 1 hmo 1' exp(intercept * 1 + b_age * 9 + b_died * 1 + b_hmo * 1);
run;
data library.addest;
	set library.addest;
	input age hmo;
	datalines;
	1 0
	1 1
	3 0
	3 1
	5 0
	5 1
	7 0
	7 1
	9 0
	9 1
	;
run;
proc sgplot data = library.addest;
	title 'Predicted number of days stayed (with 95% CL) by age and hmo status for patients who died';
	band x = age lower = lower upper = upper / group=hmo;
	scatter x= age y = estimate / group = hmo;
	series x = age y = estimate / group = hmo;
run; 

/*Zero-truncated Poisson regression using proc fmm*/
proc fmm data = library.ztp;
	class hmo died;
	model stay = age hmo died / dist = truncpoisson;
run;
