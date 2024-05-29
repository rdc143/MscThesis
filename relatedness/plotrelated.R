library(ggplot2)
library(grid)
library(gridExtra)
library(ggrepel)
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")


args <- commandArgs(trailingOnly = TRUE)

dat1 <- read.table(args[1], header = TRUE)
dat2 <- read.table(args[2], header = TRUE, comment.char = "^")

dat1$comp <- paste0(pmin(dat1$IID1, dat1$IID2), " & ", pmax(dat1$IID1, dat1$IID2))
dat2$comp <- paste0(pmin(dat2$IID1, dat2$IID2), " & ", pmax(dat2$IID1, dat2$IID2))

dat <- merge(dat1, dat2, by = c("comp"))
dat

# color if pair does not pass relatedness threshold
dat$cut <- ((dat$Z1 + dat$Z2) > 0.5) | (dat$RATIO > 6)

pdf(args[3], width = 20, height = 10)

title <- tools::file_path_sans_ext(basename(args[3]))
title <- paste(comnames[substr(title, 1, 4)], substr(title, 5, 7))

p1 <- ggplot(dat, aes(Z1, Z2, label = comp, color = cut)) +
  geom_text_repel(size = 3, segment.linetype = 1) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
  geom_point() +
  theme_classic()

p2 <- ggplot(dat, aes(RATIO, KINSHIP, label = comp, color = cut)) +
  geom_text_repel(size = 3, segment.linetype = 1) +
  coord_cartesian(xlim = c(1, 10), ylim = c(-.5, .5)) +
  geom_point() +
  theme_classic()

grid.arrange(p1, p2, ncol = 2, top = textGrob(title, gp = gpar(fontsize = 20, font = 3)))
dev.off()
