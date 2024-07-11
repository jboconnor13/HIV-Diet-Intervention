#!/bin/bash

################################################################################################################################################################
###### --Fecal DM Diversity Analysis ---------------------------------------------------------------------------------------------------------######
###### --Author: JOC--------------------------------------------------------------------------------------------------------------------------------------######                                                                                                                                          
###### --Date: July 3, 2024-------------------------------------------------------------------------------------------------------------------------------######                                                                                                                            
################################################################################################################################################################

################################################################################################################################################################
##--QIIME Activation and Directory Navigation-------------------------------------------------------------------------------------------------------------######
source /Users/johnoconnor/mambaforge/etc/profile.d/conda.sh
conda activate qiime2-2023.5

# Initial move up two directories to the parent dirctory
cd ../..

# Navigation to the Fecal Data Directory
cd Data/QIIME_Files

#We use the core-metrics command to generate all of the alpha and beta diversity as well as the PCOA results
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny Fecal/Alpine_Output_070224/insertion-tree.qza \
  --i-table Fecal/Alpine_Output_070224/sepp-filtered-rarefied.qza \
  --p-sampling-depth 12922 \
  --m-metadata-file Fecal/Metadata/metadata.tsv \
  --output-dir Fecal/Diversity_Results
#We now export the alpha diversity vectors
#Shannon
qiime tools export \
  --input-path Fecal/Diversity_Results/shannon_vector.qza \
  --output-path Fecal/Diversity_Results/Shannon
#Faith's
qiime tools export \
  --input-path Fecal/Diversity_Results/faith_pd_vector.qza \
  --output-path Fecal/Diversity_Results/Faith

#Now we export the distance matrices
#Weighted
qiime tools export \
 --input-path Fecal/Diversity_Results/weighted_unifrac_distance_matrix.qza  \
 --output-path Fecal/Diversity_Results/WU_Matrix
#Unweighted
qiime tools export \
 --input-path Fecal/Diversity_Results/unweighted_unifrac_distance_matrix.qza  \
 --output-path Fecal/Diversity_Results/UU_Matrix

 

###Biplots

#For biplots we need to insitially generate a relative frequency output
qiime feature-table relative-frequency \
  --i-table Fecal/Alpine_Output_070224/sepp-filtered-rarefied.qza \
  --o-relative-frequency-table Fecal/Alpine_Output_070224/sepp-filtered-rarefied-rel.qza

#Now with that we geneatre biplots
#Weighted UniFrac
qiime diversity pcoa-biplot \
 --i-pcoa Fecal/Diversity_Results/weighted_unifrac_pcoa_results.qza \
 --i-features Fecal/Alpine_Output_070224/sepp-filtered-rarefied-rel.qza \
 --o-biplot Fecal/Diversity_Results/WU_biplot.qza
#Unweighted UniFrac
 qiime diversity pcoa-biplot \
 --i-pcoa Fecal/Diversity_Results/unweighted_unifrac_pcoa_results.qza \
 --i-features Fecal/Alpine_Output_070224/sepp-filtered-rarefied-rel.qza \
 --o-biplot Fecal/Diversity_Results/UU_biplot.qza