#!/bin/bash

################################################################################################################################################################
###### --Microbiome Analysis in QIIME---------------------------------------------------------------------------------------------------------------------######
###### --Author: JOC--------------------------------------------------------------------------------------------------------------------------------------######                                                                                                                                          
###### --Date: August 28, 2023----------------------------------------------------------------------------------------------------------------------------######                                                                                                                            
################################################################################################################################################################

################################################################################################################################################################
##--QIIME Activation and Directory Navigation-------------------------------------------------------------------------------------------------------------######
conda activate qiime2-2023.5
#cd HIVStudy/QIIME_Files

################################################################################################################################################################
##--FeatureTable and FeatureData Summaries----------------------------------------------------------------------------------------------------------------######
qiime feature-table summarize \
   --i-table feature-table-dm.qza \
   --o-visualization feature-table.qzv \
   --m-sample-metadata-file sample-metadata-dm-12122022.tsv

qiime feature-table tabulate-seqs \
   --i-data rep-seqs-dada2-8-15-25-29.qza \
   --o-visualization rep-seqs-dada2-8-15-25-29.qzv

################################################################################################################################################################
##--Tree Generation for Phylogenetic Diversity Analyses---------------------------------------------------------------------------------------------------######
qiime phylogeny align-to-tree-mafft-fasttree \
   --i-sequences rep-seqs-dada2-8-15-25-29.qza \
   --o-alignment aligned-rep-seqs.qza \
   --o-masked-alignment masked-aligned-rep-seqs.qza \
   --o-tree unrooted-tree.qza \
   --o-rooted-tree rooted-tree.qza

################################################################################################################################################################
##--Alpha and Beta Diversity Analysis---------------------------------------------------------------------------------------------------------------------######
###Setup of core-metrics-results folder to include core phylogeneic metrics for the data set
qiime diversity core-metrics-phylogenetic \
   --i-phylogeny rooted-tree.qza \
   --i-table feature-table-dm.qza \
   --p-sampling-depth 1103 \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --output-dir core-metrics-results

### Calculation of Faith Phylogoenetic Diversity 
qiime diversity alpha-group-significance \
   --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --o-visualization core-metrics-results/faith-pd-group-significance.qzv
### Calculation of Evenness
qiime diversity alpha-group-significance \
   --i-alpha-diversity core-metrics-results/evenness_vector.qza \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --o-visualization core-metrics-results/evenness-group-significance.qzv
### Calculation of Differences in Unweighted Unifrac Distances by HIV
qiime diversity beta-group-significance \
   --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --m-metadata-column HIV_Status \
   --o-visualization core-metrics-results/unweighted-unifrac-HIV-group-significance.qzv \
   --p-pairwise
### Calculation of Differences in Unweighted Unifrac Distances by Diet
qiime diversity beta-group-significance \
   --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --m-metadata-column Diet \
   --o-visualization core-metrics-results/unweighted-unifrac-diet-significance.qzv \
   --p-pairwise

################################################################################################################################################################
##--Alpha Rarefaction Plotting----------------------------------------------------------------------------------------------------------------------------######
qiime diversity alpha-rarefaction \
   --i-table feature-table-dm.qza \
   --i-phylogeny rooted-tree.qza \
   --p-max-depth 4000 \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --o-visualization alpha-rarefaction.qzv

################################################################################################################################################################
##--Taxonomic Analysis------------------------------------------------------------------------------------------------------------------------------------######
###Initial Download of the GreenGenes classifier
wget \
   -O "gg-13-8-99-515-806-nb-classifier.qza" \
   "https://data.qiime2.org/2023.5/common/gg-13-8-99-515-806-nb-classifier.qza"

###Taxonomic Classification
qiime feature-classifier classify-sklearn \
   --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
   --i-reads rep-seqs-dada2-8-15-25-29.qza \
   --o-classification gg-taxonomy.qza

###Data Summary and Tabulation 
qiime metadata tabulate \
   --m-input-file gg-taxonomy.qza \
   --o-visualization gg-taxonomy.qzv

qiime taxa barplot \
   --i-table feature-table-dm.qza \
   --i-taxonomy gg-taxonomy.qza \
   --m-metadata-file sample-metadata-dm-12122022.tsv \
   --o-visualization taxa-bar-plots.qzv
################################################################################################################################################################
##--Differential abundance testing with ANCOM-------------------------------------------------------------------------------------------------------------######
#qiime composition add-pseudocount \
#   --i-table feature-table-dm.qza \
#   --o-composition-table comp-feature-table.qza

#qiime feature-table filter-samples \
#   --i-table comp-feature-table.qza \
#   --m-metadata-file sample-metadata-dm-12122022.tsv \
#   --p-where "[Timepoint]='1'" \
#   --o-filtered-table comp-feature-table-1.qza

#qiime composition ancom \
#   --i-table comp-feature-table-1.qza \
#   --m-metadata-file sample-metadata-dm-12122022.tsv \
#   --m-metadata-column HIV_Status \
#   --o-visualization ancom-hiv.qzv
