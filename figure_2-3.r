# FIGURE 2 A to F as well as S5A and B using ./Simulations/00_results_fig2-3_nodensity.txt
par(mar=c(5,5,2,2))
ER_data <- read.table("./Simulations/00_results_fig2-3.txt", header=T)
s.list <- unique(ER_data$s)
r.list <- unique(ER_data$r)
D.list <- unique(ER_data$Demes)
growth = 1.5

for (s in s.list){
    for (r in r.list) {
        for (D in D.list){
            filename <- paste("SS_Island_s", s, "_r", r, "_D", D, "_nodensity.eps", sep="")
            setEPS()
            postscript(filename, width=7, height=5)
            
            par1 <- (ER_data$Demes == D & ER_data$isGlobal == 0.0 & ER_data$growth == growth 
                     & ER_data$s == s & ER_data$z == 0.02 & ER_data$r == r)
            ER1 <- ER_data[par1,]
            par2 <- (ER_data$Demes == D & ER_data$isGlobal == 1.0 & ER_data$growth == growth
                     & ER_data$s == s & ER_data$z == 0.02 & ER_data$r == r)
            ER2 <- ER_data[par2,]
            plot(ER1$migration, ER1$Rescue, pch = 19, col = "gray60", ylim = c(0, 1.0),
                 xlab="Migration rate", ylab="Probability of rescue", log="x", cex.axis = 1.5, cex.lab =1.5)
            points(ER2$migration, ER2$Rescue, pch = 19)
            arrows(ER1$migration, ER1$Rescue - ER1$Error, 
                   ER1$migration, ER1$Rescue + ER1$Error, 
                   length=0.05, angle=90, code=3, col = "gray60")
            arrows(ER2$migration, ER2$Rescue - ER2$Error, 
                   ER2$migration, ER2$Rescue + ER2$Error, 
                   length=0.05, angle=90, code=3, col = "black")
            grid()
            if (s == 0.1 & D == 4){
                legend("bottomright", c("Stepping Stone", "Island"), 
                       pch=c(19, 19), col = c("gray60", "black"), cex=1.5, bty="n")
            }
            dev.off()
        }
    }
}


# FIGURE 3 A to F as well as S5 C and D using ./Simulations/00_results_fig2-3_nodensity.txt

for (s in s.list){
    for (r in r.list) {
        for (D in D.list){
            filename <- paste("Comparison_s", s, "_r", r, "_D", D, "_nodensity.eps", sep="")
            setEPS()
            postscript(filename, width=7, height=5)
            
            par1 <- (ER_data$Demes == D & ER_data$isGlobal == 0.0 & ER_data$growth == growth
                     & ER_data$s == s & ER_data$z == 0.02 & ER_data$r == r)
            ER1 <- ER_data[par1,]
            par2 <- (ER_data$Demes == D & ER_data$isGlobal == 1.0 & ER_data$growth == growth
                     & ER_data$s == s & ER_data$z == 0.02 & ER_data$r == r)
            ER2 <- ER_data[par2,]
            plot(ER1$migration*2/D, ER1$Rescue, pch = 19, col = "gray60", ylim = c(0, 1.0), xlim=c(1e-4, 1),
                 xlab="Migration rate", ylab="Probability of rescue", log="x", cex.axis = 1.5, cex.lab =1.5)
            points(ER2$migration, ER2$Rescue, pch = 19)
            arrows(ER1$migration*2/D, ER1$Rescue - ER1$Error, 
                   ER1$migration*2/D, ER1$Rescue + ER1$Error, 
                   length=0.05, angle=90, code=3, col = "gray60")
            arrows(ER2$migration, ER2$Rescue - ER2$Error, 
                   ER2$migration, ER2$Rescue + ER2$Error, 
                   length=0.05, angle=90, code=3, col = "black")
            grid()
            if (s == 0.1 & D == 4){
                legend("bottomright", c("Stepping Stone", "Island"), 
                       pch=c(19, 19), col = c("gray60", "black"), cex=1.5, bty="n")
            }
            dev.off()
        }
    }
}
