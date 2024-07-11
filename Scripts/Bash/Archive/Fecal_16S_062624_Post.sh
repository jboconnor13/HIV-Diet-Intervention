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
  --i-table Fecal/twice-filtered-feature-table.qza \
  --p-sampling-depth 2790 \
  --o-rarefied-table Fecal/rarefied-table.qza

qiime diversity alpha \
  --i-table Fecal/rarefied-table.qza \
  --p-metric shannon \
  --o-alpha-diversity Fecal/shannon_diversity.qza


qiime tools export \
  --input-path Fecal/shannon_diversity.qza \
  --output-path Fecal/shannon_diversity.csv

