library(dplyr)
library(ggplot2)
library(gridExtra)
library(stringr)
tab <- read.table("./tragBostau9_BBAA.txt", header = T)
# tab <- read.table("./tragBostau9_Dmin.txt", header=T)
tab$std.err <- tab$Dstatistic / tab$Z.score
tab$lower <- tab$Dstatistic - tab$std.err
tab$upper <- tab$Dstatistic + tab$std.err

comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")
replace_strings <- function(data, dictionary) {
  mutate_all(data, ~ str_replace_all(., dictionary))
}


filtered <- tab %>%
  filter(substr(P1, 1, 4) == substr(P2, 1, 4)) %>%
  filter(substr(P1, 1, 4) != substr(P3, 1, 4)) %>%
  filter_all(all_vars(!grepl("NA-", .)))

p_cutoff <- .05 / nrow(filtered) # Bonferroni cor.
D_cutoff <- 0.025
# Z_cutoff <- 3

# sig <- filtered[filtered$Z.score > Z_cutoff, ]
sig <- filtered[filtered$p.value < p_cutoff, ]

highD <- sig[sig$Dstatistic > D_cutoff, ]

highD$P1_P2 <- paste(highD$P1, highD$P2, sep = " & ")
highD$P3_species <- substr(highD$P3, 1, 4)
highD$P1_P2_species <- substr(highD$P1, 1, 4)

highD[, 13:15] <- replace_strings(highD[, 13:15], comnames)

# comcolors <- c("#F8766D" = "eland", "#CD9600" = "giant_eland", "#7CAE00" = "greater_kudu", "#00BE67" = "lesser_kudu", "#00BFC4" = "mountain_nyala", "#C77CFF" = "nyala", "#FF61CC" = "sitatunga", "#FFFF7C" = "bushbuck", "#383838" = "waterbuck")
comcolors <- c(
  "eland" = "#F8766D", "giant_eland" = "#CD9600", "greater_kudu" = "#7CAE00",
  "lesser_kudu" = "#00BE67", "mountain_nyala" = "#00BFC4", "nyala" = "#C77CFF",
  "sitatunga" = "#FF61CC", "bushbuck" = "#FFFF7C", "waterbuck" = "#383838"
)

# pdf("dstat.pdf")
# ggplot(highD, aes(Dstatistic, P1_P2, color=P3_species)) +
#   geom_point(position = position_dodge(width = 0.5), alpha=0.3) +
#   geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5), alpha=0.2) +
#   geom_vline(xintercept = D_cutoff, linetype="dotted") +
#   scale_color_manual(values = comcolors) +
#   labs(color = "P3 species")
# dev.off()


p <- list()
species <- unique(highD$P1_P2_species)
for (i in 1:length(species)) {
  print(species[i])
  plotdat <- highD[highD$P1_P2_species == species[i], ]
  p[[i]] <- ggplot(plotdat, aes(Dstatistic, P1_P2, color = P3_species)) +
    geom_point(position = position_dodge(width = 0.5), alpha = 0.6) +
    geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5), alpha = 0.4) +
    geom_vline(xintercept = D_cutoff, linetype = "dotted") +
    scale_color_manual(values = comcolors) +
    labs(color = "P3 species")
}


pdf("dstat_grouped_withcor.pdf")
for (i in 1:length(p)) {
  print(p[[i]])
}
dev.off()
