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

qiime feature-table filter-samples \
  --i-table Fecal/feature-table.qza \
  --m-metadata-file Fecal/Metadata/metadata.tsv \
  --p-where "MSMHIVGroup IN ('HIV-Positive-MSM', 'HIV-Negative-MSM','HIV-Negative-NonMSM')" \
  --o-filtered-table Fecal/filtered-feature-table.qza


##--FeatureTable and FeatureData Summaries----------------------------------------------------------------------------------------------------------------######
qiime feature-table summarize \
   --i-table Fecal/filtered-feature-table.qza \
   --o-visualization Fecal/filtered-feature-table.qzv \
   --m-sample-metadata-file Fecal/Metadata/metadata.tsv

qiime feature-table tabulate-seqs \
   --i-data Fecal/rep-seqs.qza \
   --o-visualization Fecal/rep-seqs.qzv

################################################################################################################################################################
##--Tree Generation for Phylogenetic Diversity Analyses---------------------------------------------------------------------------------------------------######


###Taxonomic Classification
qiime feature-classifier classify-sklearn \
   --i-classifier Classifiers/gg-13-8-99-515-806-nb-classifier.qza \
   --i-reads Fecal/rep-seqs.qza \
   --o-classification Fecal/gg-taxonomy.qza

###Data Summary and Tabulation 
qiime metadata tabulate \
   --m-input-file Fecal/gg-taxonomy.qza \
   --o-visualization Fecal/gg-taxonomy.qzv

qiime taxa barplot \
   --i-table Fecal/filtered-feature-table.qza \
   --i-taxonomy Fecal/gg-taxonomy.qza \
   --m-metadata-file Fecal/Metadata/metadata.tsv  \
   --o-visualization Fecal/filtered-taxa-bar-plots.qzv


#We will filter and rarefy  
qiime taxa filter-table \
  --i-table Fecal/filtered-feature-table.qza\
  --i-taxonomy Fecal/gg-taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table Fecal/twice-filtered-feature-table.qza

qiime feature-table summarize \
  --i-table Fecal/twice-filtered-feature-table.qza \
  --o-visualization Fecal/twice-filtered-feature-table.qzv \
  --m-sample-metadata-file Fecal/Metadata/metadata.tsv