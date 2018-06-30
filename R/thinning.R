#' Thinning the Original Data
#'
#'Delete features in the original data with a majority of data missing.
#'
#' @param data Original dataset
#'
#' @param col_preserve The maximum percentage of number of columns can be deleted due to massive missingness.
#'
#' @param col_pct Criterion for column deletion due to massive missingness. If missing percentage is larger than this threshold, delete the corresponding column.
#'
#' @return Returns a list of two elements. "data.new" Returns data after deleting non-informative columns. "misscol" Returns olumns deleted by the procedure.
#'
#' @export
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
