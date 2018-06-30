
#1 sifter
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


#2.imputation

firstImp<-function(sepdata,maxiter=1){
  K<-missForest(sepdata,maxiter=maxiter)$ximp
  return(K)
}

#3. subjdist
subjdist<-function(completedata){
  numcols <- 1:ncol(completedata)
  numdist <- as.dist(wordspace::dist.matrix(as.matrix(completedata[,numcols]),method="euclidean"))#include the scale before calculating it
  numdist<-(numdist-min(numdist))/(max(numdist)-min(numdist))#scale to 0-1
  comb_subjects = combn(1:nrow(completedata), 2)
  b = rbind(comb_subjects, numdist)
  subjDist = data.frame(t(b))
  names(subjDist) = c("Case_j", "Case_i", "Distance")
  subjDist_sorted <- subjDist[order(subjDist$Distance), ]
  return(subjDist_sorted)
}

#4. thinning
thinning<-function(data,col_preserve=.5,col_pct=.7){
#Preprocessing Delete features that are 70% or more missing under col_preserve
  leastcol=floor(col_preserve*ncol(data))
  misscol<-which(apply(data,2,function(x) sum(is.na(x))/nrow(data))>=col_pct)
  ordered.misscolpct<-sort(apply(data,2,function(x) sum(is.na(x))/nrow(data)),decreasing = TRUE,na.last = TRUE)
  
  if(length(misscol)==0){
    data.new<-data
  } else if(length(misscol)<=leastcol ) {
    data.new<-data[,-misscol]
  } else if(length(misscol)>leastcol){
    misscol<-which(apply(data,2, function(x) sum(is.na(x))/nrow(data))>=ordered.misscolpct[leastcol])
    data.new<-data[,-misscol]
  }
  return(list(data.new,misscol))# output=deleted data[[1]], deleted missing cols[[2]], deleted missing rows[[3]]
}


