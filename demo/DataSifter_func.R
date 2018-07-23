### DataSifter small application
library(DataSifter.lite)
#Generate original data
set.seed(1234)
x1<-runif(1000)
x2<-runif(1000) 
x3<-runif(1000)
x4<-runif(1000)
x5<-runif(1000)

data1<-data.frame(x_1=x1,x_2=x2,x_3=x3,x_4=x4,x_5=x5)
data1$y=1+x1+x2-0.5*x3-2*x4+0.5*x5

#Generate "sifted" data with "medium" level of obfuscation
sifteddata <- dataSifter(level = "medium",data=data1,nomissing = TRUE)

#Calculate Percent Identical Feature Values(PIFV)
PIFV <- pctMatch(data1,sifteddata)
summary(PIFV)

#Linear model for testing data utility
model <- lm(y~x1+x2+x3+x4+x5,data = sifteddata)
summary(model)$coefficients

