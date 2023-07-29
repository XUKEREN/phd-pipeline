library(tidyverse)
library(data.table)
library(knitr)
library(mediation)
library(broom)

covariates_1487 <- fread("/dir/mediation/covariates_1487.txt")
set2 <- fread("/mediation/set2_for_med_meta234.txt") %>% filter(beadPosition %in% beadPosition_Latino_set2)
set3 <- fread("/mediation/set3_for_med_meta234.txt") %>% filter(beadPosition %in% beadPosition_Latino_set3)
set4 <- fread("/mediation/set4_for_med_meta234.txt") %>% filter(beadPosition %in% beadPosition_Latino_set4)


# test meta234 rs78396808 cg16499656
med.fit <- lm(cg16499656 ~ rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set2)
out.fit <- glm(CaCo ~ cg16499656 + rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 +
    epi6 + epi7 + epi8 + epi9 + epi10, data = set2, family = "binomial")
set.seed(2021)
med.out <- mediate(med.fit, out.fit, treat = "rs78396808", mediator = "cg16499656", robustSE = F, sims = 1000, boot = F)
write_rds(med.fit, "med.fit_set2_meta234_rs78396808_cg16499656.rds")
write_rds(out.fit, "out.fit_set2_meta234_rs78396808_cg16499656.rds")
write_rds(med.out, "med.out_set2_meta234_rs78396808_cg16499656.rds")

med.fit <- lm(cg16499656 ~ rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set3)
out.fit <- glm(CaCo ~ cg16499656 + rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 +
    epi6 + epi7 + epi8 + epi9 + epi10, data = set3, family = "binomial")
set.seed(2021)
med.out <- mediate(med.fit, out.fit, treat = "rs78396808", mediator = "cg16499656", robustSE = F, sims = 1000, boot = F)
write_rds(med.fit, "med.fit_set3_meta234_rs78396808_cg16499656.rds")
write_rds(out.fit, "out.fit_set3_meta234_rs78396808_cg16499656.rds")
write_rds(med.out, "med.out_set3_meta234_rs78396808_cg16499656.rds")


med.fit <- lm(cg16499656 ~ rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set4)
out.fit <- glm(CaCo ~ cg16499656 + rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 +
    epi6 + epi7 + epi8 + epi9 + epi10, data = set4, family = "binomial")
set.seed(2021)
med.out <- mediate(med.fit, out.fit, treat = "rs78396808", mediator = "cg16499656", robustSE = F, sims = 1000, boot = F)
write_rds(med.fit, "med.fit_set4_meta234_rs78396808_cg16499656.rds")
write_rds(out.fit, "out.fit_set4_meta234_rs78396808_cg16499656.rds")
write_rds(med.out, "med.out_set4_meta234_rs78396808_cg16499656.rds")


# test meta34 for rs78396808	cg01139861
set3 <- fread("/mediation/set3_for_med_meta34.txt") %>% filter(beadPosition %in% beadPosition_Latino_set3)
set4 <- fread("/mediation/set4_for_med_meta34.txt") %>% filter(beadPosition %in% beadPosition_Latino_set4)
med.fit <- lm(cg01139861 ~ rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set3)
out.fit <- glm(CaCo ~ cg01139861 + rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set3, family = "binomial")
set.seed(2021)
med.out <- mediate(med.fit, out.fit, treat = "rs78396808", mediator = "cg01139861", robustSE = F, sims = 1000, boot = F)
write_rds(med.fit, "med.fit_set3_meta34_rs78396808_cg01139861.rds")
write_rds(out.fit, "out.fit_set3_meta34_rs78396808_cg01139861.rds")
write_rds(med.out, "med.out_set3_meta34_rs78396808_cg01139861.rds")

med.fit <- lm(cg01139861 ~ rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set4)
out.fit <- glm(CaCo ~ cg01139861 + rs78396808 + sex + plate + rc1 + rc2 + rc3 + rc4 + rc5 + rc6 + rc7 + rc8 + rc9 + rc10 + epi1 + epi2 + epi3 + epi4 + epi5 + epi6 + epi7 + epi8 + epi9 + epi10, data = set4, family = "binomial")
set.seed(2021)
med.out <- mediate(med.fit, out.fit, treat = "rs78396808", mediator = "cg01139861", robustSE = F, sims = 1000, boot = F)
write_rds(med.fit, "med.fit_set4_meta34_rs78396808_cg01139861.rds")
write_rds(out.fit, "out.fit_set4_meta34_rs78396808_cg01139861.rds")
write_rds(med.out, "med.out_set4_meta34_rs78396808_cg01139861.rds")
