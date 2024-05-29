library(maps)
library(mapdata)
library(mapproj)
source('/home/rdc143/trag_analyses/admixture/map/piescatter.R')
palette('Tableau 10')

args <- commandArgs(trailingOnly = TRUE)

nproj <- as.numeric(args[3])

ISOcodes_afr <- c(
  "DZA", "AGO", "BEN", "BWA", "BFA", "BDI", "CMR", "CAF", "TCD", "COD", 
  "COG", "DJI", "EGY", "ERI", "SWZ", "ETH", "GAB", "GMB", "GHA", "GIN", "GNB", 
  "CIV", "KEN", "LSO", "LBR", "LBY", "MWI", "MLI", "MRT", "MAR", "MOZ", 
  "NAM", "NER", "NGA", "RWA", "SEN", "SLE", "SOM", "ZAF", "SSD", "SDN", 
  "TZA", "TGO", "TUN", "UGA", "ZMB", "ZWE", "MDG"
)
african_countries_full <- iso.expand(ISOcodes_afr)

# nams <- map("world", namesonly = T, plot=FALSE)

png(paste0(args[1], ".png"), width = 2000, height = 2000)
ori <- c(7.766668, 19.303225, 0)
map("world", region=african_countries_full, col='black') #, orientation = ori)

sample_points <- read.table(paste0(args[1], ".proj.coords"))[, 2:3]
colnames(sample_points) <- c("lat", "lon")

loc_proj <- data.frame(mapproject(sample_points$lon, sample_points$lat)) #, orientation = ori)

### mark out samples which have the admix prop derived from projection
is_proj <- 1:nrow(loc_proj) > nrow(loc_proj) - nproj

### repel points from eachother
loc_proj <- round(loc_proj, 4)

sorted_indices <- order(loc_proj$x, loc_proj$y)
loc_proj <- loc_proj[sorted_indices, ]

is_proj <- is_proj[sorted_indices]

loc_proj$x_new <- jitter(loc_proj$x, amount=2)
loc_proj$y_new <- jitter(loc_proj$y, amount=2)
offset <- .85

drawline <- rep(TRUE, nrow(loc_proj))

for (i in 2:nrow(loc_proj)) {
  if (loc_proj[i, 1] == loc_proj[i - 1, 1] && loc_proj[i, 2] == loc_proj[i - 1, 2]) {
    loc_proj[i, 3] <- loc_proj[i - 1, 3] + offset
    loc_proj[i, 4] <- loc_proj[i - 1, 4]
    drawline[i] <- FALSE
  }
}

segments(x0 = loc_proj[drawline, "x"],
         y0 = loc_proj[drawline, "y"],
         x1 = loc_proj[drawline, "x_new"],
         y1 = loc_proj[drawline, "y_new"])

admix <- data.frame(read.table(paste0(args[1], ".Q")))

m1 <- cbind(loc_proj[,3:4], admix[sorted_indices, ])
piescatter(m1, add = T, xradius = 0.4)

points(loc_proj[is_proj, 3], loc_proj[is_proj, 4], cex=3.5, lwd=2)

title(paste0(args[1], " , K = ", args[2]), cex.main = 8)
dev.off()
