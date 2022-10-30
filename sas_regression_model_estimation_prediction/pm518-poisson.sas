/*pm518 - hw6 - poisson regression*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw6\nickel3.csv" out=nickel3 dbms=csv replace;
    getnames=yes;
run;
proc contents data=nickel3;run;
proc print data=nickel3; run;

data nickel3;
set nickel3;
log_py = log(py);
run;

proc genmod data=nickel3;
class afe(ref='1')/ param=glm;
class yfe(ref='1')/ param=glm;
class tfe(ref='1')/ param=glm;
model NUMDEAD  = afe yfe tfe/link =log dist=poi offset=log_py type3;
store p1;
run;

/*get irr for slopes and rate for the intercept*/
ods output ParameterEstimates = est;
proc plm source = p1;
show parameters;
run;
data est_exp;
set est;
irr_or_rate = exp(estimate);
if parameter eq "Intercept" then irr_or_rate=exp(estimate)*100000;
run;
proc print data= est_exp;
run;

/*test for goodness of fit*/
/*calculate the p-value*/
/*deviance goodness of fit*/
Data a; 
y = 1-probchi(58.1660,61);
Proc print; 
title ‘2-sided P-value for X=58.1660 in chi-sq_61 dist’;
run;
/*pearson chi-square goodness of fit*/
Data a; 
y = 1-probchi(110.4572,61);
Proc print; 
title ‘2-sided P-value for X=110.4572 in chi-sq_61 dist’;
run;

/*b.Use the PREDICT statement to estimate the number of nasal cancer deaths 
in each stratum combination of AFE, YFE, TFE*/  
proc genmod data=nickel3;
class afe(ref='1')/ param=ref;
class yfe(ref='1')/ param=ref;
class tfe(ref='1')/ param=ref;
model NUMDEAD  = afe yfe tfe/link =log dist=poi offset=log_py type3;
output out=out p=pcount xbeta=xb stdxbeta=std;
run;


      data predrates;
         set out;
         obsrate=NUMDEAD/py;  /* observed rate */
         lograte=xb-log_py;
         prate=exp(lograte);  /* predicted rate */
         lcl=exp(lograte-probit(.975)*std);
         ucl=exp(lograte+probit(.975)*std);
		 prednumdead=prate*py;
         keep py NUMDEAD prednumdead afe yfe tfe prate obsrate lcl ucl;
         run;

      proc print data=predrates;
         id py NUMDEAD;
         run;

/*use sgplot to test for outliers*/

/*Yes, there are two outliers with numdead > 4 or prednumdead > 4 */
proc sgplot data=predrates;                                                                                                                                                                            
reg y=NUMDEAD x=prednumdead;                                                                                                        
run;                                                                                                                                    
  

/*test for interaction*/

proc genmod data=nickel3;
class afe(ref='1')/ param=ref;
class yfe(ref='1')/ param=ref;
class tfe(ref='1')/ param=ref;
model NUMDEAD  = afe yfe tfe afe*yfe/link =log dist=poi offset=log_py type3;
run;

proc genmod data=nickel3;
class afe(ref='1')/ param=ref;
class yfe(ref='1')/ param=ref;
class tfe(ref='1')/ param=ref;
model NUMDEAD  = afe yfe tfe afe*tfe/link =log dist=poi offset=log_py type3;
run;

proc genmod data=nickel3;
class afe(ref='1')/ param=ref;
class yfe(ref='1')/ param=ref;
class tfe(ref='1')/ param=ref;
model NUMDEAD  = afe yfe tfe yfe*tfe/link =log dist=poi offset=log_py type3;
run;


Data a; 
y = 1-probchi(58.1660-49.0842,61-52);
Proc print; 
run;

Data a; 
y = 1-probchi(58.1660-48.5290, 61-50);
Proc print; 
run;

Data a; 
y = 1-probchi(58.1660-41.8419, 61-50);
Proc print; 
run;


/*estimate RR and the CI for each factor*/
proc genmod data=nickel3;
class afe(ref='1')/ param=glm;
class yfe(ref='1')/ param=glm;
class tfe(ref='1')/ param=glm;
model NUMDEAD  = afe yfe tfe/link =log dist=poi offset=log_py type3;
lsmeans afe yfe tfe / ilink diff exp cl;
run;

/*b.Use the LINCOM statement to compute a rate ratio for this hypothetical subject 
compared to a subject with baseline exposure levels (AFE=1, YFE=1, TFE=1), 
along with a 95% confidence interval and test that this joint rate ratio = 1.

hypothetical subject: a man employed at age 25 in 1923, who has been employed for 35 years
*/

/*the order depends on the Class Level Information table*/
/*here, the order is as below: 
Class Values 
afe  2 3 4 1 
yfe  2 3 4 1 
tfe  2 3 4 5 1 
*/
proc genmod data=nickel3;
class afe(ref='1')/ param=glm;
class yfe(ref='1')/ param=glm;
class tfe(ref='1')/ param=glm;
model NUMDEAD  = afe yfe tfe/link =log dist=poi offset=log_py type3;
estimate "Rate 1" intercept 1 afe 1 0 0 0 yfe 0 0 1 0 tfe 0 1 0 0 0;
estimate "Rate 2" intercept 1 afe 0 0 0 1 yfe 0 0 0 1 tfe 0 0 0 0 1;
estimate "ratio" afe 1 0 0 -1 yfe 0 0 1 -1 tfe 0 1 0 0 -1;
run;

/*negative binomal regression*/ 
proc genmod data=nickel3;
class afe(ref='1')/ param=ref;
class yfe(ref='1')/ param=ref;
class tfe(ref='1')/ param=ref;
model NUMDEAD  = afe yfe tfe/ link=log  dist=negbin offset=log_py type3;
run;

