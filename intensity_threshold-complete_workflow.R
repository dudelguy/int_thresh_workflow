##############################################################################################################

# load the packages required for the script

library(raster)
library(class)
library(clusterCrit)


##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

# load the dataset to be investigated and save it to the variable 'normalized_intensities'
# the dataset should be prepared as described in steps 1-3 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)
# the relevant element intensities of the LIBS spectra should be normalized.
# each row of the dataset should represent one measurement point
# each column should contain the normalized intensity value of the specific spectral position 

#                   ____________________________________________________________________________
##                 |          | element line 1 | element line 2 |...|...|...|...|...|...|...    |
##                 |____________________________________________________________________________|
##                 |   point1 |    intensity   |    intensity   |___|___|___|___|___|___|___    |
##                 |   point2 |    intensity   |    intensity   |___|___|___|___|___|___|___    |
##                 |     ...  |       ...      |       ...      |___|___|___|___|___|___|___    |
##                 |     ...  |       ...      |       ...      |___|___|___|___|___|___|___    |
#                   ____________________________________________________________________________



normalized_intensities <- read.table() 


##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

# code to execute step 4 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)

# set a seed to enable reproducability. 
# the three seeds 42, 1312 and 23 were used for the three individual runs performed for the paper
# this code shows the first run with seed 42
set.seed <- 42

# randomly draw 40000 individual measurement points from the complete data set 
# these samples are used to define the optimal number of cluster centers with the PBM-Index and can be adjusted according to the underlying data
bootstrapedIndex <- sample(c(1:nrow(normalized_intensities)), 40000, replace=FALSE)

# subset the complete dataset with the randomly drawn points  
bootstrapedPixel <- normalized_intensities[bootstrapedIndex,]
  
# use k-means on the subset with a varying number of 1 to 15 cluster centers 
# optimal number of cluster centers is then defined using the PBM-Index
# the calculated models are saved in a list.
# after the optimal number of cluster centers is determined, the model with best results can be extracted from the list
kmeansModel <- list()

# the results for kmeans with 15 different cluster centres are saved in a dataframe
# this dataframe is used to calucalte the PBM-Index for every cluster center investigated
kmeansCluster <- as.data.frame(matrix(NA,nrow(bootstrapedPixel),15))

# loop to calulcate k-means wit 1 to 15 cluster centers
# the results are saved in the formerly defined list/the dataframe
for(i in 1:15){
  # nstart and iter.max can be varied. Here, they are set to the values used in the paper.
  kmeansModel[[i]] <- kmeans(bootstrapedPixel, i, nstart=10, iter.max = 200, algorithm="MacQueen")
  kmeansCluster[,i] <- kmeansModel[[i]]$cluster
}

# 'intCriteria' from the package 'clusterCrit' was used to calculate the PBM-Index for the 15 different k-means models
# the values of the PBM-Index are saved in 'intCritPBM'
intCritPBM <- c()
bootstrapedPixel_asNumeric <- apply(bootstrapedPixel,2,as.numeric)
for(i in 1:15){
  intCritPBM[i] <- intCriteria(bootstrapedPixel_asNumeric,kmeansCluster[,i], "PBM")
}

# in the next step, intCritPBM can be used to find the optimal number of cluster centers, according to the PBM-Index
# information on how to interpret this index can be found in the documentation of the package 'clusterCrit'
# afterwards, the model with optimal results can be retrieved from the list and saved in a new variable for further use
kmeansBestCluster <- kmeansModel[[3]]$centers

# the optimal number of cluster centers was calculated with a subset of 40 000 measurement points, 
# due to computing power of the PC (calucalting the criteria is time consuming),
# the results of this model were extended onto the complete sample by using the k-nearest-neighbor algorithm
knn_fitRemainingData <- normalized_intensities[-bootstrapedIndex,]
knnPredicted <- knn(kmeansBestCluster, knn_fitRemainingData, c(1:nrow(kmeansBestCluster)), k=1)

# to observe the results, they can be saved in a dataframe
knn_results <- as.data.frame(matrix(,nrow(normalized_intensities),1))
knn_results[as.numeric(rownames(bootstrapedPixel)),] <- kmeansModel[[3]]$cluster
knn_results[-bootstrapedIndex,] <- as.integer(knnPredicted)


##############################################################################################################
##############################################################################################################
##############################################################################################################

# if you already know the optimal number of cluster centers for your problem, you can start here

# in our case, three cluster centers showed optimal results and the complete data set was clustered accordingly 
kmeans_results <- kmeans(normalized_intensities, 3, nstart=10, iter.max = 200, algorithm="MacQueen")
kmeans_results <- kmeans_results$cluster

# due to the structure of the input data, the clustered data does not display the 2D-map directly
# for the following image analysis, the data therefore needs to be converted accordingly
# this can be done in R or externally
# now, every entry of the data frame should represent the posisiont of the pixel that was measured in the spatial LIBS measurement
# here, the self-made function 'initialData_to_map' is used

lengthMap <- #must be filled according to the pixel length of the 2D map 
hightMap <-  #must be filled according to the pixel hight of the 2D map  

kmeans_results_2D <- initialData_to_map(kmeans_results,lengthMap,hightMap,1)

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

# code to execute step 5 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)

# to reduce pixel variety for all the classes, the function 'majority_filter' is applied
# it determines the major cluster class of the defined moving window 
# the size of the window can be adjusted, here, the window size that was applied in the paper was used
movingWindow <- majority_filter(as.data.frame(kmeans_results_2D),5,5)


##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

# code to execute step 6 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)

# 1. calculate buffer zones for Ca-rich clasts 
clastsCa <- movingWindow

# to calculate buffer zone for Ca-rich clasts, a new matrix is set, in which all points of this class are labelled '1'
# the remaining points get the label '0'
# the k-means clustering with three cluster centers (i.e. 3 labels) assigned label 2 to the Ca-rich clasts
# this might differ and needs to be validated using the optical image or LIBS emission lines for e.g. Ca
# after verification, all pixel with label 2 are changed to label 1, pixels with label 1 or 3 are assigned the label 0
clastsCa[which(as.numeric(movingWindow)==2)] <- 1
clastsCa[which(movingWindow==3)] <- 0
clastsCa[which(movingWindow==1)] <- 0


# the function 'extract_buffer_zones' is used to find the pixels that belong to every buffer zone around Ca-rich clasts
buffer_zones_ca <- extract_buffer_zones(clastsCa)

####################################################################################
# 2. calculate buffer zones for Si-rich clasts 
# to calculate buffer zone for Si-rich clasts, a new matrix is set, in which all points of this class are labelled '1'
# the remaining points get the label '0'
# the k-means clustering with three cluster centres (i.e. 3 labels) assigned label 3 to the Si-rich clasts
# this might differ and needs to be validated using the optical image or LIBS emission lines for e.g. Si
# after verification, all pixel with label 3 are changed to label 1, pixels with label 1 or 2 are assigned the label 0

clastsSi <- movingWindow

clastsSi[which(movingWindow==3)] <- 1
clastsSi[which(movingWindow==2)] <- 0
clastsSi[which(movingWindow==1)] <- 0

# the function 'extract_buffer_zones' is used to find the pixels that belong to every buffer zone around Si-rich clasts
buffer_zones_si <- extract_buffer_zones(clastsSi)


# in a next step, the intensity information of all pixels that belong to buffer zones is extracted

# for Ca-rich clasts

# create empty dataframe to save the intensities in
intValues_bufferZones_Ca <- as.data.frame(matrix(NA,nrow(normalized_intensities),ncol(normalized_intensities)))
colnames(intValues_bufferZones_Ca) <- colnames(normalized_intensities)

# fill dataframe with intensity values by looping through the positions of each individual buffer zone
for(i in 1:length(buffer_zones_ca[[1]])){
  intValues_bufferZones_Ca[which(buffer_zones_ca[[1]][[i]]==1),] <- normalized_intensities[which(buffer_zones_ca[[1]][[i]]==1),]
}

intValues_bufferZones_Ca <- na.omit(intValues_bufferZones_Ca)


# for Si-rich clasts

# create empty dataframe to save the intensities in
intValues_bufferZones_Si <- as.data.frame(matrix(NA,nrow(normalized_intensities),ncol(normalized_intensities)))
colnames(intValues_bufferZones_Si) <- colnames(normalized_intensities)

# fill dataframe with intensity values by looping through the positions of each individual buffer zone
for(i in 1:length(buffer_zones_si[[1]])){
  intValues_bufferZones_Si[which(buffer_zones_si[[1]][[i]]==1),] <- normalized_intensities[which(buffer_zones_si[[1]][[i]]==1),]
}

intValues_bufferZones_Si <- na.omit(intValues_bufferZones_Si)


##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

# code to execute step 7 of section 2.3 of Müller, Meima & Rammlmair 2021 (https://doi.org/10.1016/j.gexplo.2020.106697)

# combine buffer zones of Ca- and Si-rich clasts in a single data frame
# buffer zones might overlap, accordingly, the overlapping pixels are removed 
# this dataframe is used to compute the statistics for all buffer pixel, which was in turn used to remove buffer zones with enriched intensities in La
allPixelAroundRims <- rbind(intValues_bufferZones_Ca[-which(as.integer(rownames(intValues_bufferZones_Ca)) %in% as.integer(rownames(intValues_bufferZones_Si))==TRUE),],intValues_bufferZones_Si)


# only buffer zones that do not include pixels with La intensities above median+3*mad are used to calculate the threshold
# median and mad are based on all pixels that belong to buffer zones. The corresponding dataframe 'allPixelAroundRims' was created one step earlier

# calculate the statistics. Buffer zones that include pixels with La intensities above median+3*mad will be excluded for threshold calculation
mad_of_bufferZones <- apply(allPixelAroundRims, 2, mad)
median_of_bufferZones <- apply(allPixelAroundRims, 2, median)
thresh_for_bufferZones <- median_of_bufferZones + 3*mad_of_bufferZones

# loop through the list with all buffer zones 
# buffer zones with pixels that show La intensities above median+3*mad will not be saved in the new list 

# only investigate the relevant La lines. Create array of numerical values that correspond to the La-intensity columns of the initial data 
la_lines <- c()

# for buffer zones around Ca-rich clasts
# use function 'rims_not_enriched' to get a list of all buffer zones not enriched in La 
rimsWithoutExcitation_Ca <- rims_not_enriched(buffer_zones_ca[[1]],thresh_for_bufferZones,normalized_intensities,la_lines)

# for buffer zones around Si-rich clasts
# use function 'rims_not_enriched' to get a list of all buffer zones not enriched in La 
rimsWithoutExcitation_Si <- rims_not_enriched(buffer_zones_si[[1]],thresh_for_bufferZones,normalized_intensities,la_lines)

# combine the buffer zones of Ca- and Si-rich clasts into single list 
allRimsWithoutExcitation <- c(rimsWithoutExcitation_Si, rimsWithoutExcitation_Ca)

# convert this list of buffer zones into a single dataframe
# thereto, create an empty dataframe first
allPixelWithoutExcitation <- as.data.frame(matrix(NA,nrow(normalized_intensities),ncol(normalized_intensities)))
colnames(allPixelWithoutExcitation) <- colnames(normalized_intensities)

# loop through the list of all buffer zones and save the corresponding pixelw in the dataframe
for(i in 1:length(allRimsWithoutExcitation)){
  allPixelWithoutExcitation[which(allRimsWithoutExcitation[[i]]==1),] <- normalized_intensities[which(allRimsWithoutExcitation[[i]]==1),]
}
allPixelWithoutExcitation <- na.omit(allPixelWithoutExcitation)

# iterative use of the z-score to create normally distributed set of noise pixel
# this final set of pixels was used to calculate the intensity thresholds for La
# note that the workflow can be used for all kinds of intensity lines by simply adapting the variable 'la_lines'
set_for_thresh_calc <- list()

for(w in 1:length(la_lines)){
  
  # in the paper, the z-score was iteratively reduced from 10 to 3. This can be adapted, depending on the underlying data
  zScore_to_use <- c(10:3) 
  invest_element_lines <- allPixelWithoutExcitation[,la_lines[w]]
  
  # loop through the z-scores used for outlier detection
  for(i in 1:length(zScore_to_use)){
    # remove outliers iteratively
    # calculate statistics necessary for the z-score
    meanAllPixel_combined <- mean(invest_element_lines)
    sdAllPixel_combined <- sd(invest_element_lines)
    rawMinusMean <- invest_element_lines - meanAllPixel_combined
    
    # calculate the z-score
    zScore <- rawMinusMean/sdAllPixel_combined
    
    # identify pixels above the investigated z-score
    idx_outlier_zScore <- which(zScore>zScore_to_use[i] | zScore<(-zScore_to_use[i]))
  
    # if outliers are detected, remove them from the dataset
    if(length(idx_outlier_zScore)!=0){
      invest_element_lines <- invest_element_lines[-idx_outlier_zScore]
    }
  }
  # after iteratively removing enriched pixels, the results are saved in a list
  # in this list, every entry contains pixels not enriched in the specific element line
  elementDependantSamples_WthoutExcitation[[w]] <- invest_element_lines
}


# final intensity threshold calculation
int_threshold_final <- c()

# loop through the list with pixels not enriched in the investigated element intensity
# after the loop, this array contains the final intensity threshold for the investigated intensity lines
for(i in 1:length(elementDependantSamples_WthoutExcitation)){
  
  inv_elementLine <- elementDependantSamples_WthoutExcitation[[i]]
  
  # calulcate mean and sd for the specific element line
  mean_inv_elementLine <- mean(inv_elementLine)
  sd_inv_elementLine <- sd(inv_elementLine)
  
  # use mean + 3*sd to calculate the final intensity threshold
  # this threshold is based on normally distributed pixels withouht any enrichment in the investigated element line
  int_threshold_final[i] <- mean_inv_elementLine + 3* sd_inv_elementLine
}

