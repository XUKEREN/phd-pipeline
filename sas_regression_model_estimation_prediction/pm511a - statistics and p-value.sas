/*Z-distribution*/
/*the area to the left of Z=1.96, Pr(Z<1.96):*/
data a;
y=probnorm(1.96);
proc print;
run;
/*the area to the right of Z=1.96, Pr(Z>1.96):*/
data a;
y=1-probnorm(1.96);
proc print;
format y pvalue6.; 
run;
/*two sided p-value corresponding to Z=1.96, Pr(z<-1.96 or Z>1.96):*/
data a;
y=(1-probnorm(1.96))*2;
y=probnorm(-1.96)*2;
y=(1-probnorm(abs(-1.96)))*2;
proc print;
format y pvalue6.; 
run;
/*find the Z-value corresponding to the 95th percentile of the standard normal, Pr(Z<?)=0.95:*/
data a;
y=probit(0.95);
proc print;
run;
/*T-distribution*/
/*find a 2-sided p-value corresponding to T=2.25 for a distribution with 10 df Pr(|T10|>2.25=?)*/
data a;
y=2*probt(-2.25,10);
y=2*[1-probt(2.25,10)];
proc print;
format y pvalue6.; 
run;
/*find the t-value corresponding to the 95% percentile of the t-distribution with 10 df, Pr(T<?)=0.95:*/
data a;
y=tinv(0.95,10);
proc print;
run;
/*chi square distribution*/
y=probchi(value, df)
/*find the area to the left 3.0 assuming a chi-square distribution with 2 df 
[Pr( \mathbit{x}_\mathbf{2}^\mathbf{2}< 3) = ?]*/
Data a; 
y = probchi(3.0,2);
Proc print; 
format y pvalue6.; 
title ‘Area to left of 3.0 in chi-sq_2 distribution’;
run;
/*find a 2-sided p-value corresponding to X=3.84, assuming X2 distribution with 1 df 
[ equivalently, Pr( \mathbit{x}_\mathbf{1}^\mathbf{2}> 3.84) = ?]*/
Data a; 
y = 1-probchi(3.84,1);
Proc print; 
format y pvalue6.; 
title ‘2-sided P-value for X=3.84 in chi-sq_1 distribution’; 
run;
/*find the 68th percentile of the X2 distribution (left hand side area) with 1 df [equivalently, 
Pr( \mathbit{x}_\mathbf{1}^\mathbf{2}< ?) = .68]*/
Data a; 
y = cinv(0.68,1);
Proc print; 
title ’68th percentile of the chi-sq_1 distribution’; 
run;

/*F distribution*/
/*y=probf(value, df1, df2)*/
/*find the 2-sided p-value corresponding to F=5.0625 (=2.252), for 1 and 10 df*/
Data a; 
y = 1-probf(5.0625,1,10); /*df1=1, df2=10*/
Proc print; 
format y pvalue6.; 
title ‘2-sided p-value for R=5.06 in F_1_10 distribution’; 
run;
/*find the 95th quantile value of a F distribution with 2 and 10 degrees of freedom*/
Data a; 
y = finv(0.95,2,10);
proc print;
run;
