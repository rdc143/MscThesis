library(genio)
library(parallel)

plink <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp")

### fixing incorrect species assignments
plink$fam$fam[plink$fam$id == "0843"] <- "KellZam"
plink$fam$fam[plink$fam$id == "0854"] <- "TimbTan"
plink$fam$fam[plink$fam$id == "0852"] <- "TimbTan"
plink$fam$fam[plink$fam$id == "0853"] <- "TimbTan"
plink$fam$fam[plink$fam$id == "0818"] <- "TstrTan"
plink$fam$fam[plink$fam$id == "0619"] <- "TstrZam"
plink$fam$fam[plink$fam$id == "0887"] <- "TscrGha"

popinfo <- substr(plink$fam$fam, 1, 4)

missing <- colMeans(is.na(plink$X))
sort(missing)

overfive <- 0.05 < rowMeans(is.na(plink$X))
mean(overfive)

complete <- !overfive
# complete <- as.vector(rowSums(is.na(plink$X)) == 0) #object too large for complete.cases
# mean(complete)

plink$X <- plink$X[complete, ]
plink$bim <- plink$bim[complete, ]

getpolycount <- function(index) {
    row <- plink$X[index, ]
    ma <- aggregate(row, by = list(popinfo = popinfo), FUN = mean, na.action = na.omit)$x
    ma[is.na(ma)] <- 0.0
    npoly <- sum(ma > 0 & ma < 2)
    npoly < 4
}



keep <- unlist(mclapply(1:nrow(plink$X), getpolycount, mc.cores = 100)) # nolint: seq_linter.

mean(keep)

plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]

write_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly", plink$X, plink$bim, plink$fam)
