/*pm511b - hw2*/
/*Q5*/
data q5; 
input cancer $ treatment $ count; 
cards;
controlled surgery 21 
controlled radiation 15 
not_controlled surgery 2 
not_controlled radiation  3
;
run;
proc freq data = q5 order = data; 
table treatment*cancer/ fisher; 
weight count;
run;


data a;
p21=PDF('HYPER',21, 41,36, 23);
p22=PDF('HYPER',22, 41,36, 23);
p23=PDF('HYPER',23, 41,36, 23);

proc Print;
run;

/*The midpvalue for the one-side test among a is 0.24.*/
/*There are few tables in the small sample size situation, */
/*and therefore few possible p-values to sum. */
/*It is hard to obtain a significant p-value. */
/*The actual type 1 error rate is likely smaller than the nominal value (alpha)*/
/*The mid p-value take half the probability of the observed table and add the full */
/*probability of the more extreme tables, */
/*which makes the test less conservative and maintain the stated false positive rates at the same time. */

data a;
p18=PDF('HYPER',18, 41,36, 23);
p18test=PDF('HYPER',18, 41,23,36);
p19=PDF('HYPER',19, 41,36, 23);
p20=PDF('HYPER',20, 41,36, 23);
p21=PDF('HYPER',21, 41,36, 23);
p22=PDF('HYPER',22, 41,36, 23);
p23=PDF('HYPER',23, 41,36, 23);
pright=p21+p22+p23;
pmid=p21/2+p22+p23;
pleft=p18+p19+p20+p21;
p2side=p21+p22+p23+p18+p19;
proc Print;
run;

data c;
test=fact(6);
proc print;
run;
