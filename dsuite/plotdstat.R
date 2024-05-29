library(tidyverse)
library(gridExtra)
#tab <- read.table("./stdtop/tragBostau9_BBAA.txt", header=T)
tab <- read.table("./stdtop/tragBostau9_Dmin.txt", header=T)
tab$std.err <- tab$Dstatistic / tab$Z.score 
tab$lower <- tab$Dstatistic - tab$std.err
tab$upper <- tab$Dstatistic + tab$std.err

p1 <- filter(tab, P3 == "sitatunga") %>%
  arrange(desc(Dstatistic)) %>%
  ggplot(aes(Dstatistic, P1, color = P2)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5)) +
  geom_vline(xintercept = 0, linetype="dotted") #+
  #ggtitle("P3: nyala")


p2 <- filter(tab, P3 == "greater_kudu") %>%
  arrange(desc(Dstatistic)) %>%
  ggplot(aes(Dstatistic, P1, color = P2)) +
  geom_point(position = position_dodge(width = 0.5)) +
  geom_errorbarh(aes(xmax = upper, xmin = lower, height = 0.2), position = position_dodge(width = 0.5)) +
  geom_vline(xintercept = 0, linetype="dotted") #+
  #ggtitle("P3: greater_kudu")

pdf("dstat.pdf")
grid.arrange(p1, p2)
dev.off()


tab[order(tab$Z.score),]
