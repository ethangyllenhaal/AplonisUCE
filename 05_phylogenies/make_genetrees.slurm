#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=12:00:00
#SBATCH --job-name=genetrees
#SBATCH --output=_gt_out_%j
#SBATCH --error=_gt_error_%j
##SBATCH --mem=1000G
#SBATCH --partition=condo
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
src=$SLURM_SUBMIT_DIR
module load miniconda3

# conda env with iqtree
source activate iqtree-env

# makes gene trees, note thread count dropped to spare memory (not it didn't matter for largest dataset, no idea why)

iqtree -S aplonis76/mafft-nexus-trim-75/ --prefix aplonis76/aplonis76_genetrees_75 -T 4
iqtree -S aplonis149_thresh40/mafft-nexus-trim-75/ --prefix aplonis149_thresh40/aplonis149_thresh40_trim_genetrees_75 -T 32
