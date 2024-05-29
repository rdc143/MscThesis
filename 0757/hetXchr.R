library(genio)

#plink <- read_plink("BosTau9_tragmain2_Xchr_variable")
#plink <- read_plink("BosTau9_tragmain2_Xchr_gk_newconvert")
plink <- read_plink("BosTau9_tragmain2_variable_noindels_8dp_Xchr_gk")
popinfo <- substr(plink$fam$id, 1, 4)

plink$X <- plink$X[, popinfo == "Tstr"]
plink$fam <- plink$fam[popinfo == "Tstr",] 

### remove sites with more than 20% missing
keep <- rowMeans(is.na(plink$X)) < 0.2
mean(keep)
plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]

### maf filter
maf <- rowMeans(plink$X, na.rm=T) / 2
keep <- 0.95 > maf & maf > 0.05 
mean(keep)
plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]



na_per_ind <- colMeans(is.na(plink$X))
sort(na_per_ind)

het <- colMeans(plink$X == 1, na.rm = TRUE)
names(het) <- plink$fam$id
sort(het)
het["TstrBot_0757"]


png("hist.png")
hist(het, br = 20)
dev.off()

plink$X["TstrBot_0751" == plink$fam$id]
table(plink$X["TstrBot_0751" == plink$fam$id])


png("plot.png")
plot(plink$X["TstrBot_0751" == plink$fam$id])
dev.off()
