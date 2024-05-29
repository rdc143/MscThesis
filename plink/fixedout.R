library(genio)

comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck", "Ctau" = "wildebeest")
colors <- c("Tory" = "#F8766D", "Tder" = "#CD9600",
"Tstr" = "#7CAE00", "Timb" = "#00BE67",
"Tbux" = "#00BFC4", "Scaf" = "#C77CFF", "Tspe" = "#FF61CC",
"Tscr" = "#FFFF7C", "Kell" = "#383838")


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


missing_per_ind_before <- colMeans(is.na(plink$X))
sort(missing_per_ind_before)

### remove sites not fixed in outgroup
outcount <- rowSums(plink$X[, c("0932", "0934", "0937")])
mean(is.na(outcount)) #8dp: 0.2583919

outcount[is.na(outcount)] <- -1
keep <- outcount == 0 | outcount == 6
mean(keep) #12dp: 0.3264803, 8dp: 0.5453126

#check how many removed sites are polymorphic in non outgroup
fixed_nonout <- rowMeans(plink$X[, -which(colnames(plink$X) %in% c("0932", "0934", "0937"))], na.rm=T) %in% c(0, 1, NaN)
mean(!fixed_nonout) # 8dp: 0.5253905
mean(!keep & !fixed_nonout) # 8dp: 0.1462941


plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]


### missingness after removing sites not fixed in outgroup
missing_per_ind <- colMeans(is.na(plink$X))
colvec <- colors[popinfo]
colvec[order(missing_per_ind)]
sort(missing_per_ind)
pdf("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout.missing_per_ind.pdf")
barplot(sort(missing_per_ind), col=colvec[order(missing_per_ind)])
legend("topleft", legend=comnames[names(colors)], col=unname(colors), lty=1, lwd=5)
dev.off()

missing_per_site <- rowMeans(is.na(plink$X))
pdf("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout.missing_per_site.pdf")
hist(missing_per_site, breaks=50)
dev.off()



write_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout", plink$X, plink$bim, plink$fam)
