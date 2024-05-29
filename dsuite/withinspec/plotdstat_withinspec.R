library(dplyr)
library(ggplot2)
library(gridExtra)
library(stringr)
tab <- read.table("./tragBostau9_BBAA.txt", header = T)
# tab <- read.table("./tragBostau9_Dmin.txt", header=T)
tab$std.err <- tab$Dstatistic / tab$Z.score
tab$lower <- tab$Dstatistic - tab$std.err * 3
tab$upper <- tab$Dstatistic + tab$std.err * 3

comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")
replace_strings <- function(data, dictionary) {
  mutate_all(data, ~ str_replace_all(., dictionary))
}


filtered <- tab %>%
  filter(substr(P1, 1, 4) == substr(P2, 1, 4)) %>%
  filter(substr(P1, 1, 4) != substr(P3, 1, 4)) %>%
  filter_all(all_vars(!grepl("NA-", .)))

removed <- anti_join(tab, filtered)

### BH correction
FDR <- 0.001
ntest <- nrow(filtered)

filtered <- filtered %>% 
  arrange(p.value) %>%
  mutate(rank = 1:ntest) %>%
  mutate(BHCV = (rank / ntest) * FDR) %>%
  mutate(sig = BHCV > p.value)


# add flipped combs with flipped values for plotting
filtered_switched <- filtered %>%
  mutate(
    temp = .data[["P1"]],
    !!"P1" := .data[["P2"]],
    !!"P2" := temp,
    across(all_of(c("Dstatistic", "lower", "upper" )), ~ . * -1)
  ) %>%
  select(-temp)

filtered <- bind_rows(filtered, filtered_switched)


filtered$P1_P2 <- paste(str_sub(filtered$P1, -3, -1), str_sub(filtered$P2, -3, -1), sep = " & ")
filtered$P3_species <- substr(filtered$P3, 1, 4)
filtered$P1_P2_species <- substr(filtered$P1, 1, 4)

filtered[, 16:18] <- replace_strings(filtered[, 16:18], comnames)

comcolors <- c(
  "eland" = "#F8766D", "giant_eland" = "#CD9600", "greater_kudu" = "#7CAE00",
  "lesser_kudu" = "#00BE67", "mountain_nyala" = "#00BFC4", "nyala" = "#C77CFF",
  "sitatunga" = "#FF61CC", "bushbuck" = "#FFFF7C", "waterbuck" = "#383838"
)



p <- list()
species <- unique(filtered$P1_P2_species)
for (i in 1:length(species)) { # nolint: seq_linter.
  plotdat <- filtered[filtered$P1_P2_species == species[i], ]
  p[[i]] <- ggplot(plotdat, aes(Dstatistic, P1_P2, color = P3_species, alpha = sig)) +
    geom_point(position = position_dodge(width = 0.5)) +
    geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5)) +
    scale_color_manual(values = comcolors) +
    geom_hline(yintercept = seq(0.5, length(unique(plotdat$P1_P2)) - 0.5), color = "black", size = 0.5) +
    geom_vline(xintercept = 0, linetype="dotted") +
    coord_cartesian(xlim = c(-0.1, 0.1)) + 
    ggtitle(paste("P1 & P2:", species[i])) +
    labs(color = "P3 species") +
    theme_bw()
}


pdf("dstat_grouped.pdf", height=10)
for (i in 1:length(p)) { # nolint: seq_linter.
  print(p[[i]])
}
dev.off()
