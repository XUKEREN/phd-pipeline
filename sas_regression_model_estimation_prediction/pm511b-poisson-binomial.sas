/*pm511b - hw7*/
/*poisson regression and negative binomial regression*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw7\hw7.dta" out=mydata dbms = dta replace;
run;
proc contents data=mydata; run;
proc print data=mydata; run;

data mydata;
set mydata;
log_n = log(n);
run;

/*only constant*/
proc genmod data=mydata;
model totborn =  /link =log dist=poi offset=log_n type3;
estimate "intercept" intercept 1; 
run;

/*calculate the p-value*/
Data a; 
y = 1-probchi(3731.8516,69);
Proc print; 
run;
Data a; 
y = 1-probchi(3375.3497,69);
Proc print; 
run;

/*test for education*/
proc genmod data=mydata;
class educ (ref='None')/ param=glm;
model totborn = educ /link =log dist=poi offset=log_n type3 ;
lsmeans educ / ilink diff exp cl;
run;

/*calculate the p-value*/
Data a; 
y = 1-probchi(2660.9976,66);
Proc print; 
run;
Data a; 
y = 1-probchi(2426.9182,66);
Proc print; 
run;

/*adjusted for covariates test for educ*/
proc genmod data=mydata;
class educ (ref='None')/ param=glm;
class dur (ref='0-4')/param=glm;
class res (ref='Rural')/param=glm;
model totborn = educ dur res/link =log dist=poi offset=log_n type3;
lsmeans educ/ ilink diff exp cl BYLEVEL;
run;

/*second approach*/

proc genmod data=mydata;
class educ (ref='None')/ param=glm;
class dur (ref='0-4')/param=glm;
class res (ref='Rural')/param=glm;
model totborn = educ dur res/link =log dist=poi offset=log_n type3;
output out=out p=pcount xbeta=xb stdxbeta=std;
run;



         data predrates;
         set out;
         lograte=xb-log_n; /* predicted log rate */
         prate=exp(lograte);  /* predicted rate */
/*         lcl=exp(lograte-probit(.975)*std);*/
/*         ucl=exp(lograte+probit(.975)*std);*/
         keep n totborn educ dur res lograte prate;
         run;

		 proc sort data= predrates;
		 by educ;
		 run;

      proc means data=predrates;
      var  lograte prate;
	  by educ;
         run;

/*second approach end*/

/*calculate the p-value*/
Data a; 
y = 1-probchi(70.6653,59);
Proc print; 
run;
Data a; 
y = 1-probchi(71.5335,59);
Proc print; 
run;

/*negative binomal regression*/ 
proc genmod data=mydata;
class educ (ref='None')/ param=glm;
class dur (ref='0-4')/param=glm;
class res (ref='Rural')/param=glm;
model totborn = educ dur res/ link=log dist=negbin offset=log_n type3;
lsmeans educ / ilink diff exp cl;
run;
/*how to get more decimals*/

/*lsmeans
https://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_genmod_sect024.htm*/
