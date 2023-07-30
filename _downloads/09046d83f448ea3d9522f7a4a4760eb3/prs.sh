#####################################################################
####################create file for different traits ################
#####################################################################

fread("Blood_Cell_Instruments.txt") -> data
## count number of SNPs for each trait 
data %>% count(exposure)

data %>% count(exposure) %>% fwrite("snp_9_expoure.txt")
data %>% filter(exposure == "Basophil") %>% fwrite("Basophil.txt")
data %>% filter(exposure == "Eosinophil") %>% fwrite("Eosinophil.txt")
data %>% filter(exposure == "LMR") %>% fwrite("LMR.txt")
data %>% filter(exposure == "Lymphocyte") %>% fwrite("Lymphocyte.txt")
data %>% filter(exposure == "Mono.z") %>% fwrite("Mono.z.txt")
data %>% filter(exposure == "Neutrophil") %>% fwrite("Neutrophil.txt")
data %>% filter(exposure == "NLR") %>% fwrite("NLR.txt")
data %>% filter(exposure == "Platelet") %>% fwrite("Platelet.txt")
data %>% filter(exposure == "PLR") %>% fwrite("PLR.txt")

#####################################################################
#################### check SNP ################
#####################################################################

# individual file  
../imputed/
ALL.filtered.psam
# SNP id 
ALL.filtered.pvar

# 7589149 variants scanned. in All.filtered.pvar
plink2 --pfile ../imputed/ALL.filtered --write-snplist --out ALL.filtered.snplist

# check intersection with the Blood_Cell_Instruments.txt
fread("ALL.filtered.snplist.snplist", header = F) -> snplist 
snplist %>% separate(V1, c('CHR', 'BP', "ref", "alt"), sep=":") -> snplist_sep
fread("Blood_Cell_Instruments.txt") -> Blood_Cell_Instruments
Blood_Cell_Instruments %>% select(CHR, BP, SNP, effect_allele.exposure, other_allele.exposure) -> Blood_Cell_Instruments

Blood_Cell_Instruments %>% distinct() # 3000 SNPs
Blood_Cell_Instruments %>% distinct() -> Blood_Cell_Instruments

snplist_sep %>% mutate_at(c("CHR", "BP"), as.numeric) -> snplist_sep
inner_join(Blood_Cell_Instruments, snplist_sep, by = c("CHR", "BP")) -> inner_snp # 2687 SNP overlaps, among which one SNP is multiallelic
   CHR       BP      SNP effect_allele.exposure other_allele.exposure ref alt
1:   6 44562107 rs491616                      G                     T   G   C
2:   6 44562107 rs491616                      G                     T   G   T 
Blood_Cell_Instruments %>% anti_join(snplist_sep, by = c("CHR", "BP")) -> anti_snp # 313 # missing 50 SNPs for lymphocytes (50/429)

# check non-inferable palindromic variants with intermediate allele frequencies (MAF>0.42). 
Blood_Cell_Instruments %>% filter(eaf.exposure < 0.5) %>% filter(eaf.exposure > 0.42) # 209
Blood_Cell_Instruments %>% filter(eaf.exposure >= 0.5) %>% filter(eaf.exposure <= 0.58) # 246
Blood_Cell_Instruments %>% filter(eaf.exposure < 0.5) %>% filter(eaf.exposure > 0.42) %>% distinct(CHR, BP,SNP,effect_allele.exposure,other_allele.exposure, eaf.exposure,prs_allele) -> df1_eaf.exposure_0.42_0.5
fwrite(df1_eaf.exposure_0.42_0.5, "df1_eaf.exposure_0.42_0.5.txt")
Blood_Cell_Instruments %>% filter(eaf.exposure >= 0.5) %>% filter(eaf.exposure <= 0.58) %>% distinct(CHR, BP,SNP,effect_allele.exposure,other_allele.exposure, eaf.exposure,prs_allele) -> df1_eaf.exposure_0.5_0.58
fwrite(df1_eaf.exposure_0.5_0.58, "df1_eaf.exposure_0.5_0.58.txt")
anti_snp %>% inner_join(df1_eaf.exposure_0.42_0.5, by = c("CHR", "BP")) %>% distinct(CHR,BP) # 13
anti_snp %>% inner_join(df1_eaf.exposure_0.5_0.58, by = c("CHR", "BP")) %>% distinct(CHR,BP) # 25
fread("snplist_missing_233.txt") -> snp233

snp233 %>% inner_join(df1_eaf.exposure_0.42_0.5, by = c("CHR", "BP")) %>% distinct(CHR,BP) # 12
snp233 %>% inner_join(df1_eaf.exposure_0.5_0.58, by = c("CHR", "BP")) %>% distinct(CHR,BP) # 24
# two snps in imputation, but with MAF > 0.42
# 17 81040847
# 19 3172905

read_rds("../imputed/chr_info.rds") -> chr_info
chr_info %>% separate(SNP, c('CHR', 'BP'), sep=":") -> chr_info
chr_info %>% mutate_at(c("CHR", "BP"), as.numeric) -> chr_info
fread("anti_snp.txt") -> anti_snp
inner_join(anti_snp, chr_info, by = c("CHR", "BP")) -> inner_snp 
inner_snp %>% fwrite("anti_snp_filtered80.txt") # 80 were filtered out, among which 60 with a Rsq < 0.3, and 20 with a MAF < 0.01

chr_info %>% select(CHR, BP, `REF(0)`, `ALT(1)`) -> snp_list_all_afterimputation
snp_list_all_afterimputation %>% fwrite("snp_list_all_afterimputation.txt") # 39117105, HRC panel has 39,741,659 in total

# find out those SNPs that did not get imputed
anti_snp %>% anti_join(snp80, by = c("CHR", "BP")) -> snp_missing # 313


# add column to indicate missing reasons: 
fread("snplist_missing_233.txt") -> snp233
fread("anti_snp_filtered80.txt") -> snp80
snp80 %>% mutate(missing_reason = case_when(
    MAF < 0.01 ~ "MAF<0.01",
    Rsq < 0.3 ~ "Rsq<0.3"
)) %>% select(CHR,BP, SNP, missing_reason) -> snp80_short
snp233 %>% mutate(missing_reason = "noimpute") %>% select(CHR,BP, SNP, missing_reason) -> snp233_short
rbind(snp80_short, snp233_short) -> mysnp
fread("Blood_Cell_Instruments.txt") -> allsnp
allsnp %>% inner_join(mysnp, by = c("CHR", "BP", "SNP"))

# missing SNP for each trait 
allsnp %>% inner_join(mysnp, by = c("CHR", "BP", "SNP")) %>% group_by(exposure) %>% distinct(SNP) %>% count(exposure) %>% fwrite("snplist_9trait_missing.csv") 
allsnp %>% inner_join(mysnp, by = c("CHR", "BP", "SNP")) %>% count(exposure, missing_reason) %>% fwrite("snplist_9trait_missing_withreason.csv") 
allsnp %>% inner_join(mysnp, by = c("CHR", "BP", "SNP")) %>% fwrite("snplist_9trait_missing_full_list.txt")


Basophil_140snp_info.txt    LMR_410snp_info.txt         Mono.z_455snp_info.txt      NLR_231snp_info.txt       PLR_435snp_info.txt
Eosinophil_350snp_info.txt  Lymphocyte_379snp_info.txt  Neutrophil_278snp_info.txt  Platelet_631snp_info.txt

#####################################################################
#################### extract instruments for Lymphocytes ################
#####################################################################
fread("Lymphocyte.txt") -> Lymphocyte
fread("snplist_sep.txt") -> snplist
snplist %>% mutate_at(c("CHR", "BP"), as.numeric) -> snplist_sep
snplist_sep %>% inner_join(Lymphocyte, by = c("CHR", "BP")) %>% distinct(V1) %>% fwrite("Lymphocyte_379snp.txt", col.names = F)
snplist_sep %>% inner_join(Lymphocyte, by = c("CHR", "BP")) %>% fwrite("Lymphocyte_379snp_info.txt", sep = "\t")

# check SNP strand 
fread("Lymphocyte_379snp_info.txt") -> df
df %>% filter(ref == effect_allele.exposure)

# Create new plink2 file using instruments
## create a1 allele 
Lymphocyte_379snp_info %>% select(V1, prs_allele) %>% fwrite("Lymphocyte_a1.txt", col.names= F, sep = "\t")

plink2 \
    --pfile ../../imputed/ALL.filtered \
    --extract Lymphocyte_379snp.txt \
    --alt1-allele force Lymphocyte_a1.txt \
    --make-pgen \
    --out Lymphocyte_379_a1
# 182 sets of allele codes rotated.

# create summary statistics file 
# CHR BP SNP A1 A2 N SE P OR INFO MAF BETA
# 1 17 16
# 1 SNP id in my pgen file
# 17 prs allele
# 16 prs weight

# prs calculation
plink2 \
    --pfile Lymphocyte_379_a1 \
    --score Lymphocyte_379snp_info.txt 1 17 16 header \
    --out Lymphocyte

# actually do not need to flip a1 ############
# can use score directly on All.filtered ############
# as long as col 17 is specified ############
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Basophil_140snp_info.txt 1 17 16 header \
    --out Basophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Eosinophil_350snp_info.txt 1 17 16 header \
    --out Eosinophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score LMR_410snp_info.txt 1 17 16 header \
    --out LMR
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Mono.z_455snp_info.txt 1 17 16 header \
    --out Mono.z
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Neutrophil_278snp_info.txt 1 17 16 header \
    --out Neutrophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score NLR_231snp_info.txt 1 17 16 header \
    --out NLR
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Platelet_631snp_info.txt 1 17 16 header \
    --out Platelet
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score PLR_435snp_info.txt 1 17 16 header \
    --out PLR


# merge the score file with clinical data 
fread("Lymphocyte.sscore") -> Lymphocyte
fread("../../gwas_run/covar_master.txt") -> covar
fread("../../gwas_run/pheno_binary_codemissing.txt") -> binary
fread("../../gwas_run/cog_pheno_WBC.txt") ->wbc
fread("../../gwas_run/cog_pheno_CNS_categorical.txt") ->CNS
mydata <- Lymphocyte %>% left_join(covar, by = "#IID")%>% left_join(binary, by = "#IID")%>% left_join(wbc, by = "#IID")%>% left_join(CNS, by = "#IID")

Basophil.sscore.cov.txt    LMR.sscore.cov.txt                NLR.sscore.cov.txt       PLR.sscore.cov.txt
Eosinophil.sscore.cov.txt  Lymphocyte.sscore.cov.txt  Neutrophil.sscore.cov.txt  Platelet.sscore.cov.txt

fread("Platelet.sscore.cov.txt") %>% left_join(CNS, by = "#IID") %>% mutate(
    CNS_Status = case_when(
        CNS_Status == "-9" ~ "NA", 
        CNS_Status == "CNS1" ~ "CNS1",
        CNS_Status == "CNS2" ~ "CNS2",
        CNS_Status == "CNS3" ~ "CNS3"
    )
) %>% fwrite("Platelet.sscore.cov.txt")

Lymphocyte %>% left_join(covar, by = "#IID") %>% left_join(binary, by = "#IID") %>% left_join(wbc, by = "#IID") -> mydata

# recode relapse
mydata %>% mutate(
    Relapse = case_when(
        Relapse == "-9" ~ "NA", 
        Relapse == "1" ~ "0",
        Relapse == "2" ~ "1"
    )
)  -> mydata

mydata %>% mutate(
    ETV6_RUNX1 = case_when(
        ETV6_RUNX1 == "-9" ~ "NA", 
        ETV6_RUNX1 == "1" ~ "0",
        ETV6_RUNX1 == "2" ~ "1"
    )
)  -> mydata

mydata %>% mutate(
    Trisomy_4_10 = case_when(
        Trisomy_4_10 == "-9" ~ "NA", 
        Trisomy_4_10 == "1" ~ "0",
        Trisomy_4_10 == "2" ~ "1"
    )
)  -> mydata


mydata %>% mutate(
    CNS_Status = case_when(
        CNS_Status == "-9" ~ "NA", 
        CNS_Status == "CNS1" ~ "CNS1",
        CNS_Status == "CNS2" ~ "CNS2",
        CNS_Status == "CNS3" ~ "CNS3"
    )
)  -> mydata


mydata %>% count(Trisomy_4_10)
mydata %>% count(ETV6_RUNX1) 

mydata %>% mutate_at(c("Relapse", "Trisomy_4_10", "ETV6_RUNX1"), as.numeric) -> mydata
library(broom)
glm(Relapse ~ WBC, data = mydata, family = "binomial") %>% tidy()
glm(Relapse ~ WBC + SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()
glm(Relapse ~ WBC + SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()
glm(Relapse ~ WBC + SCORE1_AVG + Gender + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data = mydata, family = "binomial") %>% tidy()
glm(Relapse ~ WBC + SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()
glm(WBC ~ SCORE1_AVG, data = mydata, family = "gaussian") %>% tidy()
glm(Relapse ~ SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()
glm(Trisomy_4_10 ~ SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()
glm(ETV6_RUNX1 ~ SCORE1_AVG, data = mydata, family = "binomial") %>% tidy()


#     min   max    mean  median
# 1 0.01308 0.017 0.01496 0.01499

#####################################################################
#################### find missing SNP proxies #######################
#####################################################################
#####################################################################
library(LDlinkR)
list_pop()
fread("anti_snp.txt") -> missing_snp
missing_snp %>% pull(SNP) -> SNP_list_LDLINK_input

LDproxy_batch(SNP_list_LDLINK_input, pop = "EUR", r2d = "r2", token = "b5418a778af3", append = T)

##  error: rs3734537 is not a biallelic variant.,rs5875276 is not a biallelic variant., # found proxies for 311 SNPs out of 313 SNPs

cat ALL.filtered.pvar | grep -v "^#" > "ALL.filtered.finding_proxy.txt"

fread("ALL.filtered.finding_proxy.txt") -> snp_imputed
fread("combined_query_snp_list.txt") -> proxy_candi
snp_imputed %>% separate(V8, c("AF", "MAF", "R2_imputation", "IMPUTED"), sep = ";") -> snp_imputed
snp_imputed$R2_imputation <- as.numeric(gsub("R2=", "", snp_imputed$R2_imputation))
fwrite(snp_imputed, "snp_imputed_R2_imputation.txt")
proxy_candi  %>% separate(Coord, c("chr", "pos"), sep = ":") -> proxy_candi
proxy_candi$chr <- gsub("chr", "", proxy_candi$chr)
snp_imputed %>% rename("chr" = "V1", "pos" = "V2") -> snp_imputed
proxy_candi$chr <- as.numeric(proxy_candi$chr)
proxy_candi$pos <- as.numeric(proxy_candi$pos)

proxy_candi %>% filter(RS_Number != query_snp) %>% filter(R2>0.95) %>% inner_join(snp_imputed, by = c("chr", "pos")) %>% group_by(query_snp) %>% arrange(desc(R2), desc(R2_imputation), desc(Distance)) %>% slice(1) -> proxies_final # 131 SNPs with proxies #182 do not have  # originally 313 missing 
fwrite(proxies_final, "proxies_final_131.txt")
# update the blood instrument file 
fread("../Blood_Cell_Instruments.txt") -> blood_instrument
fread("proxies_final_131.txt") -> proxies
proxies_allele <- proxies %>% separate(Correlated_Alleles, c("allele1", "allele2"), sep = ",") %>% separate(allele1, c("allele1_old", "allele1_new"), sep = "=") %>% separate(allele2, c("allele2_old", "allele2_new"), sep = "=") %>% select(query_snp, RS_Number, chr, pos, allele1_new, allele1_old, allele2_new, allele2_old)

proxies %>% separate(Correlated_Alleles, c("allele1", "allele2"), sep = ",") %>% separate(allele1, c("allele1_old", "allele1_new"), sep = "=") %>% separate(allele2, c("allele2_old", "allele2_new"), sep = "=") %>% filter(allele1_old != V4 | allele2_old != V5) # five with flipped allele

proxies_allele <- proxies_allele %>% rename("SNP"= "query_snp")
# has NA for ref allele it should be C - update it 
proxies_allele <- proxies_allele %>% mutate(allele1_old = ifelse(SNP == "rs181707610", "C", allele1_old))

blood_instrument_join_proxies <- blood_instrument %>% left_join(proxies_allele, by = "SNP")
blood_instrument_join_proxies %>% 
mutate(
    SNP = ifelse(is.na(RS_Number), SNP, RS_Number), 
    CHR = ifelse(is.na(RS_Number), CHR, chr), 
    BP = ifelse(is.na(RS_Number), BP, pos)) %>% 
mutate(
    effect_allele.exposure = case_when(
    is.na(allele1_new) ~ effect_allele.exposure,
    !is.na(allele1_new) & effect_allele.exposure == allele1_old ~ allele1_new,
    !is.na(allele2_new) & effect_allele.exposure == allele2_old ~ allele2_new
)) %>% 
mutate(other_allele.exposure = case_when(
    is.na(allele1_new) ~ other_allele.exposure,
    !is.na(allele1_new) & other_allele.exposure == allele1_old ~ allele1_new,
    !is.na(allele2_new) & other_allele.exposure == allele2_old ~ allele2_new
)) %>% mutate(prs_allele = case_when(
    is.na(allele1_new) ~ prs_allele,
    !is.na(allele1_new) & prs_allele == allele1_old ~ allele1_new,
    !is.na(allele2_new) & prs_allele == allele2_old ~ allele2_new
)) -> blood_instrument_join_proxies_updated

blood_instrument_updated <- blood_instrument_join_proxies_updated %>% select(-c("RS_Number", "chr", "pos", "allele1_new", "allele1_old", "allele2_new", "allele2_old"))

blood_instrument_updated %>% fwrite("blood_instrument_updated_proxies.txt", sep = "\t")

# create info files 
fread("snp_imputed_R2_imputation.txt") -> df
fread("blood_instrument_updated_proxies.txt") -> instrument
df[,1:5] -> df
colnames(df) <- c("CHR", "BP", "V1", "ref", "alt")
instrument %>% left_join(df, by = c("CHR", "BP")) # two more columns 
instrument %>% left_join(df, by = c("CHR", "BP")) -> instrument2
instrument2  %>% count(exposure, CHR, BP) %>% filter(n >1)  # check duplicates 
# remove the G C records 
instrument2 %>% filter(!V1 == "6:44562107:G:C")
instrument2 %>% filter(!V1 == "6:44562107:G:C" | is.na(V1)) -> instrument2
instrument2 %>% select(c("V1","CHR","BP","ref", "alt", "SNP", "effect_allele.exposure", "other_allele.exposure", "samplesize.exposure", "eaf.exposure", "beta.exposure", "se.exposure", "pval.exposure", "units.exposure", "exposure", "prs_weight", "prs_allele")) -> instrument2
instrument2 -> data

# update the units.exposure column 
data %>% mutate(units.exposure  = ifelse(units.exposure  == "1SD", "1SD", "1unitratio")) -> data

data %>% filter(exposure == "Basophil") %>% fwrite("Basophil.info.txt",sep = "\t")
data %>% filter(exposure == "Eosinophil") %>% fwrite("Eosinophil.info.txt",sep = "\t")
data %>% filter(exposure == "LMR") %>% fwrite("LMR.info.txt",sep = "\t")
data %>% filter(exposure == "Lymphocyte") %>% fwrite("Lymphocyte.info.txt",sep = "\t")
data %>% filter(exposure == "Mono.z") %>% fwrite("Mono.z.info.txt",sep = "\t")
data %>% filter(exposure == "Neutrophil") %>% fwrite("Neutrophil.info.txt",sep = "\t")
data %>% filter(exposure == "NLR") %>% fwrite("NLR.info.txt",sep = "\t")
data %>% filter(exposure == "Platelet") %>% fwrite("Platelet.info.txt",sep = "\t")
data %>% filter(exposure == "PLR") %>% fwrite("PLR.info.txt",sep = "\t")

####################################################################
#################### calculate PRS again ############################
#####################################################################
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Lymphocyte.info.txt 1 17 16 header \
    --out Lymphocyte
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Basophil.info.txt 1 17 16 header \
    --out Basophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Eosinophil.info.txt 1 17 16 header \
    --out Eosinophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score LMR.info.txt 1 17 16 header \
    --out LMR
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Mono.z.info.txt 1 17 16 header \
    --out Mono.z
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Neutrophil.info.txt 1 17 16 header \
    --out Neutrophil
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score NLR.info.txt 1 17 16 header \
    --out NLR
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score Platelet.info.txt 1 17 16 header \
    --out Platelet
plink2 \
    --pfile ../../imputed/ALL.filtered \
    --score PLR.info.txt 1 17 16 header \
    --out PLR

####################################################################
#################### merge the score file with clinical data  ############################
#####################################################################
# use a for loop to do this 
library(data.table)
library(tidyverse)

for (input in c("Basophil", "LMR", "NLR", "PLR", "Eosinophil", "Lymphocyte", "Neutrophil", "Platelet", "Mono.z"))
{
fread(paste0(input,".sscore")) -> Lymphocyte
fread("../../gwas_run/covar_master.txt") -> covar
fread("../../gwas_run/pheno_binary_codemissing.txt") -> binary
fread("../../gwas_run/cog_pheno_WBC.txt") ->wbc
fread("../../gwas_run/cog_pheno_CNS_categorical.txt") ->CNS
mydata <- Lymphocyte %>% left_join(covar, by = "#IID")%>% left_join(binary, by = "#IID")%>% left_join(wbc, by = "#IID")%>% left_join(CNS, by = "#IID")

mydata %>% mutate(
    CNS_Status = case_when(
        CNS_Status == "-9" ~ "NA", 
        CNS_Status == "CNS1" ~ "CNS1",
        CNS_Status == "CNS2" ~ "CNS2",
        CNS_Status == "CNS3" ~ "CNS3"
    )
) %>% mutate(
    Relapse = case_when(
        Relapse == "-9" ~ "NA", 
        Relapse == "1" ~ "0",
        Relapse == "2" ~ "1"
    )
)  %>% mutate(
    ETV6_RUNX1 = case_when(
        ETV6_RUNX1 == "-9" ~ "NA", 
        ETV6_RUNX1 == "1" ~ "0",
        ETV6_RUNX1 == "2" ~ "1"
    )
)  %>% mutate(
    Trisomy_4_10 = case_when(
        Trisomy_4_10 == "-9" ~ "NA", 
        Trisomy_4_10 == "1" ~ "0",
        Trisomy_4_10 == "2" ~ "1"
    )
)  -> mydata

mydata %>% mutate_at(c("Relapse", "Trisomy_4_10", "ETV6_RUNX1"), as.numeric) -> mydata

mydata %>% count(Trisomy_4_10)
mydata %>% count(ETV6_RUNX1)
mydata %>% count(Relapse) 
mydata %>% count(CNS_Status) 
mydata %>% fwrite(paste0(input,".sscore.cov.txt"))

}

######################### extract array variable #####################
#####################################################################
#####################################################################
fread("/dir/kerenxu/gwas_cog/pre_imputation/cog9906_500K.fam") ->  snp5
fread("/dir/kerenxu/gwas_cog/pre_imputation/cog9904_9905_snp6.fam") ->  snp6
snp5 <- snp5 %>% unite("#IID", V1:V2, sep = "_",remove = FALSE) %>% select(`#IID`)
snp5$array <- "500K"
snp6 <- snp6 %>% unite("#IID", V1:V2, sep = "_",remove = FALSE) %>% select(`#IID`)
snp6$array <- "affy6"
df_array <- rbind(snp5, snp6)
df_array %>% fwrite("array_type.txt")

######################### PRSice##########################################
# download PRSice wget https://github.com/choishingwan/PRSice/releases/download/2.3.3/PRSice_linux.zip

#####################################################################
#################### double check PRS ###############################
#####################################################################

cp /dir/kerenxu/gwas_cog/prs/prs_plink2/Lymphocyte_379snp.txt MySNPs.list

bcftools filter --include 'ID=@MySNPs.list' ALL.filtered_sorted.vcf.gz > Lymphocyte.vcf

bcftools filter --include 'ID=@/dir/kerenxu/gwas_cog/prs/prs_plink2/Mono.z_455snp.txt' ALL.filtered_sorted.vcf.gz > Lymphocyte.vcf

# in R check DS and HDS, calculate PRS manually
library(data.table)
library(tidyverse)
fread("z_gt_cleaned_Lymphocyte_379snp.txt") -> z_gt
fread("Lymphocyte_379snp_info.txt") -> Lymphocyte_379snp_info
Lymphocyte_379snp_info %>% filter(prs_allele == ref) %>% pull(V1) -> snp_flip_dosage
z_gt %>% mutate(gt_DS_flipped = ifelse(ID %in% snp_flip_dosage, 2-gt_DS, gt_DS)) %>% select(Indiv, ID, gt_DS_flipped) -> z_gt_flipped
z_gt_flipped %>% pivot_wider(names_from = ID, values_from = gt_DS_flipped) -> z_gt_wider
z_gt_wider[,-1]
NAMED_ALLELE_DOSAGE_SUM = apply(z_gt_wider[,-1], 1, sum)
Lymphocyte_379snp_info %>% pull(prs_weight) -> prs_weight
SCORE1_AVG <- apply(mapply(FUN = `*`, z_gt_wider, prs_weight), 1, sum) /758
df <- data.frame(z_gt_wider$Indiv, NAMED_ALLELE_DOSAGE_SUM, SCORE1_AVG)

## check if there is missing SNP in the dataset
apply(is.na(df), 1, sum)
