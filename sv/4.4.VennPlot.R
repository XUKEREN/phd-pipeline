library(VennDiagram)
library(data.table)
library(tidyverse)
library(pals)
setwd("/dir/sv/one_caller/")
theme_set(theme_light())

# read file path
all_paths <- list.files(pattern = "*.venn.txt", full.names = TRUE)

# read file content
all_content <-
  all_paths %>%
  lapply(fread,
    header = TRUE, colClasses = "character"
  )

# read file name
all_filenames <- all_paths %>%
  as.list()

# combine file content list and file name list
all_lists <- mapply(c, all_content, all_filenames, SIMPLIFY = FALSE)

# unlist all lists and change column name
all_result <- rbindlist(all_lists, fill = T)

df <- all_result

splitted <- t(sapply(df$SUPP_VEC, function(x) substring(x, first = c(1, 2, 3), last = c(1, 2, 3)))) %>% data.frame()

venn.diagram(list(delly = which(splitted[, 1] == 1), lumpy = which(splitted[, 2] == 1), manta = which(splitted[, 3] == 1)), fill = c("gray", "orange", "blue"), alpha = c(0.5, 0.5, 0.5), cex = 2, lty = 2, filename = paste0("38samples.overlapp.tiff"), main = "38 samples", main.pos = c(0.1, 0.1))

df_total <- all_result %>%
  filter(SUPP %in% c("2", "3")) %>%
  count(sample) %>%
  rename("n_total" = "n")

# stacked
all_result %>%
  filter(SUPP %in% c("2", "3")) %>%
  count(sample, SVTYPE) %>%
  left_join(df_total, by = "sample") %>%
  ggplot(aes(x = reorder(sample, -n_total), y = n, fill = SVTYPE)) +
  geom_bar(position = "stack", stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  scale_fill_manual(values = as.vector(cols25(25))) +
  guides(fill = guide_legend(title = "SV type")) +
  labs(x = "sample id") +
  scale_y_continuous(expand = c(0, 0))

# percent
all_result %>%
  filter(SUPP %in% c("2", "3")) %>%
  count(sample, SVTYPE) %>%
  left_join(df_total, by = "sample") %>%
  ggplot(aes(x = reorder(sample, -n_total), y = n, fill = SVTYPE)) +
  geom_bar(position = "fill", stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  scale_fill_manual(values = as.vector(cols25(25))) +
  guides(fill = guide_legend(title = "SV type")) +
  labs(x = "sample id") +
  scale_y_continuous(expand = c(0, 0))

# check the median SV
median(df_total$n_total)
range(df_total$n_total)

# check SV categories
all_result %>%
  filter(SUPP %in% c("2", "3")) %>%
  count(SVTYPE) %>%
  ggplot(aes(x = reorder(SVTYPE, -n), y = n, fill = SVTYPE)) +
  geom_bar(position = "stack", stat = "identity") +
  theme(legend.position = "none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  scale_fill_manual(values = as.vector(cols25(25))) +
  guides(fill = guide_legend(title = "")) +
  labs(x = "SV type") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1320)) +
  geom_text(aes(label = n), vjust = 0)
