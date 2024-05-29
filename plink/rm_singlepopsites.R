library(genio)
library(parallel)

plink <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly")

popinfo <- substr(plink$fam$fam, 1, 4)


getpolycount <- function(index) {
    row <- plink$X[index, ]
    ma <- aggregate(row, by = list(popinfo = popinfo), FUN = mean, na.action = na.omit)$x
    ma[is.na(ma)] <- 0.0
    npoly <- sum(ma > 0)
    npoly > 1
}



keep <- unlist(mclapply(1:nrow(plink$X), getpolycount, mc.cores = 124)) # nolint: seq_linter.

mean(keep)

plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]

write_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly_nosinglepopsites", plink$X, plink$bim, plink$fam)
