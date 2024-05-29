library(ggplot2)
library(dplyr)
library(ggrepel)

het <- read.table("/maps/projects/popgen/people/rdc143/QCSeq/std_analyses/psmc/tragmain2/heterozygosity.txt")

het$ID <- substr(het$V1, 9, 12)
het$group <- substr(het$V1, 1, 7)


###reclassify inds
het$group[het$ID == "0843"] <- "KellZam"
het$group[het$ID == "0854"] <- "TimbTan"
het$group[het$ID == "0852"] <- "TimbTan"
het$group[het$ID == "0853"] <- "TimbTan"
het$group[het$ID == "0818"] <- "TstrTan"
het$group[het$ID == "0619"] <- "TstrZam"
het$group[het$ID == "0887"] <- "TscrGha"

het$loc <- substr(het$group, 5, 7)
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck", "Ctau" = "wildebeest")
het$spec <- comnames[substr(het$group, 1, 4)]


### mark outliers
het <- het %>%
  group_by(group) %>%
  mutate(stddev = sd(V2)) %>%
  mutate(mean_value = mean(V2))

het[is.na(het$stddev), "stddev"] <- 0
het$outlier <- (abs(het$V2 - het$mean_value) > het$stddev) & (abs(het$V2 - het$mean_value) > 0.0001)


het <- het %>% filter(spec != "waterbuck" & spec != "wildebeest" & spec != "waterbuck")

het <- het[!het$ID == "0757", ]

pdf("het_boxplot_within_psmc_fixedscale.pdf", width=14, height = 7)
ggplot(het, aes(x = loc, y = V2)) +
geom_boxplot(outlier.shape = NA) +
facet_wrap(factor(spec, levels=c("eland", "bushbuck", "mountain_nyala","greater_kudu", "sitatunga", "lesser_kudu", "nyala", "giant_eland")) ~ ., scale = "free_x", ncol = 4) +
# geom_text(data = het[het$outlier, ], aes(label = ID), size = 2, col = "#ff5900", hjust = -0.3) +
geom_point(data = het[het$outlier, ]) +
geom_text_repel(data = het[het$outlier, ], aes(label = ID), size = 2, col = "#ff5900", bg.colour = "white", bg.r = .2) +
theme_bw()
dev.off()

#het %>% filter(group == "ToryZam")
#het %>% filter(spec == "eland") %>% print(n=86)
