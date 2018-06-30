#' Subject Distance
#'
#' Calculates the Euclidian distance between two subjects based on their feature values.
#'
#' @param completedata A complete data frame without missing values.
#'
#' @return Return a dataframe that shows sorted between subject distances according to structured variables.
#' @export
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
