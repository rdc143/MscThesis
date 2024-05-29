library(ggplot2)
library(tidyr)
library(dplyr)
library(genio)
source("https://raw.githubusercontent.com/ANGSD/angsd/master/R/plot2dSFS.R")

P <- read.table("./testmaf.2.P")
colnames(P) <- c("eland", "greater_kudu")

# df <- data.frame(P)
# pdf("pjointdist.pdf")
# df %>%
#     ggplot(aes(eland, greater_kudu)) +
#     geom_point()
# dev.off()


df <- data.frame(P)[1:1e6, ] %>% pivot_longer(cols = c("eland", "greater_kudu"))

pdf("pdist.pdf")
df %>%
    ggplot(aes(value, fill = name)) +
    geom_histogram(alpha=.5, bins=100)
dev.off()

folded <- df
flip <- folded$value > 0.5
folded[flip, 2] <- 1 - folded[flip, 2]
folded$value <- signif(folded$value, 4)

pdf("pdist_folded.pdf")
folded %>%
    ggplot(aes(value, fill = name)) +
    geom_histogram(alpha=.5, bins=100)
dev.off()


### 2dsfs

# plink <- read_plink("../gk_eland/BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_gk_eland")
plink <- read_plink("./testmaf")

popinfo <- substr(plink$fam$fam, 1, 4)
comnames <- c("Tory" = "Eland", "Tder" = "Giant eland", "Tstr" = "Greater kudu", "Timb" = "Lesser kudu", "Tbux" = "Mountain nyala", "Scaf" = "Nyala", "Tspe" = "Sitatunga", "Kell" = "Waterbuck", "Tscr" = "Bushbuck")
popinfo <- unname(comnames[popinfo])

X <- as.matrix(plink$X)

pal <- color.palette(c("darkgreen", "#00A600FF", "yellow", "#E9BD3AFF", "orange", "red4", "darkred", "black"), space = "rgb")

pops <- unique(popinfo)

pdf("gk_eland_2dsfs_aftermaf.pdf")
ind1 <- which(popinfo == "Eland")
ind2 <- which(popinfo == "Greater kudu")

tab <- table(rowSums(X[, ind1]), rowSums(X[, ind2]))
tab[1, 1] <- NA
tab[dim(tab)[1], dim(tab)[2]] <- NA
tab <- tab / sum(tab, na.rm = T)
print(pplot(tab, xlab = "Eland", ylab = "Greater kudu", pal = pal))
dev.off()


pdf("test.pdf")
hist(P$eland[1:1e6], breaks=1000)
dev.off()