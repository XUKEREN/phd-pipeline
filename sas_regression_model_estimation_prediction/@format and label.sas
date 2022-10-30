proc import datafile="C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw2\tuyns2.csv" out=tuyns2 dbms=csv replace;
    getnames=yes;
run;
proc contents data=tuyns2;run;
proc print data=tuyns2; run;
/*check for missing data*/
PROC FREQ DATA=tuyns2 ;
  TABLES age_group alcohol tobacco disease numsub ;
RUN ;  
/*dichtomize alochol*/
data tuyns2_new;
set tuyns2;
alcohol_dic=0;
if alcohol=3 or alcohol=4 then alcohol_dic=1;
run;
/*check*/
proc freq data=tuyns2_new;
table alcohol*alcohol_dic;
run;
/*dichtomize tobacco*/
data tuyns2_new;
set tuyns2_new;
tobacco_dic=0;
if tobacco=3 or tobacco=4 then tobacco_dic=1;
run;
/*check*/
proc freq data=tuyns2_new;
table tobacco*tobacco_dic;
run;

/*create formats*/
proc format;
	value age_groupf	1 = '25-34'
		  				2 = '35-44'
						3='45-54'
						4='55-64'
						5='65-74'
						6='75+';

	value alcoholf	1 = '0-39'
					2 = '40-79'
					3 = '80-119'
					4 = '120+';

	value alcohol_dicf	0 = '0-79'
						1 = '80+';

    value tobaccof	1 = '0-9'
					2 = '10-19'
					3 = '20-29'
					4 = '30+';

	value tobacco_dicf	0 = '0-19 '
						1 = '20+';
	value diseasef 	0 = 'Control'
				 	1 = 'Case';
run;

data tuyns2_new;
set tuyns2_new;
	format age_group age_groupf. 
		   alcohol alcoholf.
		   alcohol_dic alcohol_dicf.
		   tobacco tobaccof.
		   tobacco_dic tobacco_dicf.
           disease diseasef.;
	label age_group = 'Age group (years)';
	label alcohol = 'Alcohol (gms/day)';
	label alcohol_dic = 'Dichotomous Alcohol (gms/day)';
	label tobacco = 'Tobacco (gms/day)';
	label tobacco_dic = 'Dichotomous Tobacco (gms/day)';
	label disease = 'Disease';
    label numsub = 'Number of subjects';
run;
proc contents data=tuyns2_new; run;

/*export dataset to a stata permanent datafile*/
proc export data=tuyns2_new outfile='C:\Users\xuker\Downloads\@USC\19spring-pm518a\hw2\tuyns2_new.dta' dbms = dta replace;
run;
