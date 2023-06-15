# function to automatically find and extract all buffer zones around specific clasts
# the clasts need to be identified beforehand using any kind of clustering

# one input variable needs to be set:
# 'map_of_all_clasts': a dataframe containing the 2D-map of the clustered data
#                      the relevant clusts must have the value 1, all other points the value 0

# output is a list that contains three entries:
# the first entry contains the list 'onlyBufferZone_list', which includes a list in which every entry displays the dataframe of an individual buffer zone
# the second entry contains the list 'SpatialonlyBufferZone_list', in which every entry displays the same information, but in the form of a raster layer
# the third entry contains the dataframe 'completeArea', which displays all buffer zones in a single dataframe

extract_buffer_zones <- function(map_of_all_clasts){
  
  # the 'clump' function from the package 'igraph' was used to separate the clast
  # the input must be in the form of a raster from the 'raster' package. the 
  clumpedClasts <- clump(raster(map_of_all_clasts))
  
  # extract the values of all individual clasts. Each clump (i.e. clast) has its own numerical value. 
  # This values is used to extract each individual clump during the loop
  all_clumps <- clumpedClasts@data@values
  
  # create lists in which the buffer zones are saved (one list for the raster format, one for R-based data frames)
  bufferedPolygonsSpatial <- list()
  bufferedPolygonsDataFrame <- list()
  
  # create buffer zones using a loop that iterates through each separated clast
  for(i in min(na.omit(all_clumps)):max(na.omit(all_clumps))){
    
    # extract positions of each clast individually with each iteration of the loop
    # the position of the targeted clast is save in the variable 'polygonToBuffer'
    polygonToBuffer <- which(all_clumps == i)
    
    # since the position of the targeted clast is saved as it is in the initial data structure, a new dataframe is created
    # this dataframe is build using the initial structure
    #create empty data frame and fill the positions of the targeted clast with an arbitrary value (here 100000) 
    newRaster <- as.data.frame(matrix(NA,ncol(map_of_all_clasts)*nrow(map_of_all_clasts),1))
    newRaster[polygonToBuffer,1] <- 100000
    
    # use the function 'initialData_to_map' to convert the targeted clast into a 2D-map
    newSpatialRaster <- initialData_to_map(newRaster, nrow(map_of_all_clasts), ncol(map_of_all_clasts), 1)
    # extract the raster layer that contains the targeted class (the remaining pixels are filled with NA values)
    rasterWithPolygon <- newSpatialRaster[[2]]
    
    # automatically extract the outermost pixels of the clast using the raster function 'boundaries'
    newBoundary <- boundaries(rasterWithPolygon[[1]], type="outer", classes=TRUE, direction=4)
    
    # create buffer zone around the boundary pixels of the clast using the raster function 'buffer'
    # width indicates the number of buffer pixels. In the paper, a single pixel was used as the buffer zone 
    # it is important to notice that the resulting raster layer contains the pixels of the clast and its buffer zone, not only pixels of the buffer zone
    newBuffer <- buffer(newBoundary, width=1, doEdge=FALSE)
    
    # save the resulting clast and its buffer zone in a list.
    # the first list contains the information in form of a dataframe
    # the second list contains the information in form of a raster layer
    bufferedPolygonsDataFrame[[i]] <- as.data.frame(newBuffer@data@values)
    bufferedPolygonsSpatial[[i]] <- newBuffer
  }
  
  # in the next step, only those pixels that belong to buffer zones are extracted 
  # thereto, the pixels beloning to the clasts were removed from the buffered area
  
  # this dataframe contains all clasts. Each class is represented by an individual numerical value
  toSubstractFromBufferZone <- as.data.frame(clumpedClasts)
  
  # create lists in which the result of every individual buffer zone is saved as an individual list entry
  SpatialonlyBufferZone_list <- list()
  onlyBufferZone_list <- list()
  
  # loop through entries of list. Each entry contains one clast plus its buffer zone 
  for(i in 1:length(bufferedPolygonsDataFrame)){
    
    # the dataframe 'toSubstractFromBufferZone' is used to extract the position of the targeted clast
    toSubstract <- which(toSubstractFromBufferZone==i)
    
    # the list with the raster layers is used to extract the position of the targeted clast plus its buffer zone 
    selectedBufferedPolygon <- bufferedPolygonsSpatial[[i]]
    
    # pixels belonging to the position of the clasts are set to NA
    # the resulting raster layer only contains the pixels of the specific buffer zone
    selectedBufferedPolygon@data@values[toSubstract] <- NA
    
    # list of every buffer zone as a raster layer. This can be plotted easily for validation purposes
    SpatialonlyBufferZone_list[[i]] <- selectedBufferedPolygon
    # list with every buffer zone as a data frame. 
    # this is used for the calculations of step 7 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)
    onlyBufferZone_list[[i]] <- as.data.frame(selectedBufferedPolygon)
  }
  
  list_with_buffer_zones <- list()
  list_with_buffer_zones[[1]] <- onlyBufferZone_list
  list_with_buffer_zones[[2]] <- SpatialonlyBufferZone_list 
  
  
  # this code is executed to create one dataframe that contains ALL buffer zones
  # after execution, completeArea contains all buffer zones
  completeArea <- bufferedPolygonsDataFrame[[1]]
  
  for(j in 1:length(bufferedPolygonsDataFrame)){
    idxBuffer <- which(bufferedPolygonsDataFrame[[j]]==1)
    completeArea[idxBuffer,1] <- 1
  }
  
  list_with_buffer_zones[[3]] <- completeArea
  
  return(list_with_buffer_zones)
} 

