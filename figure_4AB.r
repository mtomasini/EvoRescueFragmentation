# Figures 4 A and B, as well as S6 A and B using ./Simulations/00_results_fig4AB_s1.txt
source("myfilledcontour_function.R")
data.theta <- read.table("./Simulations/00_results_fig4AB.txt", header=T)

possible.m <- as.numeric(levels(factor(data.theta$migration)))
possible.th <- as.numeric(levels(factor(data.theta$TotalGenerations)))

matrix.L <- matrix(NA, nrow =length(possible.m), ncol =length(possible.th) )
matrix.G <- matrix(NA, nrow =length(possible.m), ncol =length(possible.th) )

# We select the part of the dataset that we want:
D = 16

pars.L = (data.theta$Demes == D & data.theta$isGlobal == 0.0)
data.L = data.theta[pars.L,]
pars.G = (data.theta$Demes == D & data.theta$isGlobal == 1.0)
data.G = data.theta[pars.G,]

for(i in 1:length(possible.m)){
    for(j in 1:length(possible.th)){
        datapoint.L <- data.L[which(data.L$migration == possible.m[i] & data.L$TotalGenerations == possible.th[j]),]
        matrix.L[i,j] <- datapoint.L$Rescue
        datapoint.G <- data.G[which(data.G$migration == possible.m[i] & data.G$TotalGenerations == possible.th[j]),]
        matrix.G[i,j] <- datapoint.G$Rescue
    }
}

#difference.rescue <- matrix.L - matrix.G

# we transform m in log base 10
transformed.m <- log(possible.m)/log(10)

palette.local <- colorRampPalette(colors = c("#f5f5f5", "#5ab4ac")) # for local
palette.global <- colorRampPalette(colors = c("#f5f5f5", "#d8b365")) # for global
par(mar=c(5,5,2,2))

# FIGURE 2A 
setEPS()
postscript("Global_m_theta_D16_s05.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = as.integer(possible.th/D),
                  z = matrix.G, 
                  color.palette = palette.global,
                  levels = pretty(c(0, 1), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Length of epoch", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()

# FIGURE B
par(mar=c(5,5,2,2))
setEPS()
postscript("Local_m_theta_D16_s05.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = as.integer(possible.th/D),
                  z = matrix.L, 
                  color.palette = palette.local,
                  levels = pretty(c(0, 1), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Length of epoch", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()
