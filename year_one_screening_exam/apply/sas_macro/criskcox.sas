  /*------------------------------------------------------------------*
   | MACRO NAME  : criskcox
   | SHORT DESC  : Competing risk survival analysis with covariates
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (03/25/2004 13:36)
   |             : Therneau, Terry
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This program performs a competing risk survival analysis.
   | A proportional hazards regression model is fit for each of the
   | competing risks.  The resultant survival curves are then
   | combined to derive the cumulative incidences (CIs) for each of
   | the competing risk, in the presence of the other competing risks.
   | The main outputs are the proportional hazards regressions for the
   | individual competing risks and a data set describing CIs for each
   | of the competing risks. This dataset describes the CIs as a
   | function of time, with a record at each time point where the CI
   | changes for any of the competing risks.  This allows inspection
   | of CIs for any predictor set.  These may be inspected numerically
   | or graphically.  This program does not provide standard errors or
   | confidence intervals for CIs, but these may generally be easily
   | obtained using resampling techniques like the jackknife.
   |
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Therneau, Terry               (03/09/2009 16:48)
   |             : Bergstralh, Eric
   |             : Kremers, Walter
   |
   | Revised to accept up to 20 different event types.
   | Output dataset is revised extensively.  See archived versions if you
   | need to rerun for an older project.
   *------------------------------------------------------------------*
   | MODIFIED BY : Kremers, Walter               (02/17/2011 17:25)
   |
   | Modification to allow for the specification of different risk
   | factors (predictors) for the different competing risks.
   *------------------------------------------------------------------*
   | MODIFIED BY : OByrne, Megan                 (06/01/2011 10:46)
   |
   | Modified for compatibility with proc phreg in v9.2. Changed syntax to
   | avoid "no by" warnings. No longer expects the data set to have a label.
   | Removed uninitialized variable.
   *------------------------------------------------------------------*
   | MODIFIED BY : Kremers, Walter               (12/14/2012 17:04)
   |             : Benson, Joanne
   |
   | Modify code to work in SAS v9.3
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %criskcox(
   |            data= ,
   |            time= ,
   |            event= ,
   |            xvars= ,
   |            start= ,
   |            strata= ,
   |            pdata= ,
   |            out=_crskcox,
   |            outdata= ,
   |            print1=Y,
   |            print2=N,
   |            print= ,
   |            method=PL,
   |            ties=efron,
   |            outCox=_crCox,
   |            varsi=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : SAS data set to use for competing risk analysis
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : follow-up time to event, pts can have only one
   |             event as defined below. Time must be >=0.
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : 0 if no event
   |             1 if event of type 1, typically event of interest
   |             ...
   |             k if event of type k, competing risk
   |             (event types consecutive and k <= 20)
   |
   | Name      : xvars
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : list of x variables for Cox model
   |             required IF varsi is not specified
   |
   | Name      : varsi
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : x variables for Cox models, each set seperated
   |             by hyphen (-)
   |             First set for event type1, 2nd for type 2, etc...
   |             Number of sets of predictors MUST be same as the
   |             number of competing risk types.
   |             When this option is used, xvars option is ignored.
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : start
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : start follow-up time to event, pts can have only one
   |             event as defined below.  Required for start/stop
   |             intervals.
   |             Leave blank for right-censored data.
   |             If used, time intervals must be > 0.
   |
   | Name      : strata
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : stratification variable
   |
   | Name      : pdata
   | Default   :
   | Type      : Dataset Name
   | Purpose   : SAS data set containing one row for each set of
   |             "xvars" on which predicted curves are desired
   |             If none is specified, dataset _pdata is derived
   |             from the program and includes all combinations of
   |             XVARS in data set for analysis.
   |
   | Name      : out
   | Default   : _crskcox
   | Type      : Dataset Name
   | Purpose   : name of output dataset
   |             Data set contains cumulative incidence estimates for
   |             specified covariates (using pdata) for each event type.
   |             Number obs = 'rows of pdata'
   |             x 'unique event times'
   |             x 'number of strata'
   |             in input dataset.
   |
   | Name      : outdata
   | Default   :
   | Type      : Dataset Name
   | Purpose   : name of output dataset.  This parameter is kept to
   |             assure backward compatibility.  Use of OUT parameter
   |             is preferred.
   |
   | Name      : print1
   | Default   : Y
   | Type      : Text
   | Purpose   : N to suppress or Y to print Cox Regression
   |             results for individual parameters.
   |
   | Name      : print2
   | Default   : N
   | Type      : Text
   | Purpose   : N to suppress or Y to print estimates of incidences
   |             for levels specified in PDATA
   |             Note: For backward compatibility, values K, T, B, or L
   |             are accepted and have the same effect as specifying Y.
   |
   | Name      : print
   | Default   :
   | Type      : Text
   | Purpose   : N to suppress printout of all results,
   |             Y to force printout of all results.
   |             If missing, printing is determined by print1 and print2.
   |             Kept to assure backwards compatibilty with older macro
   |             versions.
   |
   | Name      : method
   | Default   : PL
   | Type      : Text
   | Purpose   : method for calculating baseline survival functions
   |             PL = Product Limit
   |             CH = Cumulative Hazard
   |             For (START, STOP) time format, program uses CH method
   |             only.
   |
   | Name      : ties
   | Default   : efron
   | Type      : Text
   | Purpose   : ties option for PHReg procedure, Efron recommended
   |
   | Name      : outCox
   | Default   : _crCox
   | Type      : Dataset Name
   | Purpose   : name of dataset with Cox model info for the different
   |             competing risk models. Data set contains model
   |             and individual parameter statistics for each
   |             of the competing risks. The model where all
   |             competing risks are combined is denoted by 0,
   |             and may serve for model inspection.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Data set containing cumulative incidence estimates for
   | specified covariates for each event type.
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | The macro may assign and thus temporarily suppress titles 8 and
   | above.
   | The progam also creates data sets _ONE, _ONENZ, _PDATA, _ANY, _CS#
   | and _crvr# (for # an underscore or number).
   | _temp05, _temp01, _temp02, _temp03, _temp04, _out01, _out02,
   | _out03, _out04.
   | These temporary datasets are deleted at the end of execution.
   |
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Located at bottom of code.
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Reference: Cheng SC,Fine JB,Wei LJ. Prediction of cumulative
   | incidence function under the proportional hazards model. Biometrics
   | 54, 219-228, 1998.
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | Copyright 2012 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
%macro criskcox(data=, start=, time=, event=, xvars=, xvarsi=, strata=,
                out=_crci, outcox=_CrCox, pdata=,
                print=, print1=Y, print2=Y,
                method=PL, ties=efron, outdata=);
 
 
%local i_ j_ type ;
%local nlevx nxs list ;
%global nxvars_ nxs_ ;
 
/* Check for usernamed output dataset */
 %IF (&out^=_crci ) & (&out^= ) & (&outdata^= ) &
         (%UPCASE(&out)^=%UPCASE(&outdata)) %THEN %PUT
 "WARNING: Different output data sets were identified by the OUT and
OUTDATA input parameters. &out (OUT) will be used.";
 
/* If &OUTDATA is entered and &OUT is _crskcox, then use &OUTDATA  */
 %IF ((&out=_crcix ) or (&out= )) & (&outdata^= )
    %THEN %LET out=&outdata;
 
%if (&print = ) %then %let print = ;
%else %if (%upcase(%substr(&print,1,1)) = N) %then %do ;
  %let print1 = N ; %let print2 = N ; %end ;
%else %if (%upcase(%substr(&print,1,1)) = Y) %then %do ;
  %let print1 = Y ; %let print2 = Y ; %end ;
 
%if (%length(&print1) > 0) %then
  %let print1 = %upcase(%substr(&print1,1,1)) ; ;
%if (%length(&print2) > 0) %then
  %let print2 = %upcase(%substr(&print2,1,1)) ; ;
 
%if ( (%length(&print) = 0) & (%length(&print1) = 0) &
      (%length(&print2) = 0) ) %then %let print1 = Y ;
 
%if (&print1 = Y) | (&print2 = Y) | ((&print2 =  K) |
  (&print2 = T) | (&print2 = B) | (&print2 = L))   %then %do ;
***** get/store titles in case overwritten ***************************;
 
%local i_ nt title1 title2 title3 title4 title5
             title6 title7 title8 title9 title10 ;
 
proc sql ;
  create table work._t as
  select * from dictionary.titles where type='T';
  reset noprint ;
quit ;
** number of titles being used *****;
proc sql ;
  reset noprint ;
  select nobs into :NT from dictionary.tables
  where libname="WORK" & memname="_T" ;
quit ;
 
** Store titles in macro variables *****;
** Initialize at least one title   *****;
%let title1    = ;
data _null_;
  set work._t ;
  length mv $10. ;
 
  mv = "title" || trim(left(put(number,2.))) ;
  call symput(MV, trim(left(text)));
run ;
 
%if (&nt <= 6) %then %let nxt1 = %eval(&nt + 2) ;
%else %let nxt1 = 8 ;
%let nxt2 = %eval(&nxt1 + 1) ;
%let nxt3 = %eval(&nxt1 + 2) ;
 
proc datasets lib=work nolist ;
  delete _t ;
run ;
 
***** END get/store titles in case overwritten **********************;
%end ;
 
%if (%length(&outCox ) = 0) %then %let outCox  = _crCox ;
%if (%length(&out) = 0) %then %let out = _crci ;
 
%let method = %upcase(&method) ;
%if ((&method ^= CH) & (&method ^= PL)) %then %let method = CH ;
%if (&start ^= ) %then %do ;
  %let method = CH ;
  %put ;
  %put %str(Warning: For Time Dependent Covariates SAS only calculates);
  %put %str(         baseline survival function using the CH method.  );
  %put ;
  %end ;
 
%if (%length(&xvarsi) > 0) %then %do ;
  * get list of vars from individual lists of vars for Cox models ;
  * nlevx - number of competing risks as implied by xvarsi ;
  %let nlevx = 0 ;
  %do i_ = 1 %to 99 ;
    %let list = %scan(&xvarsi,&i_, '-') ;
    %if (&list ^= ) %then %do ;
	  %let nlevx = %eval(&nlevx + 1) ;
      data _crvr&i_ ;
	  evt = &i_ ;
	  length var $32 ;
	  %do j_ = 1 %to 99 ;
	    %let var = %scan(&list,&j_) ;
	    %if (&var ^= ) %then %do ;
               var = upcase("&var") ;  output ; %end ;
        %end ;
      proc sort data=_crvr&i_ ;
        by var ;
*      proc print data=_crvr&i_ ;
	  run ;
      %end ;
    %end ;
  data _crvr_ ;
    set %do i_ = 1 %to &nlevx ; _crvr&i_ %end ; ;
    proc sort data=_crvr_ ; by evt var ;
      data _crvr_ ; length xvarsi $200 ; set _crvr_ end=eod ;
        by evt var ; retain xvarsi ;
        if (first.evt & (_n_ > 1)) then
         xvarsi = trim(left(xvarsi)) || ' -' ;
        xvarsi = trim(left(xvarsi)) || ' ' || trim(left(var)) ;
        if eod then do ;
          call symput('xvarsi_',trim(left(xvarsi))) ;
		end ;
*proc print data=_crvr_ ; run ; %put nlevx=&nlevx xvarsi_ = &xvarsi_ ;
 
  proc sort data=_crvr_ (drop=xvarsi) out=_temp01 ; by var ;
  data _crvr0 ; length xvars $200 ; set _temp01 end=eod ;
    by var ; retain xvars ; retain nxs 0 ; drop evt ;
    if first.var then do ;
      xvars = trim(left(xvars)) || ' ' || trim(left(var)) ;
      nxs = nxs + 1 ;  output ;  end ;
    if eod then do ;
      call symput('xvars',trim(left(xvars))) ;
      call symput('nxs' ,trim(left(put(nxs,4.)))) ;
	  end ;
*  proc print data = _crcv0 ;
  run ; %put xvars = &xvars ;
  %end ;
%else %do ;
  ** count the number of x vars ;
  %let nxs=0 ;
  %do i_ = 1 %to 50 ;
    %if %scan(&xvars, &i_)= %then %goto done ;
    %let nxs=%eval(&nxs+1) ;
    %end ;
  %done: %put Number of predictors is &nxs ;
  %end ;
%let xvars_ = &xvars ;
%let nxs_ = &nxs ;
 
%if (&strata ^= ) %then %do ;
  proc contents data=&data out=_out00 noprint ;
  data _null_ ;
    set _out00 ;
    if (upcase(name) = "%upcase(&strata)") then
        call symput('type',trim(left(put(type,2.)))) ;
  run ; %put type = &type ;
  %end ;
 
**remove bad event, start & time data, missing Xs ;
data _one ;
  set &data ;
  keep evt %if (&start ^= ) %then start ; time &strata &xvars ;
  evt=&event ;
  %if (&start ^= ) %then %do ; start = &start ; %end ;
  time = &time ;
  ** omit records with negative times **;
  if ((evt in (0 %do i_ = 1 %to 20 ; , &i_%end ;)) %if (&start ^= )
    %then & (start >= 0) ; & (time > 0)) ;
  xmiss = 0 ;
  ** omit records with missing strata **;
  %if (&strata ^= ) %then %do;
    %if (&type = 1) %then %do; if (&strata = .) then xmiss = 1 ; %end ;
    %if (&type = 2) %then %do; if (&strata = ' ') then xmiss = 1; %end;
    %end ;
  ** omit records with missing Xs;
  %do i=1 %to &nxs ;
    xx=%scan(&xvars,&i) ;
    if xx=. then xmiss=1 ;
    %end ;
  if xmiss=1 then delete ;
run ;
 
** get number of competing risks **;
proc sort data=_one ;
  by evt ;
data _onenz ; * _one wiht no zeros ;
  set _one (where=(evt ^= 0)) ;
data _null_ ;
  set _onenz end=eod ;
  by evt ;
  retain count_ 0 ;
  if first.evt then count_ = count_ + 1 ;
  if eod then call symput('nlev',trim(left(put(count_,4.)))) ;
run ; %put Number of competing risks = &nlev ;
 
***** if pdata not specified derive data set with *****;
*****  unique covariates in analysis data set     *****;
%if (&pdata = )%then %do ;
  %let pdata=_pdata ;
  proc sort data=_one out=_pdata ;
    by &xvars ;
  data _pdata ;
    set _pdata ;
    by &xvars ;
    if first.%scan(&xvars,&nxs) ;
  %end ;
 
 ******************************************************************;
 
**** Overall survival estimates using method=&method *************;
**** NOT used for calculations may serve for data inspection *****;
ods select none;
proc phreg data=_one ;
  model %if (&start ^= ) %then (start, time) * ;
        %else time * ;
        evt(0) = &xvars / %if (&ties ^= ) %then ties = &ties ; ;
  %if (&strata ^= ) %then strata &strata ; ;
  baseline covariates=&pdata out=_any survival=S_any /
                                       nomean method=&method ;
  ods output parameterestimates=_out01 %if &sysscpl=Linux or &sysver=9.3 %then %do; (rename=(parameter=variable)) %end;;
  ods output FitStatistics=_out02 ;
  ods output GlobalTests=_out03 ;
  ods output CensoredSummary=_out04 ;
 
        data _null_;
            dsid=open('_out01');
            call symput('labelexist',varnum(dsid,'label'));
        run;
 
data _temp01 ;
  length num 8 %if &labelexist %then %do; label %end; data $ 32 pred $128
         variable time start event stratum $18;
  set _out01 ;
  drop df ;
  Num = 0 ;
  data = "&data " ;
  stratum = "&strata " ;
  time = "&time " ;
  start  = "&start  " ;
  event = "&event " ;
  CR_Num = 0 ;
  pred = "&xvars " ;
  uclhr = exp(estimate + probit(0.975)*stderr) ;
  lclhr = exp(estimate - probit(0.975)*stderr) ;
data _temp02 ;
  set _out02 (where=(criterion='-2 LOG L')) ; drop criterion ;
data _temp03 ;
  set _out03 (where=(test='Likelihood Ratio')) ; drop test ;
  rename chisq=ModChiSq DF=ModDf ProbChiSq=ModProb ;
data _temp04 ;
  set _out04 ;
  rename event = nEvent ;
  %if (&strata ^= ) %then %do ; drop stratum ; * if (stratum = .) ;
       if (&strata in (' ' 'A') ) ; %end ;
data &outCox ; set _temp04;
   if _n_=1 then do;
      set _temp02;
      set _temp03;
      set _temp01;
      end;
run;
 
*** Survival Cause Specific (SCS) estimates using method=&method ****;
*** USED for derivation of crude cumulative incidences *****;
%do i_ = 1 %to &nlev ;
  %let list = %scan(&xvarsi,&i_, '-') ;
  %if (%length(&list) = 0) %then %let list = &xvars ;
  **** Cox for event type &i_ ;
  proc phreg data=_one ;
    model %if (&start ^= ) %then (start, time) * ;
          %else time * ;
          evt(0
           %do j_ = 1 %to &nlev ; %if &i_ ^= &j_ %then , &j_ ; %end ;)
          = &list / %if (&ties ^= ) %then ties = &ties ; ;
    %if (&strata ^= ) %then strata &strata ; ;
    baseline covariates=&pdata out=_cs&i_ survival=scs&i_ /
                                                nomean method=&method ;
 
    ods output parameterestimates=_out01 %if &sysscpl=Linux or &sysver=9.3 %then %do; (rename=(parameter=variable)) %end;;
    ods output FitStatistics=_out02 ;
    ods output GlobalTests=_out03 ;
    ods output CensoredSummary=_out04 ;
  data _temp01 ;
    length num 8 data $ 32 pred $128
           variable time start  event stratum $18;
    set _out01 ;
    drop df ;
    Num = &i_ ;
    data = "&data " ;
    stratum = "&strata " ;
    time = "&time " ;
    start  = "&start  " ;
    event = "&event " ;
    CR_Num = &i_ ;
    pred = "&list " ;
    uclhr = exp(estimate + probit(0.975)*stderr) ;
    lclhr = exp(estimate - probit(0.975)*stderr) ;
    label cr_num = 'Comp Risk 0 for any' ;
  data _temp02 ;
    set _out02 (where=(criterion='-2 LOG L')) ; drop criterion ;
  data _temp03 ;
    set _out03 (where=(test='Likelihood Ratio')) ; drop test ;
    rename chisq=ModChiSq DF=ModDf ProbChiSq=ModProb ;
  data _temp04 ;
    set _out04 ;
    rename event = nEvent ;
    %if (&strata ^= ) %then %do ; drop stratum ; * if (stratum = .) ;
        if (&strata in (' ' 'A') ) ; %end ;
  data _temp05 ; set _temp04;
   if _n_=1 then do;
      set _temp02;
      set _temp03;
      set _temp01;
      end;
  run;
 
  data &outCox ;
    set &outCox _temp05 ;
  run ;
  %end ;
ods select all;
 
%if (&print1 = Y) %then %do;
  proc print data=&outCox (where=(modprob ^= .)) label ;
    title&nxt1 "Criskcox macro: data=&data "
           %if (&start ^= ) %then "start=&start " ;
           "time=&time event=&event xvars=&xvars" ;
    title&nxt2 "Competing Risks Survival Analysis - Individual"
               "PH-Cox Regressions censoring for other risks" ;
    title&nxt3 "Model summary" ;
    by Cr_num pred ;
    id Cr_num pred ;
    var Total nEvent PctCens withoutcovariates ModChiSq moddf modprob;
  proc print data=&outCox label ;
    title&nxt3 "Parameter Summary" ;
    by Cr_num pred ;
    id Cr_num pred ;
    var Variable Estimate StdErr ProbChiSq lclhr
        HazardRatio uclhr %if &labelexist %then %do; Label %end;;
  run ; title&nxt1 ;
  %end ;
 
 ***************************************************************;
 
***** SORT AND  E X P A N D  SURVIVAL PROB DATASETS  *****;
***** OUT TO FULL SET OF PREDICTORS                  *****;
proc sort data=_any ;  by &strata &xvars time ;
%do i_ = 1 %to &nlev ;
  %let list = %scan(&xvarsi,&i_, '-') ;
  %if (%length(&list) = 0) %then %let list = &xvars ;
  proc sort data=_any (keep=&strata &xvars time) out=_temp06 ;
      by &strata &list time &xvars ;
      * vars in &xvars redundent but this does not influence ordering;
  data _cs&i_._ ;  set _cs&i_ ; * for cheking merge ;
  proc sort data=_cs&i_ ;  by &strata &list time ;
  data _cs&i_ ;  set _cs&i_ ;  by &strata &list time ; if first.time ;
  data _cs&i_ ;
    merge _temp06  _cs&i_ ; ***** or   merge _cs&i_ _temp01 ????? ;
    by &strata &list time ;
  proc sort data=_cs&i_ ;  by &strata &xvars time ;
  run ;
  %end ;
 
 ** merge output datasets, each has 1 obs/event time ;
 ** results in different n in each file ;
 ** carry forward LAST values of scs&i_ ;
 
 data &out ;
   merge _any %do i_ = 1 %to &nlev ; _cs&i_ %end ; ;
   by &strata &xvars time ;
   keep &strata &xvars time s_any
        %do i_ = 1 %to &nlev ; scs&i_  %end ; ;
   retain %do i_ = 1 %to &nlev ; scs_&i_ %end ; ;
   if first.%scan(&xvars,&nxs) then do ;
     %do i_ = 1 %to &nlev ;
       scs_&i_   = scs&i_   ;
       %end ;
     end;
   %do i_ = 1 %to &nlev ;
     if (scs&i_ ne .) then scs_&i_ = scs&i_ ;
     scs&i_ = scs_&i_ ;
     %end ;
 
*=====================================================================;
*--- get Crude (cumulative) Incidence (CI) ---------------------------;
 
data &out ;
  set &out ;
  by &strata &xvars ;
  retain sall %do i_ = 1 %to &nlev ; ci&i_ %end ; ;
 
  if first.%scan(&xvars,&nxs) then do ;
    sall = 1 ;
    %do i_ = 1 %to &nlev ;  ci&i_ = 0 ;  %end ;
    end;
 
  %do i_ = 1 %to &nlev ;  lg_scs&i_ = lag(scs&i_  ) ;  %end ;
 
  if first.%scan(&xvars,&nxs) then do ;
    %do i_ = 1 %to &nlev ;  lg_scs&i_ = 1 ;  %end ;
    end;
 
  ***** overall survival & change in overall, *****;
  *****      making some account for ties     *****;
  * get changes in CI -                              **;
  * in case numerically S is 0 then assessing change of 0 ;
  %do i_ = 1 %to &nlev ;
    if (lg_scs&i_ <= 0) then dci&i_ = 0 ;
    else dci&i_ = sall*(1-scs&i_/lg_scs&i_) ;
    %end ;
 
  * Delta CI for all causes together ;
  dci_sum = dci1 %do i_ = 2 %to &nlev ; + dci&i_ %end ; ;
  * Note, this is open to debate. ;
  * One can also argue the overall survival should be the product of  ;
  * the individual survivals,  However, if ties are real the sum of   ;
  * the individual dcis should apply.  If continuous then overall     ;
  * survival should be derived for different possible sequences of    ;
  * events and this involves reduced set for second event ;
  * e.g. if SA = SB2 = 9/10 for a time point then :       ;
  * P(survive) = (9/10) * (8/9)                           ;
  * alternately consider the analogue to the Flemming-Harrington      ;
  * estimate (Thernaeau & Grambsch p.267). If all of n elements have  ;
  * same risk then for 2 events the incremental term in the estimate  ;
  * for baseline cumulative hazard is not 1/n + 1/n but (1/n + 1/(n-1))
  * which again is analogous to what one would observe in the case of ;
  * two subesquent events ;
 
   * this next bit of code is only expected to apply for extreme  ;
   * covariates where approximations may be too large of CI ;
 
   if (dci_sum > sall) then do ;
     %do i_ = 1 %to &nlev ;
       dci&i_ = dci&i_ * sall / dci_sum ;
       %end ;
     dci_sum = dci1 %do i_ = 2 %to &nlev ; + dci&i_ %end ; ;
     end ;
 
   * update ci&i_ *********;
   %do i_ = 1 %to &nlev ;
     ci&i_ = ci&i_ + dci&i_ ;
     %end ;
 
   sall = sall - dci_sum ;
   if (sall < 0) then sall = 0 ;
              * sall may be < 0 only due to rounding error ;
   ci_sum  = 1 - sall ;
 
   label s_any    = "Naive Surv Any Risk (&method)"
         sall     = "Model Surv All Risk (&method)"
         ci_sum   = "Sum Comp Risk Cum Inc"
         dci_sum  = "Delta Sum Cum Inc &method"
         %do i_ = 1 %to &nlev ;
           scs&i_ = "PHReg Surv Risk &i_"
           ci&i_  = "Comp Risk Cum Inc &i_"
           dci&i_ = "Delta Comp Risk Cum Inc &i_"
           %end ; ;
 
* scs for survival cause specific ;
* comp risk cumulative incidence often referred to as;
* crude cumulative incidence ;
 
   format s_any sall dci_sum ci_sum
          %do i_ = 1 %to &nlev ; scs&i_ dci&i_ ci&i_ %end ; 6.4 ;
run ;
*=====================================================================;
*---- print comp risk (crude) cumulative incidences ------------------;
 
%if ((&print2 = Y) | (&print2 = B) | (&print2 = T) |
     (&print2 = L)) %then %do ;
  title&nxt1 "Criskcox macro: data=&data "
           %if (&start ^= ) %then "start=&start " ;
           "time=&time event=&event xvars=&xvars" ;
  title&nxt2 "PH Reg Survials censoring for other factors"
             " (Cause Specific Survivals) and" ;
  title&nxt3 "Competing Risks Cumulative Incidences accounting"
             " for other risks (Crude CI) (method=&method)" ;
  proc print data=&out label ;
    by &strata &xvars ;
    id &strata &xvars time ;
    var s_any
        %do i_ = 1 %to &nlev ; scs&i_ %end ; sall
        %do i_ = 1 %to &nlev ; ci&i_  %end ; ci_sum ;
  run ; title&nxt1 ;
  %end ;
run ;
 
%if (&nt > 7) %then %do i_ = &nxt1 %to &nt ;
           title&i_ "&&title&i_" ;  %end ;
 
proc datasets lib=work nolist ;
  delete %if (%length(&xvarsi) > 0) %then %do ; _crvr_
            %do i_ = 0 %to &nlevx ; _crvr&i_  %end ; %end ;
         %if (&strata ^= ) %then _out00 ;
         _one _onenz _out01 _out02 _out03 _out04
         _temp01 _temp02 _temp03 _temp04 _temp05 _temp06
         _any %do i_ = 1 %to &nlev ; _cs&i_ _cs&i_._ %end ;
         ;
 
run ; quit ;
 
%mend criskcox ;
 
**********************************************************************;
***** Example Calls                                              *****;
**********************************************************************;
 
 /*
data one ;
  input obs t evt z;
  all=1 ;
  cards ;
1 2 1 0
2 3 0 0
3 4 1 0
4 5 2 0
5 6 0 0
6 7 2 0
7 8 0 0
8 9 0 0
9 10 0 0
10 11 0 0
11 1  1 1
12 2  2 1
13 3  1 1
14 4  2 1
15 5  1 1
16 6  1 1
17 7  0 1
18 8  2 1
19 9  0 1
20 10 0 1
run;
 
data two ;
  input obs t evt z;
  all=1 ;
  cards ;
1 1 1 0
2 2 1 0
3 3 0 0
4 4 2 0
5 5 1 0
6 6 2 0
7 7 0 0
8 8 1 0
9 9 0 0
10 10 0 0
11 1  0 1
12 2  0 1
13 3  1 1
14 4  0 1
15 5  0 1
16 6  0 1
17 7  1 1
18 8  0 1
19 9  2 1
20 10 0 1
run ;
 
data fiv ;
  input obs t_ evt z_ ;
  all=1 ;
cards ;
1 2 1 0
2 3 0 0
3 4 1 0
4 5 1 0
5 6 0 0
6 7 1 0
7 8 0 0
8 9 0 0
9 10 0 0
10 11 1 0
10 12 1 0
10 13 0 0
11 1  1 1
12 2  0 1
13 3  1 1
14 4  1 1
15 5  1 1
16 6  1 1
17 7  0 1
18 8  1 1
19 9  0 1
20 11 1 1
21 11 1 1
22 12 1 1
23 13 1 1
24 14 1 1
25 15 1 1
26 16 1 1
run ;
 
data onex ; set one ; if (t > 10.5) then evt = 1 ;
 
data pred ; **define z0 ;
  z=0  ; output ;
  z=0.3; *output ;
  z=0.6; output ;
  z=1  ; output ;
data pred2 ; all=1 ; output ; run ;
 
data predfiv ;
  z_ = 0  ; output ;
  z_ = 1  ; output ;
run ;
  */;
 
  /*
options mprint ps=56 ls=132;
options mprint ps=50 ls=132;
title1 "Data set one--tied events of different types";
proc print data=one; run ;
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=L);
title2 "Longest obs time with event" ;
%criskcox(data=onex,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=L);
 
title "Data set two---no ties of any type";
proc print data=two;
%criskcox(data=two,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=L) ;
*%comprisk(data=two,time=t,event=evt,print=Y) ;
options nomprint ;
  */
 
  /*
** example of plots from macro output **;
title1 "Data set one" ;
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L);
 symbol1 i=steplj v=none l=1;
 symbol2 i=steplj v=none l=2;
 symbol3 i=steplj v=none l=5;
 symbol4 i=steplj v=none l=7;
 
 proc gplot data=_crci ;
   by z ;
   plot ci_sum*time=1 ci1*time=2 ci2*time=3 /
       overlay vaxis=0 to 1 by .2 haxis=0 to 12 by 2 ;
 run ; quit ;
 
 proc gplot data=_crci ;
   plot sall*time=z scs1*time=z scs2*time=z /
       vaxis=0 to 1 by .2 haxis=0 to 12 by 2 ;
 run ; quit ;
options ls=80 ps=56 ;
  */;
 
 
  /*
options mprint ps=56 ls=132;
 
title1 "Data Set one" ;
title2
"In presence of ties naive ovarall surv''l may not be same as sum CIs";
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=L);
data onea ;
    set one ;
    if (evt = 1) then t = t+0.00 ;
    if (evt = 2) then t = t+0.01 ;
    if (evt = 0) then t = t+0.02 ;
title1"Data Set onea" ;
title2"Even in absence of ties naive ovarall survival may not be " ;
title3"same as sum CIs due to imbalance of different underlying risks";
 
title4"risks through time and different effects of predictors on HRs" ;
%criskcox(data=onea,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=Y);
*%comprisk(data=onea,time=t,event=evt,group=all,print=Y);
options ls=80 ps=56 ;
title1 ;
  */;
 
  /*
title1 "Test for case of only 1 risk (no competing risk)" ;
%criskcox(data=fiv, pdata=predfiv, time=t_, event=evt,
    xvars=z_, print1=N, print2=L) ;
*%comprisk(data=fiv,time=t_,event=evt,group=all,print=Y);
  */;
 
  /*
title1 "Example where different risks have different risk factors" ;
data three ;
  input obs time event age gleas junk ;
  all=1 ;
  cards ;
 1  2  1  45 1 1
 2  3  0  30 1 2
 3  4  1  47 4 1
 4  5  2  65 2 2
 5  6  0  40 1 1
 6  7  2  70 1 2
 7  8  0  60 1 1
 8  9  0  50 2 2
 9 10  0  42 1 1
10 11  0  65 1 2
11  1  1  60 3 1
12  2  2  70 2 2
13  3  1  44 3 1
14  4  2  56 2 2
15  5  1  66 4 1
16  6  1  55 2 2
17  7  0  57 3 1
18  8  2  65 1 0
19  9  0  45 1 1
20 10  0  40 1 2
run ;
 
data pred3 ;
  input age gleas junk ;
  all=1 ;
  cards ;
55 1 1
55 4 1
65 1 1
65 4 1
run ;
 
title2 "my second title" ;
title3 "my third title" ;
 
*%criskcox(data=three,pdata=pred3,time=time,event=event,
           xvarsi = age gleas - age junk , print1=Y, print2=L);
%criskcox(data=three,pdata=pred3,time=time,event=event,
           xvarsi = gleas - age, print1=Y, print2=L);
title ;
  */;

