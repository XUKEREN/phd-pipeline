libname library 'C:\Users\xuker\Downloads\@USC\18fall-PM511A- Data Analysis\final project-pm511';
run; 
/*take a look at the dataset*/
data mydata;
set library.nhanes2000_326;
run;
proc contents data = mydata;run;

/*set decimal place*/
proc format; 
picture stderrf (round) 
low-high=' 9.99)' (prefix='(')
.=' ';
run;

ods output ParameterEstimates (persist) = t;
proc reg data = mydata;
model BPsys = male/clb; 
model BPsys = male bmi/clb; 
model BPsys = male bmi htin/clb; 
model BPsys = male bmi htin smoke/clb; 
model BPsys = male bmi htin smoke wtlbs/clb;
run;
ods output close;
proc print data=t; run;
proc tabulate data=t noseps; 
class model variable; 
var estimate stderr LowerCL UpperCL ; 
table variable=''*(estimate =' '*sum=' ' stderr=' '*sum=' '  *F=stderrf.),
model=' ' 
/ box=[label="Parameter"] rts=15 row=float misstext=' ';
run;
