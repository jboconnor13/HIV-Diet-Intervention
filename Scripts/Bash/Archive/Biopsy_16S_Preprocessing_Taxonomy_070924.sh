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


################################################################################################################################################################
##--Initial filtering


##--FeatureTable and FeatureData Summaries----------------------------------------------------------------------------------------------------------------######
qiime feature-table summarize \
   --i-table Biopsy/feature-table.qza \
   --o-visualization Biopsy/feature-table.qzv \
   --m-sample-metadata-file Biopsy/Metadata/allmetadata.txt

qiime feature-table tabulate-seqs \
   --i-data Biopsy/rep-seqs.qza \
   --o-visualization Biopsy/rep-seqs.qzv

################################################################################################################################################################
##--Tree Generation for Phylogenetic Diversity Analyses---------------------------------------------------------------------------------------------------######


###Taxonomic Classification
qiime feature-classifier classify-sklearn \
   --i-classifier Classifiers/gg-13-8-99-515-806-nb-classifier.qza \
   --i-reads Biopsy/rep-seqs.qza \
   --o-classification Biopsy/gg-taxonomy.qza

###Data Summary and Tabulation 
qiime metadata tabulate \
   --m-input-file Biopsy/gg-taxonomy.qza \
   --o-visualization Biopsy/gg-taxonomy.qzv

qiime taxa barplot \
   --i-table Biopsy/feature-table.qza \
   --i-taxonomy Biopsy/gg-taxonomy.qza \
   --m-metadata-file Biopsy/Metadata/allmetadata.txt  \
   --o-visualization Biopsy/taxa-bar-plots.qzv


#We will filter and rarefy  
qiime taxa filter-table \
  --i-table Biopsy/feature-table.qza\
  --i-taxonomy Biopsy/gg-taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table Biopsy/filtered-feature-table.qza

qiime feature-table summarize \
  --i-table Biopsy/filtered-feature-table.qza \
  --o-visualization Biopsy/filtered-feature-table.qzv \
  --m-sample-metadata-file Biopsy/Metadata/allmetadata.txt