library(tidyverse)
library(data.table)
library(pmsignature)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(BSgenome.Hsapiens.UCSC.hg38)

inputFile <- paste0("/dir/BCFtools.filter.tumoronly.autosomal.vcf/smoking_38_vcf/smoking_tumor_autosomal_MPF_SBS.txt")

G <- readMPFile(inputFile,
    numBases = 5, trDir = TRUE,
    bs_genome = BSgenome.Hsapiens.UCSC.hg38::BSgenome.Hsapiens.UCSC.hg38,
    txdb_transcript = TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene
)

set.seed(2021)
Param4 <- getPMSignature(G, K = 4, numInit = 100)
Param5 <- getPMSignature(G, K = 5, numInit = 100)

# improved correlation matrix
library(corrplot)

cor4 <- round(cor(getMembershipValue(Param4)),
    digits = 2
)
cor5 <- round(cor(getMembershipValue(Param5)),
    digits = 2
)

# create dataset for loglikelihood, bootstrap error and correlation
df_loglikelihood <- data.frame(K = c(2, 3, 4, 5, 6, 7, 8), loglikelihood = c(Param2@loglikelihood, Param3@loglikelihood, Param4@loglikelihood, Param5@loglikelihood, Param6@loglikelihood, Param7@loglikelihood, Param8@loglikelihood), bootstraperror = c(mean(bootParam2[[1]]), mean(bootParam3[[1]]), mean(bootParam4[[1]]), mean(bootParam5[[1]]), mean(bootParam6[[1]]), mean(bootParam7[[1]]), mean(bootParam8[[1]])), max.cor = c(max(cor2[cor2 != max(cor2)]), max(cor3[cor3 != max(cor3)]), max(cor4[cor4 != max(cor4)]), max(cor5[cor5 != max(cor5)]), max(cor6[cor6 != max(cor6)]), max(cor7[cor7 != max(cor7)]), max(cor8[cor8 != max(cor8)])))

# create plots to decide the best number of signatures
df_loglikelihood %>% ggplot(aes(x = K, y = loglikelihood)) +
    geom_line()
ggsave("loglikelihood.png", width = 6, height = 4)

df_loglikelihood %>% ggplot(aes(x = K, y = bootstraperror)) +
    geom_line()
ggsave("bootstraperror.png", width = 6, height = 4)

df_loglikelihood %>% ggplot(aes(x = K, y = max.cor)) +
    geom_line()
ggsave("max.cor.png", width = 6, height = 4)

corrplot(cor(getMembershipValue(Param4)),
    method = "number",
    type = "upper" # show only upper side
)
corrplot(cor(getMembershipValue(Param5)),
    method = "number",
    type = "upper" 

# visualize signature
visPMSignature(Param4, 1)
ggsave("k4.1.png", width = 6, height = 4)
visPMSignature(Param4, 2)
ggsave("k4.2.png", width = 6, height = 4)
visPMSignature(Param4, 3)
ggsave("k4.3.png", width = 6, height = 4)
visPMSignature(Param4, 4)
ggsave("k4.4.png", width = 6, height = 4)

visPMSignature(Param5, 1)
ggsave("k5.1.png", width = 6, height = 4)
visPMSignature(Param5, 2)
ggsave("k5.2.png", width = 6, height = 4)
visPMSignature(Param5, 3)
ggsave("k5.3.png", width = 6, height = 4)
visPMSignature(Param5, 4)
ggsave("k5.4.png", width = 6, height = 4)
visPMSignature(Param5, 5)
ggsave("k5.5.png", width = 6, height = 4)

visMembership(G, Param4)
ggsave("Membershipk4.png", width = 6, height = 4)
visMembership(G, Param5)
ggsave("Membershipk5.png", width = 6, height = 4)


getSignatureValue(Param4, 1) %>% fwrite("Param4.sig1.csv")
getSignatureValue(Param4, 2) %>% fwrite("Param4.sig2.csv")
getSignatureValue(Param4, 3) %>% fwrite("Param4.sig3.csv")
getSignatureValue(Param4, 4) %>% fwrite("Param4.sig4.csv")

getSignatureValue(Param5, 1) %>% fwrite("Param5.sig1.csv")
getSignatureValue(Param5, 2) %>% fwrite("Param5.sig2.csv")
getSignatureValue(Param5, 3) %>% fwrite("Param5.sig3.csv")
getSignatureValue(Param5, 4) %>% fwrite("Param5.sig4.csv")
getSignatureValue(Param5, 5) %>% fwrite("Param5.sig5.csv")

getMembershipValue(Param4) %>% fwrite("MembershipValuek4.csv", row.names = T)
getMembershipValue(Param5) %>% fwrite("MembershipValuek5.csv", row.names = T)

# check correlation of different individuals
getMembershipValue(Param4) %>% ggplot(aes(x = signature_1, y = signature_2)) +
    geom_point()
