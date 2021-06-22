# Figure 4A, B and C, change s to see in turn 4A (s=0.1), 4B (s=0.5) and 4C (s=1.0)
m.low = 0.00032
m.1 = 0.01
m.intermediate = 0.02154
m.2 = 0.1 # 0.06813
m.high = 0.68129
r = 0.5
s = 1.0
isGlobal = FALSE # CHANGE THIS TO TRUE TO OBTAIN SAME FIGURES FOR ISLAND MODEL

data <- read.table("../Cluster_results/00_results_Parameters_fig4.txt", header = T)

par1 <- (data$isGlobal == isGlobal & data$s == s & data$z == 0.02 & data$r == r & data$migration == m.low)
ER1 <- data[par1,]
ER1 <- ER1[order(ER1$Demes),]
par2 <- (data$isGlobal == isGlobal & data$s == s & data$z == 0.02 & data$r == r & data$migration == m.intermediate)
ER2 <- data[par2,]
ER2 <- ER2[order(ER2$Demes),]
par3 <- (data$isGlobal == isGlobal & data$s == s & data$z == 0.02 & data$r == r & data$migration == m.high)
ER3 <- data[par3,]
ER3 <- ER3[order(ER3$Demes),]
par4 <- (data$isGlobal == isGlobal & data$s == s & data$z == 0.02 & data$r == r & data$migration == m.1)
ER4 <- data[par4,]
ER4 <- ER4[order(ER4$Demes),]
par5 <- (data$isGlobal == isGlobal & data$s == s & data$z == 0.02 & data$r == r & data$migration == m.2)
ER5 <- data[par5,]
ER5 <- ER5[order(ER5$Demes),]

plot.limit <- max(ER1$Rescue, ER2$Rescue, ER3$Rescue, ER4$Rescue, ER5$Rescue)

setEPS()
postscript("../Figures_review/NewFig4/Demes_low_high_migration_s1_r05_local.eps", width=7, height=5)
par(mar=c(5,5,2,2))
plot(ER1$Demes, ER1$Rescue, 
     xlab = "Number of demes", ylab = "Probability of rescue",
     cex.axis = 1.5, cex.lab = 1.5, ylim=c(0, plot.limit), pch=19, type="b", col="gold")
points(ER2$Demes, ER2$Rescue, pch = 19, col="magenta", type="b")
points(ER3$Demes, ER3$Rescue, pch = 19, type="b", col="royalblue")
points(ER4$Demes, ER4$Rescue, pch = 19, lty=1, type="b", col="orange")
points(ER5$Demes, ER5$Rescue, pch = 19, lty=1, type="b", col="purple")
grid()
legend("topleft", c(expression(m == 6.8129%*%10^-1), expression(m == 1%*%10^-1), 
                    expression(m == 2.154%*%10^-2), expression(m == 1%*%10^-2), 
                    expression(m == 3.2%*%10^-4)),
       pch=c(19, 19, 19, 19, 19), col = c("royalblue", "purple", "magenta", "orange", "gold"),
       lty=c(1,1,1,1,1), cex=1.3, bty="n")
dev.off()

