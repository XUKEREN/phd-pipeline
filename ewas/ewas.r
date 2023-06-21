library(tidyverse)
library(data.table)
library(impute)
library(minfi)
library(IlluminaHumanMethylationEPICanno.ilm10b2.hg19)
library(IlluminaHumanMethylation450kanno.ilmn12.hg19)

# Set work path
setwd("/dir/kerenxu/methylation_mediation")

# Clinical data frame preparation, rename columns for variables to match exactly

clinical_0 <- read.csv("clinical_variables/clinical_variables.csv")

glint <- read.csv("glint_PCs/glint_PCs.csv") # dataframe containing variables to control for

## main variable to look at
varOI <- "CaCo"
clinical_0 %>% dplyr::count(CaCo)

## variables to be controlled for
varCF <- c("sex", "plate")
clinical_0 %>% dplyr::count(sex)
clinical_0 %>% dplyr::count(plate)

glintvarCF <- c("rc1", "rc2", "rc3", "rc4", "rc5", "rc6", "rc7", "rc8", "rc9", "rc10", "epi1", "epi2", "epi3", "epi4", "epi5", "epi6", "epi7", "epi8", "epi9", "epi10")

# Prepare beta values for the file
beta_0 <- as.data.frame(readRDS("methylation/methylation_noob/beta_noob_imputed.rds"))
varDF1 <- clinical_0[, c("beadPosition", "subjectId", varCF, varOI)]
varDF2 <- allsubswithbothmethylationandgenetics[, c("beadPosition", "subjectId", "set")] %>% filter(set == "set1")
varDF3 <- glint[, c("beadPosition", glintvarCF)]
varDF4 <- inner_join(varDF1, varDF2, by = c("subjectId", "beadPosition"))
varDF5 <- inner_join(varDF4, varDF3, by = "beadPosition")
varDF6 <- na.omit(varDF5)

# subjects that will be included in the EWAS study
finalSubs <- intersect(colnames(beta_0), varDF6$beadPosition)

# beta and clinical variables based on the new data
rownames(beta_0) <- beta_0$probeId
beta_0_finalSubs <- beta_0[, finalSubs]
beta_4 <- as.data.frame(t(beta_0_finalSubs))
rownames(varDF6) <- varDF6$beadPosition
varDF7 <- varDF6[finalSubs, ]
rownames(varDF7) <- c()
beta <- beta_4
var <- varDF7
write_rds(beta, "ewas/beta.rds")
write_rds(var, "ewas/var.rds")

# start ewas
beta <- read_rds("ewas/set1/beta.rds")
var <- read_rds("ewas/set1/var.rds")

probes <- as.character(colnames(beta))

reg <- lapply(probes, function(probe) {
  c(
    data.frame(cpg_name = probe),
    summary(
      glm(beta[, probe] ~ var$CaCo + var$sex + var$plate + var$rc1 + var$rc2 + var$rc3 + var$rc4 + var$rc5 + var$rc6 + var$rc7 + var$rc8 + var$rc9 + var$rc10 + var$epi1 + var$epi2 + var$epi3 + var$epi4 + var$epi5 + var$epi6 + var$epi7 + var$epi8 + var$epi9 + var$epi10, family = "binomial")
    )$coefficients[2, 1:4]
  )
})

reg_1 <- bind_rows(reg)

data("IlluminaHumanMethylation450kanno.ilmn12.hg19")
anno <- IlluminaHumanMethylation450kanno.ilmn12.hg19 %>%
  getAnnotation() %>%
  as.data.frame()
# annotate by left joining, remove all probes on chrX, Y, and with maf <0.05 if located at SNP
outcomes_anno <- reg_1 %>%
  left_join(anno, by = c("cpg_name" = "Name")) %>%
  dplyr::filter(Probe_maf < 0.05 | is.na(Probe_maf), chr != "chrX" & chr != "chrY") %>%
  dplyr::mutate(adjP = p.adjust(`Pr(>|t|)`, method = "fdr")) %>%
  arrange(adjP)


comb_p <- outcomes_anno %>%
  mutate(chrom = chr, end = pos, start = pos, p_val = `Pr(>|t|)`) %>%
  dplyr::select(chrom, start, end, p_val) %>%
  drop_na() %>%
  arrange(chrom, start)

write_tsv(comb_p, "ewas/comb_p.txt")
write_rds(outcomes_anno, "ewas/outcomes_anno.rds")
