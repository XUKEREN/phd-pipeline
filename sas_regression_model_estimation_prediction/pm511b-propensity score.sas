/*pm511b - propensity score - lecture 13*/

/*set system, read macro*/
options ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=('C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro');

/*a propensity score is the conditional probability that a subject receives treatment
given that subject's observed covariates. 
the goal of propensity score is to mimic what happens in the RCT by balancing observed
covariates between subjects in controls and treatment groups*/


/*load glow data*/
/*saveold hsb_old.dta, version(12) replace*/
proc import datafile="C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\19spring-pm511b\glow_bonemed" 
out=mydata dbms = dta replace;
run;
proc contents data = mydata;
run;
/*create treatment group*/
proc freq data = mydata;
table BONEMED*BONEMED_FU;
run;
data mydata;
set mydata;
bonetreat = 0;
if BONEMED = 1 and BONEMED_FU = 1 then bonetreat =1;
run;
proc freq data = mydata;
table bonetreat;
run;
/*identify potential confounders for the association between BONETREAT-FRACTURE*/
proc logistic data = mydata descending; 
class bonetreat (ref = "0") / param = ref; 
model FRACTURE = bonetreat  / cl;
run;
/*if it is not multiple categorical variable*/
%macro speed(confounder);
proc logistic data = mydata descending; 
class bonetreat (ref = "0") / param = ref; 
model FRACTURE = bonetreat &confounder. / cl;  
run;
%mend;
%speed(AGE);
%speed(PRIORFRAC);
%speed(WEIGHT);
%speed(HEIGHT);
%speed(BMI);
%speed(PREMENO);
%speed(MOMFRAC);
%speed(ARMASSIST);
%speed(SMOKE);

/*Fit logistic regression model to estimate propensity scores: 
Outcome = BONETREAT, covariates = PRIORFRAC, AGE, HEIGHT, BMI*/
/*Distributions of covariates and linearity*/
proc freq data = mydata;
table BONETREAT*PRIORFRAC;
run;
/*check for linearity*/
%include "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro\logit_linearity.sas";
%logit_linearity(mydata,1,BONETREAT,age, c =  , x =  )
%logit_linearity(mydata,1,BONETREAT,HEIGHT, c =  , x =  )
%logit_linearity(mydata,1,BONETREAT,BMI, c =  , x =  )

run;
/*likelihood ratio test*/
   data lrt_pval;
    	LRT = abs(531.886-529.132);
    	df  = 31;
    	p_value = 1 - probchi(LRT,df);
		proc print;
    	run;	
/*linear term is the best model for age, but the graph showing violation of linearity*/
/*still tansfer age?? */
proc means data = mydata;
var age;
run;

data mydata;
set mydata;
agec=age-68.562;
agec_2 = agec**2;
run;

proc logistic data = mydata descending; 
model BONETREAT = agec agec_2/ cl;  
run;
/*age_2 is significant in the model*/

/*run full model*/
proc logistic data = mydata descending; 
class PRIORFRAC (ref = "0") / param = ref; 
model BONETREAT = PRIORFRAC agec agec_2 HEIGHT BMI/ cl;  
run;

/*create propensity score using proc logistic */
proc logistic data = mydata descending; 
class PRIORFRAC (ref = "0") / param = ref; 
model BONETREAT = PRIORFRAC agec agec_2 HEIGHT BMI/link=glogit rsquare;
output out = psdataset pred = ps xbeta= logit_ps;
run; 
/*PS = predicted event probability of receiving treatment based on specified factors*/

/*get the distribution of p scores*/
proc univariate data=psdataset plot;
title 'Histograms of Propensity Scores by Treatment Group'; 
var ps; 
class BONETREAT;
histogram ps / ctext=purple cfill=blue 
kernel (k=normal color=green w=3 l=1) 
normal (color = red w=3 l= 2) 
ncols=1 nrows=2;
inset n='N' (comma6.0) mean='Mean' (6.2) 
median='Median' (6.2) mode='Mode'(6.2) 
normal kernel(type) / position=NW;
run;

/*Identify observations that fall outside areas of common support*/
proc sort data = psdataset;
by BONETREAT;
run;
proc means min max data = psdataset;
var ps;
by BONETREAT;
run;
proc univariate data = psdataset;
var ps;
by BONETREAT;
run;


data psdataset;
set psdataset;
out = 0;
if BONETREAT = 1 and ps > 0.6773 then out =1; /*the second largest score in group =0*/
if BONETREAT = 0 and ps < 0.0457 then out =1; /*the smallest score in group =1*/
run;

data psdataset_new;
set psdataset;
if out = 0;
run;

/*After identifying and eliminating subjects based on ????^(X), */
/*re-run the propensity score model on the reduced dataset and re-estimate propensity scores.*/
proc logistic data = psdataset_new descending; 
class PRIORFRAC (ref = "0") / param = ref; 
model BONETREAT = PRIORFRAC agec agec_2 HEIGHT BMI/link=glogit rsquare;
output out = psdataset2 pred = ps xbeta=logit_ps;
run;
/*goodness of fit of the data and ROC */
proc logistic data = psdataset_new descending; 
class PRIORFRAC (ref = "0") / param = ref; 
model BONETREAT = PRIORFRAC agec agec_2 HEIGHT BMI/aggregate scale=none LACKFIT;
roc;
run;


/*methods 1 regression adjustment*/

/*incorporating
propensity scores – assume logistic regression modeling of binary outcome variable here*/
/*although the methods are applicable to any outcome model*/

/*As a continuous covariate, must evaluate the linearity of ????^ and transform if needed*/
proc logistic data = psdataset_new descending; 
class BONETREAT (ref = "0") / param = ref; 
model fracture = BONETREAT/cl;
run;

%logit_linearity(psdataset_new,1,fracture,ps, c = BONETREAT , x =  )
/*linearity of the propensity score looks great!!*/
proc logistic data = psdataset_new descending; 
class BONETREAT (ref = "0") / param = ref; 
model fracture = BONETREAT ps/cl;
run;

/*method 2 - stratifying by p score*/

proc rank data = psdataset_new groups=5 out = rank_ds; 
ranks rank; 
var ps;
run;
proc sort data = rank_ds;
by rank;
run;
proc means data = rank_ds min max;
var ps;
by rank;
run;

/*check for covariate balance in each quintile*/
proc ttest data=rank_ds;
class BONETREAT; 
var age height bmi;
by rank;
run;

proc freq data = rank_ds;
table priorfrac*BONETREAT/ chisq;
by rank;
run;

/*Fit a treatment-outcome logit model for each stratum (j)*/
proc logistic data = rank_ds descending; 
class BONETREAT (ref = "0") / param = ref; 
model fracture = BONETREAT/cl;
by rank;
run;
/*get pooled estimated OR*/
data a;
beta1=1.160;
beta2=0.847;
beta3=0.568;
beta4=-0.209;
beta5=0.325;
ln_OR = (beta1+beta2+beta3+beta4+beta5)/5;
pooled_OR=exp(ln_OR);
se1=0.709;
se2=0.699;
se3=0.507;
se4=0.498;
se5=0.457;
se_ln_OR = ((se1**2+se2**2+se3**2+se4**2+se5**2)/25)**(1/2);
lower_ci=exp(ln_OR-1.96*se_ln_OR);
upper_ci=exp(ln_OR+1.96*se_ln_OR);
proc print;
run;

/*Alternative quintile analysis: fit a full model with interaction terms (stratum-by-treatment)*/
proc logistic data = rank_ds descending; 
class BONETREAT (ref = "0") / param = ref; 
class rank (ref = "0") / param = ref; 
model fracture = BONETREAT rank BONETREAT*rank/cl;
run;
/* bsaed on the type 3 test, interaction term is not significant*/
/*use main effect model*/
proc logistic data = rank_ds descending; 
class BONETREAT (ref = "0") / param = ref; 
class rank (ref = "0") / param = ref; 
model fracture = BONETREAT rank/cl;
run;

