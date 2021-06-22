positive.value <- function(vector){
    for (i in 1:length(vector)){
        if(vector[i] < 0 ){
            vector[i] <- 0
        }
        else {
            next
        }
    }
    return(vector)
}

# formula for rescue from de novo in phase 1
p.dnm.1 <- function(m, z, s, r, theta, zeta){
    kappa <- 10000
    u <- 1/20000
    p.dnm <- positive.value(1-exp((u*(-((r + m*zeta)*(s^2 + s*z + m*s*(1 - zeta) + 2*m*z*(1 - zeta) - m*s*zeta - s*sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2))*
                                            theta) + ((m*(2*s + z)*zeta - z*(s + z + m*(1 - zeta) + sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2)))*
                                                          (r - m*(1 - zeta) + m*zeta - (r - m*(1 - zeta) + m*zeta)/exp((r + m*zeta)*theta) + m*(1 - zeta)*(r + m*zeta)*theta))/(r + m*zeta))*kappa)/
                                      ((r + m*zeta)*sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2))))
    
    return(p.dnm)
}

# formula for rescue from de novo in phase 2
p.dnm.2 <- function(m, z, s, r, theta, zeta){
    kappa <- 10000
    u <- 1/20000
    term.1 <- (-2*u*z*(r - m*(1 - zeta) + m*zeta + exp((r + m*zeta)*theta)*(r + m*(1 - zeta) + m*zeta))*kappa)
    term.2 <- exp((r + m*zeta)*theta)/(r*(r + m*zeta))
    p.res.inf <- positive.value(1-exp((-2*u*z*(r - m*(1 - zeta) + m*zeta + exp((r + m*zeta)*theta)*(r + m*(1 - zeta) + m*zeta))*kappa) / exp((r + m*zeta)*theta)/(r*(r + m*zeta))))
    
    return(p.res.inf)
}

p.sgv.1phase <- function(m, z, s, r, theta, zeta){
    kappa <- 10000
    u <- 1/20000
    p.res.sgv <- positive.value(1-(((s*sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2) - u*(s*(s + z) + m*(s + 2*z)*(1 - zeta) - m*s*zeta)*kappa +
                                         s*u*sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2)*kappa)*
                                        (-(u*z*(z + m*(1 - zeta) - m*zeta + sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2))*kappa) +
                                             s*(sqrt((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2) - u*z*kappa + 2*m*u*zeta*kappa)))/
                                       (s^2*((s + z + m*(1 - zeta))^2 + 2*m*(-s - z + m*(1 - zeta))*zeta + m^2*zeta^2))))
    
    return(p.res.sgv)
}

theoretical.formula <- function(m, z, s, r, theta, zeta, sgv){
    
    p.no.res.denovo <- (1-p.dnm.1(m, z, s, r, theta, zeta))*(1-p.dnm.2(m, z, s, r, theta, zeta))
    
    if(sgv == TRUE){
        ptot <- 1 - p.no.res.denovo*(1-p.sgv.1phase(m, z, s, r, theta, zeta))
    } 
    else{
        ptot <- 1 - p.no.res.denovo
    }
    
    return(ptot)
}