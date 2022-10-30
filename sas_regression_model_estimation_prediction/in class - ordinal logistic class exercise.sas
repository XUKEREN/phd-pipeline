proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\depress_ord.csv" 
out=depress_ord dbms=csv replace;
    getnames=yes;
run;
proc contents data=depress_ord;
run;
proc print data=depress_ord;
run;

ods graphics on; 
proc logistic data=depress_ord plots(only)=oddsratio; 
class race (ref='1')/param=ref; 
model depress = race; oddsratio race; effectplot / polybar;
run; ods graphics off;

ods graphics on; 
proc logistic data=depress_ord plots(only)=oddsratio; 
class gender (ref='0')/param=ref; 
model depress = gender; oddsratio gender; effectplot / polybar;
run; ods graphics off;

ods graphics on; 
proc logistic data=depress_ord plots(only)=oddsratio; 
class agecat (ref='1')/param=ref; 
model depress = agecat; oddsratio agecat; effectplot / polybar;
run; ods graphics off;

/*wald test to compare hispanic and asian*/
ods graphics on; 
proc logistic data=depress_ord plots(only)=oddsratio; 
class gender (ref='0')/param=ref; 
class race (ref='3')/param=ref; 
model depress = race gender; oddsratio race gender; effectplot / polybar;
run; ods graphics off;

/*LRT to compare hispanic and asian*/
/*use constraint command*/
