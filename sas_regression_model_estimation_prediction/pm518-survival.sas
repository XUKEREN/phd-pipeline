/*pm518 - hw7 - survival analysis*/

proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw5\nickel.csv" out=nickel dbms=csv replace;
    getnames=yes;
run;
proc contents data=nickel;run;
proc print data=nickel; run;

/*clean the data*/
data nickel;
set nickel;
yfe=dob+afe;
run;

data nickel;
set nickel;
afecat=4;
if afe lt 20 then afecat=1;
if afe le 27.4 and afe ge 20.0 then afecat=2;
if afe le 34.9 and afe ge 27.5 then afecat=3;
yfecat=4;
if yfe ge 1902 and yfe lt 1910 then yfecat=1;
if yfe ge 1910 and yfe lt 1915 then yfecat=2;
if yfe ge 1915 and yfe lt 1920 then yfecat=3;
run;

data nickel;
set nickel;
exposcat=2;
if expos=0 then exposcat=0;
if expos gt 0 and expos le 8.0 then exposcat=1;
run;

data nickel;
set nickel;
agestartdic=0;
if agestart ge 45 then agestartdic=1;
run;

proc print data=nickel;
run;


/*question 1: STSET the data*/
data nickel;
set nickel;
t0=AGESTART-AFE;
t1=AGEEND-AFE;
run;

data nickel;
set nickel;
exposcat5=4;
if expos=0 then exposcat5=0;
if expos gt 0 and expos le 4.0 then exposcat5=1;
if expos gt 4.0 and expos le 8.0 then exposcat5=2;
if expos gt 8.0 and expos le 12.0 then exposcat5=3;
run;

proc sort data=nickel; by exposcat5; run;
proc means data = nickel min max;
var expos;
by exposcat5;
run;

/*question 2: STCOX*/
data nickel;
set nickel;
status=0;
if icdcode=160 then status=1;
run;
proc phreg data = nickel;
class afecat (ref= '1')/param=ref; 
model (t0, t1)*status(0) = afecat /risklimits;
run;
proc phreg data = nickel;
class yfecat (ref= '1')/param=ref; 
model (t0, t1)*status(0) = yfecat /risklimits ;
run;
proc phreg data = nickel;
class exposcat5 (ref= '0')/param=ref; 
model (t0, t1)*status(0) = exposcat5 /risklimits;
run;

proc phreg data = nickel;
model (t0, t1)*status(0) = afe /risklimits;
run;
proc phreg data = nickel;
model (t0, t1)*status(0) = yfe /risklimits ;
run;
proc phreg data = nickel;
model (t0, t1)*status(0) = expos /risklimits;
run;

 data lrt_pval;
        LRT = 621.566-619.210;
        df  = 2;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;

data lrt_pval;
        LRT = 643.851-632.709;
        df  = 2;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;


data lrt_pval;
        LRT = 619.706-614.640;
        df  = 3;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;

/*question 3*/
proc phreg data = nickel;
class afecat (ref= '1')/param=ref; 
class yfecat (ref= '1')/param=ref; 
class exposcat5 (ref= '0')/param=ref; 
model (t0, t1)*status(0) = afecat yfecat exposcat5/risklimits type3(LR);
run;


proc phreg data = nickel;
class afecat (ref= '1')/param=ref; 
class yfecat (ref= '1')/param=ref; 
class exposcat5 (ref= '0')/param=ref; 
model (t0, t1)*status(0) = afecat yfecat exposcat5/risklimits type3(LR);
output out=schoen 
ressch=schafecat schyfecat schexposcat5;
run;
data schoen; 
set schoen; 
lenfol=t1-t0;
run;
proc loess data = schoen; 
model schafecat=lenfol / smooth=(0.2 0.4 0.6 0.8); 
run; 
proc loess data = schoen; 
model schyfecat=lenfol / smooth=(0.2 0.4 0.6 0.8); 
run;
proc loess data = schoen; 
model schexposcat5=lenfol / smooth=(0.2 0.4 0.6 0.8); 
run;
proc corr data=schoen;
var schafecat schyfecat schexposcat5;
with lenfol;
run;

data nickel;
set nickel;
lenfol=t1-t0;
run;


/*question 4*/
/*Using the multivariable model in #3, plot the predicted survival curves for: */
/*a. A hypothetical subject with 10 years of exposure, who was 34 years old when first employed in 1918.*/
/*b. A subject with the same covariates as above, except having 0 years of exposure.  */

data Inrisks;
   length Id $30;
   input afecat yfecat exposcat5 Id $8-37;
   datalines;
3 3 3  afecat=3 yfecat=3 exposcat5=3
3 3 0  afecat=3 yfecat=3 exposcat5=0
;
run;
proc print data=Inrisks;
run;

ods graphics on;
proc phreg data = nickel plots=survival;
class afecat (ref= '1')/param=ref; 
class yfecat (ref= '1')/param=ref; 
model (t0, t1)*status(0) = afecat yfecat exposcat5;
baseline covariates=Inrisks out=Pred1 survival=_all_/rowid=Id;
run;

proc print data=Pred1;
run;

