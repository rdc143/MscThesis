tab <- read.table("LRTmat.txt", header=F)
names <- read.table("../../sitesfilter_lists/Tstr.txt")$V1

names <- tools::file_path_sans_ext(tools::file_path_sans_ext(basename(names)))
hetplas <- tab > 24
rowsum <- rowSums(hetplas)
shared <- rowsum > 1

# shared2 <- shared
# padding <- 200
# maxinbin <- 5

# for (i in (1 + padding):(length(shared) - padding)) {
#   binnedsum <- sum(rowsum[(i - padding):(i + padding)])
#   if (binnedsum > maxinbin) {
#     # if (!shared2[i]) {print("hit")}
#     shared2[i] <- TRUE
#   }
# }

mean(shared)
# mean(shared2)
hetplas[shared, ] <- FALSE

pdf("bypos.pdf", height = 3)

for (name in names){
hist(which(hetplas[, names == name]), breaks=50, main=name, ylim=c(0,12))
}
dev.off()

het <-colSums(hetplas)
names(het) <- names
pdf("hetplas.pdf", height = 3)
barplot(sort(het), col=(names[order(het)] == 'TstrBot_0757'), xaxt='n')
dev.off()

