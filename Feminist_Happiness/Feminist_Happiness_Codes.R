# Feminist Happiness: Models Run 
# Note: While code has been reorganized, it was one of my first instances of R coding and models run. Thus, portions of this project will be fairly disorganized. 

# Install Packages as needed 
install.packages("readr")
install.packages("Hmisc")
install.packages("stargazer")

# Load Libraries 
library(readr)
library(dplyr)
library(magrittr)
library(stargazer)
library(ggplot2)
library(plm)
require(foreign)
require(ggplot2)
require(MASS)
require(Hmisc)
require(reshape2)
library(VGAM)

# Other Functions Used 
# First Diff Model 
firstD <- function(var, group, df){
  bad <- (missing(group) & !missing(df))
  if (bad) stop("if df is specified then group must also be specified")
  
  fD <- function(j){ c(NA, diff(j)) }
  
  var.is.alone <- missing(group) & missing(df)
  
  if (var.is.alone) {
    return(fD(var))
  }
  if (missing(df)){
    V <- var
    G <- group
  }
  else{
    V <- df[, deparse(substitute(var))]
    G <- df[, deparse(substitute(group))]
  }
  
  G <- list(G)
  D.var <- by(V, G, fD)
  unlist(D.var)
}
# Data Normalization
normalized <- function(x, ...) {(x - min(x, ...)) / (max(x, ...) - min(x, ...))}
normalized<-function(y) {
  
  x<-y[!is.na(y)]
  
  x<-(x - min(x)) / (max(x) - min(x))
  
  y[!is.na(y)]<-x
  
  return(y)
}

# -----------------------------------------------------------------------------

# Load WVS R Data File - Time Series Data 
  # Womens' Equality Measure (Country to Country)  
ei <- readxl::read_xlsx("NationalWmnEquality.xlsx")

  # Time Series Data: World Values Survey - please unzip the zip file within this folder to use rdata. 
load('WVS_TimeSeries_R_v1_5.rdata')
wvstime <- WVS_TimeSeries_R_v1_5 %>% dplyr::rename(Country = S003)
rm(WVS_TimeSeries_R_v1_5)                            

# -----------------------------------------------------------------------------
# Remove NA etc. 
wvstime <- wvstime[wvstime$S002, ] # Remove NA Records - No Blank or NaN records within 'Happiness' Column 
wvstime[wvstime <= -1 ] <- NA # Remove NA Records - All Negative Number Responses in df are n/a or missing; removed for this project. 
wvspanel <- wvstime[wvstime$S002 %in% c(4,5,6), ]
wvspanel<- wvspanel[wvspanel$X001 %in% c(2), ]
wvspanel <- wvstime[wvstime$S001 %in% c(2), ]
wvspanel <- na.omit(wvspanel)

# Joing WVS Time and Equality Index 
wvstime <- dplyr::rename(wvstime,c('unsid'='S006'))
ei <- ei %>% dplyr::rename(Country = Label)
wvstime <- left_join(ei, wvstime, by = "Country")
wvstime <- rename(wvstime,c('gii'='Equality Index'))
wvstime$giipts<- wvstime$gii*100

# Setting High vs Low Gender Inequality with thresholds of 38.7 and 50 respectively. 
wvstime$giihilo[wvstime$giipts > 38.7]<-1
wvstime$giihilo[wvstime$giipts <= 38.7]<-0
wvstime$giihilo1[wvstime$giipts > 50]<-1
wvstime$giihilo1[wvstime$giipts <= 50]<-0

# Creating Binary Variable versions of existent likert scale variables (for logit models)
wvstime$satisfied <- wvstime$A170
wvstime$satnot[wvstime$satisfied >= 5]<-1
wvstime$satnot[wvstime$satisfied < 5]<-0

# Reverse Coding Happiness Variable 
wvstime$happy <- 5-wvstime$A008

# Recoding Variables

  # Dependent Variable: Happiness 
wvstime$happy1 <- scales::rescale(wvstime$happy, to=c(0,1)) # How happy are you (rescaled)
summary(wvstime$happy1) 

wvstime$satisfied1 <- scales::rescale(wvstime$satisfied, to=c(0,1)) # How satisfied are you (rescaled)
summary(wvstime$satisfied1) 

wvstime$happinesssc <- (wvstime$happy1 + wvstime$satisfied1)/2 # Composite Score (Happiness) 
summary(wvstime$happiness) 

cor(wvs6$happy1, wvs6$satisfied1,  method = "pearson", use = "complete.obs") # Pearson Correlation between happiness and satisfied 
# output: 0.454 - creates suspicion for ability to combine into one composite measure 

dv <- wvs6[c('happy','satisfied')]

  # Independent Variable 1: Democracy: Women have the same rights as men (10 Pt Likert)
wvstime$wmnsrts <- wvstime$E233 
summary(wvstime$C001)
wvstime$C001[wvstime$C001==1]<-4
wvstime$C001 <- wvstime$C001-1
wvstime$C001 <- 4-wvstime$C001

wvstime$D066_B[wvstime$D066_B==1]<-4
wvstime$D066_B <- wvstime$D066_B-1
wvstime$D066_B <- 4-wvstime$D066_B

  # Independent Variable 2: econeq1: men are more important to the economy 
wvstime$econeq1 <- (wvstime$C001+wvstime$D066_B)/2

  # Independent Variable 2: econeq1: men are more important to the economy 
wvstime$econeq2 <- (wvstime$D061+wvstime$D059+wvs6$D078)/3
  # Independent Variable 2: econeq1: men are more important to the economy (Recoded as binary)
wvstime$econeq3[wvstime$econeq2==1]<-0
wvstime$econeq3[wvstime$econeq2==2]<-0
wvstime$econeq3[wvstime$econeq2==3]<-1
wvstime$econeq3[wvstime$econeq2==4]<-1

  # Independent Variable 3: nowmnhome: Being a housewife is just as fulfilling as working for pay. (4 Scale Likert)
wvstime$nowmnhome <-wvstime$D057
wvstime$housewifeeq<-5-wvstime$nowmnhome

wvstime$incomescl <- wvstime$X047

  # Control 1: Economic Feminism: Women as Breadwinners 
wvstime$breadwin <- wvstime$X040
wvstime$breadwin[wvstime$breadwin==2]<-0
summary(wvstime$breadwin)

  # Control 2: Married 
  # Recoding 'Widowed' etc to ever been married 
wvstime$married[wvstime$X007==6]<-0
wvstime$married[wvstime$X007==5]<-1
wvstime$married[wvstime$X007==4]<-1
wvstime$married[wvstime$X007==2]<-1
wvstime$married[wvstime$X007==3]<-1 

# Age and Children Columns (Rename)
wvstime <- wvs %>% dplyr::rename(age = X003) %>% dplyr::rename(children = X011)

# Time Series Reduced to only Wave 6
wvs6 <- wvstime[wvstime$S002 %in% c(6), ]
wvs6 <- wvs6[wvs6$X001 %in% c(2), ]
controlvars <- wvs6[c('married','children','age','breadwin','incomescl','Equality Index')]
iv <- wvs6[c('menecon1','menecon2','wmnsrts','nowmnhome')]
iv <- na.omit(iv)

# Wave 6 Variable: Womens Rights (Squared) for Quadratic Term (for testing for fit) 
wvs6$wmnsrtssq<-wvs6$wmnsrts^2
wvs6$econeq2sq<-wvs6$econeq2^2

# Wave 6 Variable: Logged Economic Equality Term (for testing for fit) 
wvs6$econeqln <- log(wvs6$econeq2)

# -----------------------------------------------------------------------------

# Descriptive Statistics 
stargazer(controlvars, type = "text", title="Descriptive statistics", digits=1, out="table1.txt")
stargazer(iv, type = "text", title="Descriptive statistics", digits=1, out="table1.txt")
stargazer(dv, type = "text", title="Descriptive statistics", digits=1, out="table1.txt")


# Means and Tables 
predictrpurchase = predict(model,datatest)
table(datatest$rpurchase, predictrpurchase)
mean(as.character(datatest$rpurchase) != as.character(predictrpurchase))

# Visualize Gender Inequality Index as histogram; 20 breaks 
hist(wvs6$gii,breaks=20)
hist(wvs6$satisfied)

# -----------------------------------------------------------------------------

# Initial OLS Models 
lm1a <- lm(satisfied~econeq1+nowmnhome+wmnsrts, data=wvs6, 
           subset = !is.na(satisfied)&!is.na(econeq1)
           &!is.na(econeq2)&!is.na(nowmnhome)&!is.na(wmnsrts)&!is.na(happy))
lm1b <- lm(satisfied~econeq2+nowmnhome+wmnsrts, data=wvs6, 
           subset = !is.na(satisfied)&!is.na(econeq1)
           &!is.na(econeq2)&!is.na(nowmnhome)&!is.na(wmnsrts)&!is.na(happy))
lm2a <- lm(happy~econeq1+nowmnhome+wmnsrts, data=wvs6, 
           subset = !is.na(satisfied)&!is.na(econeq1)
           &!is.na(econeq2)&!is.na(nowmnhome)&!is.na(wmnsrts)&!is.na(happy))
lm2b <- lm(happy~econeq2+nowmnhome+wmnsrts, data=wvs6, 
           subset = !is.na(satisfied)&!is.na(econeq1)
           &!is.na(econeq2)&!is.na(nowmnhome)&!is.na(wmnsrts)&!is.na(happy))
# Visualize Initial OLS Models 
stargazer(lm1a, lm1b, lm2a, lm2b, title="Initial - Simple OLS Models", type='text',align=TRUE)


# Refined Model 1 - regression with controls 
lm3 <- lm(satisfied~econeq2+housewifeeq+wmnsrts+age+married+children+incomescl+giipts, data=wvs6, 
          subset = !is.na(satisfied)&!is.na(econeq1)
          &!is.na(econeq2)&!is.na(housewifeeq)&!is.na(wmnsrts)&!is.na(happy))
stargazer(lm3, title="Initial - Simple OLS Models", type='text',align=TRUE)


# Refined model 2 - regression with controls (setting Marriage as.factor bc all the categoreis are not in order )

lm4 <- lm(happiness~econeqln+wmnsrts+as.factor(X007)+incomescl+giipts, data=wvs6, 
          subset = !is.na(satisfied)&!is.na(econeq1)
          &!is.na(econeq2)&!is.na(housewifeeq)&!is.na(wmnsrts)&!is.na(happy))
stargazer(lm4, title="Initial - Simple OLS Models", type='text',align=TRUE)

# Same as above model
lm5 <- lm(satisfied~econeq2+wmnsrts+as.factor(X007)+incomescl+giipts, data=wvs6, 
          subset = !is.na(satisfied)&!is.na(econeq1)
          &!is.na(econeq2)&!is.na(housewifeeq)&!is.na(wmnsrts)&!is.na(happy))
stargazer(lm5, title="Initial - Simple OLS Models", type='text',align=TRUE)

# -----------------------------------------------------------------------------

# Correlation Matrix Construction 
to_correlate <- wvs6 %>% dplyr::select(age,children,married, incomescl, giipts) 
correlation.matrix <- cor(na.omit(wvs6[c("age","children","married", "incomescl","giipts")]))
stargazer(correlation.matrix, title="Correlation Matrix",type ='text' )

# -----------------------------------------------------------------------------

# Regressions with Interaction Term 
wvstime$agesq<-wvstime$age^2
lm7 <- lm(satisfied~econeq2+wmnsrts+age+incomescl+giihilo+econeq2:giihilo, data=wvs6, 
          subset = !is.na(satisfied)&!is.na(econeq1)
          &!is.na(econeq2)&!is.na(housewifeeq)&!is.na(wmnsrts)&!is.na(happy))
# Visualize lm7 for project paper  
stargazer(lm7, title="Initial - Simple OLS Models", type='text',align=TRUE)

lm8 <- lm(satisfied~econeq2+wmnsrts+age+incomescl+giipts, data=wvs6, 
          subset = !is.na(satisfied)&!is.na(econeq1)
          &!is.na(econeq2)&!is.na(housewifeeq)&!is.na(wmnsrts)&!is.na(happy))
stargazer(lm8, title="Initial - Simple OLS Models", type='text',align=TRUE)

# Logit 
logit1 <- glm(satnot ~ econeq2+wmnsrts+age+incomescl+giipts, data = wvs6, family = propodds,maxit = 100)
logit1 = glm(depressbi ~ firstgen + safeatschool+fmlyroutine, data=nls, family=binomial)
summary(logit1)

# Ordinal logit 
vglm1 <- vglm(satisfied ~ econeq2+wmnsrts+age+incomescl+giipts, data = wvs6, family = propodds)
summary(vglm1)

# Ordered Logit - Satisfied vs. Economic Equality + Womens Rights + GII + Income (Scale)
model <- polr(as.factor(satisfied) ~ econeq2+wmnsrts+age+incomescl+giipts, data = wvs6, Hess = TRUE)

# Attempted to run Panel Data - First Differences 
plm1 <- plm(satisfied~econeq2+wmnsrts+age+incomescl+giipts, index = c("S007","S002"),
            model="fd", data=wvspanel, subset = !is.na(satisfied)&!is.na(age)
            &!is.na(econeq2)&!is.na(incomescl)&!is.na(giipts)&!is.na(wmnsrts))
summary(plm1)

plm2 <- plm(polhitok~sei+as.factor(race)+sex+year, index = c("idnum", "panelwave"), 
            model="fd", data=gsspanel, 
            subset = !is.na(polhitok)&!is.na(race)&!is.na(sex))