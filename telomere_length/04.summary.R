library(data.table)
library(tidyverse)
library(pals)
setwd("/dir/telomere.length")

# load summary stats from step 3
telseq <- fread("ALL.25cohort.telseq.txt", header = F) %>% select(-V35)
telomerehunter <- fread("ALL.25cohort.telomerehunter.txt")

# clean two datasets
colnames(telseq) <- c("ReadGroup", "Library", "Sample", "Total", "Mapped", "Duplicates", "LENGTH_ESTIMATE", "TEL0", "TEL1", "TEL2", "TEL3", "TEL4", "TEL5", "TEL6", "TEL7", "TEL8", "TEL9", "TEL10", "TEL11", "TEL12", "TEL13", "TEL14", "TEL15", "TEL16", "GC0", "GC1", "GC2", "GC3", "GC4", "GC5", "GC6", "GC7", "GC8", "GC9")

colnames(telomerehunter) <- c("PID", "sample", "total_reads", "intratel_reads", "gc_bins_for_correction", "total_reads_with_tel_gc", "tel_content")

## for telomerehunter, tel_content is the column indicating TL
df.telomerehunter.length.final <- telomerehunter %>%
    mutate(Sample = ifelse(sample == "tumor", paste0("T", PID), paste0("G", PID))) %>%
    select(sample, Sample, tel_content) %>%
    rename("Sample Type" = "sample")

## for telseq, to calculate TL for each sample, we need to take a weighted average of all the read groups within each sample:
## https://github.com/zd1/telseq/issues/1

df.sample.reads.total <- telseq %>%
    group_by(Sample) %>%
    summarize(sample.reads.total = sum(Total))

df.telseq.length.final <- telseq %>%
    left_join(df.sample.reads.total, by = "Sample") %>%
    mutate(LENGTH_ESTIMATE_weighted = LENGTH_ESTIMATE * Total / sample.reads.total) %>%
    group_by(Sample) %>%
    summarize(telseq.length = sum(LENGTH_ESTIMATE_weighted))

df_final <- df.telomerehunter.length.final %>% left_join(df.telseq.length.final)

# create final correlation plot
df_final %>% ggplot(aes(x = tel_content, y = telseq.length)) +
    geom_point(aes(color = `Sample Type`)) +
    theme_minimal() +
    xlab("telomerehunter") +
    ylab("telseq") +
    geom_smooth(method = "lm", formula = y ~ x) +
    scale_color_manual(values = as.vector(cols25(2))) +
    annotate("text", x = 400, y = 5, label = "italic(R) ^ 2 == 0.957", parse = TRUE) +
    annotate("text", x = 400, y = 4.8, label = "italic(P) < 2.2e-16", parse = TRUE)

cor.test(df_final$tel_content, df_final$telseq.length, methods = "spearman")

# create final output - Tumor/Normal telomere length
df_final %>%
    separate(Sample, c("junk", "Sample"), sep = "G") %>%
    separate(junk, c("junk", "Sample2"), sep = "T") %>%
    mutate(Sample = ifelse(is.na(Sample), Sample2, Sample)) %>%
    dplyr::rename("telhunter.tel_content" = "tel_content") %>%
    select(-c("junk", "Sample2")) %>%
    pivot_wider(names_from = `Sample Type`, values_from = c("telhunter.tel_content", "telseq.length")) %>%
    mutate(telseq.T.N.ratio = telseq.length_tumor / telseq.length_control) %>%
    mutate(telomerehunter.T.N.ratio = telhunter.tel_content_tumor / telhunter.tel_content_control) %>%
    fwrite("ALL.25cohort.T.N.ratio.txt")
