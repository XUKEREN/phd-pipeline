/*set system, read macro*/
options ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=('C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro');

/*import dataset*/
/*set library*/
libname library 'C:\Users\xuker\Downloads\@USC\18fall-PM511A- Data Analysis\final project-pm511';
run; 
/*take a look at the dataset*/
proc print data=library.nhanes2000_326; run;
proc contents data=library.nhanes2000_326; run;

/*categorize education*/
data nhanes2000_326;
set library.nhanes2000_326;
educ_new=0;
if educ=. then educ_new=.;
if educ GT 6 and educ LE  12 then educ_new=1;
if educ GT 12 and educ LE 16 then educ_new=2;
if educ GT 16 then educ_new=3;
run;
/*create a new dataset with no missing BPsys*/
data nhanes2000_326_BPsys;
set nhanes2000_326;
if BPsys ge 0;
run;
proc contents data=nhanes2000_326_BPsys;
run;
proc freq data=nhanes2000_326;
table educ_new;
run;

/*table 1 macro-harvard*/
%table1(
data=mydata, 
/*agegroup=agegrp, */
ageadj=F,
exposure=mi_chd, 
varlist= totchol bmi age sysbp sex educ cursmoke diabetes, 
/*noadj = ageyr, */
cat=  cursmoke diabetes, 
poly=educ sex,
mdn = educ,
rtftitle=subject characteristics by mi_chd, 
landscape=F, 
fn=@mets Metabolic equivalents from recreational and leisuretime activities. 
@cpmh Postmenopausal hormone replacement therapy. 
@chld Number of children among parous women., 
file = testf1, 
dec=2,
uselbl=F);
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

/*continuous variables with continuous variables*/
/*Spearman correlation and Pearson correlation*/
/*check the normality for continuous variables in the entire cohort*/
proc univariate data=nhanes2000_326 plot normal; 
var age htin wtlbs htErr wtErr;
run;

/*if normal, then use pearson*/
/*if N is large, pearson still ok even if not normal*/
proc corr data=lib.chol plots=matrix; 
var chol tg; 
with bmi;
run;
/*if not normal, then use Spearman*/
proc corr data=nhanes2000_326 spearman;
var age htin wtlbs;
with htErr wtErr;
run;


/*continuous variables with categorical variables*/
/*test the normality by categories*/
proc univariate data=nhanes2000_326 plot normal; 
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


/*if not normal, then use Wilcoxon rank sum test*/
proc npar1way data=nhanes2000_326 wilcoxon;   
class male;   
var htErr wtErr;   
run; 
/*if not normal, then use non-parametric ANOVA*/
proc npar1way data=nhanes2000_326 wilcoxon;   
class race;   
var htErr wtErr BPsys;   
run; 
/*There is no Kruskal-Wallis multiple comparisons procedure for unraveling pairwise differences. */
/*One approach would be to do a series of Wilcoxon rank sum tests of all possible groups pairs, */
/*with a Bonferroni adjustment to the significant level*/

/*pairwise comparison after non-parametric anova*/
data dataset1;
set nhanes2000_326;
if race ne 1;
run;
proc npar1way data=dataset1 wilcoxon;   
class race;   
var htErr;   
run; 
data dataset1;
set nhanes2000_326;
if race ne 2;
run;
proc npar1way data=dataset1 wilcoxon;   
class race;   
var htErr;   
run; 
data dataset1;
set nhanes2000_326;
if race ne 3;
run;
proc npar1way data=dataset1 wilcoxon;   
class race;   
var htErr;   
run; 

/*check categorical data*/
proc freq data = mydata;
table sex*mi_chd/chisq;
table educ*mi_chd/chisq;
table cursmoke*mi_chd/chisq;
table diabetes*mi_chd/chisq;
run;
/*if cell is small, use fisher to replace chisq*/

/*calculate sample size*/
data dataset2;
set nhanes2000_326;
if educ ne .;
if race ne .;
if BPsys ne .;
run;
proc contents data=dataset2;
run;
