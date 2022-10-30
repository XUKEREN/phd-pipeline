/*pm511a - partial F test*/
DATA A;
SSE=551.723; 
/*residuals */
SSY=2387.653;
/*total*/
SST=SSY-SSE;
DF1=3;
/*regression df*/
DF2=22-3;
/*total df - regression df = residual df*/
MST=SST/DF1;
MSE=SSE/DF2;
F=MST/MSE;
R2=(ssy-sse)/ssy;
RUN;
proc print data=A; run;
Data b;
y = 1-probf(F,3,19);
Proc print; run;

/*Null hypothesis: beta for X1X3 = beta for X2X3 =0*/
/*F-partial=((SSTfull-SSTreduced)/(pfull-preduced))/(SSEfull/(n-pfull-1))*/
data a;
SSTfull=894.56737;
SSTreduced=819.74732;
pfull=5;
/*number of parameters except for the intercept*/
Preduced= 3;
SSEfull=3719.05168;     
n=42;
Fpartial=((SSTfull-SSTreduced)/(pfull-preduced))/(SSEfull/(n-pfull-1)) ;
df1=Pfull-Preduced;
df2=n-pfull-1;
alpha=0.05;
y = 1-probf(Fpartial,df1,df2); 
Proc print; 
format y pvalue6.; 
run;
