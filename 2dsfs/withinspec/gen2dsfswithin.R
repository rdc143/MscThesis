library(genio)
library(parallel)
suppressWarnings(try(source("https://raw.githubusercontent.com/ANGSD/angsd/master/R/fstFrom2dSFS.R"), silent = TRUE))

plink <- read_plink("/home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout")

fam <- as.data.frame(plink$fam)
popinfo <- substr(fam$fam, 1, 4)
comnames <- c("Tory" = "Eland", "Tder" = "Giant eland", "Tstr" = "Greater kudu", "Timb" = "Lesser kudu", "Tbux" = "Mountain nyala", "Scaf" = "Nyala", "Tspe" = "Sitatunga", "Kell" = "Waterbuck", "Tscr" = "Bushbuck")
indnames <- paste0(fam$fam, "_", fam$id)
colnames(plink$X) <- indnames
print("plink file loaded")

totsitesn <- 1454587021 # bcftools index /home/rdc143/QCSeq/gt/results/tragmain2/vcf/BosTau9_tragmain2_sites.bcf.gz.csi -n

for (spec in unique(popinfo)) {
    keepind <- popinfo == spec
    if (sum(keepind) < 2) {
        break
    }
    inds <- indnames[keepind]
    X <- as.matrix(plink$X)[, keepind]

    #remove invariable sites to speed up
    invar <- rowSums(X, na.rm = TRUE) == 0
    X <- X[!invar, ]

    combs <- t(combn(inds, 2))

    getSFS <- function(index, geno) {
        sfs <- table(X[, combs[index, 1]], X[, combs[index, 2]])
        sfs[1, 1] <- totsitesn - sum(sfs[2:3, 2:3])
        fst <- getFst(sfs)
        dxy <- (2 * (sfs[2, 2] + sfs[2, 3] + sfs[3, 2] + sfs[1, 2] + sfs[2, 1]) + 4 * (sfs[1, 3] + sfs[3, 1])) / (4 * sum(sfs))
        c(as.vector(sfs), unname(fst), dxy)
    }
    sfslist <- mclapply(1:nrow(combs), getSFS, geno = X, mc.preschedule = FALSE, mc.cores = 64)

    mat <- do.call(rbind, sfslist)
    mat <- cbind(combs, mat)
    colnames(mat) <- c("A", "B", "A0B0", "A1B0", "A2B0", "A0B1", "A1B1", "A2B1", "A0B2", "A1B2", "A2B2", "fstW", "fstU", "dxy")
    write.table(mat, file = paste0("./", spec, ".allsites.2dsfs.tsv"), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
}
