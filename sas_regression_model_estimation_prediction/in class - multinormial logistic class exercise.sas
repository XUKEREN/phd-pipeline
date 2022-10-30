proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\pathology.csv" out=pathology dbms=csv replace;
    getnames=yes;
run;
proc contents data=pathology;
run;
proc print data=pathology;
run;

data pathology (drop=i);
set pathology;
do i = 1 to count;
output;
end;
run;
proc print data=pathology;
run;

proc logistic data = pathology; 
class apoe4(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 / link = glogit;
run;

proc logistic data = pathology; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = female / link = glogit;
run;

proc logistic data = pathology; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = female / link = glogit equalslopes ;
run;


proc logistic data = pathology; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = female / link = glogit unequalslopes;
run;

proc logistic data = pathology; 
class apoe4(ref = '0') / param = ref; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 female / link = glogit;
run;

proc logistic data = pathology; 
class apoe4(ref = '0') / param = ref; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 female / link = glogit equalslopes=female;
run;

proc logistic data = pathology; 
class apoe4(ref = '0') / param = ref; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 female / link = glogit;
run;


/*interaction*/
proc logistic data = pathology; 
class apoe4(ref = '0') / param = ref; 
class female(ref = '0') / param = ref; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 female apoe4*female/ link = glogit;
run;


/*predicted probabilities from the model*/
/*use the fitted model to obtain predicted probabilities for each of the outcomes
for given covariate patterns*/
proc logistic data = pathology; 
class apoe4(ref = '0') / param = glm; 
class female(ref = '0') / param = glm; 
class outcome (ref = 'no pathology'); 
model outcome = apoe4 female apoe4*female/ link = glogit;
lsmeans apoe4*female / ilink exp diff or;
run;

 lsmeans diagnosis*treatment / ilink exp diff;
   lsmestimate diagnosis*treatment 'A vs C complicated' 1 0 -1 / exp;
   slice diagnosis*treatment / sliceby(diagnosis='complicated') diff exp;

/*how to use Joint Tests???*/
/*how to use estimate to replace lincom???*/
/*how to use restrict to replace constraint???*/
/*https://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_logistic_sect058.htm*/
/*https://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_introcom_a0000003021.htm*/

/*likelihood ratio test to replace the contraint command in stata*/
/*for female*/
data lrt_pval;
        LRT = abs(998.532-1030.994);
        df  = 1;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;

/*for age*/
   data lrt_pval;
        LRT = abs(998.532-1068.748);
        df  = 1;
        p_value = 1 - probchi(LRT,df);
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;		

