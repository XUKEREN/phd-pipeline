/*pm511b - hw6*/
/*exact logistic regression*/
proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm511b\hw6\hw6_1.dta" out=mydata dbms = dta replace;
run;
proc print data=mydata;
run;

/*create formats*/
proc format;
	value racef	1 = 'Non-Hispanic white'
		  		2 = 'African-American'
				3='Hispanic white'
				4='Asian'
				;

	value malef	1 = 'male'
			0 = 'female'
			;

	value overweightf      1 = 'overweight'
				0 = 'normal weight';
	value hibpf 1= "Yes" 
			   0 = "No";
run;

data mydata;
set mydata;
	format race racef. 
		   male malef.
		   overweight overweightf.
           hibp hibpf.;
run;
proc contents data=mydata; run;
proc print data=mydata;run;

/*Tabulate */ 
proc freq data=mydata;
table hibp*race;
table hibp*male;
table hibp*overweight;
run;

/*logistic regression */
proc logistic data = mydata; 
class race (ref = 'Non-Hispanic white') / param = ref; 
class hibp (ref = 'No')/ param = ref; 
model hibp = race / link = glogit;
run;  

/*exact logistic regression*/
proc logistic data = mydata; 
class race (ref = 'Non-Hispanic white') / param = ref; 
class hibp (ref = 'No')/ param = ref; 
model hibp = race / link = glogit;
exact race / estimate=both;
run; 

/*conditioning on male and overnight*/
proc logistic data = mydata; 
class race (ref = 'Non-Hispanic white') / param = ref; 
class male (ref = 'female') / param = ref; 
class overweight (ref = 'normal weight') / param = ref; 
class hibp (ref = 'No')/ param = ref; 
model hibp = race male overweight/ link = glogit;
exact race / estimate=both;
run; 

proc logistic data = mydata; 
class race (ref = 'Non-Hispanic white') / param = ref; 
class male (ref = 'female') / param = ref; 
class overweight (ref = 'normal weight') / param = ref; 
class hibp (ref = 'No')/ param = ref; 
model hibp = race male overweight/ link = glogit;
exact race male overweight/ estimate=both;
run; 
