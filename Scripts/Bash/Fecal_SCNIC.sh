#!/bin/bash

################################################################################################################################################################
###### --Blood SCNIC Analysis---------------------------------------------------------------------------------------------------------######
###### --Author: JOC--------------------------------------------------------------------------------------------------------------------------------------######                                                                                                                                          
###### --Date: July 11, 2024-------------------------------------------------------------------------------------------------------------------------------######                                                                                                                            
################################################################################################################################################################

################################################################################################################################################################
##--QIIME Activation and Directory Navigation-------------------------------------------------------------------------------------------------------------######
source /Users/johnoconnor/mambaforge/etc/profile.d/conda.sh
conda activate qiime2-2023.5

# Initial move up two directories to the parent dirctory
cd ../..

# Navigation to the Fecal Data Directory
cd Data/QIIME_Files/Fecal

#Collappse the Table to the Genus Lavel
qiime taxa collapse \
  --i-table Alpine_Output_070324/sepp-filtered-rarefied.qza \
  --i-taxonomy gg-taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table genus-collapsed-sepp-filtered-rarefied-table.qza

#Now we export to a biom format
qiime tools export \
  --input-path genus-collapsed-sepp-filtered-rarefied-table.qza \
  --output-path exported-genus-collapsed-sepp-filtered-rarefied-table

#Now we deactivate QIIME so that we can activate SCNIC
conda deactivate

#The SCNIC3 conda environment is established
conda activate SCNIC3

#Within mode will be used to establish correlations between microbes
SCNIC_analysis.py within -i exported-genus-collapsed-sepp-filtered-rarefied-table/feature-table.biom -o SCNIC_within_Output/ -m sparcc

#Module model will be used to established modules
SCNIC_analysis.py modules -i SCNIC_within_Output/correls.txt -o SCNIC_modules_Output/ --min_r .35 --table exported-genus-collapsed-sepp-filtered-rarefied-table/feature-table.biom

conda deactivate
conda activate qiime2-2023.5

qiime tools import \
 --input-path SCNIC_modules_Output/collapsed.biom \
 --output-path SCNIC_modules_Output/collapsed.qza \
 --type "FeatureTable[Frequency]"



