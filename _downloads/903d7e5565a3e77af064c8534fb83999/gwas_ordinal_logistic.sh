###################################
###################################
###################################
# ordinal logistic regression GWAS#

module load julia/1.5.2

# in slurm job
module load gcc/8.3.0
module load julia/1.5.2

###################################
###################################
###################################
# install julia package 
enter ] key to switch to package module
export JULIA_DEPOT_PATH="/dir/kerenxu/scratch_julia"
pkg> add https://github.com/OpenMendel/SnpArrays.jl
pkg> add https://github.com/OpenMendel/VCFTools.jl
pkg> add https://github.com/OpenMendel/BGEN.jl
pkg> add https://github.com/OpenMendel/OrdinalMultinomialModels.jl
pkg> add https://github.com/OpenMendel/OrdinalGWAS.jl

######################################################################
######################################################################
######################################################################
# convert plink2 file to BGEN file using PLINK2 #####################
######################################################################
######################################################################
######################################################################
## first remove the individual with missing CNS
plink2 --pfile ../imputed/ALL.filtered --remove PAKTKZ-G_PAKTKZ-G.txt --make-pgen --out ALL.filtered.plink2.1055
plink2 --pfile ALL.filtered.plink2.1055 --export bgen-1.2 --out ALL.filtered.plink2.1055.bgen

## create covariate file with CNS phenotype 
fread("cog_pheno_CNS.txt") -> CNS_pheno
CNS_pheno %>% mutate(CNS_Status = ifelse(CNS_Status == -9, NA, CNS_Status))  %>% count(CNS_Status)
CNS_pheno %>% mutate(CNS_Status = ifelse(CNS_Status == -9, NA, CNS_Status))  -> CNS_pheno_new
fread("covar_master.txt") -> covar_master
covar_master %>% left_join(CNS_pheno_new, by = "#IID") -> covariate.bgen # add CNS pheno

## REMOVE PAKTKZ-G_PAKTKZ-G.txt from covariate.bgen, get cov_new.csv

## run julia 
using OrdinalGWAS
ordinalgwas(@formula(CNS_Status ~ Gender + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10), "/dir/kerenxu/gwas_cog/gwas_run/cov_new.csv", "/dir/kerenxu/gwas_cog/gwas_run/ALL.filtered.plink2.1055"; geneticformat = "BGEN")

######################################################################
######################################################################
######################################################################
######## convert vcf to bgen file using qctool #######################
######################################################################
######################################################################
######################################################################
##  extract those individuals without missing covariates from vcf 
##  two ways 

vcftools --remove-indv PAKTKZ-G_PAKTKZ-G --vcf ALL.filtered_sorted.vcf.gz --recode --out ALL.filtered_sorted1055.vcf.gz
bcftools view ALL.filtered_sorted.vcf.gz -s ^PAKTKZ-G_PAKTKZ-G -o ALL.filtered_sorted1055.vcf.gz  -O z 

## find a way to create BGEN file 
it might be from UK biobank QCTOOLs 
## https://biobank.ndph.ox.ac.uk/crystal/crystal/docs/bgen12formats.pdf
## use qctool to convert vcf to bgen
qctool_v2.0.7 -g ALL.filtered_sorted1055.vcf.gz -vcf-genotype-field GP -og ALL.filtered_sorted1055.bgen
## add sample ids to the converted bgen file from ALL.filtered_sorted1055.sample
qctool_v2.0.7 -g ALL.filtered_sorted1055.bgen -og ALL.filtered_sorted1055_withsample.bgen -s ALL.filtered_sorted1055.sample
## make sure sample id order is the same
qctool_v2.0.7 -g ALL.filtered_sorted1055_withsample.bgen -og reordered.ALL.filtered_sorted1055.bgen -reorder cov_id.txt
## codes to exclude samples
qctool_v2.0.7 -g ALL.filtered_sorted1055.bgen -og filtered.ALL.filtered_sorted1055.bgen -excl-samples samples.txt
## codes to check the sample order in the original vcf file
bcftools query -l ALL.filtered_sorted1055.vcf.gz
## run ordinal gwas in julia 
ordinalgwas(@formula(CNS_Status ~ Gender + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10), "/dir/kerenxu/gwas_cog/gwas_run/cov_new.csv", "/dir/kerenxu/gwas_cog/gwas_run/ALL.filtered_sorted1055_withsample"; geneticformat = "BGEN")
