# this function is used to convert the initial structure of of the LIBS intensity data into stacks of 2D-maps

# several variables are needed as input
# 'initial_matrix': dataframe that has the initial structure of the LIBS intensity data set:
#                   each row of the data set should represent one measurement point
#                   each column should contain a LIBS intensity or a result after processing (i.e. the labels after clustering) 

#                   ____________________________________________________________________________
##                 |          | element line 1 | element line 2 |...|...|...|...|...|...|...    |
##                 |____________________________________________________________________________|
##                 |   point1 |    intensity   |    intensity   |___|___|___|___|___|___|___    |
##                 |   point2 |    intensity   |    intensity   |___|___|___|___|___|___|___    |
##                 |     ...  |       ...      |       ...      |___|___|___|___|___|___|___    |
##                 |     ...  |       ...      |       ...      |___|___|___|___|___|___|___    |
#                   ____________________________________________________________________________

# 'pixel_length': the length of the mapping in pixels (i.e. number of measurement points in x direction) 
# 'pixel_hight': the hight of the mapping in pixels (i.e. number of measurement points in y direction) 
# 'number_maps': the total number of maps to create (e.g. the number of element lines extracted from the spectra)

# output is a list with two lists. 
# in the first list, every list entry contains a dataframe representing the actual 2D-map of the data. 
# each entry of this dataframe corresponds to the measurement point at the same position of the sample
# in the second list, every entry contains a 2D-map of the data, but as a raster layer from the raster package.
# this is useful and necessary for several further processing steps, and, additionally, allows easy plotting of the data by simply using the plot function

initialData_to_map <- function(initial_matrix, pixel_length, pixel_hight, number_maps){
  
  # initialize list for output
  toReturn <- list()
  
  # load the Raster package. This is used for the transformation and much faster than the traditional approach without any package
  require(raster)
  
  # assign x and y values to each pixel. This is a necessary input for the function 'RasterLayer'
  x <- rep(seq(1, pixel_length, by = 1) , pixel_hight)
  y <- c()
  k <- 1
  
  for(i in pixel_hight:1){
    y[k:(k+pixel_length-1)] <- rep(i,pixel_length)
    k <- k+pixel_length
  }
  
  # combine x and y assignment with the data frame in the initial data structure
  forRaster <- cbind(x,y,initial_matrix)
  
  # variable used to save the raster layer for the ouput
  asRaster <- list()
  # variable used to save the dataframes containing the maps for the ouput
  forDataFrame <- list()
  
  # loop through the initial dataframe accoring to the amount of maps that should be created 
  for(i in 1:number_maps){
    # create variables with columns that are chosen from the variable 'forRaster' 
    # the first two columns contain x and y assignment used for the raster transformation, the following columns contain the data that is to be transformed into the 2D-maps 
    colToChoose <- c(1,2,(i+2))
    # convert chosen columns into raster layer and save in list
    asRaster[[i]] <- rasterFromXYZ(forRaster[,colToChoose])
    # convert raster layer into matrix and save in other list
    forDataFrame[[i]] <- raster::as.matrix(asRaster[[i]])
  }
  
  # add list with dataframes and list with raster layers to list
  toReturn[[1]] <- forDataFrame
  toReturn[[2]] <- asRaster
  
  # return the list that contains the two other lists
  return(toReturn)
}
