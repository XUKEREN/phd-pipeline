# population structure qc  

# differnet snp information => update bim file snp name first 
plink --bfile ../pre_imputation/clean-inds-cog9904_9905_snp6_geno_maf_hwe --extract hapmap3r2_CEU.CHB.JPT.YRI.no-at-cg-snps.txt --make-bed --out cog_snp6.hapmap-snps

# after imputation 
# merge vcf from different chrs togethor  
# took a long time to use bcftools  
## bcftools concat chr{1..23}.dose.vcf.gz -Oz -o  cog_snp6.vcf.gz
## bcftools concat chr{1..23}.dose.vcf.gz -Oz -o  cog_500K.vcf.gz

# filter by imputation quality first ?? 
https://www.biostars.org/p/6476/

https://www.biostars.org/p/310175/ # filter R2>0.8


# use plink  
plink --vcf myvcf.vcf --maf 0.05 --recode --out myplink  

plink --bfile ../sample_data_clean_ind_marker/cog9906_500K_1000G --pca --out cog9906_500K_1000G_pca

plink --bfile ../sample_data_clean_ind_marker/cog9904_9905_snp6_1000G --pca --out cog9904_9905_snp6_1000G_pca


