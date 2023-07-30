# post imputaiton qc: Verma et al. 2014
# meta-analysis qc: Winkler et al. 2014

##################################################################################################
##################################################################################################
##################################################################################################
####### Imputation evaluation ####################################################################
# 1.Number of imputed SNPs
# 2.Number of imputed SNPs in MAF bins
# 3.Number of imputed SNPs with good imputation score (~r2 >0.8)
# 4. Aggregate R2 per allele frequency bins
library(data.table)
library(tidyverse)

all_paths <- list.files(path = ".",
             pattern = "*info.gz",full.names = TRUE)

all_content <-
  all_paths %>%
  lapply(fread,
         header = TRUE)

all_filenames <- all_paths %>%
  basename() %>%
  as.list()

# combine file content list and file name list
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
 
# unlist all lists and change column name
all_result <- rbindlist(all_lists, fill = T)
# change column name
names(all_result)[14] <- "chr"
all_result %>% count(chr, Genotyped) %>% fwrite("numberofimputedgenotypedsnp.txt")
all_result %>% count(chr)%>% fwrite("numberofsnp.txt")

# check the total number of snps
numberofimputedgenotypedsnp %>% group_by(Genotyped) %>% summarize(total_snp = sum(n))

chr_info <- read_rds("chr_info.rds")
pdf("MAF_distribution_postimputation.pdf")
hist(chr_info$MAF,main = "MAF distribution", xlab = "MAF")
dev.off()

chr_info <- read_rds("chr_info.rds")
pdf("Rsq_distribution_postimputation.pdf")
hist(chr_info$Rsq,main = "Rsq distribution", xlab = "Rsq")
abline(v=0.3,col="RED",lty=2)
dev.off()

chr_info <- read_rds("chr_info.rds")
chr_info_common <- chr_info %>% filter(MAF >= 0.01)
pdf("Rsq_distribution_postimputation_MAFnoless0.01.pdf")
hist(chr_info_common$Rsq,main = "Rsq distribution", xlab = "Rsq")
abline(v=0.3,col="RED",lty=2)
dev.off()

chr_info <- read.table("chr_info", header =TRUE, as.is=T)
pdf("Rsq_distribution_postimputation.pdf")
hist(chr_info$Rsq,main = "Rsq distribution", xlab = "Rsq")
abline(v=0.3,col="RED",lty=2)
dev.off()

pdf("Rsq.pdf")
plot(chr_info$Rsq, xlab="Index", ylab="Rsq")
abline(h=0.3,col="RED",lty=2)
dev.off()

chr_info %>% mutate(MAF_bin = case_when(
    MAF < 0.01/100 ~ "<0.01",
    MAF >= 0.01/100 & MAF < 0.02/100 ~ "0.01-0.02",
    MAF >= 0.02/100 & MAF < 0.05/100 ~ "0.02-0.05",
    MAF >= 0.05/100 & MAF < 0.1/100 ~ "0.05-0.1",
    MAF >= 0.1/100 & MAF < 0.2/100 ~ "0.1-0.2",
    MAF >= 0.2/100 & MAF < 0.5/100 ~ "0.2-0.5",
    MAF >= 0.5/100 & MAF < 1/100 ~ "0.5-1",
    MAF >= 1/100 & MAF < 2/100 ~ "1-2",
    MAF >= 2/100 & MAF < 5/100 ~ "2-5",
    MAF >= 5/100 & MAF < 10/100 ~ "5-10",
    MAF >= 10/100 & MAF < 20/100 ~ "10-20",
    MAF >= 20/100 & MAF < 50/100 ~ "20-50",
    MAF >= 50/100 ~ ">=50",
)) %>% group_by(MAF_bin) %>% summarize(total = n(), avg_Rsq = mean(Rsq)) %>% fwrite("avg_Rsq_MAF_bin.txt")


# SNPS with MAF >= 0.01
# 7834317
# SNPS with RSQ >= 0.3
chr_info_common %>% filter(Rsq >= 0.3) %>% nrow()
# 7589149

##################################################################################################
##################################################################################################
##################################################################################################
####### POST imputation filter ###################################################################
# use bcf   
for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
  do
bcftools view -i 'R2>=.3 & MAF>=.01' -Oz chr$chnum.dose.vcf.gz > chr$chnum.filtered.vcf.gz
done

# check number of snps in each filtered vcf
for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
  do
bcftools stats chr$chnum.filtered.vcf.gz > chr$chnum.filtered.stats
done

for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
  do
bcftools stats chr$chnum.filtered_sorted.vcf.gz > chr$chnum.filtered_sorted.stats
done


# merge each chr by concat 
# sort first 
for chr in {1..22}; do \
bcftools sort chr${chr}.filtered.vcf.gz -Oz -o chr${chr}.filtered_sorted.vcf.gz
done

bcftools sort chr1.filtered.vcf.gz -Oz -o chr1.filtered_sorted.vcf.gz

bcftools concat chr{1..22}.filtered_sorted.vcf.gz -Oz -o  ALL.filtered_sorted.vcf.gz

# convert vcf to plink
plink2 --vcf ALL.filtered_sorted.vcf.gz dosage=HDS  --out ALL.filtered
# or 
plink2 --vcf ALL.filtered_sorted.vcf.gz dosage=HDS  --make-pgen --out ALL.filtered

for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
  do
gzip chr$chnum.info
done

# use plink2   
# -format
# This option specifies which fields to output for the FORMAT field in output imputed VCF file. Available handles are GT,DS,HDS,GP,SD. Default setting is GT,DS.
# GT - Estimated most likely genotype.
# DS - Estimated alternate allele dosage [P(0/1)+2*P(1/1)].
# HDS - Estimated phased haploid alternate allele dosage.
# GP - Estimated Posterior Genotype Probabilities P(0/0), P(0/1) and P(1/1).
# SD - Estimated Variance of Posterior Genotype Probabilities.
for chnum in {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22};
  do
  gunzip chr$chnum.info.gz
  plink2 --vcf chr$chnum.dose.vcf.gz dosage=HDS --make-bed --out plinkout/chr$chnum.HDS
  plink2 --bfile plinkout/chr$chnum.HDS --qual-scores chr$chnum.info 7 1 1 --qual-threshold 0.3 --make-bed --out plinkout/chr$chnum.HDS.rsq
  plink2 --bfile plinkout/chr$chnum.HDS.rsq --maf 0.01 --make-bed --out plinkout/chr$chnum.HDS.rsq.maf
done

# merge vcf 
for i in {1..22}
do
echo chr$i.HDS.rsq.maf >> mergelist.txt
done

#create file merge.list that contains the directory of each chromosome
plink2 --pmerge-list mergelist.txt --make-bed --out cog_HDS.rsq.maf


# merge vcf 
for i in {1..22}
do
echo chr$i.HDS.rsq.maf >> mergelist.txt
done


##################################################################################################
##################################################################################################
##################################################################################################
####### PCA again after excluding individuals failed population structure ########################

## prune data 
plink2 --pfile ALL.filtered --exclude range ../pre_imputation/high-LD-regions_hg19.txt --indep-pairwise 50 5 0.2 --out ALL.filtered_pruned

## remove inds from pruned dataset
plink2 --pfile ALL.filtered --extract ALL.filtered_pruned.prune.in --make-pgen --out ALL.filtered_pruned

## run pca
plink2 --pfile ALL.filtered_pruned --pca --out ALL.filtered_pruned_pca

# combine file content list and file name list
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)
 
# unlist all lists and change column name
all_result <- rbindlist(all_lists, fill = T)
# change column name
names(all_result)[14] <- "chr"
all_result %>% count(chr, Genotyped) %>% fwrite("numberofimputedgenotypedsnp.txt")
all_result %>% count(chr)%>% fwrite("numberofsnp.txt")


##################################################################################################
##################################################################################################
##################################################################################################
####### PCA again using 1KGP as reference ########################################################

# use plink 2 file for pca

# convert plink2 to plink1 file just to check the strand issue and qc
plink2 --pfile ALL.filtered_pruned --max-alleles 2 --make-bed --out ALL.filtered_pruned
plink --freq --bfile ALL.filtered_pruned --out ALL.filtered_pruned_freq

module load gcc perl # (do not run on nodes will give error)
perl HRC-1000G-check-bim.pl -b ALL.filtered_pruned.bim -f ALL.filtered_pruned_freq.frq -r ../../ancestry/1000G/1000GP_Phase3_combined.legend -g -p ALL
sh Run-plink.sh

plink2 --pfile /imputed/pca_1000G_dosage/ALL.filtered_pruned --exclude /imputed/pca_1000G_dosage/Exclude-ALL.filtered_pruned-1000G.txt --make-pgen --out /imputed/pca_1000G_dosage/TEMP1

plink2 --pfile /imputed/pca_1000G_dosage/TEMP1 --update-map /imputed/pca_1000G_dosage/Position-ALL.filtered_pruned-1000G.txt --make-pgen --out /imputed/pca_1000G_dosage/TEMP3

# don't run this part wierd -> change ref/alt 
plink2 --pfile /imputed/pca_1000G_dosage/TEMP3 --alt1-allele force /imputed/pca_1000G_dosage/Force-Allele1-ALL.filtered_pruned-1000G.txt --make-pgen --out /imputed/pca_1000G_dosage/ALL.filtered_pruned-updated  

## update variant id to match 1000G id
fread("ID-ALL.filtered_pruned-1000G.txt", header =F) -> myid
myid %>% separate(V2, c("V2", "junk"), sep = ":") -> myid
myid %>% select(V1, V2) -> myid
myid %>% fwrite("variant_id.txt", col.names = F, sep = "\t")

## merge mydata with 1000G
plink2 --pfile TEMP3 --update-name variant_id.txt --make-pgen --out ALL.filtered_pruned-updated_newid

## OOM issue - can only use plink 1 for this step 
plink --bfile ../../ancestry/1000G/all_phase3 --allow-extra-chr --extract variant_id_extract.txt --make-bed --out all_phase3_cog.filtered

### convert to plink2 file 
plink2 --bfile all_phase3_cog.filtered --make-pgen --out all_phase3_cog.filtered
plink2 --pfile ALL.filtered_pruned-updated_newid --extract all_phase3_cog.filtered.txt --make-pgen --out ALL.filtered_pruned-updated_newid2
plink2 --pfile ALL.filtered_pruned-updated_newid2_formerge --pmerge all_phase3_cog.filtered_formerge --make-pgen --out cog_1000G
plink --bfile cog_1000G --pca --out cog_1000G_pca

## merge 
plink2 --pfile ../ALL.filtered_pruned --pmerge ../../ancestry/1000G/all_phase3 --make-pgen --out cog_1000G
plink2 --pfile ALL.filtered_pruned-updated_newid2 --exclude snp_list_remove --make-pgen --out ALL.filtered_pruned-updated_newid2_formerge
plink2 --pfile all_phase3_cog.filtered --exclude snp_list_remove --make-pgen --out all_phase3_cog.filtered_formerge

## remove multiallelic variants -> five
rs113234741
rs111710788
rs77875881
rs113794244
rs111345934

plink2 --pfile ALL.filtered_pruned-updated_newid2_formerge --extract variant_same_ref_alt.txt --make-pgen --out ALL.filtered_pruned-updated_newid2_formerge2
plink2 --pfile all_phase3_cog.filtered_formerge --extract variant_same_ref_alt.txt --make-pgen --out all_phase3_cog.filtered_formerge2

### export to vcf first and then merge 
plink2 --pfile ALL.filtered_pruned-updated_newid2_formerge2 --export vcf-4.2 vcf-dosage=HDS bgz --out ALL.filtered_pruned-updated_newid2_formerge
plink2 --pfile all_phase3_cog.filtered_formerge2 --export vcf-4.2 vcf-dosage=HDS bgz --out all_phase3_cog.filtered_formerge

tabix ALL.filtered_pruned-updated_newid2_formerge.vcf.gz
tabix all_phase3_cog.filtered_formerge.vcf.gz
bcftools merge ALL.filtered_pruned-updated_newid2_formerge.vcf.gz all_phase3_cog.filtered_formerge.vcf.gz -O z -o cog_1000G.vcf.gz

### run pca 
plink2 --pfile cog_1000G --pca --out cog_1000G_pca