/*import dataset*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\final project\framingham_2019" out=mydata dbms = dta replace;
run;
proc contents data=mydata;
run;
proc print data=mydata;
run;
/*create formats*/
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
/*QUESTION 2*/
ods graphics on; 
proc lifetest data=mydata method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time lasttime*mi_chd(0); 
strata diabetes; 
run; 
ods graphics off;
proc print data= a; run;
/*calculate the cumulative survival rate at specific time points*/
proc lifetest data=mydata method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr 
timelist =5 10 15 20 reduceout noprint stderr; 
time lasttime*mi_chd(0); 
strata diabetes; 
run; 
proc print data = A;run;


/*check if there are ties*/

proc freq data = mydata;
table lasttime;
run;
/*it turns out that a few time points with 2 events*/
/*check if change ties would make any differences*/
proc phreg data = mydata;
model lasttime*mi_chd(0) = bmi/ risklimits covb ties=EFRON;
run;
proc phreg data = mydata;
model lasttime*mi_chd(0) = bmi/ risklimits covb ties=BRESLOW;
run;
proc phreg data = mydata;
model lasttime*mi_chd(0) = bmi/ risklimits covb ;
run; 


/*did not change*/
/*Use martingale residuals to evaluate the linearity of the continuous independent variables*/
ods graphics on; 
proc phreg data = mydata;
model lasttime*mi_chd(0) = ;
output out=residuals resmart=martingale; run;
proc loess data = residuals plots=ResidualsBySmooth(smooth); 
model martingale = totchol / smooth=0.8; run;
proc loess data = residuals plots=ResidualsBySmooth(smooth); 
model martingale = bmi / smooth=0.8; run;
proc loess data = residuals plots=ResidualsBySmooth(smooth); 
model martingale = age / smooth=0.8; run;
proc loess data = residuals plots=ResidualsBySmooth(smooth); 
model martingale = sysbp / smooth=0.8; run;
ods graphics off;
/*linearity all good except for BMI
looks like BMI could be ln transformed
*/
data mydata;
set mydata;
lnbmi=log(bmi);
bmi_new=bmi**2;
run;
/*check again - not improve much*/
proc phreg data = mydata;
model lasttime*mi_chd(0) = ;
output out=residuals resmart=martingale; run;
proc loess data = residuals plots=ResidualsBySmooth(smooth); 
model martingale = bmi_new / smooth=0.8; run;
/*center continuous variables*/
proc means data = mydata mean;
var totchol bmi age sysbp;
run;
data mydata;
set mydata;
totcholcenter=totchol-236.85;
bmicenter=bmi-25.80;
agecenter=age-49.55;
sysbpcenter=sysbp-132.28;
run;

/*Test the univariate association of each of the variables with the MI/CHD hazard rate*/
proc phreg data = mydata;
model lasttime*mi_chd(0) =totcholcenter/ risklimits type3;
run;
proc phreg data = mydata;
model lasttime*mi_chd(0) =bmicenter/ risklimits type3;
run;
proc phreg data = mydata;
model lasttime*mi_chd(0) =agecenter/ risklimits type3;
run;
proc phreg data = mydata;
model lasttime*mi_chd(0) =sysbpcenter/ risklimits type3;
run;
proc phreg data = mydata;
class sex (ref= 'Male')/param=ref; 
model lasttime*mi_chd(0) =sex/ risklimits type3;
run;
proc phreg data = mydata;
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =educ/ risklimits type3;
run;
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
model lasttime*mi_chd(0) =cursmoke/ risklimits type3;
run;
proc phreg data = mydata;
class diabetes (ref= 'no')/param=ref; 
model lasttime*mi_chd(0) =diabetes/ risklimits type3;
run;

/*check for confoundings*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes/ risklimits type3;
run;
/*add agecenter*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter/ risklimits type3;
run;
/*add sex*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex/ risklimits type3;
run;
/*add educ*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex educ/ risklimits type3;
run;

/*proportional hazards assumption*/
/*methond 1: plot Schoenfeld residuals against time */
/*create dummy variables for sex and education*/
data mydata_phtest;
set mydata;
sex=sex-1;
if educ = 1 then do; educ_2 = 0; educ_3 = 0; educ_4=0; end; 
if educ = 2 then do; educ_2 = 1; educ_3 = 0; educ_4=0; end; 
if educ = 3 then do; educ_2 = 0; educ_3 = 1; educ_4=0; end; 
if educ = 4 then do; educ_2 = 0; educ_3 = 0; educ_4=1; end;
run;

%include 'C:\Users\xuker\Downloads\@USC\19spring-pm518a\final project\Score test for proportionality after cox model.sas';
%phreg_score_test(lasttime, mi_chd, 
totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex educ_2 educ_3 educ_4, 
                  strata= , data=mydata_phtest, type="time");

/*create loess plot for scaled Schoenfeld residuals against time*/
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex educ_2 educ_3 educ_4; 
id randid; 
output out=res WTRESSCH = stotcholcenter_r sbmicenter_r ssysbpcenter_r scursmoke_r sdiabetes_r sagecenter_r
ssex_r seduc_2_r seduc_3_r seduc_4_r;
run;

proc loess data=res; 
model stotcholcenter_r=lasttime /smooth=0.4; 
ods output OutputStatistics=myout;
run; 
quit;
proc sort data = myout; 
by lasttime;
run;
symbol1 c = gray i = none v = circle h=.8 ; 
symbol2 c = black i = join v = none w=2.5; 
title "Scaled Schonefeld Residuals of total cholesterol vs. time";
axis1  minor=none label=(a=90 'Scaled Schonefeld Residuals - totcholcenter') ;
axis2 order=(0 to 25 by 5) label=('Time') minor=none; 
proc gplot data = myout; 
plot DepVar*lasttime=1 Pred*lasttime=2 /vaxis = axis1 haxis = axis2 vref=0 overlay;
run; quit;

proc loess data=res; 
model SEDUC_4_R=lasttime /smooth=0.4; 
ods output OutputStatistics=myout;
run; 
proc sort data = myout; 
by lasttime;
run;
symbol1 c = gray i = none v = circle h=.8 ; 
symbol2 c = black i = join v = none w=2.5; 
title "Scaled Schonefeld Residuals of educ_college vs. time";
axis1  minor=none label=(a=90 'Scaled Schonefeld Residuals - educ_college') ;
axis2 order=(0 to 25 by 5) label=('Time') minor=none; 
proc gplot data = myout; 
plot DepVar*lasttime=1 Pred*lasttime=2 /vaxis = axis1 haxis = axis2 vref=0 overlay;
run; quit;

proc loess data=res; 
model ssex_r=lasttime /smooth=0.4; 
ods output OutputStatistics=myout;
run; 
proc sort data = myout; 
by lasttime;
run;
symbol1 c = gray i = none v = circle h=.8 ; 
symbol2 c = black i = join v = none w=2.5; 
title "Scaled Schonefeld Residuals of sex vs. time";
axis1  minor=none label=(a=90 'Scaled Schonefeld Residuals - sex') ;
axis2 order=(0 to 25 by 5) label=('Time') minor=none; 
proc gplot data = myout; 
plot DepVar*lasttime=1 Pred*lasttime=2 /vaxis = axis1 haxis = axis2 vref=0 overlay;
run; quit;
title

/*method 2 - use assess statement to test assumption*/

ods graphics on; 
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex educ/ risklimits type3;
assess PH / resample; 
run; 
ods graphics off;

/*method 3 - interaction with time*/
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 totcholcentertime; 
totcholcentertime = totcholcenter*log(lasttime);
run;
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 totcholcentertime; 
totcholcentertime = totcholcenter*lasttime;
run;
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 educ_4time; 
educ_4time = educ_4*log(lasttime);
run;
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 educ_4time; 
educ_4time = educ_4*lasttime;
run;
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 sextime; 
sextime = sex*log(lasttime);
run;
proc phreg data = mydata_phtest outest=est covout; 
model lasttime*mi_chd(0) = totcholcenter bmicenter sysbpcenter cursmoke 
diabetes agecenter sex educ_2 educ_3 educ_4 sextime; 
sextime = sex*lasttime;
run;
/*model sex and educ with interaction term with time*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter sex educ sextime eductime/ risklimits type3;
sextime = sex*lasttime;
eductime=educ*lasttime;
run;
/*model sex and educ with interaction term with log time*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter sex educ sextime eductime/ risklimits type3;
sextime = sex*log(lasttime);
eductime=educ*log(lasttime);
run;
/*stratify by sex and educ since they are not modifiable risk factors*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter / risklimits type3;
strata sex educ;
run;
/*original model*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter sex educ/ risklimits type3;
run;
/*final model*/

/*model diagnosis*/
/*make id as a character instead of a numeric for easier labeling*/
data mydata;
set mydata;
id = put(randid, 12. -L);
run;
/*Cox-Snell residuals*/
* First get the Cox-Snell residuals.;
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter / risklimits type3;
strata sex educ;
output out = cox_snell LOGSURV = h;  /*-logsurv is the cox-snell residual*/
run;

data cox_snella;
  set cox_snell;
  h = -h;
  cons = 1;
run;

* Then using NA method to estimate the cumulative hazard function for residuals;

proc phreg data = cox_snella ;
  model  h*mi_chd(0) = cons;
  output out = cox_snellb logsurv = ls /method = ch;
run;

data cox_snellc;
  set cox_snellb;
    haz = - ls;
run;

proc sort data = cox_snellc;
 by h;
run;

title "cox_snell";
axis1  minor = none;
axis2 minor = none label = ( a=90);
symbol1 i = stepjl c= blue pointlabel=(height=10pt '#id');
symbol2 i = join c = red l = 3;
proc gplot data = cox_snellc;
  plot haz*h =1 h*h =2 /overlay haxis=axis1 vaxis= axis2;
  label haz = "Estimated Cumulative Hazard Rates";
  label h = "Residual";
run;
quit;

/*Influence Diagnostics*/
proc phreg data = mydata; 
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter / risklimits type3;
strata sex educ;
output out = dfbeta dfbeta=dftotcholcenter dfbmicenter dfsysbpcenter dfcursmoke dfdiabetes dfagecenter; run;
proc sgplot data = dfbeta;
title;
scatter x = lasttime y=dftotcholcenter / markerchar=id; run;
proc sgplot data = dfbeta;
scatter x = lasttime y=dfbmicenter / markerchar=id; run;
proc sgplot data = dfbeta;
scatter x = lasttime y=dfsysbpcenter / markerchar=id; run;
proc sgplot data = dfbeta;
scatter x = lasttime y=dfcursmoke / markerchar=id; run;
proc sgplot data = dfbeta;
scatter x = lasttime y=dfdiabetes / markerchar=id; run;
proc sgplot data = dfbeta;
scatter x = lasttime y=dfagecenter / markerchar=id; run;

/*likelihood displacement*/
proc phreg data = mydata; 
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter 
cursmoke diabetes agecenter / risklimits type3;
strata sex educ;
output out=ld ld=ld; 
run;
proc sgplot data=ld; 
scatter x=lasttime y=ld / markerchar=id; 
run;

/*print influential points*/
proc print data = mydata(where=(id='7411567' or id='1080920' or id='8875547'
or id='610021' or id='7351212' or id='1864342' or id='9255084' or id='6300384')); 
var id totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter; run;

/*final model*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=ref; 
class diabetes (ref= 'no')/param=ref; 
class sex (ref= 'Male')/param=ref; 
class educ (ref= '0-11 years')/param=ref; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter / risklimits type3;
strata sex educ;
run;

/*test whether the diabetes association with MI/CHD hazard varies by the level of total cholesterol*/
proc phreg data = mydata;
class cursmoke (ref= 'no')/param=glm; 
class diabetes (ref= 'no')/param=glm; 
class sex (ref= 'Male')/param=glm; 
class educ (ref= '0-11 years')/param=glm; 
model lasttime*mi_chd(0) =totcholcenter bmicenter sysbpcenter cursmoke diabetes agecenter diabetes*totcholcenter/ type3(all);
strata sex educ;
HAZARDRATIO diabetes / at(totcholcenter=-36.85);
HAZARDRATIO diabetes/ at(totcholcenter=0);
lsmeans diabetes / ilink diff exp cl;
run;
