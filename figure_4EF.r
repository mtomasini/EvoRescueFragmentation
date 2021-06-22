# Figures 4 E and F 
source("./myfilledcontour_function.R")
data.s <- read.table("./Simulations/00_results_fig4EF.txt", header=T)

possible.m <- as.numeric(levels(factor(data.s$migration)))
possible.s <- as.numeric(levels(factor(data.s$s)))

matrix.L <- matrix(NA, nrow =length(possible.m), ncol =length(possible.s) )
matrix.G <- matrix(NA, nrow =length(possible.m), ncol =length(possible.s) )

# We select the part of the dataset that we want:
D = 16

pars.L = (data.s$Demes == D & data.s$isGlobal == 0.0)
data.L = data.s[pars.L,]
pars.G = (data.s$Demes == D & data.s$isGlobal == 1.0)
data.G = data.s[pars.G,]

for(i in 1:length(possible.m)){
    for(j in 1:length(possible.s)){
        datapoint.L <- data.L[which(data.L$migration == possible.m[i] & data.L$s == possible.s[j]),]
        matrix.L[i,j] = datapoint.L$Rescue
        datapoint.G <- data.G[which(data.G$migration == possible.m[i] & data.G$s == possible.s[j]),]
        matrix.G[i,j] = datapoint.G$Rescue
    }
}

# we transform m in log base 10
transformed.m <- log(possible.m)/log(10)
palette.local <- colorRampPalette(colors = c("#f5f5f5", "#5ab4ac")) # for local
palette.global <- colorRampPalette(colors = c("#f5f5f5", "#d8b365")) # for global
par(mar=c(5,5,2,2))

# FIGURE 2D
setEPS()
postscript("Global_m_s_D16.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = possible.s,
                  z = matrix.G, 
                  color.palette = palette.global,
                  levels = pretty(c(0, 1.0), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Cost in unperturbed deme", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()

# FIGURE 2E
setEPS()
postscript("Local_m_s_D16.eps", width=7, height=5)
my.filled.contour(x = transformed.m,
                  y = possible.s,
                  z = matrix.L, 
                  color.palette = palette.local,
                  levels = pretty(c(0, 1.0), 10),
                  plot.title = {
                      title(xlab = "Migration rate (log)", cex.lab = 1.5)
                      title(ylab = "Cost in unperturbed deme", cex.lab = 1.5)
                      #abline(v = transformed.mlow, lty = 2, lwd = 2, col="red")
                  },
                  plot.axes={
                      axis(1,cex.axis=1.5)
                      axis(2,cex.axis=1.5)
                  })
grid()
dev.off()
