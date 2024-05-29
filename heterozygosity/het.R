library(genio)
library(ggplot2)
library(dplyr)

plink <- read_plink("/home/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly")


fam <- as.data.frame(plink$fam)
popinfo <- substr(fam$fam, 1, 4)
comnames <- c("Tory" = "eland", "Tder" = "giant_eland", "Tstr" = "greater_kudu", "Timb" = "lesser_kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck", "Ctau" = "wildebeest")
popinfo <- unname(comnames[popinfo])


het <- colMeans(plink$X == 1, na.rm = T)

df <- data.frame(cbind(het = het, popinfo, loc = substr(fam$fam, 5, 7), id = fam$id, poploc = fam$fam))
df$het <- as.numeric(df$het)
df <- df %>%
  group_by(poploc) %>%
  mutate(stddev = sd(het)) %>%
  mutate(mean_value = mean(het))

df[is.na(df$stddev), "stddev"] <- 0
df$outlier <- abs(df$het - df$mean_value) > (df$stddev * 2) 


df[df$outlier,]

# pdf("het_boxplot.pdf")
# df %>%
# #filter(popinfo != "waterbuck") %>%
# ggplot(aes(x=popinfo, y=het)) +
# geom_boxplot()
# dev.off()

pdf("het_boxplot_within.pdf")
df %>%
    # filter(popinfo != "waterbuck") %>%
    ggplot(aes(x = loc, y = het)) +
    geom_boxplot() +
    facet_wrap(~popinfo, scale = "free_x") + 
    geom_text(data = df[df$outlier,], aes(label = id), size = 2, col = "#ff5900") +
    theme_bw()
dev.off()
