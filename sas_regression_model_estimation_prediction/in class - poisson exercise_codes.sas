/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*PM511B LECTURE 10*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/
/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/

/**/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\units.csv" out=units dbms=csv replace;
    getnames=yes;
run;
proc contents data=units;run;
proc print data=units; run;

proc freq data=units;
table units;
run;

proc sort data=units;
by white;
run;

proc means data=units n mean ;
var units;
by white ;
run;

proc sort data=units;
by miavr;
run;

proc means data=units n mean ;
var units;
by miavr;
run;

proc sort data=units;
by white;
run;

proc means data=units n mean ;
var units;
by white;
run;

data units;
set units;
log_N = log(pop);
log_PY=log(pop*6-3*dead);
run;

/*only constant*/
proc genmod data=units;
model units  =  /link =log dist=poi type3;
run;

/*with miavr*/
proc genmod data=units;
class miavr (ref='0')/ param=ref;
model units  = miavr /link =log dist=poi type3;
run;

proc genmod data=units;
class miavr (ref='0')/ param=glm;
class male (ref='0')/ param=glm;
class hx_db (ref='0')/ param=glm;
class bmicat (ref='0')/ param=glm;
model units  = miavr agecent male hx_db bmicat /link =log dist=poi type3;
run;

proc genmod data=units;
class miavr (ref='0')/ param=glm;
class male (ref='0')/ param=glm;
class hx_db (ref='0')/ param=glm;
class bmicat (ref='0')/ param=glm;
model units  = miavr agecent male hx_db bmicat /link =log dist=poi type3;
output out=out p=pcount xbeta=xb stdxbeta=std;
run;

      data predrates;
         set out;
         lognum=xb;
         pnum=exp(lognum);  /* predicted num */
         lcl=exp(lognum-probit(.975)*std);
         ucl=exp(lognum+probit(.975)*std);
         keep units pnum miavr agecent male hx_db bmicat lcl ucl;
         run;

      proc print data=predrates;
         id  units;
         run;


proc genmod data=insure;
         class car age;
         model c = car age / dist=poisson link=log offset=ln;
         estimate "Rate: age=1, small" intercept 1 age 1 0 car 0 0 1;
         run;


/* awards dataset */
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\awards.csv" out=awards dbms=csv replace;
    getnames=yes;
run;
proc contents data=awards;run;
proc print data=awards; run;

/*estimate RR and the CI for each factor*/
/*methods 1 use plm hand calculate*/
proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = prog math /link =log dist=poi type3;
store p1;
run;

ods output ParameterEstimates = est;
proc plm source = p1;
show parameters;
run;
data est_exp;
set est;
irr = exp(estimate);
         lcl=exp(Estimate-probit(.975)*StdErr);
         ucl=exp(Estimate+probit(.975)*StdErr);
if parameter ^= "Intercept";
run;
proc print data= est_exp;
run;



/*mathods 2 use estimate and lsmeans*/
proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = prog math /link =log dist=poi type3;
lsmeans prog  / ilink diff exp cl;
/*only estimate allows continuous variables*/
estimate "math" math 1; 
run;

proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = prog math /link =log dist=poi type3;
estimate "Rate: age=1, small" intercept 1 age 1 0 car 0 0 1;
run;


/*Predicting counts*/
proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = prog math /link =log dist=poi type3;
output out=out p=pcount xbeta=xb stdxbeta=std;
run;

/*METHOD 1*/
      data predrates;
         set out;
         lognum=xb;
         pnum=exp(lognum);  /* predicted num */
         lcl=exp(lognum-probit(.975)*std);
         ucl=exp(lognum+probit(.975)*std);
         keep num_awards prog math pnum lcl ucl;
         run;

      proc print data=predrates;
         id  num_awards;
         run;

proc sort data=predrates;
by prog;
run;

/*create the scatter plot grouped by program*/
proc sgplot data=predrates;                                                                                                                                                                            
loess y=pnum x=math/ group=prog;     
run;    

/*METHOD 2 - not working since this poisson regression
proc plm only can produce log(), we need to exp the outcome
*/
proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = prog math /link =log dist=poi type3;
store P1;
run;

proc plm restore=P1;
estimate 'pred loss, MATH=41, PROG=vocation' intercept 1 math 41 PROG 0 1 0/e; 
run;


/*lecture 11 - week 13 exercise */
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\trains.csv" out=train dbms=csv replace;
    getnames=yes;
run;
proc contents data=train;run;
proc print data=train; run;

data train;
set train;
log_km= log(km);
timenew=time-1975;
run;

proc genmod data=train;
model collisions  = timenew /link =log dist=poi offset=log_km type3;
run;

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hospital_er_admits.csv" out=er dbms=csv replace;
    getnames=yes;
run;
proc contents data=er;run;
proc print data=er; run;

data er;
set er;
log_tot1= log(tot1);
run;
proc genmod data=awards;
class prog (ref='general')/ param=glm;
model num_awards  = tot4 math /link =log dist=poi type3 offset=log_tot1;
run;  


/*poisson regression diagnosis*/
ods graphics on;
proc genmod data=units;
class miavr (ref='0')/ param=glm;
class male (ref='0')/ param=glm;
class hx_db (ref='0')/ param=glm;
class bmicat (ref='0')/ param=glm;
model units  = miavr agecent male hx_db bmicat /link =log dist=poi type3 influence;
output out=out p=pcount xbeta=xb stdxbeta=std;
run;
quit;
ods graphics off;

/*predicted # versus observed #*/


/*compare Poisson with negbin*/
