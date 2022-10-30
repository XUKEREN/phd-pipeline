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
poly= educ_new race,
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
proc glm data=a; class group; 
model y = group / solution; 
means group / lsd bon tukey scheffe alpha=0.05; 
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
