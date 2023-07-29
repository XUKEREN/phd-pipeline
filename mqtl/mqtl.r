# Matrix eQTL by Andrey A. Shabalin
# http://www.bios.unc.edu/research/genomic_software/Matrix_eQTL/
#
# Be sure to use an up to date version of R and Matrix eQTL.

# source("Matrix_eQTL_R/Matrix_eQTL_engine.r");
library(MatrixEQTL)

## Location of the package with the data files.
# base.dir = find.package('MatrixEQTL');
base.dir <- "/dir/"
## Settings

# Linear model to use, modelANOVA, modelLINEAR, or modelLINEAR_CROSS
useModel <- modelLINEAR
# modelANOVA, modelLINEAR, or modelLINEAR_CROSS

# Genotype file name
SNP_file_name <- paste(base.dir, "/data/meta234/set4/SNP.txt", sep = "")
# Gene expression file name
expression_file_name <- paste(base.dir, "/data/meta234/set4/GE.txt", sep = "")
# Covariates file name
# Set to character() for no covariates
covariates_file_name <- paste(base.dir, "/data/meta234/set4/Covariates.txt", sep = "")
# Output file name
output_file_name <- tempfile()
# Only associations significant at this level will be saved
# pvOutputThreshold = 1e-2;
pvOutputThreshold <- 1
# Error covariance matrix
# Set to numeric() for identity.
errorCovariance <- numeric()
# errorCovariance = read.table("Sample_Data/errorCovariance.txt");


## Load genotype data
snps <- SlicedData$new()
snps$fileDelimiter <- ","
# the period character
snps$fileOmitCharacters <- "NA"
# denote missing values;
snps$fileSkipRows <- 1
# one row of column labels
snps$fileSkipColumns <- 1
# one column of row labels
snps$fileSliceSize <- 2000
# read file in slices of 2,000 rows
snps$LoadFile(SNP_file_name)
## Load gene expression data

gene <- SlicedData$new()
gene$fileDelimiter <- ","
# the TAB character
gene$fileOmitCharacters <- "NA"
# denote missing values;
gene$fileSkipRows <- 1
# one row of column labels
gene$fileSkipColumns <- 1
# one column of row labels
gene$fileSliceSize <- 2000
# read file in slices of 2,000 rows
gene$LoadFile(expression_file_name)
## Load covariates

cvrt <- SlicedData$new()
cvrt$fileDelimiter <- ","
# the TAB character
cvrt$fileOmitCharacters <- "NA"
# denote missing values;
cvrt$fileSkipRows <- 1
# one row of column labels
cvrt$fileSkipColumns <- 1
# one column of row labels
if (length(covariates_file_name) > 0) {
    cvrt$LoadFile(covariates_file_name)
}

## Run the analysis

me <- Matrix_eQTL_engine(
    snps = snps,
    gene = gene,
    cvrt = cvrt,
    output_file_name = output_file_name,
    pvOutputThreshold = pvOutputThreshold,
    useModel = useModel,
    errorCovariance = errorCovariance,
    verbose = TRUE,
    pvalue.hist = T,
    min.pv.by.genesnp = FALSE,
    noFDRsaveMemory = FALSE
)
me2 <- Matrix_eQTL_engine(
    snps = snps,
    gene = gene,
    cvrt = cvrt,
    output_file_name = output_file_name,
    pvOutputThreshold = pvOutputThreshold,
    useModel = useModel,
    errorCovariance = errorCovariance,
    verbose = TRUE,
    pvalue.hist = "qqplot",
    min.pv.by.genesnp = FALSE,
    noFDRsaveMemory = FALSE
)
unlink(output_file_name)

## Results:
cat("Analysis done in: ", me$time.in.sec, " seconds", "\n")
cat("Detected eQTLs:", "\n")
show(me$all$eqtls)

library(tidyverse)
me$all$eqtls %>%
    mutate(se = beta / statistic) %>%
    data.table::fwrite("mqtl_set4_dmp234.txt")
## Plot the histogram of all p-values
plot(me)
plot(me2)
