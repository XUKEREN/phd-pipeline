/*create variables for quartiles*/
proc rank data=subjdata_326 out=out1 groups=4;
var WEIGHT;
ranks WEIGHT_RANK;
run;

/*The only 2-quantile is called the median*/
/*The 3-quantiles are called tertiles or terciles ? T*/
/*The 4-quantiles are called quartiles ? Q; the difference between upper and lower quartiles is also called the interquartile range, midspread or middle fifty ? IQR = Q3 -  Q1*/
/*The 5-quantiles are called quintiles ? QU*/
/*The 6-quantiles are called sextiles ? S*/
/*The 7-quantiles are called septiles*/
/*The 8-quantiles are called octiles*/
/*The 10-quantiles are called deciles ? D*/
/*The 12-quantiles are called duo-deciles or dodeciles*/
/*The 16-quantiles are called hexadeciles ? H*/
/*The 20-quantiles are called ventiles, vigintiles, or demi-deciles ? V*/
/*The 100-quantiles are called percentiles ? P*/
/*The 1000-quantiles have been called permilles or milliles, but these are rare and largely obsolete[1]*/
