# int_thresh_workflow

This repository contains the code associated to steps 4 to 7 described in section 2.3 in 'Müller, Meima and Rammlmair 2021, Detecting REE-rich areas in heterogeneous drill cores from Storkwitz using LIBS and a combination of k-means clustering and spatial raster analysis, J. Geochem. Explor. 221, 106697' (https://doi.org/10.1016/j.gexplo.2020.106697).

<br />
<p align="center">
<img width="638" alt="Screenshot 2023-06-15 143412" src="https://github.com/dudelguy/int_thresh_workflow/assets/130980491/e6729d5f-e5ed-4721-84e7-59e1ac4f736c">
</p>
<br />

The paper describes an automated workflow to create intensity limits for specific La emission lines extracted from LIBS spectra, above which the occurence of REE-bearing minerals can be verified.  
The workflow covers the separation of large Si- and Ca-bearing clasts and rock matrix using k-means clustering on LIBS spectra. Afterwards, buffer zones around the clasts are computed and their corresponding intensity values are processed to automatically create a matrix-matched data set, which contains only pixel without La enrichment. This data set is then used to calculate the intensity thresholds for the extracted La emission lines.
More detailed information can be found in the paper. The code was developed at the Federal Institute of Geosciences and Natural Resources of Germany (BGR) as part of the project [GeoLIBScanner](https://www.bgr.bund.de/DE/Themen/Min_rohstoffe/Projekte/Mineralische-Reststoffe-abgeschlossen/GeoLIBScanner.html), which was funded by the German Federal Ministry for Economic Affairs and Energy (Grant Nr. ZF4441001SA7). 
After small adaptations, the provided code should be applicable for similar problems occuring in the geological LIBS community.

The provided files contain the complete workflow of the steps 4-7 of section 2.3. A short description of each file is found below, a more detailed description can be found in the documentation of the individual files. 

### intensity threshold - complete workflow
This file contains the complete workflow of the steps 4-7 of section 2.3. To be able to run the code, four separate functions need to be loaded. They are provided in the additional files of this repository. Several variables need to be set depending on the investigated data set.
Input for the complete workflow are the measured LIBS spectra, which should be processed as described in steps 1-3 of section 2.3. The element specific emission lines need to be extracted with peak integration, normalized and stored in a data frame, in which every row contains the information of one measurement point and every column contains the normalized emission intensity of the specific element line. 

### 1. Function: initialData_to_map
This function is used to convert the initial structure of of the LIBS intensity data into stacks of 2D-maps. Input is a data frame with a similar structure as the input data, although the columns do not necessarily need to include emission intensities. It is also possible to convert e.g. the labels after clustering or classification into a 2D-representation. 

### 2. Function: majority_filter
This function includes the majority filter that was applied in step 5 of section 2.3. It is used on the clustering result to smooth the image and correct wrongly clustered measurement points.

### 3. Function: extract_buffer_zones
This function is used to create the buffer zones around specific clasts of the same class und to extract the spatial positions of the associated pixels. This information can be used to spatially reconstruct the buffer zones on a 2D-map for validation or to get the intensity values of all pixels from the buffer zones from the initial input data.  

### 4. Function: rims_not_enriched
This function is applied to the ouput of function 3 'extract_buffer_zones'. In combination with a formerly defined intensity threshold (in the paper, 'median + 3 x MAD' is used), buffer zones with pixels above the threshold intensity are removed. The remaining output contains a list, in which each entry is associated to a buffer zone that only includes pixels not enriched in the specific intensity values. 





