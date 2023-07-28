
all_paths <- list.files(pattern = "*.seg", full.names = TRUE)

# read file content
all_content <-
  all_paths %>%
  lapply(fread,
    header = TRUE
  )

# read file name
all_filenames <- all_paths %>%
  basename() %>%
  as.list()

# combine file content list and file name list
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

# unlist all lists and change column name
all_result <- rbindlist(all_lists, fill = T)

# change column name
all_result <- all_result %>%
  separate("V1", c("Sample", "junk"), sep = ".seg") %>%
  relocate(Sample) %>%
  select(Sample, chrom, loc.start, loc.end, num.mark, seg.mean)
colnames(all_result) <- c("Sample", "Chromosome", "Start Position", "End Position", "Num Markers", "Seg.CN")

fwrite(all_result, "gistic_38_input.seg", sep = "\t")
