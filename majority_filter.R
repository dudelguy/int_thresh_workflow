# function applies a sliding window on the clustered image and changes the class of the central pixel to the major class of the investigated window

# three input parameter need to be set:
# 'matrix_to_filter': a matrix or data frame that contains the clustered 2D-image of the investigated sample
# 'xWindow': the hight of the applied window (in pixel). 
# 'yWindow': the length of the applied window (in pixel).
# if even, hight/length of the window will be 'xWindow/yWindow + 1', if uneven, hight/length will be 'xwindow/yWindow'
# this ensures a window of uneven size, so that the investigated pixel will always be in the center of the moving window

# one ouput variable:
# 'newMatrix': a matrix that contains the 2D-filtered image

majority_filter <- function(matrix_to_filter, xWindow, yWindow){
  xPixel <- floor(xWindow/2)
  yPixel <- floor(yWindow/2)
  
  newMatrix <- matrix(,nrow(matrix_to_filter), ncol(matrix_to_filter))
  
  for(i in 1:nrow(matrix_to_filter)){
    for(j in 1:ncol(matrix_to_filter)){
      
      # padding is used, therefore the different corners and border areas need to be calculated separately
      
      #corner top-left
      if(j<=yPixel & i<=xPixel){
        window <- as.matrix(matrix_to_filter[1:(i+xPixel),1:(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      #corner bottom-right
      if(j>(ncol(matrix_to_filter)-yPixel) & i>(nrow(matrix_to_filter)-xPixel)){
        window <- as.matrix(matrix_to_filter[xPixel:nrow(matrix_to_filter),yPixel:ncol(matrix_to_filter)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      #corner bottom-left
      if(j<=yPixel & i>(nrow(matrix_to_filter)-xPixel)){
        window <- as.matrix(matrix_to_filter[xPixel:nrow(matrix_to_filter),1:(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      #corner top-right
      if(j>(ncol(matrix_to_filter)-yPixel) & i<=xPixel){
        window <- as.matrix(matrix_to_filter[1:(i+xPixel),yPixel:ncol(matrix_to_filter)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      # rigth border
      if(i>(nrow(matrix_to_filter)-xPixel) & j>yPixel & j<=(ncol(matrix_to_filter)-yPixel)){
        window <- as.matrix(matrix_to_filter[xPixel:ncol(matrix_to_filter),(j-yPixel):(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      # bottom border
      if(j>(ncol(matrix_to_filter)-yPixel) & i>xPixel & i<=(nrow(matrix_to_filter)-xPixel)){
        window <- as.matrix(matrix_to_filter[(i-xPixel):(i+xPixel),j:(ncol(matrix_to_filter))])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      # top border
      if(i<=xPixel & j>yPixel & j<=(ncol(matrix_to_filter)-yPixel)){
        window <- as.matrix(matrix_to_filter[1:(i+xPixel),(j-yPixel):(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      # left border 
      if(j<=yPixel & i>xPixel & i<=(nrow(matrix_to_filter)-xPixel)){
        window <- as.matrix(matrix_to_filter[(i-xPixel):(i+xPixel),1:(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
      # normal area
      if(i>xPixel & j>yPixel & i<=(nrow(matrix_to_filter)-xPixel) & j<=(ncol(matrix_to_filter)-yPixel)){
        window <- as.matrix(matrix_to_filter[(i-xPixel):(i+xPixel),(j-yPixel):(j+yPixel)])
        mostCommonClass <- as.integer(names(which.max(table(window))))
        
        newMatrix[i,j] <- mostCommonClass
      }
      
    }
  }
  
  return(newMatrix)
}
