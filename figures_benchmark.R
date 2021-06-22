# FIGURES S2, S3 and S4 in supplemental material
par(mar=c(5,5,2,2))

source("ER_formulas.r")
data <- read.table("./Simulations/Benchmark_theta0.txt", header=T)

# image one: island model (isGlobal = 1), image two: stepping ston model (isGlobal = 0)
isGlobal <- 0.0
if (isGlobal) { title = "global" } else { title = "local" }
par.low <- (data$isGlobal == isGlobal & data$migration == 0.00032)
data.low <- data[par.low,]
par.med <- (data$isGlobal == isGlobal & data$migration == 0.02154)
data.med <- data[par.med,]
par.hig <- (data$isGlobal == isGlobal & data$migration == 0.68129)
data.hig <- data[par.hig,]

plot(data.low$Demes, data.low$Rescue, pch = 1, ylim = c(0, 0.8),
     xlab="Number of demes", ylab="Probability of rescue", cex.axis = 1.5, cex.lab =1.5)
points(data.med$Demes, data.med$Rescue, pch = 19, col = "gray60")
points(data.hig$Demes, data.hig$Rescue, pch = 19, col = "black")
arrows(data.low$Demes, data.low$Rescue - data.low$Error, 
       data.low$Demes, data.low$Rescue + data.low$Error, 
       length=0.05, angle=90, code=3, col = "black")
arrows(data.med$Demes, data.med$Rescue - data.med$Error, 
       data.med$Demes, data.med$Rescue + data.med$Error, 
       length=0.05, angle=90, code=3, col = "black")
arrows(data.hig$Demes, data.hig$Rescue - data.hig$Error, 
       data.hig$Demes, data.hig$Rescue + data.hig$Error, 
       length=0.05, angle=90, code=3, col = "black")
grid()
legend("topleft", c("low m", "med. m", "high m"), pch=c(1, 19, 19), col = c("black", "gray60", "black"), 
       cex=1.5, bty="n")
mtext(title)
Pres.dn.deme <- u*z*K/(r)
Pres.sgv.deme <- u*z*K/(s)
Pres.tot <- 1 - ((1-Pres.dn.deme)*(1-Pres.sgv.deme))
lines(d, rep(Pres.tot,17), lty=2, col="red",lwd=2)


data.migr <- read.table("./Simulations/Benchmark_m0.txt", header=T)
par.loc <- (data.migr$isGlobal == 0.0)
data.loc <- data.migr[par.loc,]
par.glo <- (data.migr$isGlobal == 1.0)
data.glo <- data.migr[par.glo,]
plot(data.glo$Demes, data.glo$Rescue, pch = 19, col = "black", ylim = c(0, 1),
     xlab="Number of demes", ylab="Probability of rescue", cex.axis = 1.5, cex.lab =1.5)
points(data.loc$Demes, data.loc$Rescue, pch = 19, col = "gray60")
arrows(data.glo$Demes, data.glo$Rescue - data.glo$Error, 
       data.glo$Demes, data.glo$Rescue + data.glo$Error, 
       length=0.05, angle=90, code=3, col = "black")
arrows(data.loc$Demes, data.loc$Rescue - data.loc$Error, 
       data.loc$Demes, data.loc$Rescue + data.loc$Error, 
       length=0.05, angle=90, code=3, col = "gray60")
grid()
legend("topleft", c("stepping stone", "island"), pch=c(19, 19), col = c("black", "gray60"), 
       cex=1.5, bty="n")
# calculate expectation
#calculate pres
Pres.dn.deme <- u*z*K/(d*r)
u = 1/20000
z = 0.02
r = 0.5
K = 20000
s = 1.0
d <- 2:18
Pres.sgv.deme <- u*z*K/(d*s)
Pres.tot <- 1 - ((1-Pres.dn.deme)*(1-Pres.sgv.deme))^d
lines(d, Pres.tot, lty=2, col="red",lwd=2)

TwoDemes <- read.table("./Simulations/Benchmark_2demes.txt", header=T)

mTheory <- seq(1e-4, 0.5, by = 1e-4)
zTheory <- 0.02
sTheory <- 1.0
rTheory <- 0.9
PresTheory <- theoretical.formula(mTheory, zTheory, sTheory, rTheory, 500, 0.5, T)

par.loc <- (TwoDemes$isGlobal==0.0 & TwoDemes$s == sTheory & TwoDemes$z == zTheory & TwoDemes$r == rTheory)
ER.loc <- TwoDemes[par.loc, ]
ER.loc <- ER.loc[-(17:20), ]
par.glo <- (TwoDemes$isGlobal==1.0 & TwoDemes$s == sTheory & TwoDemes$z == zTheory & TwoDemes$r == rTheory)
ER.glo <- TwoDemes[par.glo, ]
ER.glo <- ER.glo[-(17:20), ]

setEPS()
postscript("2Demes_s1.0_r0.9_th500.eps", width=7, height=5)
plot(ER.loc$migration, ER.loc$Rescue, pch = 19, ylim = c(0, 1.0), log='x',
     xlab="Number of demes", ylab="Probability of rescue", col="gray60",
     cex.axis = 1.5, cex.lab =1.5)
points(ER.glo$migration, ER.glo$Rescue, pch = 19, col="black")
lines(mTheory, PresTheory, lty=2, col="red")
grid()
legend("topleft", c("Island model", "Stepping stone model", "Tomasini&Peischl, 2020"),
       pch=c(19, 19, NA), lty=c(NA, NA, 2), col = c("black", "gray60", "red"), 
       cex=1.5, bty="n")
dev.off()
