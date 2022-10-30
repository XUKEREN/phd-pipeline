
/*Estimating an odds ratio for a variable involved in an interaction*/

data uti;
         input diagnosis : $13. treatment $ response $ count @@;
         datalines;
      complicated    A  cured 78  complicated   A not 28
      complicated    B  cured 101 complicated   B not 11
      complicated    C  cured 68  complicated   C not 46
      uncomplicated  A  cured 40  uncomplicated A not 5
      uncomplicated  B  cured 54  uncomplicated B not 5
      uncomplicated  C  cured 34  uncomplicated C not 6
      ;

    proc logistic data=uti;
         freq count;
         class diagnosis treatment / param=glm;
         model response(event="cured") = diagnosis treatment diagnosis*treatment;
         oddsratio treatment / at(diagnosis='complicated');
         lsmeans diagnosis*treatment / ilink oddsratio diff;
         slice diagnosis*treatment / sliceby(diagnosis='complicated') diff oddsratio;
/*same results from lsmestimate, estimate, and contrast*/
         lsmestimate diagnosis*treatment 'A vs C complicated' 1 0 -1 / exp;
         estimate 'A vs C in complicated' treatment 1 0 -1
                  diagnosis*treatment 1 0 -1 0 0 0 / exp;
         contrast 'A vs C in complicated' treatment 1 0 -1
                  diagnosis*treatment 1 0 -1 0 0 0 / estimate=exp;
         run;

/*complicated 1 0*/
/*A 1 0 0 */
/*B 0 1 0 */
/*C 0 0 1*/
/**/
/*trtment term*/
/*A 1 0 0*/
/*C 0 0 1*/
/*A vs C 1 0 -1*/
/**/
/*interaction term*/
/*A and complicared*/
/*1 0 0 0 0 0*/
/*C and complicated*/
/*0 0 1 0 0 0*/
/*A versus C in complicated 1 0 -1 0 0 0*/


/*proc genmod*/
proc genmod data=six descending;
         class case city;
         model wheeze = city age smoke / dist=bin;
         repeated subject=case / type=exch;
         estimate "log O.R. Age" age 1 / exp;
         estimate "log O.R. Kingston vs Portage" city 1 -1 / exp;
         lsmeans city / ilink exp diff cl;
         lsmestimate city 'Kingston vs Portage' 1 -1 / exp cl;
         run;


/*Usage Note 24447: Examples of writing CONTRAST and ESTIMATE statements*/
/*Example 1: A Two-Factor Model with Interaction*/
data test;
   seed=6342454;
   do a=1 to 5;
      do b=1 to 2;
         do rep=1 to ceil(ranuni(seed)*5)+5;
            y=5 + a + b + a*b + rannor(seed);
            output;
         end;
      end;
   end;
run;
proc print data = test;
run;
/*a has 5 levels, b has 2 levels*/
/*use lsmeans to calculate all the means*/
proc mixed data=test;
   class a b;
   model y=a b a*b / solution;
   lsmeans a*b / e; /*lsmeans with e will provide oefficient vector*/
run;

/*use estimate the specify which mean we want to calculate*/
proc mixed data=test; class a b;
model y=a b a*b; 
lsmeans a*b;
estimate 'AB11' 
intercept 1
a 1 0 0 0 0 
b 1 0
a*b 1 0 0 0 0 0 0 0 0 0; 
estimate 'AB12' 
intercept 1
a 1 0 0 0 0 
b 0 1
a*b 0 1 0 0 0 0 0 0 0 0; 
/*estimate 'AB12new'*/
/*intercept 1*/
/*a 1 0 0 0 0 */
/*b 0 1*/
/*a*b 0 0 0 0 0 1 0 0 0 0; */
/*wrong numbers since we need ot use b multiples each cell of a
 no to use a to multiple each cell of b*/
run;

proc mixed data=test; 
class a b;
model y= a b a*b; 
lsmeans a*b / diff; /*lsmeans with diff will provide all the differences*/
lsmestimate a*b 'AB11 - AB12' 1 -1 0 0 0 0 0 0 0 0; 
slice a*b / sliceby(a='1') diff; 
contrast 'AB11 - AB12' 
/*Note that the coefficients for the INTERCEPT and A effects cancel out, */
/*removing those effects from the final coefficient vector. */
/*However, coefficients for the B effect remain in addition to coefficients for the A*B interaction effect.*/
b 1 -1
a*b 1 -1 0 0 0 0 0 0 0 0; 
/*You can also duplicate the results of the CONTRAST statement with an ESTIMATE statement. */
/*Note that the ESTIMATE statement displays the estimated difference in cell means (–2.5148) */
/*and a t-test that this difference is equal to zero, */
/*while the CONTRAST statement provides only an F-test of the difference. */
/*The tests are equivalent.*/
estimate 'AB11 - AB12' 
b 1 -1 
a*b 1 -1 0 0 0 0 0 0 0 0; 
run;


/*A Two-Factor Logistic Model with Interaction Using Dummy and Effects Coding*/
data uti;
   input diagnosis : $13. treatment $ response $ count @@;
   datalines;
complicated    A  cured 78  complicated   A not 28
complicated    B  cured 101 complicated   B not 11
complicated    C  cured 68  complicated   C not 46
uncomplicated  A  cured 40  uncomplicated A not 5
uncomplicated  B  cured 54  uncomplicated B not 5
uncomplicated  C  cured 34  uncomplicated C not 6
;
run;
proc print data = uti;
run;
proc logistic data=uti; freq count;
class diagnosis treatment / param=glm;
model response(event='cured') = diagnosis treatment diagnosis*treatment; 

contrast 'trt A vs C in comp' 
treatment 1 0 -1 
diagnosis*treatment 1 0 -1 0 0 0 / estimate=both;
output out=out xbeta=xbeta; 

oddsratio treatment / at(diagnosis='complicated');

lsmeans diagnosis*treatment / ilink exp diff;
lsmestimate diagnosis*treatment 'A vs C complicated' 1 0 -1 / exp; 
slice diagnosis*treatment / sliceby(diagnosis='complicated') diff exp;

run;

/*treatment a 1 0 0*/
/*treatment c 0 0 1*/
/*diagnosis complicated 1 0 */
/*diagnosis uncomp 0 1 */
/*diagnosis complicated * treatment a : 1 0 * 1 0 0 = 1 0 0 0 0 0 */
/*diagnosis comp * treatment c: 0 0 1 0 0 0*/

/*The XBETA= option in the OUTPUT statement requests the linear predictor, x'ß, */
/*for each observation. This is the log odds. */
/*The following statements print the log odds for treatments A and C in the complicated diagnosis.*/
proc print data=out noobs;
where diagnosis="complicated" and response="cured" and treatment in ("A","C"); 
var diagnosis treatment xbeta; 
run;

/*proc genmod can also be used to estimate the odds ratio*/
proc genmod data=uti; freq count;
class diagnosis treatment;
model response = diagnosis treatment diagnosis*treatment / dist=binomial; 
estimate 'trt A vs C in comp' treatment 1 0 -1 diagnosis*treatment 1 0 -1 0 0 0 / exp;

lsmeans diagnosis*treatment / ilink exp diff;
lsmestimate diagnosis*treatment 'A vs C complicated' 1 0 -1 / exp; 
slice diagnosis*treatment / sliceby(diagnosis='complicated') diff exp;

run;



/*Example 4: Comparing Models*/
