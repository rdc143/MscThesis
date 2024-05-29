source("https://raw.githubusercontent.com/GenisGE/evalAdmix/master/visFuns.R")
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")

args <- commandArgs(trailingOnly = TRUE)

spec <- substr(as.vector(read.table(args[1])$V1), 1, 4)[1]
pop <- substr(as.vector(read.table(args[1])$V1), 5, 7) # N length character vector with each individual population assignment
q <- as.matrix(read.table(args[2])) # admixture porpotions q is optional for visualization but if used for ordering plot might look better
nproj <- as.numeric(args[3])
k <- dim(q)[2]

ord <- orderInds(pop=pop, q=q) # ord is optional but this make it easy that admixture and correlation of residuals plots will have individuals in same order

proj <- ord > length(ord)-nproj
proj_indices <- as.vector(which(proj))

pdf(args[4], width=16, height=7)
plotAdmix(q=q, pop=pop, ord=ord, inds=as.vector(read.table(args[1], colClasses=c(rep("factor", 2)))$V2), rotatelab=-15, main=paste("Admixture proportions assuming K =",k, ", for", comnames[spec]))
text(proj_indices - .5, rep(.1, nproj), "*", cex = 3)
dev.off()
