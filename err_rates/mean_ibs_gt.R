library(genio)
library(ape)
library(phytools)
library(parallel)
library(Biostrings)
library(SNPRelate)
library(dplyr)
library(ggplot2)

plink <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly")


fam <- as.data.frame(plink$fam)
popinfo <- substr(fam$fam, 1, 4)
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck", "Ctau" = "wildebeest")
popinfo <- unname(comnames[popinfo])


### polarize in relation to waterbuck to get accurate ibs distance to outgroup as proxy for total branch length / mut rate

ref <- readDNAStringSet("/maps/projects/popgen/people/rdc143/genomes/GCF_002263795.3_ARS-UCD2.0_genomic.fna")
getrefchrname <- function(index) {
       strsplit(names(ref)[index], " ")[[1]][1]
}

refchrnames <- unlist(lapply(1:length(ref), getrefchrname)) # nolint: seq_linter.


### flip sites where both outgroups are alt remove ones, where only one is different
sameasref <- function(index) {
       chr <- unlist(plink$bim[index, 1])
       pos <- unlist(plink$bim[index, 4])
       toString(subseq(ref[refchrnames == chr], start = pos, end = pos)) == plink$bim[index, 6]
}


same <- unlist(mclapply(1:nrow(plink$X), sameasref, mc.cores = 180)) # nolint: seq_linter.
table(same)
mean(same)

same_out <- (plink$X[, "0932"] == 0) & (plink$X[, "0934"] == 0) & (plink$X[, "0937"] == 0)
same_out[is.na(same_out)] <- FALSE
table(same_out)
mean(same_out)

flip <- !same & !same_out
table(flip)
mean(flip)

keep <- (same & same_out) | flip
table(keep)
mean(keep)

plink$X[flip, ] <- 2 - plink$X[flip, ]
plink$X <- plink$X[keep, ]
plink$bim <- plink$bim[keep, ]


### save polarized plink
# write_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly_polarized", plink$X, plink$bim, plink$fam)
# plink <- read_plink("./BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_polarized")


### boxplot for individual IBS values

ibs <- colMeans(plink$X, na.rm = T)
# ibs <- colMeans(plink$X > 0, na.rm = T) # count hets as homo for the the alt
# ibs <- colMeans(plink$X[as.vector(rowSums(is.na(plink$X)) == 0)]) # remove all sites with missing

df <- data.frame(cbind(ibs = as.numeric(ibs), popinfo, loc = substr(fam$fam, 5, 7), id = fam$id))

pdf("ibs_boxplot_within.pdf")
df %>%
       filter(popinfo != "waterbuck" & popinfo != "wildebeest" ) %>%
       ggplot(aes(x = loc, y = as.numeric(ibs))) +
       geom_boxplot() +
       facet_wrap(~popinfo, scale = "free_x")
dev.off()


# agg <- aggregate(colSums(plink$X) / nrow(plink$X), by = list(popinfo = popinfo), FUN = mean)
# meanibs <- agg$x
# names(meanibs) <- agg$popinfo


# pdf("mean_ibs_gt.pdf", width = 14)
# barplot(meanibs, col = c("#FFFF7C", "#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC", "#383838")) # , ylim=c(0.25,0.35))
# legend("topleft",
#        legend = c("Bushbuck", "Eland", "Giant Eland", "Greater kudu", "Lesser kudu", "Mountain nyala", "Nyala", "Sitatunga", "Waterbuck"),
#        fill = c("#FFFF7C", "#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC", "#383838")
# )

# dev.off()


# tree <- read.tree("input.tre")

# pdf("tree_ibs.pdf")
# plotTree.barplot(tree, meanibs)
# dev.off()


# bodysizes <- c(65, 550, 600, 230, 100, 240, 110, 100) #very rough estimates from a quick googling
# pdf("bodysize.pdf")
# plot(bodysizes, meanibs[1:8], col=c("#FFFF7C", "#F8766D","#CD9600","#7CAE00", "#00BE67","#00BFC4","#C77CFF","#FF61CC", "#383838"))
# legend("topright",legend=c("Bushbuck", "Eland", "Giant Eland","Greater kudu", "Lesser kudu","Mountain nyala","Nyala", "Sitatunga", "Waterbuck"),
#        fill = c("#FFFF7C", "#F8766D","#CD9600","#7CAE00", "#00BE67","#00BFC4","#C77CFF","#FF61CC", "#383838"))

# dev.off()

# gentime <- c(5.1, 7.8, 8.0, 6.2, 4.3, 7.0, 5.5, 4.6) # rough estimates from IUCN
# pdf("gentime.pdf")
# plot(gentime, meanibs[1:8], col = c("#FFFF7C", "#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC"))
# legend("topright",
#        legend = c("Bushbuck", "Eland", "Giant Eland", "Greater kudu", "Lesser kudu", "Mountain nyala", "Nyala", "Sitatunga"),
#        fill = c("#FFFF7C", "#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC")
# )

# dev.off()

# check how alt alleles are coded, whether they are alt to ref or minor
# sum(rowMeans(plink$X) > 1)


# pdf("ibs_boxplot_within_free.pdf")
# df %>%
# filter(popinfo != "waterbuck") %>%
# ggplot(aes(x=loc, y=as.numeric(ibs))) +
# geom_boxplot() +
# facet_wrap(~popinfo, scale="free")
# dev.off()
