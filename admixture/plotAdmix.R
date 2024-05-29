source("https://raw.githubusercontent.com/GenisGE/evalAdmix/master/visFuns.R")

args <- commandArgs(trailingOnly = TRUE)

pop <- as.vector(read.table(args[1])$V1) # N length character vector with each individual population assignment
q <- as.matrix(read.table(args[2])) # admixture porpotions q is optional for visualization but if used for ordering plot might look better
r <- as.matrix(read.table(args[3]))

ord <- orderInds(pop=pop, q=q) # ord is optional but this make it easy that admixture and correlation of residuals plots will have individuals in same order

pdf(args[4], width=16, height=6)
plotAdmix(q=q, pop=pop, ord=ord, inds=as.vector(read.table(args[1], colClasses=c(rep("factor",6)))$V2))
plotCorRes(cor_mat = r, pop = pop, ord=ord, title = "Admixture evaluation as correlation of residuals", max_z=0.25, min_z=-0.25)
dev.off()
