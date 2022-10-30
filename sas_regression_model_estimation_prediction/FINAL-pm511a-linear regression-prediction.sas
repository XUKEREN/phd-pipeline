/* name: Keren Xu */
/* data: */
/*EDA - continuous variable */

/*set system, read macro*/
options ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=('C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro');

/*import dataset*/
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
proc freq data=mydata;
table male;
table race;
table wtEndDigit;
table educ;
table smoke;
run;
/*check missing and extreme values for continous variable*/
proc means data = mydata n nmiss p25 p50 p75 qrange min max;
var age htin wtlbs htErr wtErr BPsys bmi bmiRep educ;
run;

/*MISSPRINT*/
/*displays missing value frequencies in frequency or crosstabulation tables */
/*but does not include them in computations of percentages or statistics.*/
/**/
/*MISSING*/
/*treats missing values as a valid nonmissing level for all TABLES variables. */
/*Displays missing levels in frequency and crosstabulation tables and includes them */
/*in computations of percentages and statistics.*/

/*make plot to check if there are extreme values for continuous variables*/
proc sgplot data=mydata; 
vbox age; 
run;
proc univariate data=mydata; 
var age; 
histogram; 
run;

/*if there are obviously abnormal values, such as age smaller than 0, then delete*/
/*see question if there is any description of the sample that is different from the dataset*/
/*people younger than 18 ...*/
/*if the value is extreme or is not apparenet, then still include in the sample, */
/*do not exclude at this early stage. */

/*keep only observations non-missing on variables of interest*/
data mydata; 
set mydata;
if race ne . and BPsys ne . and educ_new ne .;  
run;
proc print data=mydata;run;
proc contents data=mydata;run;

/*consider if there are any variables with any obvious clinical classification*/
/*categorize education*/
data mydata;
set mydata;
educ_new=1;
if educ=. then educ_new=.;
if educ GT 6 and educ LE  12 then educ_new=2;
if educ GT 12 and educ LE 16 then educ_new=3;
if educ GT 16 then educ_new=4;
run;
/*create a new dataset with no missing BPsys*/
data mydata_BPsys;
set mydata;
if BPsys ge 0;
run;
proc contents data=mydata_BPsys;
run;
proc freq data=mydata;
table educ_new;
run;

/*create formats*/
proc format;
	value educ_newf	1 = '1'
		  				2 = '2'
						3='3'
						4='4';

	value racef	1 = '1'
					2 = '2'
					3 = '3';
run;

data mydata;
set mydata;
	format educ_new educ_newf. 
		   race racef.
;
run;
proc contents data=mydata; run;

/*table 1 macro-harvard*/
%table1(
data=mydata, 
/*agegroup=agegrp, */
ageadj=F,
exposure= , 
noexp=T,
varlist= educ_new male race smoke age bmi bmiRep educ, 
/*noadj = ageyr, */
cat=   male  smoke , 
poly= educ_new race,  /*reference group should start from 1*/
rtftitle=subject characteristics by  , 
landscape=F, 
fn=@mets Metabolic equivalents from recreational and leisuretime activities. 
@cpmh Postmenopausal hormone replacement therapy. 
@chld Number of children among parous women., 
file = testf1, 
dec=2,
uselbl=F
);

/*table 1 macro-stanford*/
%include "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro\table1_stanford.sas";
%let yourdata=nhanes2000_326_BPsys;
%let output_data=test_summary; 
%let formatsfolder=;
%let yourfolder=; 
%let decimal_max=2;
%let varlist_cat = educ_new male race smoke; 
%let varlist_cont = age bmi bmiRep educ;
%let output_order = educ_new male race smoke age bmi bmiRep educ; 
%let group_by= ;
%let group_by_missing= 0; 
%Table_summary;


/*pairwise association*/
/*continuous variables with continuous variables*/
/*Spearman correlation and Pearson correlation*/
/*check the normality for continuous variables in the entire cohort*/
proc univariate data=mydata plot normal; 
var age htin wtlbs htErr wtErr;
run;

/*if normal, then use pearson*/
/*if N is large, pearson still ok even if not normal*/
proc corr data=mydata plots=matrix; 
var chol tg; 
with bmi;
run;

/*continuous variables with categorical variables*/
/*test the normality by categories*/
proc univariate data=mydata plot normal; 
var htErr wtErr;
class male;
run;
/*if normal, then use Two-sample t-test*/
/*boxplot to see distribution of continuous variable*/
proc ttest data=mydata;
class mi_chd; 
var lasttime totchol bmi age sysbp;
run;
/*if normal, then use one-way anova*/
proc glm data=mydata; class race; 
model BPsys = race / solution; 
means race / lsd bon tukey scheffe alpha=0.05; 
title 'F-test and pairwise comparisons';
run;
/*If the sample sizes are equal, or close to equal, across groups, use Tukey’s test*/
/*If sample sizes are quite different, or if you want to perform more complex comparisons of means, 
use Scheffe’s test*/

/*check categorical data*/
proc freq data = mydata;
table sex*mi_chd/chisq;
table educ*mi_chd/chisq;
table cursmoke*mi_chd/chisq;
table diabetes*mi_chd/chisq;
run;
/*if cell is small, use fisher to replace chisq*/

/*calculate sample size*/
data mydata2;
set mydata;
if educ ne .;
if race ne .;
if BPsys ne .;
run;
proc contents data=mydata2;
run;


/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*in order to use proc reg, have to make dummy variables for categorical variables*/
/*create dummy variables for categorical variables*/
data mydata;
set mydata;
if race=1 then do; white=1;black=0;end;
if race=2 then do; black=1;white=0;end;
if race=3 then do; white=0; black=0;end;
if educ_new=0 then do; educdic=0;end;
if educ_new=1 then do; educdic=0;end;
if educ_new gt 1 then do educdic=1;end;
/*second way*/
/*poor is the reference group*/
LQ_excl = 0;
if LifeQual="Excellen" then LQ_excl = 1;
LQ_good = 0;
if LifeQual="Good" then LQ_good = 1;
LQ_fair = 0;
if LifeQual="Fair" then LQ_fair = 1;
run;

/*Before I begain modeling, I ploted the data first. By examining these initial plots, */
/*I can quickly assess whether the data have linear relationships or interactions are present.*/
/*outcome is BPsys*/
/*pay attention to check if the outcome can be negative or not -
if it can - then add a certain constant to make it positive then transform it*/
/*plot the outcome against the main effect of interest*/
data mydata; 
set mydata; 
sqrtBPsys = sqrt(BPsys); 
logBPsys = log(BPsys); 
run;
proc gplot data=mydata; symbol1 v=star i=rl; *adds a linear regression line;
plot BPsys*BMI = 1; 
title 'Scatterplot of BPsys vs. variables';
run;
proc gplot data=mydata; symbol1 v=star i=rl; *adds a linear regression line;
plot (sqrtBPsys logBPsys)*BMI = 1; *trick to make 2 plots at once; 
title 'Scatterplot of log and sqrt distance vs. mph';
run;
/*plot the outcome against main effect of interest stratified by the potential modifiers*/
proc sgplot data=mydata;
scatter x=BMI y=BPsys / group=male transparency=0.5 ; 
reg x=BMI y=BPsys / group=male;
run;


/*create prediction model*/

/* optional steps: univariate linear regression analysis*/
/*if we use proc glm we do not have to create dummy variable now or interaction variables*/
/*we do not need to do pairwise association analysis if we already used univariate regression*/
proc mixed data=mydata;
model BPsys = age / solution ;
run;
proc mixed data=mydata;
class sex(ref="0");
model BPsys = sex / solution ;
run;
proc mixed data=mydata;
class educ_new(ref="1");
model BPsys = educ_new / solution ;
run;
proc mixed data=mydata;
class race(ref="1");
model BPsys = race / solution ;
run;
proc mixed data=mydata;
class smoke(ref="0");
model BPsys = smoke / solution ;
run;

proc reg data= mydata;
Model logBPsys=smoke/clb;
Output out=modeleval r=resid p=pred;
Run;
proc univariate data=modeleval plot normal;
Var resid;
Run;
proc sgplot data=modeleval;
Scatter x=pred y=resid;
Loess x=pred y=resid/smooth=.4;
refline 0;
Run;

/*rescale X variables*/
/*center all the continuous variables by mean*/
/*compute means for variables for centering*/
data mydata; 
set mydata;
tempid = 1; 
run;
proc means data=mydata; 
by tempid; * -- all subjects have tempid=1;                                                                          
var age bmi bmiRep;                                                                                                                 
output out=sumstats mean=meanage meanbmi meanbmiRep;                                                                                                                                                                                               
data mydata2; merge sumstats mydata; by tempid;                                                                                                 
age = age-meanage;                                                                                                                      
bmi = bmi - meanbmi; 
bmiRep=bmiRep-meanbmiRep; 
/*age2 = age*age;  * -- create quadratic terms for age, ht, and bmi;                                                                        */
/*bmi2= bmi*bmi;*/
run;
data mydata2;
set mydata2;
drop _FREQ_ _TYPE_;
run;

/*consider to spline continous variables if the assumption is violated*/
/*spline codes*/
/*Model 2M: µ(FEV) = beta0 + beta1AGEPFT+ beta2(AGEPFT-12.5)+ + beta3(AGEPFT-15.5)+*/
/*SAS code to create the two spline variables: */
DATA datm; set spline.datm; 
If AGEPFT ne . then do;
if AGEPFT > 12.5 then AGEPFTsp1 = AGEPFT-12.5; 
else AGEPFTsp1 = 0;
if AGEPFT > 15.5 then AGEPFTsp2 = AGEPFT-15.5; 
else AGEPFTsp2 = 0;
end; 
RUN;
/*SAS code to fit the model: */
PROC REG DATA=datm; 
MODEL FEV=AGEPFT AGEPFTsp1 AGEPFTsp2 /clb; 
RUN;
/*consider to further categorize the x varriable if the assumption is violated*/
/*create variables for quartiles*/
proc rank data=subjdata_326 out=out1 groups=4;
var WEIGHT;
ranks WEIGHT_RANK;
run;


/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/
/*****************************************************************/

/*create a maximum set of covariates in the model*/
/*prepare for model prediction*/
/*create dummy variables for race*/
data  mydata;
set library.nhanes2000_326;;
if race=1 then do; white=1;black=0;end;
if race=2 then do; black=1;white=0;end;
if race=3 then do; white=0; black=0;end;
run;
/*keep only observations with nonmissing value*/
data mydata; set mydata;
if race ne .;  
run;
/*compute means for variables for centering*/
data mydata; set mydata;
tempid = 1; 
run;
proc means data=mydata; 
by tempid; * -- all subjects have tempid=1;                                                                          
var age htin wtlbs bmi;                                                                                                                 
output out=sumstats mean=meanage meanhtin meanwtlbs meanbmi;                                                                                                                                                                                               
data mydata2; merge sumstats mydata; by tempid;                                                                                                 
age = age-meanage;                                                                                                                      
htin = htin - meanhtin;                                                                                                                       
wtlbs = wtlbs - meanwtlbs;                                                                                                                       
bmi = bmi - meanbmi;                                                                                                                    
age2 = age*age;  * -- create quadratic terms for age, ht, and bmi;                                                                        
htin2 = htin*htin; 
wtlbs2=wtlbs*wtlbs; 
bmi2= bmi*bmi;
run;
data mydata2;
set mydata2;
drop _FREQ_ _TYPE_;
run;

data mydata;
set mydata2;
malehtin=male*htin;
malewtlbs=male*wtlbs;
agehtin=age*htin;
agewtlbs=age*wtlbs;
htErrnew=sign(htErr)*abs(htErr)**(1/3);
run;



/*create interaction terms and higher order terms*/
data myadata;
set mydata;
age2=age*age;
bmi2=bmi*bmi;
bmismoke=bmi*smoke;
bmimale=bmi*male;
bmieducdic=bmi*educdic;
bmiRepeducdic=bmiRep*educdic;
run;

/*preliminary test for collinearity using proc corr*/
ods graphics on;
proc corr data=mydata plots=matrix(histogram);
var age htin wtlbs bmi age2 htin2 wtlbs2 bmi2;
run;
ods graphics off;
/*if there are variables highly correlated (the p-value shows significance), 
then consider to only include one in the model, or temporarily keep in the model at this early stage*/

/*prediction model*/

/*choose a maximum set of main effect model*/

/*transfer age, bmi, height, weight*/

/*center continuous variables*/

/*consider collinearity*/

/*consider all the potential interacton*/

/*check LINE for the maximum model
I will often evaluate assumptions on the maximum model (all candidate Xvariables) 
to make major modeling decisions (e.g., transformations of Y) at the beginning of the analysis. 
Once I’ve used a model selection procedure to identify a candidate final model, 
I will check assumptions again.*/


/*stepwise selection*/
proc glmselect data=mydata; 
class male; 
class race;
model htErrnew = age htin wtlbs male race 
age*age htin*htin wtlbs*wtlbs 
male*htin male*wtlbs age*htin age*wtlbs / selection = stepwise 
details = all hierarchy = single sle=0.15 sls=0.15 showpvalues select=sl stop=sl; 
title "Stepwise selection for FEV1";
run;
/*conditional model selection*/
proc reg data=mydata; 
model fev = asian black hispanic other age ht wt bmi age2 ht2 bmi2 female asthma ets wheeze / 
selection = stepwise sle=0.15 sls=0.15 include=4;
* -- 'include' forces the first p variables into the model (here p=4); 
title 'Stepwise regression forcing RACE into the model';
run;

/*pay attention to see if there is interaction term without lower effect
if the whole set of the indicator variables is here. 
if the lower order term is here for the higher order term*/

/*get the candidate final model*/

/*assess the LINE for the multivariate main effect linear regression*/
ods graphics on;
proc reg data= mydata;
Model htErrnew=age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin/clb vif tol;
Output out=modeleval r=resid p=pred;
Run;
quit;
ods graphics off;/*Futher explore the relationships between Y and each X, 
to discover ways to improve the model. e.g. look at the residuals vs each X*/

/*check normaity*/
proc univariate data=modeleval plot normal;
	var resid;
	title 'Check normality of residuals';
run;

/*Check linearity & equal variance*/
proc sgplot data=modeleval;
  scatter x=pred y=resid; *usual scatterplot of resid vs. pred;
  loess x=pred y=resid /clm smooth=.4;  *loess smooth of this rel'n;
  refline 0;              *add a reference line at y=0;
  title 'Evaluate linearity assumption with Loess smooth';
run;

/*transfer log if the assumption is not met*/
/*log Y or sqrt Y*/
/*if Y can be negative, then cannot use log transfer or sqrt transfer*/
data mydata2;
set mydata2;
logBPsys=log(BPsys);
run;
proc reg data=mydata2;
model logBPsys=age bmi age2 bmi2 male black white smoke educdic bmismoke bmimale bmieducdic/clb;
run;

/*assess the collinearity*/
/*CHECK COLLINEARITY AGAIN*/
proc reg data= mydata;
Model htErrnew=age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin/tol vif;
Run;
/*tolerance < 0.1 indicates substantial collinearity. with lower tolerance values indicating increasing collinearity
tolerance = 0 for an x variable means it is perfectly predicted by the set of remaining x variables
variance inflation factor = 1/tolerance. rule of thumb: VIF > 10 indicates substantial collinearity*/
/*interpretation: 
The pollutants PM10 and PM2.5 are highly correlated with each other (R=0.96). 
This high correlation indicates that they are substantially collinear, 
and thus regression analyses that include both in the same model should be interpreted with caution*/
/*
Final thoughts: what should you do when you see collinearity?
Examples: ? If including age and age2 as predictors, it is a good idea to center age on its mean ( ageC = age-mean(age) ) and then include ageC, ageC2 in the model for reduced collinearity
? If including weight and BMI as predictors and they are highly collinear, you should chose only one to include in the model
o If they are highly collinear, they provide essentially the same information and little is lost by including only one
o One strategy for picking – which one is easier/cheaper to obtain, less likely to have measurement error, or has less missing data?
*/
/*using log(Y) or sqrt(Y) might fix the problem*/
/*we could also test the residual vs each x. */
/*consider adding quadratic, cubic, etc terms for x*/
/*or adding a linear spline term for x*/
/*for instance, increasing spread with increasing X is often fixed by using log(Y) - (lecture 5)*/

/*normality is not a major concern for large sample size*/

/*now we get the final predictive model*/
proc reg data= mydata2;
Model logBPsys=age bmi age2 male black white educdic bmismoke bmieducdic/tol vif;
Run;

/*Model diagnosis*/
/*o	Outliers: any rare or unusual observation that appears at one of the extremes of the data range
(e.g. extreme in X or extreme in Y)*/
/*o	Leverage: hi, measures the extremeness of an observation with respect to the independent variables
leverage for the particular data point depends on the distance of its X-value from the corresponding
mean of all X values (i.e. X_hat)
rule of thumb: observations with hi>2(k+1)/n are worth investigation, where k is the number of Xs in the model
The farther an X value is from the mean of the Xs, the more leverage it has, and thus the more potential influence 
it has on the fit of the regression line. 
*/
/*o	Influential points: a particular data point is influential if, by itself, it has a substantial impact 
on the parameter estimates (intercept, slopes) in a model. This typically happens when the observation is 
both extreme in X (has leverage) AND is unusual in the pattern of Y|X*/
/*o	Advanced residual analysis*/
/*consider 3 statistics which quantify the amount of influence an observation has on the estimated
regression slopes or predicted value of Y
- Cook's distance: a general measure of how much the regression estimates (intercept, slopes) change with the 
deletion of each observation.
like the jackknife residual, di will be large if either the leverage or studentized residual is large
rule of thumb: an observation with di>1 may be worth investigating
- DFBETAS: if we delete ith observation, and refit the regresion model, how do each of the regression coefficient 
estimates change? 
rule of thumb: observations that lead to absolute values of dfbetas>2/sqrt(n) are influential in estimating the slope
similar calculation can be done for the change in the intercept
- DFFITS: if we delete the ith observation, and refit the regression model, how does the predicted value for the ith
individual change? 
rule of thumb: an observation with absolute value DFFITS >2sqrt(k/n) is influential*/


/*https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_reg_sect040.htm*/
/*https://stats.idre.ucla.edu/sas/library/sas-libraryoverview-of-sas-proc-reg/*/
/*check residuals*/
ods graphics on;
proc reg data=mydata;
model htErrnew=age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin/r influence spec spec tol vif;
output out=resid r=resid student=stud_r rstudent=jackknife p=pred H=h_ii DFFITS=dffits_i cookd=D_i;
run;
quit;
ods graphics off;

/*take a rough look at different parameters*/
/*take a look at COOK'D first*/
ods graphics on;
proc reg data=mydata 
      plots(label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
   id id;
   model  htErrnew=age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin;
run;
ods graphics off; 

/*take a look at JACKKNIFE*/
proc univariate data=resid;
var jackknife;
id jackknife;
run;
/*note that here obs shows the order of the row not the ID number!!!!*/

/*see pattern of parameters aginst predicted values*/
proc gplot data=resid; 
symbol1 v=star; 
plot (resid stud_r jackknife)*pred /vref=0; 
title 'Plots of various residuals against predicted';
run;
/*check for the outlier ID*/
proc sgplot data = resid;
scatter x = resid y=pred / markerchar=id; 
run;
proc sgplot data = resid;
scatter x = stud_r y=pred / markerchar=id; 
run;
proc sgplot data = resid;
scatter x = jackknife y=pred / markerchar=id; 
run;

/*print out outliers */
proc print data=stdres;
where cookd > 1;
var age weight cholesterol triglycerides hdl ldl height skinfold
systolicbp diastolicbp exercise coffee cholesterolloss;
run;

/*test if these cooks'ds are significantly greater than 0*/
data c;
t = 4.95512;
n = 1978;
df = n-1-2;
p = (1-probt(abs(t),df))*2;
alpha = 0.05/n;
run;

proc print data=c;
run;

data c;
t = 4.69839;
n = 1978;
df = n-1-2;
p = (1-probt(abs(t),df))*2;
alpha = 0.05/n;
run;

proc print data=c;
run;

data c;
t = 4.57309;
n = 1978;
df = n-1-2;
p = (1-probt(abs(t),df))*2;
alpha = 0.05/n;
run;

/*Diagnostics for Mira Loma (observation 8)
? n = 12 
? k = 1
? Leverage = 0.66 > 2(k+1)/n = 2*(1+1)/12 = 0.3333 
Conclusion: ML has large leverage and thus is potentially influential
? Jackknife residual = 2.05 (not too striking, but we will test to see whether larger than expected)
? Cook’s distance = 3.099 > 1 Conclusion: ML is influential in its effect on regression estimates
? (DFBETA) = 2.67 > 2 / n = 0.57
Conclusion: ML has a large influence on the slope estimate (Note: ML also has large influence on the intercept estimate)
? (DFFITS) = 2.86 > 2 k n/ = 0.57
Conclusion: ML is influential in the fit of the regression line 
What information is provided by residual plots?
*/



/*Sensitivity analysis*/
/*to see if we rule out the outliers, how the coefficients will change*/
proc reg data=a; 
where pm10 < 66;  * -- exclude the outlier;    
model growmmef = pm10 / r influence; 
title 'Regression of MMEF growth rate on PM10 without ML';
run;


/*We need to use our brains to make sure the final model 
makes sense and that it will have practical utility as a means of making predictions*/

/*validation of the prediction model*/
/*Validation is an important step to examine the generalizability of a prediction model (
e.g., how well your model will perform in a new study population)*/
/*
- split-sample validation
- external validation*/


/*report the final model -  rememeber to report the intercept!!!*/
/*validation*/
data nhanes500; 
set library.nhanes500;
run;

/*compute means for variables for centering*/
data nhanes500; set nhanes500;
tempid = 1; 
run;
proc means data=nhanes500; 
by tempid; * -- all subjects have tempid=1;                                                                          
var age htin wtlbs bmi;                                                                                                                 
output out=sumstats mean=meanage meanhtin meanwtlbs meanbmi;                                                                                                                                                                                               
data nhanes500_2; merge sumstats nhanes500; by tempid;                                                                                                 
age = age-meanage;                                                                                                                      
htin = htin - meanhtin;                                                                                                                       
wtlbs = wtlbs - meanwtlbs;                                                                                                                       
bmi = bmi - meanbmi;                                                                                                                    
age2 = age*age;  * -- create quadratic terms for age, ht, and bmi;                                                                        
htin2 = htin*htin; 
wtlbs2=wtlbs*wtlbs; 
agehtin=age*htin;
htErrnew=sign(htErr)*abs(htErr)**(1/3);
malewtlbs=male*wtlbs;
agehtin=age*htin;
run;
data nhanes500_2;
set nhanes500_2;
drop _FREQ_ _TYPE_;
run;

* METHOD 1 - PROC SCORE;
proc reg data=mydata outest=trainreg;
	htErrnew_hat: model htErrnew=age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin;
run;
proc score data=nhanes500_2 score=trainreg out=validreg type=parms nostd predict;
	var age male htin wtlbs age2 htin2 wtlbs2 malewtlbs agehtin;
run;

proc print data=validreg (obs=10);
	var id htErrnew_hat;
	title 'Predicted htErrnew for holdout dataset ';
run;

proc corr data=validreg outp=CORRholdout;
	var htErrnew htErrnew_hat;
	title 'R2 for validation dataset';
run;
* create dataset containing 1 row with Pearsons R value;
data a; set CORRholdout;
	if _TYPE_='CORR' AND _NAME_='htErrnew'; * -- keep only observation 5; 
	rename htErrnew_hat = PearsonR;
run;
* calculate R2;
data a; set a;
	keep PearsonR R2;
	R2=PearsonR**2;
proc print data=a;
run;

