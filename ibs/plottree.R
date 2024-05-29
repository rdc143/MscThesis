library(ape)

# m <- as.matrix(read.table("trag2hd_snps_varonly.dist", header=F))
m <- as.matrix(read.table("tragmain_sites_variable_noindels_nomultipoly_nomissing.dist", header = F))

# names <- read.table("trag2hd_snps_varonly.dist.id", sep=",")
names <- read.table("tragmain_sites_variable_noindels_nomultipoly_nomissing.dist.id", sep = ",")
names <- gsub("\t", "_", names$V1)
names
rownames(m) <- names
colnames(m) <- names
spec <- substring(colnames(m), 1, 4)
spec
colors <- c(
       "Tory" = "#F8766D", "Tder" = "#CD9600",
       "Tstr" = "#7CAE00", "Timb" = "#00BE67",
       "Tbux" = "#00BFC4", "Scaf" = "#C77CFF", "Tspe" = "#FF61CC",
       "Tscr" = "#FFFF7C", "Kell" = "#383838"
)

# neighbour joining
out <- c("KellZam_0843")
pdf("ibstree_fixedinds.pdf")
plot.phylo(root(nj(m), outgroup = out), tip.color = colors[spec], cex = 0.2)
# ape::add.scale.bar()
legend("bottomright",
       legend = c("Eland", "Giant Eland", "Greater kudu", "Lesser kudu", "Mountain nyala", "Nyala", "Sitatunga", "Bushbuck", "Waterbuck"),
       fill = c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC", "#FFFF7C", "#383838")
)
dev.off()


### use this to check 0757 for hybridization
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")

ind0757 <- m["TstrBot_0757", ]
ind0763 <- m["TstrKen_0763", ]

gk <- m[comnames[spec] == "greater_kudu", ]
gk <- gk[rownames(gk) != "TstrBot_0757" & rownames(gk) != "TstrKen_0763", ]

avg_gk <- colMeans(gk)

pdf("0757_ibs.pdf", width = 14)
boxplot((ind0757 / avg_gk) ~ comnames[spec], xlab="Species", ylab = "Ratio of distances")
abline(h = 1)
abline(h = 0.75)
dev.off()

mean((ind0757 / avg_gk)[comnames[spec] == "eland"])

head(sort(ind0757))
tail(sort(ind0757[spec == "Tstr"]))


pdf("0763_ibs.pdf", width = 14)
boxplot((ind0763 / avg_gk) ~ comnames[spec])
dev.off()
