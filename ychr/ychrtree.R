library(ape)

m <- as.matrix(read.table("ychr.dist", header = F))

# names <- read.table("trag2hd_snps_varonly.dist.id", sep=",")
names <- read.table("ychr.dist.id", sep = ",")
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
out <- c("TstrBot_0757")
pdf("ychrtree.pdf")
plot.phylo(root(nj(m), outgroup = out), tip.color = colors[spec], cex = 2)
# ape::add.scale.bar()
legend("bottomright",
       legend = c("Eland", "Giant Eland", "Greater kudu", "Lesser kudu", "Mountain nyala", "Nyala", "Sitatunga", "Bushbuck", "Waterbuck"),
       fill = c("#F8766D", "#CD9600", "#7CAE00", "#00BE67", "#00BFC4", "#C77CFF", "#FF61CC", "#FFFF7C", "#383838")
)
dev.off()
