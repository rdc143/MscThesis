library(dplyr)
library(ggplot2)
library(gridExtra)
library(stringr)
tab <- read.table("./tragBostau9_BBAA.txt", header=T)
#tab <- read.table("./tragBostau9_Dmin.txt", header=T)
tab$std.err <- tab$Dstatistic / tab$Z.score 
tab$lower <- tab$Dstatistic - tab$std.err
tab$upper <- tab$Dstatistic + tab$std.err

comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")
replace_strings <- function(data, dictionary) {
  mutate_all(data, ~ str_replace_all(., dictionary))
}


filtered <- tab %>% # maybe only keep ones with gk as p1/2? 
  filter((P3 == "TstrBot_0757" & substr(P2, 1, 4) == "Tory")) #|
#         ((P1 == "TstrBot_0757" | P2 == "TstrBot_0757") & substr(P3, 1, 4) == "Tory"))
filtered

Z_cutoff <- 3
sig <- filtered[filtered$Z.score > Z_cutoff,]

pdf("0757.pdf")
ggplot(sig, aes(Dstatistic, P2, color=P1)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5)) +
  labs(color = "P1 pop") +
  theme(legend.position="left")
dev.off()
