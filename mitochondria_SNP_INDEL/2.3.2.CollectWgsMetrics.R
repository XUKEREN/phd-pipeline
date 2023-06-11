# R codes to summarize

args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
library(data.table)
library(tidyverse)

df <- read.table(paste0(input, ".AlignToMt.bam.CollectWgsMetrics.metrics.txt"), skip = 6, header = TRUE, stringsAsFactors = FALSE, sep = "\t", nrows = 1)
write.table(floor(df[, "MEAN_COVERAGE"]), paste0(input, ".AlignToMt.bam.CollectWgsMetrics.mean_coverage.txt"), quote = F, col.names = F, row.names = F)
write.table(df[, "MEDIAN_COVERAGE"], paste0(input, ".AlignToMt.bam.CollectWgsMetrics.median_coverage.txt"), quote = F, col.names = F, row.names = F)
