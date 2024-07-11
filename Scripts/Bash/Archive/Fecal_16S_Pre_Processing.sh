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
  --i-table Fecal/feature-table-dm.qza \
  --m-metadata-file Fecal/Metadata/metadata.tsv \
  --p-where "MSMHIVGroup IN ('HIV-Positive-MSM', 'HIV-Negative-MSM','HIV-Negative-NonMSM')" \
  --o-filtered-table Fecal/filtered-feature-table-dm.qza


##--FeatureTable and FeatureData Summaries----------------------------------------------------------------------------------------------------------------######
qiime feature-table summarize \
   --i-table Fecal/filtered-feature-table-dm.qza \
   --o-visualization Fecal/filtered-feature-table-dm.qzv \
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
   --i-table Fecal/filtered-feature-table-dm.qza \
   --i-taxonomy Fecal/gg-taxonomy.qza \
   --m-metadata-file Fecal/Metadata/metadata.tsv  \
   --o-visualization filtered-taxa-bar-plots.qzv

#Fragment insertion via the SEPP plugin provides an alternative way to acquire the Phylogeny by inserting sequences of FeatureData[Sequence] into a high quality reference phylogeny 

qiime fragment-insertion sepp \
  --i-representative-sequences Fecal/rep-seqs.qza \
  --i-reference-database Reference_Databases/sepp-refs-gg-13-8.qza \
  --o-tree Fecal/insertion-tree.qza \
  --o-placements Fecal/insertion-placements.qza

qiime fragment-insertion filter-features \
  --i-table Fecal/filtered-feature-table-dm.qza \
  --i-tree Fecal/insertion-tree.qza \
  --o-filtered-table Fecal/twice-filtered-feature-table-dm.qza \
  --o-removed-table Fecal/removed_table.qza

#qiime diversity core-metrics-phylogenetic \
#  --i-phylogeny rooted-tree.qza \
#  --i-table table.qza \
#  --p-sampling-depth 1103 \
#  --m-metadata-file sample-metadata.tsv \
#  --output-dir core-metrics-results

##We will filter and rarefy  
#qiime taxa filter-table \
#  --i-table table.qza \
#  --i-taxonomy taxonomy.qza \
#  --p-exclude Bacteria, mitochondria,chloroplast \
#  --o-filtered-table filtered-table.qza

#qiime taxa filter-seqs \
#  --i-sequences rep-seqs.qza \
#  --i-taxonomy taxonomy.qza \
#  --p-exclude Bacteria, mitochondria,chloroplast \
#  --o-filtered-sequences filtered-seqs.qza

#qiime feature-table rarefy \
#  --i-table table-no-bacteria-no-mitochondria-no-chloroplast.qza \
#  --p-sampling-depth 10000 \
#  --o-rarefied-table rarefied-table.qza
