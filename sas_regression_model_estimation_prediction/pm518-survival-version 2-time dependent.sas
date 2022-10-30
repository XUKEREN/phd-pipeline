/*pm518 - survival analysis version 2 - lecture 12*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\frtcs3.csv" out=frtcs3 dbms=csv replace;
    getnames=yes;
run;
proc contents data=frtcs3;run;
proc print data=frtcs3; run;

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\wellhart_2012.csv" out=wellhart_2012 dbms=csv replace;
    getnames=yes;
run;
proc contents data=wellhart_2012;run;
proc print data=wellhart_2012; run;

/*class example*/
/*stset in stata first 

stset ageend, id(id) failure(cvdevent) enter(agestart)
*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\wellhart_2012.csv" out=wellhart_2012 dbms=csv replace;
    getnames=yes;
run;
proc contents data=wellhart_2012;run;
proc print data=wellhart_2012; run;

data wellhart_2012;
set wellhart_2012;
hdl_10=hdl/10;
ldl_25=ldl/25;
tg_100=tg/100;
gluc_50=glucose/50;
sbp_20=sbp/20;
dbp_10=dbp/10;
run;

/*counting process*/
proc phreg data = wellhart_2012;
class hrt(ref= "No")/param=ref; 
model (_t0, _t)*_d(0) = hrt /risklimits ;
run;

proc phreg data = wellhart_2012;
class Diabetes(ref= "No diabe")/param=ref; 
model (_t0, _t)*_d(0) = Diabetes /risklimits ;
run;

proc phreg data = wellhart_2012;
model (_t0, _t)*_d(0) = gluc_50 /risklimits ;
run;

proc phreg data = wellhart_2012;
class Diabetes(ref= "No diabe")/param=ref; 
model (_t0, _t)*_d(0) = Diabetes gluc_50 /risklimits ;
run;

proc phreg data = wellhart_2012;
class Diabetes(ref= "No diabe")/param=ref; 
model (_t0, _t)*_d(0) = Diabetes gluc_50 Diabetes*gluc_50/risklimits ;
hazardratio Diabetes/ diff=all;
hazardratio gluc_50/ diff=all;
run;

proc phreg data = wellhart_2012;
model (_t0, _t)*_d(0) = tg_100 /risklimits ;
run;

/* test the relation with survival for tx sex and grade*/
proc freq data= pharynx;
table TX*status/chisq;
run;

proc freq data=pharynx;
table sex*status/chisq;
run;

proc freq data=pharynx;
table grade*status/chisq;
run;

proc sort data=pharynx;by status;run;
proc means data=pharynx mean std;
var age;
by status;
run;


data pharynx;
set pharynx;
if grade=9 then grade = . ;
run;

ods graphics on; 
proc lifetest data=pharynx method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
run; 
ods graphics off;

ods graphics on; 
proc lifetest data=pharynx method=KM alpha=0.05 plots=survival(test) conftype=loglog outsurv=A stderr; 
time time*status(0); 
strata tx; 
run; 
ods graphics off;

/*cox regression*/

proc phreg data=pharynx; 
class sex(ref= first) tx(ref= first)/param=ref; 
model time*status(0)= sex tx sex*tx /risklimits covb ;
hazardratio 'all pairs' sex/ diff=all;
hazardratio 'all pairs' tx/ diff=all;
run;

