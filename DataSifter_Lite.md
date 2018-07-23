DataSifter Lite Version Guide
================
Nina Zhou
6/30/2018

Installation
============

Installation and loading the package can be done using following codes.

``` r
require(devtools)
install_github("SOCR/DataSifter")
library(DataSifter.lite)
```

Generate original and "sifted" data
===================================

Here we show a small example to share synthetic data with DataSifter. We generate 5 predictors that follows uniform distribution and a corresponding outcome variable.

``` r
set.seed(1234)
x1<-runif(1000)
x2<-runif(1000) 
x3<-runif(1000)
x4<-runif(1000)
x5<-runif(1000)

data1<-data.frame(x_1=x1,x_2=x2,x_3=x3,x_4=x4,x_5=x5)
data1$y=1+x1+x2-0.5*x3-2*x4+0.5*x5
```

Then, proceed to generate synthetic datasets under different levels of obfuscations. Note that under the "indep" level, DataSifter creates each variable independently from their empirical distribution in the original data.

``` r
set.seed(1234)
siftedata_s<-DataSifter.lite::dataSifter(level = "small",data=data1,nomissing = TRUE)
```

    ##   missForest iteration 1 in progress...done!
    ## [1] "Artifical missingness and imputation done"
    ## [1] "Obfuscation step done"

``` r
siftedata_m<-DataSifter.lite::dataSifter(level = "medium",data=data1,nomissing = TRUE)
```

    ##   missForest iteration 1 in progress...done!
    ##   missForest iteration 1 in progress...done!
    ## [1] "Artifical missingness and imputation done"
    ## [1] "Obfuscation step done"

``` r
siftedata_l<-DataSifter.lite::dataSifter(level = "large",data=data1,nomissing = TRUE)
```

    ##   missForest iteration 1 in progress...done!
    ##   missForest iteration 1 in progress...done!
    ##   missForest iteration 1 in progress...done!
    ##   missForest iteration 1 in progress...done!
    ##   missForest iteration 1 in progress...done!
    ## [1] "Artifical missingness and imputation done"
    ## [1] "Obfuscation step done"

``` r
siftedata_i<-DataSifter.lite::dataSifter(level = "indep",data=data1,nomissing = TRUE)
```

We utilize the `pctMatch()` to examine privacy protection ability. `pctMatch()` compares each record in the original and "sifted" data and outputs a list of Percent of Identical Feature Values (PIFV) for all records.

``` r
PIFV_s <- DataSifter.lite::pctMatch(data1,siftedata_s)
PIFV_m <- DataSifter.lite::pctMatch(data1,siftedata_m)
PIFV_l <- DataSifter.lite::pctMatch(data1,siftedata_l)
PIFV_i <- DataSifter.lite::pctMatch(data1,siftedata_i)
```

Let's visualize the results.

``` r
library(ggplot2)
PIFV <- data.frame(Levels=rep(c("small","medium","large","indep"),each=1000),
                 PIFVs=c(PIFV_s,PIFV_m,PIFV_l,PIFV_i))
PIFV$Levels <- factor(PIFV$Levels,levels=c("small","medium","large","indep"))

ggplot(data = PIFV,aes(x=Levels,y=PIFVs,fill=Levels))+
      geom_boxplot()+
      scale_fill_brewer(palette="RdBu")+
      ggtitle("PIFVs under different levels of obfuscations")
```

![](DataSifter_Lite_files/figure-markdown_github/PIFV%20boxplots-1.png)

As shown in the box plots, there is an increasing effect of privacy protection for higher levels of obfuscations.

Let's fit linear models to investigate the preservation of the original joint distribution.

``` r
original<-lm(y~x1+x2+x3+x4+x5,data = data1)
sum_o <- summary(original)$coefficients

small <- lm(y~x1+x2+x3+x4+x5,data = siftedata_s)
sum_s <- summary(small)$coefficients

medium <- lm(y~x1+x2+x3+x4+x5,data = siftedata_m)
sum_m <- summary(medium)$coefficients

large <- lm(y~x1+x2+x3+x4+x5,data = siftedata_l) 
sum_l <- summary(large)$coefficients

indep <- lm(y~x1+x2+x3+x4+x5,data = siftedata_i)
sum_i <- summary(indep)$coefficients

summary_models <- cbind.data.frame(sum_o[,1],sum_s[,1],sum_m[,1],sum_l[,1],sum_i[,1])
colnames(summary_models) <- c("Original","Small","Medium","Large","Indep")
library(knitr)
kable(summary_models)
```

|             |  Original|       Small|      Medium|       Large|       Indep|
|-------------|---------:|-----------:|-----------:|-----------:|-----------:|
| (Intercept) |       1.0|   0.9975797|   1.0408885|   0.9892373|   1.0906277|
| x1          |       1.0|   0.9881577|   0.7816077|   0.4263463|   0.0222831|
| x2          |       1.0|   0.9933017|   0.8128473|   0.4858206|  -0.0498579|
| x3          |      -0.5|  -0.4838077|  -0.3934999|  -0.2813201|  -0.0492461|
| x4          |      -2.0|  -1.9772400|  -1.6615458|  -0.8582042|  -0.1655056|
| x5          |       0.5|   0.4860466|   0.3552303|   0.2478866|   0.1099275|

The original data utility measured by the linear model is diminishing when level of obfuscation is higher. Overall, under the "medium" level of obfuscation, we can achieve a good balance between patient privacy and data utility.
