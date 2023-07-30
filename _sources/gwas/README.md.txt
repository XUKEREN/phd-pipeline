# Genome-wide association study

This is a workflow that performs GWAS for the AFFY6.0 and 500K datasets.

- [pre_imputation_qc.sh](./pre_imputation_qc.sh). Pre-imputation quality control is based on [Anderson et al.](https://www.nature.com/articles/nprot.2010.116) and [Marees et al.](https://pubmed.ncbi.nlm.nih.gov/29484742/).

- [pca_script.sh](./pca_script.sh) Population stratification: We analyzed population stratification using the genotyping data of independent autosomal SNPs. We next performed global ancestry estimation using ADMIXTURE v1.3, and principal components analysis (PCA) using the smartpca program from EIGENSOFT v6.1.

- Imputation: Genome-wide imputation was conducted on the Michigan Imputation Server.
- [post_imputation.sh](./post_imputation.sh): Post imputation quality control: Imputed MAF and the imputation quality score (r2) were used for filtering SNPs. The genetic ancestry PCs were computed with the dosage information from a subset of random autosomal SNPs in linkage equilibrium using plink v2.0 with the 1KGP phase 3 populations as reference.
- GWAS:

  - [gwas_run.sh](./gwas_run.sh)
  - [gwas_ordinal_logistic.sh](./gwas_ordinal_logistic.sh)
  - The phenotype central nervous system involvement status was classified as CNS1 (no blast cells in CSF), CNS2 (<5 WBC/mul CSF with blast cells), or CNS3 (5 WBC/mul CSF with blast cells, or signs of CNS involvement). To identify the association between the autosomal SNPs and the CNS involvement in ALL cases, we used three types of regressions: (1) linear regression predicting CNS status as a function of the dosages of every variant, (2) firth logistic regression predicting the binomial CNS status (CNS2+CNS3 vs. CNS1) as a function of the dosages of every variant, and (3) ordinal logistic regression predicting the CNS status as a function of the dosages of every variant. We fitted linear regression and firth logistic regression using plink v2.0 and ordinal logistic regression using OrdinalGWAS.jl

- [prs.sh](./prs.sh): Polygenetic risk scores for blood-cell traits.
