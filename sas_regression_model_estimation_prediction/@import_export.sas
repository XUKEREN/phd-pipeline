/*different ways of importing dataset*/
/*import dataset*/
/*if it is stata file: */
/*convert file to stata version 12*/
/*saveold hsb_old.dta, version(12) replace*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\final project\framingham_2019" 
out=mydata dbms = dta replace;
run;
/*if it is sas file:*/
/*read dataset without format*/
OPTIONS nofmterr;
libname library "C:\Users\xuker\Downloads\@@screening_exam_prepare\@kx apply prep";
PROC print DATA=library.***;
RUN;


/*export dataset*/
/*export dataset to a SAS dataset*/
data library.***;
set work.***;
run;


/*export dataset to a stata permanent datafile*/
proc export data=tuyns2_new outfile='C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw2\tuyns2_new.dta' 
dbms = dta replace;
run;


/*## input with format*/
/*[HOW DO I READ IN A CHARACTER VARIABLE WITH VARYING LENGTH IN A SPACE DELIMITED DATASET? ]*/
/*(https://stats.idre.ucla.edu/sas/faq/how-do-i-read-in-a-character-variable-with-varying-length-in-a-space-delimited-dataset/)*/
/*- use & before $19.*/
/*- use two space between character and number, e.g. progressive_disease and 28*/

data hw5; 
input therapy $ gender $ response & $19. counts; 
cards;
sequential male progressive_disease  28
sequential female progressive_disease  4
alternating male progressive_disease  41
alternating female progressive_disease  12
sequential male no_change  45
sequential female no_change  12
alternating male no_change  44
alternating female no_change  7
sequential male partial_remission  29 
sequential female partial_remission  5 
alternating male partial_remission  20 
alternating female partial_remission  3 
sequential male complete_remission  26 
sequential female complete_remission  2
alternating male complete_remission  20
alternating female complete_remission  1
;
run;

proc contents data=hw5;
run;
proc print data=hw5;
run;
