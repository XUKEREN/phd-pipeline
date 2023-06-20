library(data.table)
library(tidyverse)
library(tableone)
covariates <- fread("/dir/covariates.txt") %>% mutate(Ethnicity = ifelse(Ethnicity == "", NA, Ethnicity))

# variables that I would like to summarize
myVars <- c("gestage", "ch_ageref", "sex", "Ethnicity", "CaCo", "set")

## Vector of categorical variables that need transformation
catVars <- c("sex", "Ethnicity", "CaCo", "set")

## Create a TableOne object
tab2 <- CreateTableOne(vars = myVars, strata = "CaCo", data = covariates, factorVars = catVars)
tab2Mat <- print(tab2, quote = FALSE, noSpaces = TRUE, printToggle = FALSE, showAllLevels = TRUE, test = TRUE)

## Save to a CSV file
write.csv(tab2Mat, "tableone_stratified.csv")
