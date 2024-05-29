library(genio)

# plink <- read_plink("BosTau9_tragmain2_sites_variable_noindels_renamed_ToryTstr_maf35")
plink <- read_plink("BosTau9_tragmain2_sites_variable_noindels_ToryTstr_newconvert_maf35")

popinfo <- substr(plink$fam$id, 1, 4)

### remove sites with more than 20% missing
keep <- rowMeans(is.na(plink$X)) < 0.2
mean(keep)

plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]


### remove sites not fixed in opposite directions between species
Tstr0 <- (rowMeans(plink$X[, popinfo == "Tstr"], na.rm = TRUE) / 2 ) < 0.05
Tstr1 <- (rowMeans(plink$X[, popinfo == "Tstr"], na.rm = TRUE) / 2 ) > 0.95

Tory0 <- (rowMeans(plink$X[, popinfo == "Tory"], na.rm = TRUE) / 2 ) < 0.05
Tory1 <- (rowMeans(plink$X[, popinfo == "Tory"], na.rm = TRUE) / 2 ) > 0.95

keep <- (Tstr0 & Tory1) | (Tstr1 & Tory0)

#flip sites so that eland(Tory) is ref or 0 (Prob not really neccessary, seems pretty polarized to this already)
plink$X[Tory1, ] <- 2 - plink$X[Tory1, ]

plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]

# no of sites left in hybrid that correspond to either species
table(plink$X[, plink$fam$id == "TstrBot_0757"])

bitmap("interanc_het.png", res=250)
plot(plink$bim$pos / 1e6, as.integer(as.factor(plink$bim$chr)), col = plink$X[, plink$fam$id == "TstrBot_0757"], pch = "|", xlab = "position in mb", ylab = "chr", main="Interancestrally heterozygous sites for 0757")
dev.off()

snippet <- plink$X[2e6:(2e6 + 1000), plink$fam$id == "TstrBot_0757"]
snippet
