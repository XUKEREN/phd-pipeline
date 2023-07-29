# Methylation quantitative trait loci analysis

This is a workflow to identify genotype-dependent DMPs associated with childhood ALL risk using the R package ‘Matrix eQTL’. We fitted an additive linear regression model predicting methylation at each CpG site as a function of SNP genotype (coded 0, 1 and 2). The associations between SNP genotypes and DMP DNA methylation were corrected for multiple testing using a stringent Bonferroni-adjusted threshold of 0.025/(number of DMPs × number of SNPs), and an FDR of 0.05. The mQTL analysis was first conducted separately in three datasets, and the results were subsequently meta-analyzed across all three datasets in fixed-effect meta-analysis models using ‘metafor’.

- Study publication: [link](https://academic.oup.com/hmg/article/31/21/3741/6611023)
- mqtl script: [link](./mqtl.r)
- meta-analysis script: [link](./mqtl_metafor.r)
