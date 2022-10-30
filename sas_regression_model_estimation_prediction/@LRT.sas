/*compute p-value based on the differences of -2loglikelihood or deviance*/
 data lrt_pval;
        LRT = <numeric value of LRT as computed above>;
        df  = <degrees of freedom as computed above>;
        p_value = 1 - probchi(LRT,df);
        format p_value pvalue6.; 
        run;

   proc print data=lrt_pval;
        title1 "LR test statistic and p-value";
        run;
