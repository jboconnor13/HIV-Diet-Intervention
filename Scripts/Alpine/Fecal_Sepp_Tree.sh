#!/bin/bash


#SBATCH --partition=amilan
#SBATCH --account=amc-general
#SBATCH --job-name=import_short
#SBATCH --nodes=1 # use 1 node 
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=16
#SBATCH --time=1-23:59:59 # Time limit days-hrs:min:sec
#SBATCH --qos=long
#SBATCH --mem=100gb # Memory limit
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=john.2.oconnor@cuanschutz.edu

module purge 
module load anaconda  
module load qiime2/2023.5

qiime fragment-insertion sepp \
  --i-representative-sequences Fecal/rep-seqs.qza \
  --i-reference-database Reference_Databases/sepp-refs-gg-13-8.qza \
  --o-tree Fecal/insertion-tree.qza \
  --o-placements Fecal/insertion-placements.qza


qiime fragment-insertion filter-features \
  --i-table Fecal/rarefied-table.qza \
  --i-tree Fecal/insertion-tree.qza \
  --o-filtered-table Fecal/sepp-filtered-rarefied.qza \
  --o-removed-table Fecal/removed_table.qza
