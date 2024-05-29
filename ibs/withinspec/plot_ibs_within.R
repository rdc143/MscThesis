library(ape)
args = commandArgs(trailingOnly=TRUE)

comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")

m <- as.matrix(read.table(args[1], header = F))

names <- read.table(paste0(args[1], ".id"), sep = ",")
names <- gsub("\t", "_", names$V1)

rownames(m) <- substring(names, 5, 12)
colnames(m) <- substring(names, 5, 12)
loc <- substring(names, 5, 7)

colors <- rainbow(18)
names(colors) <- c(
        "Aby", "Bot", "Cam", "Cha", "Con", "DRC", "Eth", "Gha", "Ken",
        "NA-", "Nam", "RSA", "Som", "SSu", "Tan", "Uga", "Zam", "Zim"
)


# neighbour joining
pdf(paste0(args[2], "_IBS.pdf"))
plot.phylo(nj(m), tip.color = colors[loc], cex = 0.5, type = "unrooted", align.tip.label = TRUE, main = comnames[args[2]])
ape::add.scale.bar()
legend("bottomright",
       legend = names(colors)[names(colors) %in% loc],
       fill = colors[names(colors) %in% loc]
)
dev.off()
