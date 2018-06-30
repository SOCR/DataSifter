#' Imputation
#'
#' Imputation using missForest package for the big data. This is to prepare for case distance calculation or impute the artificial missingness.
#'
#' @param sepdata A data frame with missing values.
#'
#' @param maxiter Max number of iterations for missForest imputation.
#' @return Returns imputed data.
#' @export
firstImp<-function(sepdata,maxiter=1){
  K<-missForest(sepdata,maxiter=maxiter)$ximp
  return(K)
}
