#!/bin/bash

################################################################################################################################################################
###### --Secondary 16S Diet Modification Data---------------------------------------------------------------------------------------------------------######
###### --Author: JOC--------------------------------------------------------------------------------------------------------------------------------------######                                                                                                                                          
###### --Date: June 25, 2024-------------------------------------------------------------------------------------------------------------------------------######                                                                                                                            
################################################################################################################################################################

################################################################################################################################################################
##--QIIME Activation and Directory Navigation-------------------------------------------------------------------------------------------------------------######
source /Users/johnoconnor/mambaforge/etc/profile.d/conda.sh
conda activate qiime2-2023.5

# Initial move up two directories to the parent dirctory
cd ../..

# Navigation to the Fecal Data Directory
cd Data/QIIME_Files

qiime feature-table rarefy \
  --i-table Biopsy/filtered-feature-table.qza \
  --p-sampling-depth 2790 \
  --o-rarefied-table Biopsy/rarefied-table.qza

qiime diversity alpha \
  --i-table Biopsy/rarefied-table.qza \
  --p-metric shannon \
  --o-alpha-diversity Biopsy/shannon_diversity.qza


qiime tools export \
  --input-path Biopsy/shannon_diversity.qza \
  --output-path Biopsy/shannon

