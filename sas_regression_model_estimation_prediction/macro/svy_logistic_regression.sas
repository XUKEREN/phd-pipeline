
/*********************************************************************************
**********************************************************************************
**    Copyright (C) 2018, Muthusi, Jacques										**
**																				**
** Description  : Generic SAS program to create publication ready tables from 	**
** 				  logistic regression models using survey or non-survey data.	**
**				  It outputs results of both simple (univariate) and multiple 	**
**				  (multivariate) regression into one table (ideal for Table 2).	**
**																				**
** Platform     : Windows                                                      	**
**																				**
** Macros used  : %svy_logitc - macro to perform simple (univariate) logistic 	**
**				  regression model for categorical predictors.					**
**																				**
**				  %svy_logitn - macro to perform simple (univariate) logistic 	**
**				  regression model for continuous predictors.					**
**																				**
**				  %svy_unilogit - macro to combine results from %svy_logitc  	**
** 				  and %svy_logitn and process output in a nice format.			**
**																				**
**				  %svy_multilogit - macro to perform multiple (multivariate) 	**
**				  logistic regression on selected predictors. 					**
**																				**
**				  %svy_printlogit - macro to combine results from simple 		**
**				  (univariate) and multiple (multivariate) logistic regression	**
**				  and package the output in a publication ready table which is 	**
**				  exported to MS Word and Excel.								**
**																				**
**				  %runquit - macro to enforce in-built SAS validation checks  	**
** 				  on input parameters.											**
**																				**
** Input        : Any 		                                            		**
**																				**
** Output       : Publication ready table of Odds Ratio (95% CI) from 			**
**				  simple (univariate) and multiple (multivariate) logistic 		**
**				  regression in MS Word and Excel.								**
**																				**
** Main macro parameters:														**
**																				**
** %svy_unilogit and %svy_multilogit											**
**		dataset		= input dataset,											**
**		condition	= (optional) any conditional statements to create			**
**					  /fine-tune final analysis dataset,						**
**		outcome	 	= the outcome variable of interest e.g., HIV status,		**
**		outevent	= the value of outcome variable we are interested in		**
**					  modelling e.g., in this case event = Positive,			**
**		catvars		= list of categorical variables (separated by space),  		**
**		contvars	= list of continuous variables (separated by space),  		**
**		class		= class statement for categorical predictors specifying		**
**					  baseline category. Baseline category for outcome 			**
**					  variable is also specified here,							**
**		strata		= (optional) survey stratification variable,				**
**		cluster	 	= (optional) survey clustering variable,					**
**		weight		= (optional) survey weighting variable,						**
**		domain 		= (optional) domain variable,								**
**		domvalue 	= the value of domain variable we are interested in,		**
**		print		= variable for displaying/suppressing the output table 		**
**					  on the output window (NO=suppress, YES=show),				**
**																				**
** %svy_printlogit																**
**		tablename	= shortname of output table,								**
**		tabletitle	= title of output table										**
**																				**
** Sample program usage:														**
**																				**
** %svy_unilogit(dataset= kais_final, 											**
**			   outcome 	= hiv,													**
**			   outevent	= Positive, 											**
**			   catvars	= sex age, 												**
**			   contvars	= cd4,													**
**			   class 	= hiv (ref="Negative") sex(ref="Male") age(ref="15-24"),**
**			   weight	= bl_weight,											**
**			   cluster	= cluster,												**
**			   strata	= strata,												**
**			   domain	= ,														**
**			   domvalue	= ,														**
**			   condition= if hiv in (1,2),										**
**			   print	= YES); 												**
**																				**
** %svy_multilogit(dataset	= kais_final, 										**
**				   outcome 	= hiv,												**
**				   outevent	= Positive, 										**
**				   catvars	= sex age, 											**
**				   contvars	= cd4,												**
**				   class 	= hiv (ref="Negative") sex(ref="Male"),				**
**				   weight	= bl_weight,										**
**				   cluster	= cluster,											**
**				   strata	= strata,											**
** 				   domain 	= ,													**
**			   	   domvalue	= ,													**
**				   condition= if hiv in (1,2),									**
**				   print	= YES); 											**
**																				**
** %svy_printlogit(tablename  = svy_logit_table,								**
**				   tabletitle = Table 1: Predictors of HIV prevalence);			**
**																				**
** Validation history                                                         	**
**       Validated by :                                    Date:           	    **
**																				**
** Modification history                                                    	    **
**       Modified by  : Muthusi, Jacques                   Date: 17JUL2017 	    **
**                                                                         	    **
** Added columns for total N, number & percent of cases n(%)					**
**																				**
**       Modified by  : Muthusi, Jacques                   Date: 25JUL2017 	    **
**																				**
** Added %runquit() macro to enforce in-built SAS validation checks on 			**
** input parameters																**
**																				**
**********************************************************************************
*********************************************************************************/

options mlogic mprint symbolgen;

%* start of simple logistic regression macro;

%macro svy_unilogit(dataset 	= , 
					outcome 	= , 
					outevent	= ,
					catvars 	= , 
					contvars	= ,
					strata		= ,
					cluster		= ,
					weight		= , 
					class 		= ,
					domain		= , 
					domvalue	= ,
					condition 	= ,
					print		= YES); 

%runquit;

%* clear all temporary data files before starting;
data _parms_c _orstat _gstats _freq logistic_table logistic_table_c logistic_table_n _var_ xx_dataset; run;

ods exclude all;

%* prepare analysis dataset;

data xx_dataset;
 	set &dataset;
		&condition;
		if &outcome ne . ;
 run;

%* get domain size;
proc sql noprint;
	select count(*) into: nobs separated by ' ' from xx_dataset where &domain = &domvalue;
quit;

%global domsize;
%let domsize=&nobs;

%* for categorical predictor variables;

%* get number of predictor variables;
data _null_;
	i = 0;
	do while (scanq("&catvars",i+1) ^= ""); i+1; end;
 	call symput("no_catvars", trim(left(i)));
run;

%* loop over list of predictor variables;
  %let vi=1;
  %let len=0;
data logistic_table_c; set _null_;run;
  %do %while(&len < &no_catvars); 
	%let len = %eval(&len + 1);
	%let catvar	 = %scan(&catvars, &vi, %str( ));

data _null_; set xx_dataset;
 call symput("varlabel", vlabel(&catvar));
run;

%let xmodel = &outcome(event="&outevent")= &catvar;

%* set class statement for predictor variables;
	 %if %index(&class, %scan(&catvars,&vi," "))>0 %then  %do; 
	    %let catvar_pos =  %index(&class, %scan(&catvars,&vi," "));
	    %let str_from_catvar = %substr(&class,&catvar_pos);
		%let str_after_catvar = %substr(&class,&catvar_pos+%length(&catvar));
	
	    %let f_char = %substr(%bquote(&str_after_catvar),1,1); 
		%if %bquote(&f_char) = %str(%() %then %do;
		   	%let brkt1 = %index ( %bquote(&str_after_catvar), %str(%());
			%let brkt2 = %index ( %bquote(&str_after_catvar), %str(%)));
        	%let xclass = &catvar %substr(%bquote(&str_after_catvar), &brkt1, &brkt2-&brkt1 + 1);
		%end;
		%else %let xclass = &catvar;
 
	 %end;
	 %else %let xclass = ;


%* call macro for simple logistic regression for each categorical predictors;
    		%svy_logitc(dataset = xx_dataset, 
	               		model 	= &xmodel, 
	               		class  	= &xclass,
						outcome = &outcome,
						outevent= &outevent,
						weight	= &weight,
						strata	= &strata,
						cluster	= &cluster,
						domain 	= &domain,
						domvalue= &domvalue);

%* build simple logistic regression table categorical predictor variable;
 			data logistic_table_c;
 				set logistic_table_c _parms_c;
 			run;

 			%put i = &vi len = &len nvar = &no_catvars;
    		%let vi = %eval(&vi + 1);
 		%end;

%* for continuous predictorvariables;

%* get number of continuous predictor variables;
data _null_;
	i = 0;
	do while (scanq("&contvars",i+1) ^= ""); i+1; end;
 	call symput("no_contvars", trim(left(i)));
run;

%* loop over the list of continuous predictor variable;
  		%let vi=1;
  		%let len=0;
		data logistic_table_n; set _null_;run;
  		%do %while(&len < &no_contvars); 
			%let len = %eval(&len + 1);
			%let contvar = %scan(&contvars, &vi, %str( ));

     data _null_; set xx_dataset;
	 	call symput("varlabel", vlabel(&contvar));
	 run;

     %let xmodel = &outcome(event="&outevent") = &contvar;

%* call macro for simple logistic regression for each continuous predictor variable;
    		%svy_logitn(dataset = xx_dataset, 
	               		model 	= &xmodel, 
						outcome = &outcome,
						outevent= &outevent,
						weight	= &weight,
						strata	= &strata,
						cluster	= &cluster,
						domain	= &domain,
						domvalue= &domvalue);

%*  build simple logistic regression table for continuous predictor variable;
 			data logistic_table_n;
 				set logistic_table_n _parms_n;
 			run;

 			%put i = &vi len = &len nvar = &no_contvars;
    		%let vi   = %eval(&vi + 1);
 		%end;

%* build simple logistic regression table for categorical and contiunous predictor variables;
data logistic_table;
set logistic_table_c logistic_table_n;
	f_order=_n_;
run;

%* check if printing output from simple logistic regression is enabled/suppressed ;
%if %upcase(&print) = NO %then %do; ods exclude all; %end;
%else  %do; ods exclude none; %end;

%* if print is enabled then display results on the output window;
proc print data = logistic_table noobs label;
	var ClassVal0 N Freq OR_CI p_value g_p_value;
run;

ods exclude none;

%mend svy_unilogit;

%* end of simple logistic regression macro;

%* start of macro for simple logistic regression on categorical variables;

%macro svy_logitc(	dataset	=, 
					class	=, 
					model	=, 
					outcome =,
					outevent=,
					strata	=, 
					cluster	=, 
					domain 	=,
					domvalue=,
					weight	=) ;

%runquit;

data _ctemp;
set &dataset;
	&condition;
	 if &outcome ne .;
run;

%* save paramater estimates in ods tables;
ods output 	Type3=_gstats 
			ParameterEstimates=_parms_c 
			OddsRatios=_orstat;

%* fit logistic regression model;
proc surveylogistic data =_ctemp;  
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	%if &domain ne %then %do;  
		domain &domain;
	%end;
	class &class /param=ref;
	model &model /clparm; 

run;

%* obtain p-value for each level of categorical variable and begin building output table;
data _parms_c; 
length Parameter $25 ClassVal0 $50 p_value $8;
set _parms_c;
	Parameter = variable;
	if ProbChiSq < 0.01 then p_value = "<.01"; 
	else p_value = put(ProbChiSq,8.2);
	if parameter="Intercept" then delete;
keep parameter ClassVal0  p_value;
if &domain=&domvalue then output;
run;

data _parms_c;
set _parms_c;
	class_order = _n_;
run;

%* obtain Odds Ratios (95% CI) and add to output table;
data _orstat;
length Parameter $25 ClassVal0 $50;
set _orstat;
	Parameter=scan(effect,1);
	OR_CI=trim(left(put(OddsRatioEst,4.1)))||" ("||trim(left(put(LowerCL,4.1)))||"-"||trim(left(put(UpperCL,4.1)))||")";
keep parameter ClassVal0 OR_CI;
if &domain=&domvalue then output;
run;

data _orstat;
set _orstat;
	class_order = _n_;
run;

proc sort data = _parms_c; by class_order; run;
proc sort data = _orstat; by class_order; run;

data _parms_c; 
merge _orstat _parms_c ;
	by class_order;	
	if OR_CI ne "" then output;
run;

%* get labels of categorical predictor variables and add to output table;
ods output CrossTabs = _freq;
proc surveyfreq data = _ctemp;
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	table &domain*&catvar*&outcome/cl col row;
run;

data _freq;
set _freq;
	if &domain eq &domvalue then output;
run;

data _freq;
length ClassVal0 $50;
set _freq;
	char_order=_n_;
	ClassVal0 = trim(left(f_&catvar));
	keep classval0 f_&outcome Frequency RowPercent Percent char_order;
run;

data _nfreq;
	set _freq;
	_nfreq=Frequency;
	_npercent=RowPercent;
	if classval0 eq "Total" then _npercent=Percent;
	if f_&outcome eq "&outevent" then output;
	keep classval0 _nfreq _npercent;
run;

data _tfreq;
	set _freq;
	_tfreq=Frequency;
	_tpercent=Percent;
	if f_&outcome eq "Total" then output;
	keep classval0 _tfreq _tpercent;
run;

proc sort data = _nfreq; by classval0;
proc sort data = _tfreq; by classval0;

data _allfreq; 
merge _nfreq _tfreq; 
	by classval0;
run;

proc sort data = _allfreq; by classval0;
proc sort data = _parms_c; by classval0;

data _parms_c; 
merge _parms_c _allfreq; 
	by classval0;
	_nfreq_percent=trim(left(_nfreq))||" ("||trim(left(put(_npercent,4.1)))||")";
	if parameter=" " then parameter="&catvar";
	if OR_CI=" " and ClassVal0 ne " " then OR_CI="ref";
	chartab_order=_n_;
	index=&vi;
run;

%* obtain type3 p-value for testing importance of categorical predictor variable;
data _gstats;
length Parameter $25 g_p_value $8;
set _gstats;
	Parameter=Effect;
	if ProbChiSq < 0.01 then g_p_value = "<.01"; 
	else g_p_value = put(ProbChiSq,8.2);
	if &domain=&domvalue then output;
	keep Parameter g_p_value;
run;

%* add type3 p-value to output table;
proc sort data=_parms_c; by Parameter; run; 
proc sort data=_gstats; by Parameter; run;

data _parms_c;  
merge _parms_c _gstats ;
	by Parameter;
run;

proc sort data=_parms_c; by Parameter; run; 

%* add column for labels of predictor variables to output table;
data _parms_c;
length varname $50;
	set _parms_c;
	varname="&varlabel";
run; 

proc sort data=_parms_c; by char_order; run; 

%* get only one instance of categorical variable label;
proc sql;
	create table _var_ as select distinct varname from _parms_c;
quit;

data _parms_c;
set _parms_c;
	drop varname;
run;

data _parms_c;
merge _var_ _parms_c;
run;  

data _parms_c;
set _parms_c;
	if varname=" " then g_p_value=" ";
keep parameter class_order varname _nfreq_percent _tfreq ClassVal0 OR_CI p_value g_p_value char_order ;
run;

%* ;
proc sql;
	create table _varname as select distinct varname as ClassVal0 from _parms_c where varname ne "";
quit;

data _parms_c;
set _varname _parms_c;
	Freq=_nfreq_percent;
	N=put(_tfreq, 6.);
	if _nfreq_percent="" then Freq="";
	if _tfreq=. then N="";
proc sort; by class_order;
run;

%* obtain totals for each categorical variable and add them to the output table;
proc sql;
create table _parms_c_total as select * from _parms_c where ClassVal0 eq "Total";
create table _parms_c_nototal as select * from _parms_c where ClassVal0 ne "Total";
quit;

data _parms_c_total;
set _parms_c_total;
	OR_CI="";
run;

data _parms_c;
set _parms_c_nototal _parms_c_total;
run;

%* insert a blank row at the end of the output dataset which splits results each categorical predictor variable from the next;
data _parms_c;
set _parms_c end=eof;
	if eof then do;
	output;
		parameter = "";
		class_order=.;
		varname="";
		ClassVal0="";
		OR_CI="";
		p_value="";
		g_p_value="";
		char_order=.;
		Frequency=.;
		Freq="";
		N="";
	end;
	output;
run;

%mend svy_logitc;
%* end of macro for simple logistic regression on categorical variables;

%* start of macro for simple logistic regression on contiunous variables;

%macro svy_logitn(	dataset =, 
					model	=, 
					outcome =,
					outevent=,
					strata	=,
					cluster	=,
					weight	=,
					domain	=,
					domvalue=);

%runquit;

data _ntemp;
	set &dataset;
	&condition;
	if &outcome ne . and &contvar ne .;
run;

%* save paramater estimates and odds ratios ods tables;
ods output 	ParameterEstimates=_parms_n 
			OddsRatios=_orstat;

%* fit the logistic regression model;
proc surveylogistic data =_ntemp;
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	%if &domain ne %then %do;  
		domain &domain;
	%end;
	model &model /clparm; 
run;

%* obtain category p-value;
data _parms_n; 
length Parameter $25 ClassVal0 $50 p_value $8;
set _parms_n;
	Parameter = variable;
	ClassVal0= "";
	if ProbChiSq < 0.01 then p_value = "<.01"; 
	else p_value = put(ProbChiSq,8.2);
	g_p_value=p_value;
	if parameter="Intercept" then delete;
	if &domain=&domvalue then output;
keep  parameter ClassVal0  p_value g_p_value;
run;

%* obtain Odds Ratios (95% CI);
data _orstat;
length Parameter $25 ClassVal0 $50;
set _orstat;
	Parameter=effect;
	ClassVal0= "";
	OR_CI=trim(left(put(OddsRatioEst,4.1)))||" ("||trim(left(put(LowerCL,4.1)))||"-"||trim(left(put(UpperCL,4.1)))||")";
	if &domain=&domvalue then output;
keep parameter ClassVal0 OR_CI;
run;

data _orstat;
set  _orstat;
	class_order = _n_;
run;

data _parms_n;
set _parms_n;
	class_order = _n_;
run;

proc sort data = _parms_n; by class_order; run;
proc sort data = _orstat; by class_order; run;

data _parms_n; 
merge _orstat _parms_n ;
length varname $50;
	by class_order;	
	varname="&varlabel";
keep parameter class_order varname ClassVal0 OR_CI p_value g_p_value;
run;

ods output statistics=_tfreqn;
proc surveymeans data=_ntemp;
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	%if &domain ne %then %do;  
		domain &outcome;
	%end;
	var &contvar;
	where &domain=&domvalue;
run;

data _tfreqn;
set _tfreqn;
_tfreq=N;
keep VarName VarLabel _tfreq;
run;

ods output CrossTabs = _nfreqn;
proc surveyfreq data = _ntemp;
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	table &domain*&outcome/cl col row;
run;


data _nfreqn;
set _nfreqn;
	if &domain eq &domvalue and f_&outcome="&outevent" then output;
run;

data _nfreqn;
length;
set _nfreqn;
	varname=upcase("&contvar");
	Parameter=upcase("&contvar");
	_nfreq=Frequency;
	_npercent=RowPercent;
	_nfreq_percent=trim(left(_nfreq))||" ("||trim(left(put(_npercent,4.1)))||")";
	keep Parameter VarName _nfreq_percent;
run;

data _freqn;
merge _nfreqn _tfreqn;
by VarName;
run;

data _freqn;
set _freqn;
	N=put(_tfreq, 6.);
	Freq=put(_nfreq_percent,20.);
	keep Parameter N Freq;
*	if &domain=&domvalue then output;
run;

data _parms_n; 
merge _parms_n _freqn;
by Parameter;
	ClassVal0=varname;
run;

%* insert a blank row at the end of the dataset;
data _parms_n;
set _parms_n end=eof;
	if eof then do;
	output;
		parameter = "";
		class_order=.;
		varname="";
		ClassVal0="";
		OR_CI="";
		p_value="";
		g_p_value="";
		char_order=.;
		Frequency=.;
		Freq="";
		N="";
	end;
	output;
run;

%mend svy_logitn;

%* Multiple logistic regression;

%macro svy_multilogit(dataset 	= ,
					  outcome 	= ,
					  outevent	= ,
					  catvars	= ,
					  contvars	= ,
					  class 	= ,
					  strata	= ,
					  cluster	= ,
					  weight	= ,
					  domain	= ,
					  domvalue	= ,
					  condition = ,
					  print		= ); 
%runquit;

ods exclude all;

%* set model statement using input parameters;
%let model = &outcome(event="&outevent")= &catvars &contvars;

%* save paramater estimates, odds ratios and type 3 global p-value ods tables;
ods output 	Type3=_gstats
			ParameterEstimates=_parms 
			OddsRatios=_orstat;

%* fit logistic regression model and apply survey design if survey data;
proc surveylogistic data =xx_dataset; 
 	%if &strata ne %then %do;  
		stratum &strata;
	%end;
	%if &cluster ne %then %do;  
		cluster &cluster;
	%end;
	%if &weight ne %then %do;  
		weight &weight;
	%end;
	%if &domain ne %then %do;  
		domain &domain;
	%end;
	class &class /param=ref;
	model &model / clparm ; 
run;

%* obtain category p-value;
data _parms; 
length Parameter $25 ClassVal0 $50 M_p_value $8;
set _parms;
	Parameter = variable;
	if ProbChiSq < 0.01 then M_p_value = "<.01"; 
	else M_p_value = put(ProbChiSq,8.2);
	if parameter="Intercept" then delete;
	if &domain=&domvalue then output;
keep  parameter ClassVal0  M_p_value ;
run;

data _parms;
set _parms;
	class_order = _n_;
run;

%* obtain Odds Ratios (95% CI);
data _orstat;
length Parameter $25 ClassVal0  $50;
set _orstat;
	Parameter=scan(effect,1);
	M_OR_CI=trim(left(put(OddsRatioEst,4.1)))||" ("||trim(left(put(LowerCL,4.1)))||"-"||trim(left(put(UpperCL,4.1)))||")";
	if &domain=&domvalue then output;
keep parameter ClassVal0 M_OR_CI;
run;

data _orstat;
set _orstat;
	class_order = _n_;
run;

proc sort data = _parms; by class_order; run;
proc sort data = _orstat; by class_order; run;

data _parms; 
merge _orstat _parms ;
	by class_order;	
run;

data _parms;
set _parms;
	if M_OR_CI=" " and ClassVal0 ne " " then M_OR_CI="ref";
run;

%* obtain type3 p-value for testing importance of variable;
data _gstats;
length Parameter $25 M_g_p_value $8;
set _gstats;
	Parameter=Effect;
	if ProbChiSq < 0.01 then M_g_p_value = "<.01"; 
	else M_g_p_value = put(ProbChiSq,8.2);
	if &domain=&domvalue then output;
	keep Effect Parameter M_g_p_value;
run;

proc sort data = _parms; by Parameter; run;
proc sort data = _gstats; by Parameter; run;

data _parms;
merge _parms _gstats ;
	by parameter;
run; 

proc sql;
update _parms as a
	set ClassVal0=(select ClassVal0 from logistic_table_n as b where a.Parameter=b.Parameter) where a.ClassVal0="";
quit;

%* get one instance of glopbal p-value;
data _parms;
set _parms;
	by parameter;
		if first.parameter then count=0;
		count+1;
run;

data _parms;
set _parms;
if count gt 1 then M_g_p_value="";
run;

%if %upcase(&print) = NO %then %do; ods exclude all; %end;
%else %do; ods exclude none; %end;
proc print data = _parms noobs label;
	var parameter ClassVal0 M_OR_CI M_p_value M_g_p_value ;
run;

ods exclude none;

%mend svy_multilogit;

%* prepare and print output to MS Excel and Word;
%macro svy_printlogit(tablename	=, 
					  outcome	=,
					  outevent	=,
					  outdir	=,
					  tabletitle=);

%runquit;

data _null_; set xx_dataset;
	call symput("outcomelab", vlabel(&outcome));
run;

data logit_table; run;

%* append results from simple and multiple logistic regression to build final reporting table;
proc sql;
	create table logit_table as
	select a.*, b.M_OR_CI, b.M_p_value, b.M_g_p_value
	from logistic_table a left join _parms b 
	on a.ClassVal0=b.ClassVal0 and a.Parameter=b.Parameter
	order by f_order;
quit;

%* define report appearance;
proc template;
define style forOR;
parent = styles.printer;
replace fonts /
	"titlefont2" = ("Times New Roman", 11pt, Bold)
	"titlefont" = ("Times New Roman", 12pt, Bold)
	"strongfont" = ("Times New Roman", 10pt, Bold)
	"emphasisfont" = ("Times New Roman", 10pt, Bold)
	"fixedemphasisfont" = ("Times New Roman", 10pt, Bold)
	"fixedstrongfont" = ("Times New Roman", 10pt, Bold)
	"fixedheadingfont" = ("Times New Roman", 10pt, Bold)
	"batchfixedfont" = ("Times New Roman", 10pt, Bold)
	"fixedfont" = ("Times New Roman", 10pt, Bold)
	"headingemphasisfont" = ("Times New Roman", 10pt, Bold)
	"headingfont" = ("Times New Roman", 10pt, Bold)
	"docfont" = ("Times New Roman", 10pt);
end;
run;

%* output report table in excel and word;
option nomprint nosymbolgen nomlogic nodate nonumber;
ods escapechar = "^";
ods rtf file="&outdir\&tablename..rtf" style=forOR;
ods tagsets.ExcelXP file="&outdir\&tablename..xls" style=forOR;
ods tagsets.ExcelXP options(sheet_label="&tablename" suppress_bylines="yes" embedded_titles="yes");

title "&tabletitle" ", N=&domsize";
footnote height=8pt j=l "(Dated: &sysdate)" j=r "{\b\ Page }{\field{\*\fldinst {\b\i PAGE}}}";

proc report data = logit_table headline spacing=1 split = "*" nowd;
	column ClassVal0 ("&outcomelab" N Freq)  ("Unadjusted * odds ratios" OR_CI p_value g_p_value) ("Adjusted * odds ratios" M_OR_CI M_p_value M_g_p_value);
	define ClassVal0 / display width = 50 right missing "Characteristic";
    define N / display width = 10 right missing "Total";
    define Freq / display width = 10 right missing "&outevent n * (Weighted %)";
	define OR_CI / display width = 20 center missing "OR (95% CI)";
	define p_value / display width = 10 center missing "P-value";
	define g_p_value / display width = 10 center missing "Global * p-value";
	define M_OR_CI / display width = 20 center missing "OR (95% CI)";
	define M_p_value / display width = 10 center missing "P-value";
	define M_g_p_value / display width = 10 center missing "Global * p-value";
run;

footnote; 
title;
ods tagsets.excelxp close;
ods rtf close;

%mend svy_printlogit;

%*  macro to does an error check then stop SAS from continuing to process the rest of the submitted statements if error is present;
%macro runquit;
	; run; quit;
	%if &syserr. ne 0 %then %do;
	%abort cancel;
	%end;
%mend runquit;
