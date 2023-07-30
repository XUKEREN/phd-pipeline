# create pheno files 
clinical[,c(1,17)] %>% mutate(pheno_ETV6_RUNX1 = case_when(
  ETV6_RUNX1 == "Positive" ~ 1,
  ETV6_RUNX1 == "Negative" ~ 0
)) -> pheno

clinical[,c(1,18)] %>% mutate(pheno_Trisomy_4_10 = case_when(
  Trisomy_4_10 == "Yes" ~ 1,
  Trisomy_4_10 == "No" ~ 0
)) -> pheno

clinical_data[,c(1,20)] %>% mutate(pheno_relapse = case_when(
  First_Event == "Relapse" ~ 1,
  First_Event == "" ~ 0,
  First_Event %in% c("Death", "SMN") ~ -9
)) -> pheno

df_relapse %>% mutate(pheno_relapse = ifelse(pheno_relapse == -9, -9, pheno_relapse+1))-> pheno

This is one of the areas where plink 1.9 is already obsolete.  With plink 2.0, use "plink2 --vcf <VCF filename> dosage=DS --out <new name>" to import the dosages from an imputation server VCF; you can then use the full range of plink2 functions on it, such as
  "plink2 --pfile <new name> --mach-r2-filter 0.3 --make-pgen --out <name2>" to filter out variants with imputation quality < 0.3 (this should use the same formula as the imputation server, let me know if you see any discrepancies),
  "plink2 --pfile ... --maf ... --pca" to extract top principal components,
  "plink2 --pfile ... --pheno ... --covar ... --glm" to perform the usual association analysis, etc.

# code phenotype to 2 cases 1 controls instead of 1 and 0
# code missing pheno to -9
# https://www.cog-genomics.org/plink/2.0/assoc  
plink2 --pfile ../imputed/ALL.filtered --pheno pheno_binary.txt --pheno-name Relapse --covar covar_master.txt --glm zs hide-covar
plink2 --pfile ../imputed/ALL.filtered --pheno pheno_binary_codemissing.txt --pheno-name ETV6_RUNX1 --covar covar_master.txt --glm zs hide-covar
plink2 --pfile ../imputed/ALL.filtered --pheno pheno_binary_codemissing.txt --pheno-name Trisomy_4_10 --covar covar_master.txt --glm zs hide-covar

## decompress
zstd -d plink2.Relapse.glm.logistic.hybrid.zst
zstd -d plink2.ETV6_RUNX1.glm.logistic.hybrid.zst
zstd -d plink2.Trisomy_4_10.glm.logistic.hybrid.zst


Rscript create_plots.R plink2.Relapse.glm.logistic.hybrid plink2.Relapse.glm.logistic.hybrid.out
Rscript create_plots.R plink2.ETV6_RUNX1.glm.logistic.hybrid plink2.ETV6_RUNX1.glm.logistic.hybrid.out
Rscript create_plots.R plink2.Trisomy_4_10.glm.logistic.hybrid plink2.Trisomy_4_10.glm.logistic.hybrid.out

# quantatitive outcomes
# code missing pheno to -9
plink2 --pfile ../imputed/ALL.filtered --pheno cog_pheno_WBC.txt --pheno-name WBC --covar covar_master.txt --glm zs hide-covar
plink2 --pfile ../imputed/ALL.filtered --pheno cog_pheno_CNS.txt --pheno-name CNS_Status --covar covar_master.txt --glm zs hide-covar

mycns %>% mutate(CNS_Status = case_when(
  CNS_Status == "CNS1" ~ 1,
  CNS_Status == "CNS2" ~ 2, 
  CNS_Status == "CNS3" ~ 3
)) %>% fwrite("cog_pheno_CNS.txt", sep = "\t")

Rscript create_plots.R plink2.WBC.glm.linear plink2.WBC.glm.linear.out
Rscript create_plots.R plink2.CNS_Status.glm.linear plink2.CNS_Status.glm.linear.out

# need to log transform WBC first 
plink2 --pfile ../imputed/ALL.filtered --pheno cog_pheno_WBC.txt --pheno-name WBC_log --covar covar_master.txt --glm zs hide-covar

# collapse CNS group 2 with group 3 

mycns %>% mutate(CNS_Status = case_when(
  CNS_Status %in% c(2:3) ~ 2,
  CNS_Status == 1 ~ 1, 
  CNS_Status == -9 ~ -9 
)) -> mycns


plink2 --pfile ../imputed/ALL.filtered --pheno cog_pheno_CNS.txt --pheno-name CNS_Status --covar covar_master.txt --glm zs hide-covar

# decompress
zstd -d plink2.WBC_log.glm.linear.zst
zstd -d plink2.CNS_Status.glm.logistic.hybrid.zst

Rscript create_plots.R plink2.WBC_log.glm.linear plink2.WBC_log.glm.linear.out
Rscript create_plots.R plink2.CNS_Status.glm.logistic.hybrid plink2.CNS_Status.glm.logistic.hybrid.out

# for ordinal output
Rscript create_plots_ordinal.R ordinalgwas.bgenqctool.pval.txt ordinalgwas.bgenqctool.pval.out
Rscript create_plots_ordinal.R ordinalgwas.bgenplink2.pval.txt ordinalgwas.bgenplink2.pval.out

Rscript create_plots_ordinal.R ordinalgwas.pval.txt ordinalgwas.pval.out

########################################
# add covariates WBC
########################################

# first create a new covar_master file with WBC log scale 
library(data.table)
library(tidyverse)
cog_pheno_WBC <- fread("cog_pheno_WBC.txt") %>% select(-"WBC")
covar_master <- fread("covar_master.txt") 
covar_master.WBC <- cog_pheno_WBC %>% left_join(covar_master, by = "#IID")
fwrite(covar_master.WBC, "covar_master.WBC.txt", sep = "\t")

# run GWAS for CNS  
plink2 --pfile ../imputed/ALL.filtered --pheno cog_pheno_CNS.txt --pheno-name CNS_Status --covar covar_master.WBC.txt --glm zs hide-covar

# create linear CNS
library(data.table)
library(tidyverse)
mycns <- fread("pheno_cog_CNS_category.txt")

mycns %>% mutate(CNS_Status = case_when(
  CNS_cate == "CNS1" ~ 1,
  CNS_cate == "CNS2" ~ 2, 
  CNS_cate == "CNS3" ~ 3,
  CNS_cate == "NONE" ~ -9
)) %>% fwrite("cog_pheno_CNS_linear.txt", sep = "\t")

# run GWAS for CNS linear  
sbatch CNS_gwas.linear.WBC_adjusted.sh


########################################
# add covariates array type 
######################################### 
# first create a new covar_master file with WBC log scale and array type
library(data.table)
library(tidyverse)
fread("/dir/kerenxu/gwas_cog/pre_imputation/cog9906_500K.fam") ->  snp5
fread("/dir/kerenxu/gwas_cog/pre_imputation/cog9904_9905_snp6.fam") ->  snp6
snp5 <- snp5 %>% unite("#IID", V1:V2, sep = "_",remove = FALSE) %>% select(`#IID`)
snp5$array <- "500K"
snp6 <- snp6 %>% unite("#IID", V1:V2, sep = "_",remove = FALSE) %>% select(`#IID`)
snp6$array <- "affy6"
df_array <- rbind(snp5, snp6)
df_array %>% fwrite("array_type.txt")

cog_pheno_WBC <- fread("cog_pheno_WBC.txt") %>% select(-"WBC")
cog_array_type <- fread("array_type.txt")
covar_master <- fread("covar_master.txt") 
covar_master.WBC.array <- cog_pheno_WBC %>% left_join(covar_master, by = "#IID")  %>% left_join(cog_array_type, by = "#IID")
fwrite(covar_master.WBC.array, "covar_master.WBC.array.txt", sep = "\t")

covar_master.WBC.array <- fread("covar_master.WBC.array.txt")
covar_master.WBC.array <- covar_master.WBC.array %>% mutate(array = ifelse(array == "500K", "array1", "array2")) 
fwrite(covar_master.WBC.array, "covar_master.WBC.array.txt", sep = "\t")

# run gwas using covar_master.WBC.array.txt
sbatch CNS_gwas.linear.WBC_array_adjusted.sh
sbatch CNS_gwas.WBC_array_adjusted.sh


########################################
# ordinal logistic regression adjusting for WBC_log 
########################################

# create new cov_new.csv file  
library(data.table)
library(tidyverse)
cov_new <- fread("/dir/kerenxu/gwas_cog/gwas_run/cov_new.csv")
cog_pheno_WBC <- fread("cog_pheno_WBC.txt") %>% select(-"WBC")
cog_array_type <- fread("array_type.txt")
cov_new.WBC.array <- cov_new %>% left_join(cog_pheno_WBC, by = "#IID")  %>% left_join(cog_array_type, by = "#IID")
fwrite(cov_new.WBC.array, "cov_new.WBC.array.txt", sep = "\t")

# use the output file from converting vcf to bgen file using qctool 

# run ordinal gwas  
sbatch CNS_gwas_ordinal.WBC_adjusted.sh


########################################
# make plots
########################################

## decompress
cd /dir/kerenxu/gwas_cog/gwas_run/gwas_output.wbc_adj
zstd -d plink2.CNS_Status.glm.logistic.hybrid.zst
zstd -d plink2.CNS_Status.glm.linear.zst
rm -rf plink2.CNS_Status.glm.logistic.hybrid.zst
rm -rf plink2.CNS_Status.glm.linear.zst

# make plots
Rscript create_plots.R plink2.CNS_Status.glm.logistic.hybrid plink2.CNS_Status.glm.logistic.hybrid.out
Rscript create_plots.R plink2.CNS_Status.glm.linear plink2.CNS_Status.glm.linear.out

# for ordinal output
Rscript create_plots_ordinal.R ordinalgwas.pval.qctools.WBC_adjusted.txt ordinalgwas.pval.qctools.WBC_adjusted.out

## decompress
cd dir/kerenxu/gwas_cog/gwas_run/gwas_output.wbc_array_adj
zstd -d plink2.CNS_Status.glm.logistic.hybrid.zst
zstd -d plink2.CNS_Status.glm.linear.zst
rm -rf plink2.CNS_Status.glm.logistic.hybrid.zst
rm -rf plink2.CNS_Status.glm.linear.zst

# make plots
Rscript create_plots.R plink2.CNS_Status.glm.logistic.hybrid plink2.CNS_Status.glm.logistic.hybrid.wbc_array_adj.out
Rscript create_plots.R plink2.CNS_Status.glm.linear plink2.CNS_Status.glm.linear.wbc_array_adj.out

# for ordinal output
Rscript create_plots_ordinal.R ordinalgwas.pval.qctools.WBC_array_adjusted.txt ordinalgwas.pval.qctools.WBC_array_adjusted.out
