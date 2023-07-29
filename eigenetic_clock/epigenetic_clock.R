###########################################################################
###########################################################################

# inpput file "set3_clock" should look like below:
#   probeId 202060330090_R05C01 202148010001_R08C01 202060330090_R01C01
# 1: cg00153101          0.20513759          0.40421196          0.16065096
# 2: cg15131146          0.22202850          0.37176636          0.26833367
# 3: cg20301308          0.04999526          0.16043421          0.08245288
# 4: cg03098721          0.43072035          0.42440584          0.50880815
# 5: cg01281797          0.07615286          0.06605341          0.14501264
# 6: cg13066703          0.11743093          0.33473348          0.06614739

# calculate methylation clock skin blood
# R functions for transforming age
adult.age1 <- 20
trafo <- function(x, adult.age = adult.age1) {
  x <- (x + 1) / (1 + adult.age)
  y <- ifelse(x <= 1, log(x), x - 1)
  y
}
anti.trafo <- function(x, adult.age = adult.age1) {
  ifelse(x < 0, (1 + adult.age) * exp(x) - 1, (1 + adult.age) * x + adult.age)
}
datClock <- read.csv("clock/aging-10-101508-s005.csv")

dat0 <- set3_clock

# sort dat0 to have the same order with datClock
dat0 <- data.frame(probeId = datClock[-1, 1]) %>% left_join(dat0, by = "probeId")

# check order
selectCpGsClock <- is.element(dat0[, 1], as.character(datClock[-1, 1]))

datMethClock0 <- data.frame(t(dat0[selectCpGsClock, -1]))

colnames(datMethClock0) <- as.character(dat0[selectCpGsClock, 1])
# Reality check: the following output should only contain numeric values.
# Further, the column names should be CpG identifiers (cg numbers).
datMethClock0[1:5, 1:5]
datMethClock <- data.frame(datMethClock0[as.character(datClock[-1, 1])])

# The number of rows should equal the number of samples (Illumina arrays)
dim(datMethClock)
# Output DNAm age estimator for the skin & blood clock
DNAmAgeSkinClock <- as.numeric(anti.trafo(datClock$Coef[1] + as.matrix(datMethClock) %*% as.numeric(datClock$Coef[-1])))

x <- datClock$Coef[1] + as.matrix(datMethClock) %*% as.numeric(datClock$Coef[-1])

df_DNAmAgeSkinClock <- data.frame(beadPosition = rownames(x), DNAmAgeSkinClock)

###########################################################################
###########################################################################

# DNAmTL
dat1 <- set3_clock_DNAmTL

datClock <- fread("DNAmTL/DNAmTL_cpgs.csv")

# sort dat1 to have the same order with datClock
dat1 <- data.frame(probeId = datClock[-1, 1] %>% pull(Variable)) %>% left_join(dat1, by = "probeId")

# check order
selectCpGsClock <- is.element(dat1[, 1], datClock[-1, 1] %>% pull(Variable))

datMethClock0 <- data.frame(t(dat1[selectCpGsClock, -1]))

colnames(datMethClock0) <- as.character(dat1[selectCpGsClock, 1])

# Reality check: the following output should only contain numeric values.
# Further, the column names should be CpG identifiers (cg numbers).
datMethClock0[1:5, 1:5]
datMethClock <- data.frame(datMethClock0[datClock[-1, 1] %>% pull(Variable)])

# The number of rows should equal the number of samples (Illumina arrays)
dim(datMethClock)

# Output DNAmTL
DNAmTL <- datClock$Coefficient[1] + as.matrix(datMethClock) %*% as.numeric(datClock$Coefficient[-1])

df_DNAmTL <- data.frame(beadPosition = rownames(x), DNAmTL)

###########################################################################
###########################################################################

# DNAmAge - pantissue clock

dat1 <- set3_clock_DNAmAge

dim(dat1) # 334 probes out of 353 probes that are needed for DNAmAge

# add those missing CpGs and gave them values NA
datClock <- fread("DNAmAge/13059_2013_3156_MOESM23_ESM.csv")

datClock_all_probe <- data.frame(probeId = datClock %>% pull(CpGmarker) %>% .[-1])

dat1 <- datClock_all_probe %>% left_join(dat1, by = "probeId")


# STEP 1: DEFINE QUALITY METRICS

meanMethBySample <- as.numeric(apply(as.matrix(dat1[, -1]), 2, mean, na.rm = F))
minMethBySample <- as.numeric(apply(as.matrix(dat1[, -1]), 2, min, na.rm = F))
maxMethBySample <- as.numeric(apply(as.matrix(dat1[, -1]), 2, max, na.rm = F))

datMethUsed <- t(dat1[, -1])

colnames(datMethUsed) <- dat1 %>% pull(probeId)

noMissingPerSample <- apply(as.matrix(is.na(datMethUsed)), 1, sum)

table(noMissingPerSample)

# STEP 2: Imputing
library(impute)
fastImputation <- FALSE
nSamples <- 914
if (!fastImputation & nSamples > 1 & max(noMissingPerSample, na.rm = TRUE) < 3000) {
  # run the following code if there is at least one missing
  if (max(noMissingPerSample, na.rm = TRUE) > 0) {
    dimnames1 <- dimnames(datMethUsed)
    datMethUsed <- data.frame(t(impute.knn(t(datMethUsed))$data))
    dimnames(datMethUsed) <- dimnames1
  } # end of if
} # end of if (! fastImputation )

if (max(noMissingPerSample, na.rm = TRUE) >= 3000) fastImputation <- TRUE

if (fastImputation | nSamples == 1) {
  noMissingPerSample <- apply(as.matrix(is.na(datMethUsed)), 1, sum)
  table(noMissingPerSample)
  if (max(noMissingPerSample, na.rm = TRUE) > 0 & max(noMissingPerSample, na.rm = TRUE) >= 3000) {
    normalizeData <- FALSE
  }

  # run the following code if there is at least one missing
  if (max(noMissingPerSample, na.rm = TRUE) > 0 & max(noMissingPerSample, na.rm = TRUE) < 3000) {
    dimnames1 <- dimnames(datMethUsed)
    for (i in which(noMissingPerSample > 0)) {
      selectMissing1 <- is.na(datMethUsed[i, ])
      datMethUsed[i, selectMissing1] <- as.numeric(probeAnnotation21kdatMethUsed$goldstandard2[selectMissing1])
    } # end of for loop
    dimnames(datMethUsed) <- dimnames1
  } # end of if
} # end of if (! fastImputation )

datMethUsed %>% dim()

# convert datMethUsed to dat1
dat1_remake <- t(datMethUsed)
colnames(dat1_remake) <- rownames(datMethUsed)
dat1_remake_probeId <- rownames(dat1_remake)
dat1_remake <- dat1_remake %>% data.table()
dat1_remake$probeId <- dat1_remake_probeId
dat1 <- dat1_remake %>% relocate(probeId)

# STEP 3: Data normalization (each sample requires about 8 seconds). It would be straightforward to parallelize this operation. ---- SKIP

# STEP 4: Predict age and create a data frame for the output (referred to as datout)

datClock <- fread("DNAmAge/13059_2013_3156_MOESM23_ESM.csv")

# sort dat1 to have the same order with datClock
dat1 <- data.frame(probeId = datClock[-1, 1] %>% pull(CpGmarker)) %>% left_join(dat1, by = "probeId")

# check order
selectCpGsClock <- is.element(dat1[, 1], datClock[-1, 1] %>% pull(CpGmarker))

datMethClock0 <- data.frame(t(dat1[selectCpGsClock, -1]))

colnames(datMethClock0) <- as.character(dat1[selectCpGsClock, 1])

# Reality check: the following output should only contain numeric values.
# Further, the column names should be CpG identifiers (cg numbers).
datMethClock0[1:5, 1:5]
datMethClock <- data.frame(datMethClock0[datClock[-1, 1] %>% pull(CpGmarker)])

# The number of rows should equal the number of samples (Illumina arrays)
dim(datMethClock)

# Output DNAm age estimator for the DNAmAge
adult.age1 <- 20
trafo <- function(x, adult.age = adult.age1) {
  x <- (x + 1) / (1 + adult.age)
  y <- ifelse(x <= 1, log(x), x - 1)
  y
}
anti.trafo <- function(x, adult.age = adult.age1) {
  ifelse(x < 0, (1 + adult.age) * exp(x) - 1, (1 + adult.age) * x + adult.age)
}

DNAmAge <- as.numeric(anti.trafo(datClock$CoefficientTraining[1] + as.matrix(datMethClock) %*% as.numeric(datClock$CoefficientTraining[-1])))

df_DNAmAge <- data.frame(beadPosition = rownames(datMethClock), DNAmAge)

###########################################################################
###########################################################################

# GA Haftorn clock

fread("GA_Haftorn_clock/set3_clock.txt") -> dat0
fread("GA_Haftorn_clock/Haftorn.probes.coef.additional.file6.cleaned.txt") -> datClock

# sort dat0 to have the same order with datClock
dat0 <- data.frame(probeId = datClock[-1, 2] %>% pull()) %>% left_join(dat0, by = "probeId")

# check order
selectCpGsClock <- is.element(dat0[, 1], as.character(datClock[-1, 2] %>% pull()))

datMethClock0 <- data.frame(t(dat0[selectCpGsClock, -1]))

colnames(datMethClock0) <- as.character(dat0[selectCpGsClock, 1])
# Reality check: the following output should only contain numeric values.
# Further, the column names should be CpG identifiers (cg numbers).
datMethClock0[1:5, 1:5]

datMethClock <- data.frame(datMethClock0[as.character(datClock[-1, 2] %>% pull())])

# The number of rows should equal the number of samples (Illumina arrays)
dim(datMethClock)
# Output DNAm age estimator
Haftorn_clock <- as.numeric(datClock$coef[1] + as.matrix(datMethClock) %*% as.numeric(datClock$coef[-1]))

x <- datClock$coef[1] + as.matrix(datMethClock) %*% as.numeric(datClock$coef[-1])

df_Haftorn_clock <- data.frame(beadPosition = rownames(x), Haftorn_clock)


###########################################################################
###########################################################################

# GA Knight clock - 6 missing
fread("/GA_Knight_clock/set3_clock.txt") -> dat1
dim(dat1)

# add those missing CpGs and gave them values NA
datClock <- fread("/GA_Knight_clock/knight_probes.csv")

datClock_all_probe <- data.frame(probeId = datClock %>% pull(CpGmarker) %>% .[-1])

dat1 <- datClock_all_probe %>% left_join(dat1, by = "probeId")


# STEP 1: DEFINE QUALITY METRICS

datMethUsed <- t(dat1[, -1])

colnames(datMethUsed) <- dat1 %>% pull(probeId)

noMissingPerSample <- apply(as.matrix(is.na(datMethUsed)), 1, sum)

table(noMissingPerSample) # 6 missing probes

# STEP 2: Imputing
library(impute)
fastImputation <- FALSE
nSamples <- 914
if (!fastImputation & nSamples > 1 & max(noMissingPerSample, na.rm = TRUE) < 3000) {
  # run the following code if there is at least one missing
  if (max(noMissingPerSample, na.rm = TRUE) > 0) {
    dimnames1 <- dimnames(datMethUsed)
    datMethUsed <- data.frame(t(impute.knn(t(datMethUsed))$data))
    dimnames(datMethUsed) <- dimnames1
  } # end of if
} # end of if (! fastImputation )

if (max(noMissingPerSample, na.rm = TRUE) >= 3000) fastImputation <- TRUE

if (fastImputation | nSamples == 1) {
  noMissingPerSample <- apply(as.matrix(is.na(datMethUsed)), 1, sum)
  table(noMissingPerSample)
  if (max(noMissingPerSample, na.rm = TRUE) > 0 & max(noMissingPerSample, na.rm = TRUE) >= 3000) {
    normalizeData <- FALSE
  }

  # run the following code if there is at least one missing
  if (max(noMissingPerSample, na.rm = TRUE) > 0 & max(noMissingPerSample, na.rm = TRUE) < 3000) {
    dimnames1 <- dimnames(datMethUsed)
    for (i in which(noMissingPerSample > 0)) {
      selectMissing1 <- is.na(datMethUsed[i, ])
      datMethUsed[i, selectMissing1] <- as.numeric(probeAnnotation21kdatMethUsed$goldstandard2[selectMissing1])
    } # end of for loop
    dimnames(datMethUsed) <- dimnames1
  } # end of if
} # end of if (! fastImputation )

datMethUsed %>% dim()

# convert datMethUsed to dat1
dat1_remake <- t(datMethUsed)
colnames(dat1_remake) <- rownames(datMethUsed)
dat1_remake_probeId <- rownames(dat1_remake)
dat1_remake <- dat1_remake %>% data.table()
dat1_remake$probeId <- dat1_remake_probeId
dat1 <- dat1_remake %>% relocate(probeId)

# STEP 3: Data normalization (each sample requires about 8 seconds). It would be straightforward to parallelize this operation. ---- SKIP

# STEP 4: Predict age and create a data frame for the output (referred to as datout)

# sort dat1 to have the same order with datClock
dat1 <- data.frame(probeId = datClock[-1, 1] %>% pull(CpGmarker)) %>% left_join(dat1, by = "probeId")

# check order
selectCpGsClock <- is.element(dat1[, 1], datClock[-1, 1] %>% pull(CpGmarker))

datMethClock0 <- data.frame(t(dat1[selectCpGsClock, -1]))

colnames(datMethClock0) <- as.character(dat1[selectCpGsClock, 1])

# Reality check: the following output should only contain numeric values.
# Further, the column names should be CpG identifiers (cg numbers).
datMethClock0[1:5, 1:5]
datMethClock <- data.frame(datMethClock0[datClock[-1, 1] %>% pull(CpGmarker)])

# The number of rows should equal the number of samples (Illumina arrays)
dim(datMethClock)

# Output DNAm age estimator for the DNAmAge

Knight_clock_week <- as.numeric(datClock$CoefficientTraining[1] + as.matrix(datMethClock) %*% as.numeric(datClock$CoefficientTraining[-1]))

Knight_clock <- 7 * Knight_clock_week

x <- as.matrix(datMethClock) %*% as.numeric(datClock$CoefficientTraining[-1])

df_Knight_clock <- data.frame(beadPosition = rownames(x), Knight_clock)

###########################################################################
###########################################################################

# GA Bohlin clock - 8 missing imputed
## took a long time to run

library(predictGA)
# read in bohlin clock
# bohlin clock
dat1 <- fread("/GA_Bohlin_clock/set3_clock.txt")
dim(dat1)

# so missing 8 CpGs in 450K

# impute knn
datClock_all_probe <- data.frame(probeId = extractSites(type = "se"))
dat1 <- datClock_all_probe %>% left_join(dat1, by = "probeId")
dim(dat1)

# STEP 1: DEFINE QUALITY METRICS
datMethUsed <- t(dat1[, -1])
colnames(datMethUsed) <- dat1 %>% pull(probeId)
noMissingPerSample <- apply(as.matrix(is.na(datMethUsed)), 1, sum)
table(noMissingPerSample) # 8 missing probes

# STEP 2: Imputing
library(impute)
fastImputation <- FALSE
nSamples <- 914
if (!fastImputation & nSamples > 1 & max(noMissingPerSample, na.rm = TRUE) < 3000) {
  # run the following code if there is at least one missing
  if (max(noMissingPerSample, na.rm = TRUE) > 0) {
    dimnames1 <- dimnames(datMethUsed)
    datMethUsed <- data.frame(t(impute.knn(t(datMethUsed))$data))
    dimnames(datMethUsed) <- dimnames1
  } # end of if
} # end of if (! fastImputation)

# check the imputed results
datMethUsed %>% select(c(
  "cg00602416", "cg01190109", "cg06753281", "cg06897661", "cg09447786",
  "cg13036381", "cg16187883", "cg22797644"
))

# STEP 3: Predict age and create a data frame for the output (referred to as datout)
mypred <- predictGA(datMethUsed, transp = F)

df_Bohlin_clock <- data.frame(beadPosition = rownames(mypred), Bohlin_clock = mypred %>% pull(GA))

df_Bohlin_clock %>% fwrite("/GA_Bohlin_clock/df_Bohlin_clock.txt")
