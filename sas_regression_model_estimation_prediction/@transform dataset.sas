/*transfer data to long format with each row as an observation based on the frequency variable */

data hw3;
input snoring disease count @@;
datalines;
0 1 24 
2 1 35 
4 1 21 
5 1 30 
0 0 1355 
2 0 603 
4 0 192 
5 0 224 
;
run;

/*transfer to the long format*/
data hw3_new (drop=i);
set hw3;
do i = 1 to count;
output;
end;
run;
proc print data=hw3_new;
run;
/*check the dataset*/
proc sort data=hw3_new;
by  disease snoring;
run;
proc freq data=hw3_new;
table snoring;
by disease;
run;


/*aggregate dataset*/
proc sql;
create table mydatanew as
select id, week, retailer, product_code, sum(quantity) as quantity, sum(total_price) as total_price
from hw3_new
group by id, week, retailer, product_code, id2, month, col3, col4 /*etc...*/
order by id, week, retailer, product_code;
quit;

data HAVE;
 input COUNTY $ SCHOOL $ 	ENROLLMENT 	VAX1 	VAX2 	SCHOOLTYPE $ ;
cards;
countyA 	littlet 	50 	48 	45 	private 	  	  	  	 
countyA 	happyda 	100 	88 	77 	public 	  	  	  	 
countyA 	playtim 	25 	22 	23 	private 	  	  	  	 
countyB 	busybee 	23 	22 	21 	public 	  	  	  	 
countyB 	childti 	27 	25 	25 	public
run;
option missing='0';
proc tabulate; 
  class COUNTY SCHOOLTYPE;
  var VAX1 ENROLLMENT;
  table COUNTY=''
      , (all SCHOOLTYPE='') *(ENROLLMENT=''*sum='Enrolment' *f=comma8.0 
                              VAX1=''      *(sum  ='Vax1'   *f=comma8.0 
                                             pctsum<ENROLLMENT>='%'))
      /box='County';
run;


/*I have the following data:*/
/*   Date                        SEDOL                         Volume*/
/*2013-03-15               5556586                         7, 000*/
/*2013-03-15               5556586                         8, 000*/
/*2013-03-15               5556586                         5, 000*/
/*2013-03-15               5556586                         2, 000*/
/*2014-03-15               5556587                         9, 000*/
/*2014-03-15               5556587                         6, 000*/
/*2014-03-15               5556587                         5, 000*/
/*2014-03-15               5556587                         5, 000*/
/*I need the data like this*/
/*   Date                        SEDOL                         Volume*/
/*2013-03-15               5556586                         22, 000*/
/*2014-03-15               5556587                         25, 000*/
/*Thanks in advance for your help. Cheers!*/
proc summary data = have;
    class date sedol;
    var volume;
    output out=want sum=;
run;
proc summary data=whatever;
    class riskgrade data_period;
    var eur obs_1 obs_2 obs_3;
    output out=want sum=sum_eur sum_obs_1 sum_obs_2 sum_obs_3 n(eur)=n;
run;
