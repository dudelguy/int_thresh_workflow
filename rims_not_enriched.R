# function to automatically extract all buffer zones that do not include a any pixel enriched in the investigated element lines

# four input variables needed:
# 'list_with_buffer_zones': list in which each entry contains a dataframe of one buffer zone.
#                           this variable can be filled by the first list that is returned from the function 'extract_buffer_zones' 

# 'threshold': threshold above which a pixel is classified as enriched.
#              Median + 3*MAD is a good way to calculate the threshold, although it can have any numerical value

# 'initial_int_data': the initial dataframe, including the normalized intensity values of all relevant element emission lines of the LIBS spectra
# 'relevant_emLines': a selection of emission lines, for which the not enriched buffer zones should be extracted

# one output variable:
# 'rimsWithoutExcitation': a list in which every entry contains the dataframe of one buffer zone not enriched in the selected emission lines

rims_not_enriched <- function(list_with_buffer_zones, threshold, initial_int_data, relevant_emLines){
  
  # create new list to save only the rims not enriched in the investigated intensities
  rimsWithoutExcitation <- list()
  k <- 1
  
  # every rim with at least one pixel above that threshold is removed
  for(i in 1:length(list_with_buffer_zones)){
    # extract La intensity lines for the specific buffer zone
    intensities_of_bufZone <- initial_int_data[which(list_with_buffer_zones[[i]]==1),relevant_emLines]
    
    # check if at least one pixel of the buffer zone shows intensities above the wanted threshold
    # save the enriched pixels in the variable 'idxAboveLOD'
    idxAboveLOD <- c()
    for(j in 1:nrow(intensities_of_bufZone)){
      idxAboveLOD[j] <- any(intensities_of_bufZone[j,] > threshold[relevant_emLines])
    }
    
    # if 'idxAboveLOD' is empty, no enriched pixels were observed
    # if this is the case, save the specific buffer zone in the new list
    if(length(which(idxAboveLOD==TRUE)) == 0){
      rimsWithoutExcitation[[k]] <- list_with_buffer_zones[[i]]
      k <- k+1
    }
  }
  
  # return the list with all buffer zones not enriched in the wanted intensity lines
  return(rimsWithoutExcitation)
}
