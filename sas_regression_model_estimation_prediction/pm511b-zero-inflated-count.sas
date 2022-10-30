/*pm511b - lecture 11*/
/*zero-inflated count data*/
/*set system, read macro*/
options nocenter ps=78 ls=125 replace formdlim='['
mautosource 
sasautos=('C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\macro');

OPTIONS nofmterr;
libname library "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep\19spring-pm511b";
PROC print DATA=library.fish;
RUN;
data fish;
set library.fish;
run;

/*first,  look at the data*/
proc means data = fish mean std min max var;
  var count child persons;
run;
proc univariate data = fish noprint;
  histogram count / midpoints = 0 to 50 by 1 vscale = count ;
run;
proc freq data = fish;
  tables camper;
run;
proc genmod data = fish;
  class camper;
  model count = child camper /dist=zip;
  zeromodel persons /link = logit;
run;
/*intercept model*/
proc genmod data = fish;
  model count =  /dist=zip;
  zeromodel  / link = logit ;
run;
/*df =3 when comparing prior model with this intercept model*/

/*use Vuong Test to compare ZIP with poisson model*/
proc genmod data = fish order=data;
  class camper;
  model count = child camper /dist=zip;
  zeromodel persons;
  output out=outzip pred=predzip pzero=p0;
  store m1;
run;
proc genmod data = outzip order=data;
  class camper;
  model count = child camper /dist=poi;
  output out=out pred=predpoi;
run;
%vuong(data=out, response=count,
       model1=zip, p1=predzip, dist1=zip, scale1=1.00, pzero1=p0, 
       model2=poi, p2=predpoi, dist2=poi, scale2=1.00,
       nparm1=3,   nparm2=2)

/*We will compute the expected counts for the categorical variable camper */
/*while holding the continuous variable child at its mean value using the atmeans option, */
/*as well as calculate the predicted probability that an observation came from the zero-generating process.*/
proc genmod data = fish;
  class camper;
  model count = child camper /dist=zip;
  zeromodel persons /link = logit ;
  estimate "camper = 0" intercept 1 child .684 camper 1 0 @ZERO intercept 1 persons 2.528; 
  estimate "camper = 1" intercept 1 child .684 camper 0 1 @ZERO intercept 1 persons 2.528; 
run;

/*use countreg*/
proc countreg data = fish method = qn;
  class camper;
  model count = child camper / dist= zip;
  zeromodel count ~ persons;
run;


/*age is significantly associated with days of hispital stay (p<0.0001), 
adjusted for surgery type, gender, diabetes and atrial fibrillation
model predicted mean (95% CI) days in hospital are: 9.06 (8.27 - 9.86) for age <=60,
or 
compared to age no more than 60, mean days in hospital was ***% higher (CI 11%, 33%)
