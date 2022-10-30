/*set system, read macro*/
options ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=('C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro');

/*import dataset*/
/*if it is stata file: */
/*convert file to stata version 12*/
/*saveold hsb_old.dta, version(12) replace*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\final project\framingham_2019" 
out=mydata dbms = dta replace;
run;
/*if it is sas file:*/
/*read dataset without format*/
OPTIONS nofmterr;
libname in "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep";
PROC print DATA=in.***;
RUN;

proc contents data=mydata;
run;
proc print data=mydata;
run;

/*create formats*/
proc format;
	value sexf	1= 'Male'
		  		2 = 'Female';
	value educf	1 = '0-11 years'
			2 = 'High school graduate'
			3 = 'Some college'
			4 = 'College degree';
	value cursmokef      0 = 'no'
				1 = 'yes';

    value diabetesf	0 = 'no'
			1 = 'yes';
run;
data mydata;
set mydata;
	format sex sexf. 
		   educ educf.
		   cursmoke cursmokef.
		   diabetes diabetesf.;
run;
proc contents data=mydata; run;

/*table 1 macro-harvard*/
%table1(
data=mydata, 
/*agegroup=agegrp, */
ageadj=F,
exposure=caco, 
varlist=  weight race2 smoke2 age2 , 
/*noadj = ageyr, */
cat=  smoke2, 
poly=race2,
mdn = race2,
rtftitle=subject characteristics by caco, 
landscape=F, 
fn=@mets Metabolic equivalents from recreational and leisuretime activities. 
@cpmh Postmenopausal hormone replacement therapy. 
@chld Number of children among parous women., 
file = testf1, 
dec=2,
uselbl=F);
/*table 1 macro-stanford*/
%include "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro\table1_stanford.sas";
%let yourdata=mydata;
%let output_data=test_summary3; 
%let formatsfolder=;
%let yourfolder=; 
%let decimal_max=2;
%let varlist_cat = educ sex cursmoke diabetes; 
%let varlist_cont = totchol bmi age sysbp;
%let output_order = totchol bmi age sysbp sex educ cursmoke diabetes; 
%let group_by=mi_chd;
%let group_by_missing=0; 
%Table_summary;

/*see how many people with Hospitalized myocardial infarction or fatal coronary heart disease*/
proc freq data=mydata;
table mi_chd;
run;
/*check missing data*/
proc means data=mydata NMISS N; 
run;
/*describe continuous variables*/
/*summarize lasttime*/
proc sort data = mydata;
by mi_chd;
run;
proc means data = mydata n sum min max mean std median;
var lasttime totchol bmi age sysbp;
by mi_chd;
run;
/*boxplot to see distribution of continuous variable*/
proc ttest data=mydata;
class mi_chd; 
var lasttime totchol bmi age sysbp;
run;
/*check categorical data*/
proc freq data = mydata;
table sex*mi_chd/chisq;
table educ*mi_chd/chisq;
table cursmoke*mi_chd/chisq;
table diabetes*mi_chd/chisq;
run;

