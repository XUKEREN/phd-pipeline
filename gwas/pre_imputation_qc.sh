# data cleaning

# rscript 
library(tidyverse)
library(data.table)

##  count number of individuals in the study
FAM <-fread("COG_5.fam", header=FALSE)
head(FAM)
dim(FAM)

## Map Information on number of SNPS count number of genotyped SNPs
map <- fread("COG_5.bim", header=FALSE)
head(map)
dim(map)

##  count number of individuals in the study
FAM <-fread("COG_6.fam", header=FALSE)
head(FAM)
dim(FAM)

## Map Information on number of SNPS count number of genotyped SNPs
map <- fread("COG_6.bim", header=FALSE)
head(map)
dim(map)

## create list to update allele  mylist.txt
### list for AFFY_6.0  
fread("AFFY_6.0_snpBatch_AFFY_52074") -> AFFY_6.0_snpBatch_AFFY_52074 
AFFY_6.0_snpBatch_AFFY_52074 %>% select(c("loc_snp_id", "allele")) -> AFFY_6.0
AFFY_6.0$loc_snp_id <- gsub("AFFY_6_1M_", "", AFFY_6.0$loc_snp_id)
AFFY_6.0 %>% separate(allele, c("ref", "alt"), sep = "/")
AFFY_6.0 %>% separate(allele, c("ref", "alt"), sep = "/") -> AFFY_6.0
AFFY_6.0 %>% fwrite("AFFY_6.0.txt")

AFFY_6.0$V1 <- "A"
AFFY_6.0$V2 <- "B"
AFFY_6.0 %>% relocate(ref, .after = last_col()) %>% relocate(alt, .after = last_col()) -> AFFY_6.0
AFFY_6.0 %>% fwrite("AFFY_6.0.txt", sep = "\t", col.names = F)
AFFY_6.0 %>% distinct() %>% fwrite("AFFY_6.0.txt", sep = "\t", col.names = F)

### snps that are not in AFFY_6.0 but in SNP6.bim
SNP_A-4259152   A       B
SNP_A-4291236   A       B
SNP_A-2111932   A       B
SNP_A-4258170   A       B
SNP_A-4233297   A       B
SNP_A-8306538   A       B
SNP_A-2261096   A       B
SNP_A-4289206   A       B
SNP_A-8431715   A       B

plink --bfile cog9904_9905_snp6 --update-alleles AFFY_6.0.txt --make-bed --out cog9904_9905_snp6_update_allele

### list for Affymetrix 500K  
plink --bfile cog9906_500K --update-alleles AFFY_500K.txt --make-bed --out cog9906_500K_update_allele

#  sex check  

## change sex chr from 24 to 23 
plink --bfile cog9904_9905_snp6_update_allele --update-chr snplist_chrx_snp6.txt --make-bed --out cog9904_9905_snp6_update_sex
plink --bfile cog9906_500K_update_allele --update-chr snplist_chrx_snp5.txt --make-bed --out cog9906_500K_update_sex

## check sex
plink --bfile cog9906_500K_update_sex --check-sex --out cog9906_500K_check_sex
plink --bfile cog9904_9905_snp6_update_sex --check-sex --out cog9904_9905_snp6_check_sex

## impute sex 
plink --bfile cog9904_9905_snp6_update_sex --impute-sex --make-bed --out cog9904_9905_snp6_impute_sex
plink --bfile cog9906_500K_update_sex --impute-sex --make-bed --out cog9906_500K_impute_sex

## identify subjects failed sex check   
fread("cog9904_9905_snp6_check_sex.sexcheck") -> snp6_sexcheck
fread("cog9906_500K_check_sex.sexcheck") -> snp5_sexcheck
fread("cog_pheno.txt") -> pheno
snp6_sexcheck %>% separate(FID, c("sample_id", "junk")) %>% select(-"junk") -> snp6_sexcheck
snp5_sexcheck %>% separate(FID, c("sample_id", "junk")) %>% select(-"junk") -> snp5_sexcheck
pheno%>% select(c("sample_id", "gender")) -> pheno

snp6_sexcheck %>% left_join(pheno, by = "sample_id") %>% count(SNPSEX, gender)
snp5_sexcheck %>% left_join(pheno, by = "sample_id") %>% count(SNPSEX, gender)
snp6_sexcheck %>% left_join(pheno, by = "sample_id")  %>% filter(SNPSEX == 0 | (SNPSEX == 1 & gender == "Female"))
snp5_sexcheck %>% left_join(pheno, by = "sample_id")  %>% filter(SNPSEX == 0 | (SNPSEX == 1 & gender == "Female"))
snp6_sexcheck %>% left_join(pheno, by = "sample_id")  %>% filter(SNPSEX == 0 | (SNPSEX == 1 & gender == "Female")) %>% fwrite("fail-sexcheck-qc_snp6.txt", sep = "\t")
snp5_sexcheck %>% left_join(pheno, by = "sample_id")  %>% filter(SNPSEX == 0 | (SNPSEX == 1 & gender == "Female"))%>% fwrite("fail-sexcheck-qc_500K.txt", sep = "\t")

## create gender check graph 
cog9906_500K_check_sex.sexcheck
gender_check.R 

# Generate a bfile with autosomal SNPs only   
plink --bfile cog9904_9905_snp6_impute_sex --not-chr 23 --make-bed --out cog9904_9905_snp6_1-22_all
plink --bfile cog9906_500K_impute_sex --not-chr 23 --make-bed --out cog9906_500K_1-22_all

# Identification of duplicated or related individuals
## The method works best when only independent SNPs are included in the analysis 
## first remove LD snps to minimize computation complexity
### --indep requires three parameters: a window size in variant count or kilobase (if the 'kb' modifier is present) units, a variant count to shift ### the window at the end of each step, and a variance inflation factor (VIF) threshold. At each step, all variants in the current window with VIF ### exceeding the threshold are removed. See the PLINK 1.07 documentation for some discussion of parameter choices.

plink --bfile cog9904_9905_snp6_1-22_all --exclude high-LD-regions_hg19.txt --range --indep-pairwise 50 5 0.2 --out cog9904_9905_snp6_pruned
plink --bfile cog9906_500K_1-22_all --exclude high-LD-regions_hg19.txt --range --indep-pairwise 50 5 0.2 --out cog9906_500K_pruned

# generate pairwise IBS for all pairs of individuals in the study based on the reduced marker set  
plink --bfile cog9904_9905_snp6_1-22_all --extract cog9904_9905_snp6_pruned.prune.in --genome --out cog9904_9905_snp6_IBS
plink --bfile cog9906_500K_1-22_all --extract cog9906_500K_pruned.prune.in --genome --out cog9906_500K_IBS

# run plot-IBD.R

# identify individual with the lower call rate in each pair to remove   

# Identification of individuals with elevated missing data rates or outlying heterozygosity rate

# Investigate missingness per individual and per SNP and make histograms.
plink --bfile cog9904_9905_snp6_update_allele --missing
plink --bfile cog9906_500K_update_allele --missing    
# output: plink.imiss and plink.lmiss, these files show respectively the proportion of missing SNPs per individual and the proportion of missing individuals per SNP.

# Generate plots to visualize the missingness results.
Rscript --no-save hist_miss.R

# check heterozygosity rate
plink --bfile cog9906_500K_impute_sex --het --out cog9906_500K_impute_sex
plink --bfile cog9904_9905_snp6_impute_sex --het --out cog9904_9905_snp6_impute_sex

# check heterozygosity rate only in chr1-22
plink --bfile cog9906_500K_1-22_all --het --out cog9906_500K_1-22_all
plink --bfile cog9904_9905_snp6_1-22_all --het --out cog9904_9905_snp6_1-22_all

# Plot of the heterozygosity rate distribution
Rscript --no-save check_heterozygosity_rate.R

# The following code generates a list of individuals who deviate more than 3 standard deviations from the heterozygosity rate mean.
# For data manipulation we recommend using UNIX. However, when performing statistical calculations R might be more convenient, hence the use of the Rscript for this step:
Rscript --no-save heterozygosity_outliers_list.R

# Generate plots to show imiss vs. het
R CMD BATCH imiss-vs-het.R


#################################################
#################################################
#################################################
#################################################
########## delete individuals ###################

# filter individuals obtained from above procedures from cog9904_9905_snp6_impute_sex and cog9906_500K_impute_sex
fail_het_qc_snp6_1_22_all
fail_het_qc_500K_1_22_all
fail_IBD_QC_cog9904_9905_snp6
## cut off value 0.25 for sex check females  
fail_sexcheck_qc_snp6
fail-sexcheck-qc_500K
sample_id_cog

fail_snp6 <- c(fail_het_qc_snp6_1_22_all %>% pull(FID), fail_IBD_QC_cog9904_9905_snp6 %>% pull(FID)) %>% unique()

# delete subjects failed sex check and IBD check before check population structure  
# do not delete subjects failed hetero yet  
plink --bfile cog9904_9905_snp6_impute_sex --remove fail_snp6_sexcheck_ibdcheck.txt --make-bed --out clean-inds-cog9904_9905_snp6
plink --bfile cog9906_500K_impute_sex --remove fail_500K_sexcheck_ibdcheck.txt --make-bed --out clean-inds-cog9904_9905_snp6

## make a summary file fail-qc-inds.txt
## remove inds 
# plink --bfile cog9904_9905_snp6_impute_sex --remove fail-qc-inds_snp6.txt --make-bed --out clean-inds-cog9904_9905_snp6
# plink --bfile cog9906_500K_impute_sex --remove fail-qc-inds_500K.txt --make-bed --out clean-inds-cog9906_500K


#################################################
#################################################
#################################################
#################################################
########## snp filter ############################
# Per-marker QC
# Per-marker QC of GWA data consists of at least four steps:
(i) identification of SNPs with an excessive missing genotype
plink --bfile clean-inds-cog9904_9905_snp6 --missing --out clean-inds-cog9904_9905_snp6_missing
plink --bfile clean-inds-cog9906_500K --missing --out clean-inds-cog9906_500K_missing
## Generate plots to visualize the missingness results.
Rscript --no-save hist_miss.R
plink --bfile clean-inds-cog9904_9905_snp6 --geno 0.02 --make-bed --out clean-inds-cog9904_9905_snp6_geno
plink --bfile clean-inds-cog9906_500K --geno 0.02 --make-bed --out clean-inds-cog9906_500K_geno

(iv) the removal of all markers with a very low minor allele frequency (MAF).
# Generate a plot of the MAF distribution.
plink --bfile clean-inds-cog9904_9905_snp6_geno --freq --out MAF_check_snp6
plink --bfile clean-inds-cog9906_500K_geno --freq --out MAF_check_500K
Rscript --no-save MAF_check.R

plink --bfile clean-inds-cog9904_9905_snp6_geno --maf 0.01 --make-bed --out clean-inds-cog9904_9905_snp6_geno_maf
plink --bfile clean-inds-cog9906_500K_geno --maf 0.01 --make-bed --out clean-inds-cog9906_500K_geno_maf

# skip HWE check right now
(ii) identification of SNPs showing a significant deviation from Hardy-Weinberg equilibrium (HWE)
# Check the distribution of HWE p-values of all SNPs.
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf --hardy --out HWE_check_snp6
plink --bfile clean-inds-cog9906_500K_geno_maf --hardy --out HWE_check_500K
# Selecting SNPs with HWE p-value below 0.00001, required for one of the two plot generated by the next Rscript, allows to zoom in on strongly deviating SNPs. 
awk '{ if ($9 <1e-10) print $0 }' HWE_check_snp6.hwe>HWE_check_snp6zoom.hwe
awk '{ if ($9 <1e-10) print $0 }' HWE_check_500K.hwe>HWE_check_500Kzoom.hwe
Rscript --no-save hwe.R
# The HWE threshold for the cases filters out only SNPs which deviate extremely from HWE. 
# This second HWE step only focusses on cases because in the controls all SNPs with a HWE p-value < hwe 1e-6 were already removed
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf --hwe 1e-10 --make-bed --out clean-inds-cog9904_9905_snp6_geno_maf_hwe
plink --bfile clean-inds-cog9906_500K_geno_maf --hwe 1e-10 --make-bed --out clean-inds-cog9906_500K_geno_maf_hwe

(iii) identification of SNPs with significantly different missing genotype rates between cases and controls
# plink --bfile clean-inds-cog9904_9905_snp6_geno –-maf 0.01 --geno 0.05 --hwe 1e-10 --make-bed --out clean-GWA-data

#################################################
#################################################
#################################################
################ ADMIXTURE ######################

# check population structure  
# extract 1-22 chr first  
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf --not-chr 23 --make-bed --out clean-inds-cog9904_9905_snp6_geno_maf_1-22
plink --bfile clean-inds-cog9906_500K_geno_maf --not-chr 23 --make-bed --out clean-inds-cog9906_500K_geno_maf_1-22

## use pruned dataset 
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_1-22 --exclude high-LD-regions_hg19.txt --range --indep-pairwise 50 5 0.2 --out clean-inds-cog9904_9905_snp6_geno_maf_1-22_pruned
plink --bfile clean-inds-cog9906_500K_geno_maf_1-22 --exclude high-LD-regions_hg19.txt --range --indep-pairwise 50 5 0.2 --out clean-inds-cog9906_500K_geno_maf_1-22_pruned

## remove inds from pruned dataset
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_1-22 --extract clean-inds-cog9904_9905_snp6_geno_maf_1-22_pruned.prune.in --make-bed --out cog9904_9905_snp6_forpopcheck
plink --bfile clean-inds-cog9906_500K_geno_maf_1-22 --extract clean-inds-cog9906_500K_geno_maf_1-22_pruned.prune.in --make-bed --out cog9906_500K_forpopcheck

## downlaod 1000G reference panel 
### https://www.cog-genomics.org/plink/2.0/resources#1kg_phase3
### download files: 
#### https://www.dropbox.com/s/afvvf1e15gqzsqo/all_phase3.pgen.zst?dl=1
#### https://www.dropbox.com/s/op9osq6luy3pjg8/all_phase3.pvar.zst?dl=1
#### https://www.dropbox.com/s/yozrzsdrwqej63q/phase3_corrected.psam?dl=1
plink2 --zst-decompress all_phase3.pgen.zst > all_phase3.pgen # Decompress pgen.zst to pgen # 2504 individuals
# https://cran.r-project.org/web/packages/plinkQC/vignettes/Genomes1000.pdf
https://github.com/danjlawson/pcapred/
https://cran.r-project.org/web/packages/snpsettest/vignettes/reference_1000Genomes.html

## convert the PLINK 2 binary to plink1  
plink2 --pfile all_phase3 vzs --max-alleles 2 --make-bed --out all_phase3

## Filter reference data for the same SNP set as in study
## We will use the list of pruned variants from the study sample to reduce the reference dataset to the size of the study samples:
## format sample data against 1000G
# Create a frequency file  
plink --freq --bfile cog9904_9905_snp6_forpopcheck --out cog9904_9905_snp6_forpopcheck_freq
plink --freq --bfile cog9906_500K_forpopcheck --out cog9906_500K_forpopcheck_freq

module load gcc perl
perl HRC-1000G-check-bim.pl -b sample_data_clean_ind_marker/cog9904_9905_snp6_forpopcheck.bim -f sample_data_clean_ind_marker/cog9904_9905_snp6_forpopcheck_freq.frq -r 1000G/1000GP_Phase3_combined.legend -g -p ALL

sh Run-plink_snp6.sh

perl HRC-1000G-check-bim.pl -b sample_data_clean_ind_marker/cog9906_500K_forpopcheck.bim -f sample_data_clean_ind_marker/cog9906_500K_forpopcheck_freq.frq -r 1000G/1000GP_Phase3_combined.legend -g -p ALL

sh Run-plink_500K.sh

# merge plink from different chr to one
for i in {1..22}
do
echo cog9904_9905_snp6_forpopcheck-updated-chr$i >> mergelist_snp6.txt
echo cog9906_500K_forpopcheck-updated-chr$i >> mergelist_500K.txt
done
plink --merge-list mergelist_snp6.txt --make-bed --out cog9904_9905_snp6_forpopcheck-updated
plink --merge-list mergelist_500K.txt --make-bed --out cog9906_500K_forpopcheck-updated

# update variant id to match 1000G id
plink --bfile cog9904_9905_snp6_forpopcheck-updated --update-name variant_id_snp6.txt --make-bed --out cog9904_9905_snp6_forpopcheck-updated_newid
plink --bfile cog9906_500K_forpopcheck-updated --update-name variant_id_500K.txt --make-bed --out cog9906_500K_forpopcheck-updated_newid

# create matched variant lists from 1000G id
plink --bfile ../1000G/all_phase3 --allow-extra-chr --extract variant_id_toextract_snp6.txt --make-bed --out all_phase3_snp6
plink --bfile ../1000G/all_phase3 --allow-extra-chr --extract variant_id_toextract_500K.txt --make-bed --out all_phase3_500K

plink --bfile cog9904_9905_snp6_forpopcheck-updated_newid --extract all_phase3_snp6_id.txt --make-bed --out cog9904_9905_snp6_forpopcheck-updated_newid2
plink --bfile cog9906_500K_forpopcheck-updated_newid --extract all_phase3_500K_id.txt --make-bed --out cog9906_500K_forpopcheck-updated_newid2

# merge sample data with reference data 
plink --bfile cog9904_9905_snp6_forpopcheck-updated_newid2 --bmerge all_phase3_snp6.bed all_phase3_snp6.bim all_phase3_snp6.fam --make-bed --out cog9904_9905_snp6_1000G
plink --bfile cog9906_500K_forpopcheck-updated_newid2 --bmerge all_phase3_500K.bed all_phase3_500K.bim all_phase3_500K.fam --make-bed --out cog9906_500K_1000G


# merge snp6 + 500K + 1000G
plink --bfile ../1000G/all_phase3 --allow-extra-chr --extract all_phase3_snp6_500K_id.txt --make-bed --out all_phase3_snp6_500K
plink --bfile cog9904_9905_snp6_forpopcheck-updated_newid2 --extract all_phase3_snp6_500K_id.txt --make-bed --out cog9904_9905_snp6_forpopcheck-updated_newid3
plink --bfile cog9906_500K_forpopcheck-updated_newid2 --extract all_phase3_snp6_500K_id.txt --make-bed --out cog9906_500K_forpopcheck-updated_newid3
plink --bfile cog9904_9905_snp6_forpopcheck-updated_newid3 --bmerge cog9906_500K_forpopcheck-updated_newid3.bed cog9906_500K_forpopcheck-updated_newid3.bim cog9906_500K_forpopcheck-updated_newid3.fam --make-bed --out snp6_500K
plink --bfile snp6_500K --bmerge all_phase3_snp6_500K.bed all_phase3_snp6_500K.bim all_phase3_snp6_500K.fam --make-bed --out cog_snp6_500K_1000G


# admixture - 10 fold cross validation 
for K in 1 2 3 4 5 6; \
do admixture --cv=10 cog9906_500K_1000G.bed $K | tee log_500K${K}.out; done

for K in 1 2 3 4 5 6; \
do admixture --cv=10 cog9904_9905_snp6_1000G.bed $K | tee log_snp6${K}.out; done

grep -h CV log_500K*.out
grep -h CV log_snp6*.out

# create pop files  
fread("../sample_data/cog9906_500K_1000G.fam", header = F) -> snp5_1000G 
fread("all_phase3.psam") -> pop
snp5_1000G %>% select(V2) %>% rename("#IID" = "V2") %>% left_join(pop)
snp5_1000G %>% select(V2) %>% rename("#IID" = "V2") %>% left_join(pop) -> pop
fread("cog_pheno.txt") -> cog_pheno
pop %>% rename( "sample_id" = "#IID") -> pop
cog_pheno$junk <- "G"
cog_pheno %>% unite(sample_id, c("sample_id", "junk"), sep = "-") -> cog_pheno
pop %>% left_join(cog_pheno, by = "sample_id") -> pop_500K_1000G
pop_500K_1000G %>% fwrite("pop_500K_1000G.txt")

fread("../sample_data/cog9904_9905_snp6_1000G.fam", header = F) -> snp6_1000G 
fread("all_phase3.psam") -> pop
snp6_1000G %>% select(V2) %>% rename("#IID" = "V2") %>% left_join(pop)
snp6_1000G %>% select(V2) %>% rename("#IID" = "V2") %>% left_join(pop) -> pop
fread("cog_pheno.txt") -> cog_pheno
pop %>% rename( "sample_id" = "#IID") -> pop
cog_pheno$junk <- "G"
cog_pheno %>% unite(sample_id, c("sample_id", "junk"), sep = "-") -> cog_pheno
pop %>% left_join(cog_pheno, by = "sample_id") -> pop_snp6_1000G
pop_snp6_1000G %>% fwrite("pop_snp6_1000G.txt")

# admixture - supervised method  
admixture --cv=10 --supervised cog9906_500K_1000G.bed 5 | tee log_500K_supervised_5.out
admixture --cv=10 --supervised cog9904_9905_snp6_1000G.bed 5 | tee log_snp6_supervised_5.out


#################################################
#################################################
#################################################
################ PCA ############################

# use plink  
plink --bfile ../sample_data_clean_ind_marker/cog9906_500K_1000G --pca --out cog9906_500K_1000G_pca
plink --bfile ../sample_data_clean_ind_marker/cog9904_9905_snp6_1000G --pca --out cog9904_9905_snp6_1000G_pca

# use smartpca 
log "convert BED/BIM/FAM to PED/MAP"
plink --bfile ../sample_data_clean_ind_marker/cog9906_500K_1000G --recode --out cog9906_500K_1000G
plink --bfile ../sample_data_clean_ind_marker/cog9904_9905_snp6_1000G --recode --out cog9904_9905_snp6_1000G
log "convert PED/MAP to SNP/IND"

./EIG-6.1.4/bin/convertf -p convertf_snp6.par
./EIG-6.1.4/bin/convertf -p convertf_500K.par

log "conduct PCA"
./EIG-6.1.4/bin/smartpca -p smartpca_snp6.par 2>&1 \
		> smartpca_snp6.stdout.stderr
./EIG-6.1.4/bin/smartpca.perl -p smartpca_500K.par 2>&1 \
> smartpca_500K.stdout.stderr
./EIG-6.1.4/bin/smartpca -p /mnt/d/gwas_cog/smartpca/smartpca_snp6.par 2>&1 \
		> /mnt/d/gwas_cog/smartpca/smartpca_snp6.stdout.stderr
./EIG-6.1.4/bin/smartpca -p /mnt/d/gwas_cog/smartpca/smartpca_500K.par 2>&1 \
		> /mnt/d/gwas_cog/smartpca/smartpca_500K.stdout.stderr


##################################################################################################
##################################################################################################
##################################################################################################
################ only include inds with clinical variables #######################################

plink --bfile clean-inds-cog9904_9905_snp6_geno_maf --keep ../sample_id_cog --make-bed --out clean-inds-cog9904_9905_snp6_geno_maf_clinical
plink --bfile clean-inds-cog9906_500K_geno_maf --keep ../sample_id_cog --make-bed --out clean-inds-cog9906_500K_geno_maf_clinical

# Identification of individuals with elevated missing data rates or outlying heterozygosity rate

# Investigate missingness per individual and per SNP and make histograms.
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_clinical --missing --out clean-inds-cog9904_9905_snp6_geno_maf_clinical_missing
plink --bfile clean-inds-cog9906_500K_geno_maf_clinical --missing --out clean-inds-cog9906_500K_geno_maf_clinical_missing
# output: plink.imiss and plink.lmiss, these files show respectively the proportion of missing SNPs per individual and the proportion of missing individuals per SNP.

# Generate plots to visualize the missingness results.
Rscript --no-save hist_miss.R

# Generate a bfile with autosomal SNPs only   
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_clinical --not-chr 23 --make-bed --out clean-inds-cog9904_9905_snp6_geno_maf_clinical_1-22
plink --bfile clean-inds-cog9906_500K_geno_maf_clinical --not-chr 23 --make-bed --out clean-inds-cog9906_500K_geno_maf_clinical_1-22

# check heterozygosity rate only in chr1-22
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_clinical_1-22 --het --out clean-inds-cog9904_9905_snp6_geno_maf_clinical_1-22_checkhetero
plink --bfile clean-inds-cog9906_500K_geno_maf_clinical_1-22 --het --out clean-inds-cog9906_500K_geno_maf_clinical_1-22_checkhetero

# Plot of the heterozygosity rate distribution
Rscript --no-save check_heterozygosity_rate.R

# The following code generates a list of individuals who deviate more than 3 standard deviations from the heterozygosity rate mean.
# For data manipulation we recommend using UNIX. However, when performing statistical calculations R might be more convenient, hence the use of the Rscript for this step:
Rscript --no-save heterozygosity_outliers_list.R

# Generate plots to show imiss vs. het
R CMD BATCH imiss-vs-het.R


#################################################
#################################################
#################################################
################ HRC impuation ##################

# before imputation check the overlap snp between snp6 and 500K 
# 679987 in snp6
# 350473 in 500K
# 303373 in common

plink --bfile clean-inds-cog9906_500K_geno_maf_clinical_1-22 --extract inner_join_snp.txt --make-bed --out cog5
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_clinical_1-22 --extract inner_join_snp.txt --make-bed --out cog6

## merge two cog files 
plink --bfile cog6 --bmerge cog5.bed cog5.bim cog5.fam --make-bed --out cog_1056

# check the IBD again for snp6 and 500K togethor  

## first remove LD snps to minimize computation complexity
### --indep requires three parameters: a window size in variant count or kilobase (if the 'kb' modifier is present) units, a variant count to shift ### the window at the end of each step, and a variance inflation factor (VIF) threshold. At each step, all variants in the current window with VIF ### exceeding the threshold are removed. See the PLINK 1.07 documentation for some discussion of parameter choices.

plink --bfile cog_1056 --exclude ../high-LD-regions_hg19.txt --range --indep-pairwise 50 5 0.2 --out cog_1056_pruned

# generate pairwise IBS for all pairs of individuals in the study based on the reduced marker set  
plink --bfile cog_1056 --extract cog_1056_pruned.prune.in --genome --out cog_1056_IBS

# no people failed IBD check  

# Create a frequency file  
plink --freq --bfile cog_1056 --out cog_1056_freq

# HRC or 1000G Imputation preparation and checking  
module load gcc perl # (do not run on nodes will give error)
perl ./HRC-1000G-check-bim.pl -b cog_1056.bim -f cog_1056_freq.frq -r ../MIS_data_prep/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
sh Run-plink.sh

# all the output are in HRC_prep 
# create index file 
for chr in {1..22}; do \
bgzip cog_1056-updated-chr${chr}.vcf
tabix cog_1056-updated-chr${chr}.vcf.gz
done

# Sort vcf using bcftools  
for chr in {1..22}; do \
bcftools sort cog_1056-updated-chr${chr}.vcf.gz -Oz -o cog_1056_chr${chr}_sorted.vcf.gz
done

# checkvcf
for chr in {1..22}; do \
checkVCF.py -r ./checkVCF-20140116/hs37d5.fa -o cog_snp6_chr${chr} cog_1056_chr${chr}_sorted.vcf.gz
done

# submit to MIS  

# second way to create vcf by chr  
# break plink file by chr
for chr in {1..23}; do \
plink --bfile clean-inds-cog9904_9905_snp6_geno_maf_hwe --chr $chr --make-bed --out MIS_data_prep/cog6_${chr}; \
done

for chr in {1..23}; do \
plink --bfile clean-inds-cog9906_500K_geno_maf_hwe --chr $chr --make-bed --out MIS_data_prep/cog5_${chr}; \
done

# Create vcf using VcfCooker 
for chr in {1..23}; do \
vcfCooker --in-bfile cog5_${chr} --ref hg19.fa --out cog5_${chr} --write-vcf --bgzf --verbose 
done

for chr in {1..23}; do \
vcfCooker --in-bfile cog6_${chr} --ref hg19.fa --out cog6_${chr} --write-vcf --bgzf --verbose 
done

# create index file 
for chr in {1..23}; do \
tabix cog5_${chr}.vcf.gz
done

for chr in {1..23}; do \
tabix cog6_${chr}.vcf.gz
done

# Sort vcf using bcftools  
for chr in {1..23}; do \
bcftools sort cog5_${chr}.vcf.gz -Oz -o cog5_${chr}.vcf.gz
done

for chr in {1..23}; do \
bcftools sort cog6_${chr}.vcf.gz -Oz -o cog6_${chr}.vcf.gz
done

# checkvcf
checkVCF.py -r ./checkVCF-20140116/hs37d5.fa -o out mystudy_chr1.vcf.gz

# imputation results  

## 274985 SNPs after HRC or 1000G Imputation preparation and checking
## Monomorphic sites: 982  
## Remaining sites in total: 274,003  

# unzip vcf for each chr   
for chr in {1..22}; do \
unzip -P m&m0rM4YIaqEMQ chr_${chr}.zip
done


##################################################################################################
##################################################################################################
##################################################################################################
####### PCA again after excluding individuals failed population structure ########################