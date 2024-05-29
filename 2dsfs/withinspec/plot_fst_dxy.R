library(ggplot2)
library(tidyr)
library(dplyr)
library(gridExtra)
comnames <- c("Tory" = "eland", "Tder" = "giant eland", "Tstr" = "greater kudu", "Timb" = "lesser kudu", "Tbux" = "mountain_nyala", "Scaf" = "nyala", "Tspe" = "sitatunga", "Kell" = "waterbuck", "Tscr" = "bushbuck")

p1lst <- list()
p2lst <- list()

for (spec in c("Tory", "Tstr", "Tder", "Timb", "Tbux", "Scaf", "Tspe")) {
    tab <- read.table(paste0(spec, ".2dsfs.tsv"), header = TRUE)

    ### remove related inds
    unrelated <- read.table("/home/rdc143/trag_analyses/plink/keep_unrelated2.txt", colClasses = rep("character", 2))
    unrelated <- as.vector(paste(unrelated$V1, unrelated$V2, sep="_"))
    tab <- tab %>% filter(A %in% unrelated & B %in% unrelated)

    #mirror matrix around diagonal for plotting
    tab_mirror <- tab
    tab_mirror$A <- tab$B
    tab_mirror$B <- tab$A
    tab <- rbind(tab, tab_mirror)

#     # split into lower and upper triangles for plotting on top of eachother
#     above_diag <- tab %>%
#         filter(A < B)
    
#     below_diag <- tab %>%
#         filter(A > B)

    # Change plotting order
    if (file.exists(paste0(spec, ".plotorder"))) {
    plotorder <- readLines(paste0(spec, ".plotorder"))

    #print(unique(tab$A)[!(unique(tab$A) %in% plotorder)]) # test to see if any missing in plotorder file
    
    tab$A <- factor(tab$A, levels = plotorder)
    tab$B <- factor(tab$B, levels = plotorder)
    }

    p1 <- ggplot(tab, aes(A, B, fill = fstU)) +
    geom_tile(color = "#f8f8f8",
            lwd = 0.1,
            linetype = 1) + 
    scale_fill_gradientn(colors = rev(viridis::viridis(9))) +
    # scale_fill_gradient2(low = "blue", mid = "green", high = "yellow", midpoint = 0.325) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    ggtitle(paste("Pairwise Fst for", comnames[spec]))

    p2 <- ggplot(tab, aes(A, B, fill = dxy)) +
    geom_tile(color = "#f8f8f8",
            lwd = 0.1,
            linetype = 1) + 
    scale_fill_gradientn(colors = rev(viridis::viridis(9))) +
    # scale_fill_gradient2(low = "blue", mid = "green", high = "yellow", midpoint = 0.325) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    ggtitle(paste("Pairwise dXY for", comnames[spec]))
    
    last_in_loc <- cumsum(rle(substr(sort(unique(tab$A)), 1, 7))$lengths)

    p1 <- p1 + geom_vline(xintercept = last_in_loc + 0.5, color = "white", size = 1.5) +
    geom_hline(yintercept = last_in_loc + 0.5, color = "white", size = 1.5)
    p2 <- p2 + geom_vline(xintercept = last_in_loc + 0.5, color = "white", size = 1.5) +
    geom_hline(yintercept = last_in_loc + 0.5, color = "white", size = 1.5)
    
    png(paste0(spec, ".fst_dxy.png"), width=1920, height=1080)
    grid.arrange(p1, p2, ncol = 2)
    dev.off()



    ### median for each location
    tab_med <- tab
    tab_med$A <- substr(tab_med$A, 1, 7)
    tab_med$B <- substr(tab_med$B, 1, 7)

    tab_med <- tab_med %>%
        group_by(A, B) %>%
        summarize(across(everything(), mean, na.rm = TRUE))
    
    if (file.exists(paste0(spec, ".plotorder"))) {
    plotorder <- unique(substr(plotorder, 1, 7))
    tab_med$A <- factor(tab_med$A, levels = plotorder)
    tab_med$B <- factor(tab_med$B, levels = plotorder)
    }

    p1 <- ggplot(tab_med, aes(A, B, fill = fstU)) +
    geom_tile(color = "#f8f8f8",
            lwd = 0.3,
            linetype = 1) + 
    scale_fill_gradientn(colors = rev(viridis::viridis(9))) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    ggtitle(paste("Pairwise Fst for", comnames[spec]))+
    xlab("") +
    ylab("")

    p2 <- ggplot(tab_med, aes(A, B, fill = dxy)) +
    geom_tile(color = "#f8f8f8",
            lwd = 0.3,
            linetype = 1) + 
    scale_fill_gradientn(colors = rev(viridis::viridis(9))) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
    ggtitle(paste("Pairwise dXY for", comnames[spec])) +
    xlab("") +
    ylab("")

#     png(paste0(spec, "_median.fst_dxy.png"), width=1920, height=1080)
#     grid.arrange(p1, p2, ncol = 2)
#     dev.off()
   p1lst[[spec]] <- p1
   p2lst[[spec]] <- p2
}


png("median.fst_dxy.png", width = 900, height = 1200)
grid.arrange(p1lst[["Tory"]], p2lst[["Tory"]],
             p1lst[["Tstr"]], p2lst[["Tstr"]],
             p1lst[["Timb"]], p2lst[["Timb"]],
             p1lst[["Tspe"]], p2lst[["Tspe"]],
             p1lst[["Tder"]], p2lst[["Tder"]],   ncol = 2)
dev.off()