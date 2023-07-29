# deconstructSigs
# https://github.com/raerose01/deconstructSigs
# https://jakeconway.github.io/docs/deconstructSigs/

library(deconstructSigs)
library(data.table)
library(tidyverse)
library(BSgenome.Hsapiens.UCSC.hg38)
library(pals)

sample.mut.ref.smoking <- fread("/dir/BCFtools.filter.tumoronly.autosomal.vcf/smoking_38_vcf/smoking_tumor_autosomal_MPF_SBS.txt", header = F)

sample.mut.ref.smoking %>%
  count(V1) %>%
  pull(V1) %>%
  dput() -> sampleid_teeth

# Convert to deconstructSigs input
sigs.input <- mut.to.sigs.input(
  mut.ref = sample.mut.ref.smoking,
  sample.id = "V1",
  chr = "V2",
  pos = "V3",
  ref = "V4",
  alt = "V5",
  bsg = BSgenome.Hsapiens.UCSC.hg38
)

# signature analysis
# https://www.rdocumentation.org/packages/deconstructSigs/versions/1.8.0/topics/whichSignatures
plot_function <- function(i) {
  plot_dataset <- whichSignatures(
    tumor.ref = sigs.input,
    signatures.ref = signatures.cosmic,
    sample.id = i,
    contexts.needed = TRUE
  )
  plot_dataset
}

sampleid_teeth %>% map(
  plot_function
) -> plot_function_output


# make pie graphs
for (i in 1:25) {
  filename <- paste0("/dir/", rownames(plot_function_output[[i]]$diff), "_pie.png")
  png(file = filename, bg = "transparent")
  makePie(plot_function_output[[i]])
}
dev.off()

# make signatures graphs
for (i in 1:25) {
  filename <- paste0("/dir/", rownames(plot_function_output[[i]]$diff), "_plotSignatures.png")
  png(file = filename, bg = "transparent")
  deconstructSigs::plotSignatures(plot_function_output[[i]])
}
dev.off()

# make dataframe
data_function <- function(i) {
  deconvolute_df <- plot_function_output[[i]]$weights
  deconvolute_df$unknwon <- plot_function_output[[i]]$unknown
  deconvolute_df$SSE <- sum(plot_function_output[[i]]$diff^2)
  deconvolute_df
}

c(1:38) %>% map(
  data_function
) -> deconvolute_df_output

deconvolute_df_output_summary <- deconvolute_df_output %>% bind_rows()

deconvolute_df_output_summary %>%
  select(c(
    "unknwon", "Signature.1", "Signature.2", "Signature.3", "Signature.4",
    "Signature.5", "Signature.6", "Signature.7", "Signature.8", "Signature.9",
    "Signature.10", "Signature.11", "Signature.12", "Signature.13",
    "Signature.14", "Signature.15", "Signature.16", "Signature.17",
    "Signature.18", "Signature.19", "Signature.20", "Signature.21",
    "Signature.22", "Signature.23", "Signature.24", "Signature.25",
    "Signature.26", "Signature.27", "Signature.28", "Signature.29",
    "Signature.30"
  )) %>%
  rownames_to_column("sampleid") %>%
  fwrite("/dir/deconstructSigs.out/deconvolute_df_output_summary.txt")

# plot out signature proportions
ggplot_df <- deconvolute_df_output_summary %>%
  rownames_to_column("sampleid") %>%
  pivot_longer(!c("sampleid", "SSE"), names_to = "signatures", values_to = "proportion") %>%
  filter(proportion != 0)

ggplot_df %>%
  pull(signatures) %>%
  unique() %>%
  dput()

ggplot_df %>% fwrite("/dir/deconstructSigs.out/deconstructSigs.out.txt")

# percent
png(file = "/dir/stacked_bar.png", bg = "transparent", width = 700, height = 500, units = "px")

ggplot(ggplot_df, aes(fill = factor(signatures, levels = c("unknwon", "Signature.25", "Signature.24", "Signature.20", "Signature.18", "Signature.16", "Signature.12", "Signature.13", "Signature.2", "Signature.4", "Signature.9", "Signature.8", "Signature.7", "Signature.6", "Signature.3", "Signature.5", "Signature.1")), y = proportion, x = reorder(sampleid, sampleid))) +
  geom_bar(position = "fill", stat = "identity") +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  scale_fill_manual(values = as.vector(cols25(25))) +
  guides(fill = guide_legend(title = "Signature")) +
  labs(x = "sample id", title = "deconstructSigs signature deconvolution")
dev.off()

# plot out error rate
png(file = "/dir/SSE.png", bg = "transparent", width = 800, height = 600, units = "px")
deconvolute_df_output_summary %>%
  rownames_to_column("sampleid") %>%
  ggplot(aes(y = SSE, x = reorder(sampleid, sampleid), label = round(SSE, 4))) +
  geom_point(color = "red") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(x = "sample id", title = "deconstructSigs SSE") +
  geom_text(size = 0.1) +
  ggrepel::geom_text_repel()
dev.off()
