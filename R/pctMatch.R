#' Percent Identical Feature Values
#'
#' Measures the Percent of Identical Feature Values (PIFV) between the “sifted” record and the original record.
#'
#' @param originaldata Original data frame.
#'
#' @param sifteddata Output data frame from DataSifter.
#' @return Returns a list of percentages for all rows.
#' 
#' @importFrom missForest missForest
#' @export
#' 
#' 
pctMatch <- function(originaldata,sifteddata){
  pctmatch <- sapply(1:nrow(originaldata),FUN = function(casenum) {
    length(which(as.character(originaldata[casenum,])==as.character(sifteddata[casenum,])))/(ncol(originaldata))
    })
  return(pctmatch)
}
