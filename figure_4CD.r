# Figures 4 C and D, as well as S6 C and D using ./Simulations/00_results_fig4CD_s1.txt
source("./myfilledcontour_function.R")
data.r <- read.table("./Simulations/00_results_fig4CD.txt", header=T)

possible.m <- as.numeric(levels(factor(data.r$migration)))
possible.r <- as.numeric(levels(factor(data.r$r)))

matrix.L <- matrix(NA, nrow =length(possible.m), ncol =length(possible.r) )
matrix.G <- matrix(NA, nrow =length(possible.m), ncol =length(possible.r) )

D = 16

pars.L = (data.r$Demes == D & data.r$isGlobal == 0.0)
data.L = data.r[pars.L,]
pars.G = (data.r$Demes == D & data.r$isGlobal == 1.0)
data.G = data.r[pars.G,]

for(i in 1:length(possible.m)){
    for(j in 1:length(possible.r)){
        datapoint.L <- data.L[which(data.L$migration == possible.m[i] & data.L$r == possible.r[j]),]
        matrix.L[i,j] = datapoint.L$Rescue
        datapoint.G <- data.G[which(data.G$migration == possible.m[i] & data.G$r == possible.r[j]),]
        matrix.G[i,j] = datapoint.G$Rescue
    }
}

#difference.rescue <- matrix.L - matrix.G

# we transform m in log base 10
transformed.m <- log(possible.m)/log(10)

#mypalette <- colorRampPalette(colors = c("#d8b365", "#f5f5f5", "#5ab4ac"))   # this is blue sea - sand
palette.local <- colorRampPalette(colors = c("#f5f5f5", "#5ab4ac")) # for local
palette.global <- colorRampPalette(colors = c("#f5f5f5", "#d8b365")) # for global
par(mar=c(5,5,2,2))

# FIGURE 2G
setEPS()
postscript("Global_m_r_D16_s05.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = possible.r,
                  z = matrix.G, 
                  color.palette = palette.global,
                  levels = pretty(c(0.0, 1.0), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Stress against wildtype", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()

# FIGURE 2H
setEPS()
postscript("Local_m_r_D16_s05.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = possible.r,
                  z = matrix.L, 
                  color.palette = palette.local,
                  levels = pretty(c(0.0, 1.0), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Stress against wildtype", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()
