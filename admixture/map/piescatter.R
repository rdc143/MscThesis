piescatter <- function(m, xradius=0.1, nedges=200, add=F, polygonlwd=0.5, ...){
    # Function that draws proportion/pie diagrams on x and y positions.
    # Needs a matrix, m, where the first column is the x positions, second
    # column is the y positions, and the remaining columns are the proportions
    # and each row represent a sample/pie.
    # xradius: controls the radius of the pies
    # nedges: controls how fine-grained the circles should be
    # add: controls whether to add the circles to an already existing plot.

    # Make unit circle with n edges
    edges <- seq(0,1,length.out=nedges)
    circle <- list(x=xradius*cos(2*pi*edges), y=xradius*sin(2*pi*edges))

    # Extract x and y coordinates and proportions.
    xs <- m[,1]
    ys <- m[,2]
    props <- as.matrix(m[,3:ncol(m)])
    props <- props / rowSums(props) # normalize
    ngroups <- ncol(props)
    groupcolors <- rep_len(palette(), ngroups)
    
    # Make empty plot with additional parameters, ...
    if (!add){
        plot(xs,ys,col='transparent', ...)
    }
    
    # Get plot limits and calculate ratio for adjusting y-coordinates.
    limits <- par("usr")
    ratio <- diff(limits[1:2])/diff(limits[3:4])
    
    # Adjust circle
    circle$y <- circle$y/ratio

    drawpie <- function(x,y,prop){
        cumprop <- cumsum(prop)
        n <- 1
        for (i in 1:ngroups){
            new_n <- round(nedges * cumprop[i])
            slice_x <- circle$x[n:new_n]+x
            slice_y <- circle$y[n:new_n]+y
            polygon(c(x,slice_x, x),c(y,slice_y, y), col=groupcolors[i], lwd=polygonlwd)
            n <- new_n
        }
    }

    # Draw each pie.
    save_for_cleanoutput <- sapply(1:nrow(m), function(x){
        drawpie(xs[x], ys[x], props[x,])
    })
}

### Example usage
# # Example matrix (first two columns are x and y coordinates and remaining columns are proportions)
# m <- matrix(c(
#     2,6,0.6,0.3,0.1,
#     5,10,0.2,0.4,0.4
# ), byrow = T, nrow = 2)

# # Default pies.
# piescatter(m)

# # Uses default palette colors, so you need to change those to change colors.
# palette(c("#56B4E9", "#E69F00", "#009E73",  "#0072B2", "#D55E00", "#CC79A7",'#999999', "#F0E442"))
# piescatter(m)

# # You can add it to an already existing plot and change the x-radius as follows:
# plot(10,100, xlim=c(0,20), ylim=c(0,200))
# piescatter(m, add=T, xradius = 1)
