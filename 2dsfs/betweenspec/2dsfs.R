library(genio)
library(RColorBrewer)
library(ggplot2)
source("https://raw.githubusercontent.com/ANGSD/angsd/master/R/plot2dSFS.R")
source("https://raw.githubusercontent.com/ANGSD/angsd/master/R/fstFrom2dSFS.R")

#df <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_trag2hd_sites_variable_noindels")
df <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing")

fam <- as.data.frame(df$fam)
popinfo <- substr(fam$fam, 1, 4)
comnames <- c("Tory" = "Eland", "Tder" = "Giant eland", "Tstr" = "Greater kudu", "Timb" = "Lesser kudu", "Tbux" = "Mountain nyala", "Scaf" = "Nyala", "Tspe" = "Sitatunga", "Kell" = "Waterbuck", "Tscr" = "Bushbuck")
popinfo <- unname(comnames[popinfo])

X <- as.matrix(df$X)
missing <- apply(is.na(X), 2, mean)
missing

# ### remove sites polymorphic in more than two species, handled in separate script for main set
# apop <- sapply(seq(1,13,by=2),function(i) rowSums(X[,i:(i+1)]))
# npoly <- 7 - rowSums(apop == 0 | apop == 4)
# npolytab <- table(npoly)
# png("npoly.png")
# barplot(npolytab[3:8])
# dev.off()
# keep <- npoly < 3
# X <- X[keep,]


### remove missing
#mean(complete.cases(X))
#X <- X[complete.cases(X), ]
#dim(X)


#subsample
#X <- X[seq(1, nrow(X), 100), ]

###SFS
pal <- color.palette(c("darkgreen","#00A600FF","yellow","#E9BD3AFF","orange","red4","darkred","black"), space="rgb")

pops <- unique(popinfo)
pops <- pops[pops != "Waterbuck" & pops != "Bushbuck"]

combs <- combn(length(pops), 2)

fst <- expand.grid(pops, pops)
fst$fstW <- NA
fst$fstU <- NA

pdf("tragmain_new_2dsfs.pdf")

for (i in 1:ncol(combs)){
    pop1 <- pops[combs[1, i]]
    pop2 <- pops[combs[2, i]]
    ind1 <- which(popinfo == pop1)
    ind2 <- which(popinfo == pop2)

    tab <- table(rowSums(X[, ind1]), rowSums(X[, ind2]))
    tab[1, 1] <- NA
    tab[dim(tab)[1], dim(tab)[2]] <- NA

    tab <- tab / sum(tab, na.rm=T)
    print(pplot(tab, xlab = pop1, ylab = pop2, pal = pal))

    fst[(fst$Var1 == pop1 & fst$Var2 == pop2), 3 ] <- signif(getFst(tab)[1], 4)
    fst[(fst$Var1 == pop1 & fst$Var2 == pop2), 4 ] <- signif(getFst(tab)[2], 4)
    #rownames(tab) <- paste0("d", as.character(combs[1, i] - 1), "_", as.character(1:dim(tab)[1] - 1))
    #colnames(tab) <- paste0("d", as.character(combs[2, i] - 1), "_", as.character(1:dim(tab)[2] - 1))

    #file <- file(paste0("./2d/giraffe_4pops_jointDAFpop", combs[1, i]-1,"_", combs[2, i]-1,".obs"), open = "wt")
    #writeLines("1 observations", file)
    #write.table(tab, sep="\t", file)
    #close(file)
}
dev.off()


png("tragmain_new_fst.png")
ggplot(fst, aes(Var1, Var2, fill= fstW)) + 
  scale_fill_gradient2() +
  geom_tile() +
  geom_text(aes(label = fstW), color = "white", size = 4)
dev.off()