/*pm518 - survival analysis - competing risk - week 14*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\bc_compete.dta" out=mydata dbms = dta replace;
run;
proc print data=mydata;
run;

proc freq data= mydata;
table status*drug/chisq;
run;
/*borderline significance*/

proc phreg data=mydata;
class drug / param=glm order=internal ref=first;
model time*Status(0) = drug / eventcode=2;
run;

proc phreg data=mydata;
class drug / param=glm order=internal ref=first;
model time*Status(0) = drug / eventcode=1;
run;

/*create ID*/
data mydata;
set mydata;
ID=_n_;
run;

/*competing risk*/
proc phreg data=mydata plots(overlay=stratum)=cif; 
class drug (order=internal ref=first); 
model time*Status(0)=drug / eventcode=1 ;
run;

proc phreg data=mydata plots(overlay=stratum)=cif; 
class drug (order=internal ref=first); 
model time*Status(0)=drug / eventcode=2;
run;

/*cause specific hazard*/
proc phreg data=mydata;
class drug (order=internal ref='0'); 
model time*Status(0,2)=drug;
run;
proc phreg data=mydata;
class drug (order=internal ref='0'); 
model time*Status(0,1)=drug;
run;

/*PH assumption test*/

/*parametric survival models*/
