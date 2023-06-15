# int_thresh_workflow

This repository contains the code associated to steps 4 to 7 described in section 2.3 in 'Müller, Meima and Rammlmair 2021, Detecting REE-rich areas in heterogeneous drill cores from Storkwitz using LIBS and a combination of k-means clustering and spatial raster analysis, J. Geochem. Explor. 221, 106697' (https://doi.org/10.1016/j.gexplo.2020.106697).

<br />
<p align="center">
<img width="638" alt="Screenshot 2023-06-15 143412" src="https://github.com/dudelguy/int_thresh_workflow/assets/130980491/e6729d5f-e5ed-4721-84e7-59e1ac4f736c">
</p>
<br />

The paper describes an automated workflow to create intensity limits for specific La emission lines extracted from LIBS spectra, above which the occurence of REE-bearing minerals can be verified.  
The workflow covers the separation of large Si- and Ca-bearing clasts and rock matrix using k-means clustering on LIBS spectra. Afterwards, buffer zones around the clasts are computed and their corresponding intensity values are processed to automatically create a matrix-matched data set, which contains only pixel without La enrichment. This data set is then used to calculate the intensity thresholds for the extracted La emission lines.
More detailed information can be found in the paper. The code was developed at the Federal Institute of Geosciences and Natural Resources of Germany (BGR) as part of the project GeoLIBScanner, which was funded by the German Federal Ministry for Economic Affairs and Energy (Grant Nr. ZF4441001SA7). 
After small adaptations, the provided code should be applicable for similar problems occuring in the geological LIBS community.

The provided files contain the complete workflow of the steps 4-7 of section 2.3. A short description of each file is found below, a more detailed description can be found in the documentation of the individual files. 

### intensity threshold - complete workflow
This file contains the complete workflow of the steps 4-7 of section 2.3. To be able to run the code, four separate functions need to be loaded. They are provided in additional the additional files of this repository.
Input for the complete workflow are the measured LIBS spectra, which should be processed as described in steps 1-3 of section 2.3. The element specific emission lines need to be extracted with peak integration, normalized and stored in a data frame, in which every row contains the information of one measurement point and every column contains the normalized emission intensity of the specific element line. Several variables need to be set depending on the investigated data set.

### 1. Function: 
In this function, OC-SVM - tuning is applied to each investigated mineral class individually. The results are combined and measurement points that are assigned to multiple classes are labelled according to the smallest euclidean distance of the related class centers. 
The function returns a data frame that includes the class labels of every investigated measurement point. Unknown data points are labelled accordingly.

### 2. Function: 
This function includes the final classification workflow as described in the paper. First, the training and unknown data are tranformed into the LDA-space using the LDA algorithm implemented in the 'MASS' package, afterwards, the two other functions are called. If necessary, self-learning can be used to iteratively increase the initial train set with the newly labelled data. The euclidean distance of newly labelled point to its associated class center can be used to adapt the number of newly labelled data points included in each self-learning iteration. 
The function returns the final classification result, as well as the result after every iteration of self-learning. This can be used to evaluate the self-learning process and find the optimal number of iterations. 

### 3. Function: 

### 4. Function: 

