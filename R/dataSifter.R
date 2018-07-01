#' Data Sifter Algorithm
#'
#' Create a informative privacy-preserving dataset that guarantees subjects' privacy while preserving the information contained in the original dataset.
#'
#' @param level Takes a value among ("none","small","medium","large","indep"). The user-defined level of obfuscation for the data sifter algorithm. Greater value represents higher level of obfuscation. The default value is "indep" with most obfuscation, which produces independent variables that follows the imperical distribution of the original data.
#'
#' @param data Original data to be processed.
#'
#' @param subjID Vector of characters indicating the variables for subject ID. These variables will be removed for privacy protection.
#'
#' @param col_preserve The maximum percentage of number of columns can be deleted due to massive missingness.
#'
#' @param col_pct Criterion for column deletion due to massive missingness. If missing percentage is larger than this threshold, delete the corresponding column.
#'
#' @param nomissing Indicator of missing in the original dataset. If nomissing=TRUE, there are no missing in the original data.
#'
#' @return Return sifted dataset.
#'
#' @import methods missForest Matrix plyr dplyr wordspace
#' 
#' @importFrom magrittr "%>%"
#' 
#' @details When level="indep" each variable in the sifted dataset is independently generated from their empirical distribution from the original data.
#' On the other hand, level="none" returns the original dataset. When some factors contain a level with empty value " ", it will likely to present "out of bounds" error.
#'
#' The process could take a while to run with large datasets. There will be two messages indicating the progress of the process. They are Artifical missingness and imputation done",
#' and "Obfuscation step done".
#' @export
dataSifter<-function(level="indep",data,subjID=NULL,col_preserve = 0.5, col_pct = 0.7,
                     nomissing=FALSE,maxiter=1){
  if(!is.null(subjID))data<-data[,-which(names(data) %in%subjID)]
  originaldatacolnames<-colnames(data)

  #Thinning step
  data<-thinning(data,col_preserve, col_pct)[[1]]
  #Do imputation
  if(nomissing==FALSE){
    #First imputation
    data.imp<-firstImp(data,maxiter=maxiter)
  }

  #Calculate distance
  subjDist_sorted<-subjdist(data)

  if(level=="none"){
    print("No Obfuscation")
    return(data)
  }else if (level=="indep"){
    rownumb<-nrow(data)
    colnumb<-ncol(data)
    listnum<-which(sapply(data, is.numeric) == TRUE)
    #Estimate num densities
    vardens<-lapply(data[,listnum],density)#create empirical distribution list
    siftedData<-data.frame(plyr::llply(.data=vardens,.fun=function(k) {
      sample(x=k$x,size =rownumb,prob=k$y/sum(k$y),replace=T)}))
    siftedData<-siftedData[,originaldatacolnames]
    return(siftedData)
  } else{
    if(level=="small"){
      k0=1;k1=0.05;k2=1;k3=0.1;k4=0.01
    }else if(level=="medium"){
      k0=0;k1=0.25;k2=2;k3=0.6;k4=0.05
    }else if(level=="large"){
      k0=0;k1=0.4;k2=5;k3=0.8;k4=0.2
    }else{
      stop("Invalid level of obfuscation.")
    }
    data_k0 <- data
    #Imputation step
    if (k1 == 0) {
      print("No imputation necessary, imputation step skipped")
      data_k2 <- data_k0
    } else {
      C <- data_k0
      for (j in 1:k2) {
        C <- missForest::prodNA(C, noNA = k1)#introduce NA values equal to k1%
        C<-firstImp(sepdata = C,maxiter=maxiter)
      }
      data_k2 <- C
    }
    print("Artifical missingness and imputation done")

    #Obfuscation step
    distmin<-min(subjDist_sorted$Distance)
    dist_cut<-sd(subjDist_sorted$Distance)
    cases_to_swap <- round(k4 * nrow(subjDist_sorted))
    list_feature_obfusc <- 1:ncol(data_k2)
    if (k3 == 0) {
      data.obfusc <- data_k2
    } else {
      data.obfusc <- data_k2
      D <- data_k2

      for (i in 1:nrow(data.obfusc)) {
        list_feature_obfusc <- sample(list_feature_obfusc, round(k3 * length(list_feature_obfusc)))# select features to obfuscate
        swap_subset <- subjDist_sorted %>% filter(Case_i==i|Case_j==i) %>% head(cases_to_swap) %>%
          filter(Distance<=(distmin+2*dist_cut))
        num_case<-ifelse(dim(swap_subset)[1]<cases_to_swap,dim(swap_subset)[1],cases_to_swap)
        if(num_case>0){
          swap_subset <- unique(c(swap_subset$Case_i,swap_subset$Case_j))
          swap_subset <- swap_subset[!swap_subset %in% i]
          case_to_swap <- sample(swap_subset, 1)
          b1 <- D[i, list_feature_obfusc]
          b2 <- D[case_to_swap, list_feature_obfusc]
          D[i, list_feature_obfusc] <- b2
          D[case_to_swap, list_feature_obfusc] <- b1
          data.obfusc[c(i, case_to_swap), list_feature_obfusc] <- D[c(i, case_to_swap), list_feature_obfusc]
        }
      }
    }
    print("Obfuscation step done")

    #return to orginal order of features
    data.obfusc<-data.obfusc[,originaldatacolnames]
    return(data.obfusc)
  }
}
