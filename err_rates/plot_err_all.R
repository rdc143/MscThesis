library(genio)
fam <- read_fam("/home/rdc143/trag_analyses/bed/BosTau9_tragmain_sites_variable_noindels")

rates <- read.table("/maps/projects/seqafrica/scratch/mapping/tragelaphini/batch_1.qc/errorrate/angsdErrorEst.txt", skip=275, header = FALSE, colClasses = c("character", "numeric", "character"), col.names = c("ID", "Value", "Percentage"), quote = "")
rates$ID <- substr(rates$ID, 2,  15)
rates$ID

in_main_set <- rates$ID %in% paste(fam$fam, fam$id, sep="_")

rates <- rates[in_main_set,]

# Convert from percentage
rates$Value <- rates$Value / 100

###fixing incorrect species assignments
rates$ID[substr(rates$ID, 9, 12) == "0843"] <- "KellZam_0843"
rates$ID[substr(rates$ID, 9, 12) == "0854"] <- "TimbTan_0854"
rates$ID[substr(rates$ID, 9, 12) == "0852"] <- "TimbTan_0852"
rates$ID[substr(rates$ID, 9, 12) == "0853"] <- "TimbTan_0853"
rates$ID[substr(rates$ID, 9, 12) == "0818"] <- "TstrTan_0818"
rates$ID[substr(rates$ID, 9, 12) == "0619"] <- "TstrZam_0619"
rates$ID[substr(rates$ID, 9, 12) == "0887"] <- "TscrGha_0887"

rates$spec <- substr(rates$ID, 1, 4) 
comnames <- c("Tory" = "Eland", "Tder" = "Giant eland", "Tstr" = "Greater kudu", "Timb" = "Lesser kudu", "Tbux" = "Mountain nyala", "Scaf" = "Nyala", "Tspe" = "Sitatunga", "Kell" = "Waterbuck", "Tscr" = "Bushbuck")
rates$name <- comnames[rates$spec]

colors <- c("Tory" = "#F8766D", "Tder" = "#CD9600",
"Tstr" = "#7CAE00", "Timb" = "#00BE67",
"Tbux" = "#00BFC4","Scaf" = "#C77CFF","Tspe" = "#FF61CC",
"Tscr" = "#FFFF7C", "Kell" = "#383838")

rates <- rates[order(rates$name),]


pdf("errorrates_tragmain.pdf", width=14)
barplot(rates$Value, col = colors[rates$spec], ylim=c(-0.0005,0.0025),)
legend("topleft",legend=c("Eland", "Giant Eland","Greater kudu", "Lesser kudu","Mountain nyala","Nyala", "Sitatunga", "Bushbuck", "Waterbuck"),  
       fill = c("#F8766D","#CD9600","#7CAE00", "#00BE67","#00BFC4","#C77CFF","#FF61CC", "#FFFF7C", "#383838"))

boxplot(Value ~ name, rates, col = c("#FFFF7C", "#F8766D","#CD9600","#7CAE00", "#00BE67","#00BFC4","#C77CFF","#FF61CC", "#383838"), ylim=c(-0.0005, 0.0025))
abline(h = 0, col = "black", lty = 2)
legend("topleft",legend=c("Eland", "Giant Eland","Greater kudu", "Lesser kudu","Mountain nyala","Nyala", "Sitatunga", "Bushbuck", "Waterbuck"),  
       fill = c("#F8766D","#CD9600","#7CAE00", "#00BE67","#00BFC4","#C77CFF","#FF61CC", "#FFFF7C", "#383838"))
dev.off()
