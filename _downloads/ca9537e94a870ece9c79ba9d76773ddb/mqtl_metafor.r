## Setting up the data and loading metafor
# We start with a dataframe with coefficients and standard errors from comparable EWAS run in several different cohorts.
library(tidyverse)
library(data.table)
library(metafor)
library(reshape)

## meta output for set 234 ##########################################################
mqtl_set2_dmp234 <- fread("mqtl_set2_dmp234.txt")
mqtl_set3_dmp234 <- fread("mqtl_set3_dmp234.txt")
mqtl_set4_dmp234 <- fread("mqtl_set4_dmp234.txt")

dat_set2 <- mqtl_set2_dmp234 %>%
  select(c("snps", "gene", "beta", "se")) %>%
  unite("snp_probe", snps:gene) %>%
  dplyr::rename("coef.set2" = "beta", "se.set2" = "se")

dat_set3 <- mqtl_set3_dmp234 %>%
  select(c("snps", "gene", "beta", "se")) %>%
  unite("snp_probe", snps:gene) %>%
  dplyr::rename("coef.set3" = "beta", "se.set3" = "se")

dat_set4 <- mqtl_set4_dmp234 %>%
  select(c("snps", "gene", "beta", "se")) %>%
  unite("snp_probe", snps:gene) %>%
  dplyr::rename("coef.set4" = "beta", "se.set4" = "se")


dat <- dat_set2 %>%
  inner_join(dat_set3, by = "snp_probe") %>%
  inner_join(dat_set4, by = "snp_probe") %>%
  data.frame()


# First, we create a list of our study names:
studies <- c("set2", "set3", "set4")

## Create the functions for a fixed effects meta-analysis
# Then we make the function that will run the meta-analysis. In this case, we're creating a function that will run a fixed effects analysis weighted by the inverse of the variance (se). The first part of the function gets the data into long format. The meta-analysis itself is performed by `rma.uni()`. Within this function, `method="FE"` tells R that we want to run a fixed effects meta-analysis.

fixed.effects.meta.analysis <- function(list.of.studies, data) {
  require(metafor)
  coefs <- data[, c("snp_probe", paste0("coef.", list.of.studies))]
  ses <- data[, c("snp_probe", paste0("se.", list.of.studies))]
  require(reshape)
  coefs <- melt(coefs)
  names(coefs) <- c("snp_probe", "set", "coef")
  ses <- melt(ses)
  data.long <- cbind(coefs, ses[, "value"])
  names(data.long) <- c("snp_probe", "set", "coef", "se")
  res <- split(data.long, f = data$snp_probe)
  res <- lapply(res, function(x) rma.uni(slab = x$study, yi = x$coef, sei = x$se, method = "FE", weighted = TRUE))
  res
}


# Now, we make another function that will extract all the information we want from our meta-analyses and merge the results back with our original cohort-specific data:
extract.and.merge.meta.analysis <- function(meta.res, data) {
  require(plyr)
  data.meta <- ldply(lapply(meta.res, function(x) unlist(c(x$b[[1]], x[c("se", "pval", "QE", "QEp", "I2", "H2")]))))
  colnames(data.meta) <- c("snp_probe", "coef.fe", "se.fe", "p.fe", "q.fe", "het.p.fe", "i2.fe", "h2.fe")
  data <- merge(data, data.meta, by = "snp_probe", all.x = T)
  data
}

## Run a fixed effects meta-analysis
# And finally, run the fixed-effects meta-analysis:
meta.results <- fixed.effects.meta.analysis(list.of.studies = studies, data = dat)
dat <- extract.and.merge.meta.analysis(meta.res = meta.results, data = dat)
dat <- dat %>% dplyr::mutate(adjP = p.adjust(p.fe, method = "fdr"))
dat <- dat %>% separate(snp_probe, c("snps", "gene"), sep = "_")
fwrite(dat, "mqtl_metafor_output_dmp234.txt")

# The output shows:

#* probe: probe ID
#* coef.study1: regression coefficient from EWAS in study 1
#* coef.study2: regression coefficient from EWAS in study 2
#* coef.study3: regression coefficient from EWAS in study 3
#* se.study1: standard error from EWAS in study 1
#* se.study2: standard error from EWAS in study 2
#* se.study3: standard error from EWAS in study 3
#* coef.fe: the meta-analysed coefficient (fixed effects)
#* se.fe: the meta-analysed standard error (fixed effects)
#* p.fe: the meta-analysed p-value (fixed effects)
#* q.fe: heterogeneity q-value
#* het.p.fe: heterogeneity p-value
#* i2.fe: heterogeneity statistic (I^2)
#* h2.fe: heterogeneity statistic (h^2)

## Forest plots
# It's usually helpful to be able to visualise the data using a forest plot.
# To do this, we can just use the `meta.results` object generated in the last step.


## meta output for set 34 ##########################################################
mqtl_set3_dmp34 <- fread("mqtl_set3_dmp34.txt")
mqtl_set4_dmp34 <- fread("mqtl_set4_dmp34.txt")

dat_set3 <- mqtl_set3_dmp34 %>%
  select(c("snps", "gene", "beta", "se")) %>%
  unite("snp_probe", snps:gene) %>%
  dplyr::rename("coef.set3" = "beta", "se.set3" = "se")

dat_set4 <- mqtl_set4_dmp34 %>%
  select(c("snps", "gene", "beta", "se")) %>%
  unite("snp_probe", snps:gene) %>%
  dplyr::rename("coef.set4" = "beta", "se.set4" = "se")

dat <- dat_set3 %>%
  inner_join(dat_set4, by = "snp_probe") %>%
  data.frame()

# First, we create a list of our study names:
studies <- c("set3", "set4")

## Create the functions for a fixed effects meta-analysis

# Then we make the function that will run the meta-analysis. In this case, we're creating a function that will run a fixed effects analysis weighted by the inverse of the variance (se). The first part of the function gets the data into long format. The meta-analysis itself is performed by `rma.uni()`. Within this function, `method="FE"` tells R that we want to run a fixed effects meta-analysis.

fixed.effects.meta.analysis <- function(list.of.studies, data) {
  require(metafor)
  coefs <- data[, c("snp_probe", paste0("coef.", list.of.studies))]
  ses <- data[, c("snp_probe", paste0("se.", list.of.studies))]
  require(reshape)
  coefs <- melt(coefs)
  names(coefs) <- c("snp_probe", "set", "coef")
  ses <- melt(ses)
  data.long <- cbind(coefs, ses[, "value"])
  names(data.long) <- c("snp_probe", "set", "coef", "se")
  res <- split(data.long, f = data$snp_probe)
  res <- lapply(res, function(x) rma.uni(slab = x$study, yi = x$coef, sei = x$se, method = "FE", weighted = TRUE))
  res
}


# Now, we make another function that will extract all the information we want from our meta-analyses and merge the results back with our original cohort-specific data:
extract.and.merge.meta.analysis <- function(meta.res, data) {
  require(plyr)
  data.meta <- ldply(lapply(meta.res, function(x) unlist(c(x$b[[1]], x[c("se", "pval", "QE", "QEp", "I2", "H2")]))))
  colnames(data.meta) <- c("snp_probe", "coef.fe", "se.fe", "p.fe", "q.fe", "het.p.fe", "i2.fe", "h2.fe")
  data <- merge(data, data.meta, by = "snp_probe", all.x = T)
  data
}

## Run a fixed effects meta-analysis
# And finally, run the fixed-effects meta-analysis:
meta.results <- fixed.effects.meta.analysis(list.of.studies = studies, data = dat)
dat <- extract.and.merge.meta.analysis(meta.res = meta.results, data = dat)
dat <- dat %>% dplyr::mutate(adjP = p.adjust(p.fe, method = "fdr"))
dat <- dat %>% separate(snp_probe, c("snps", "gene"), sep = "_")
fwrite(dat, "mqtl_metafor_output_dmp34.txt")
