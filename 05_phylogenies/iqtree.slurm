#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=aplonis_iqtree
#SBATCH --output=_iqtree_out_%j
#SBATCH --error=_iqtree_error_%j
#SBATCH --partition=condo
##SBATCH --mem=90G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
module load miniconda3
source activate iqtree-env

# iqtree run for various subsets of the data

iqtree -s aplonis_time34_concat_75per.phylip -alrt 1000 -m GTR+I+G -B 1000 -T 32
iqtree -s aplonis_time75_concat_75per.phylip -alrt 1000 -m GTR+I+G -B 1000 -T 32
iqtree -s aplonis_thresh40_trim_149_concat_75per.phylip -alrt 1000 -m GTR+I+G -B 1000 -T 32
iqtree -s aplonis76_concat_75per.phylip -alrt 1000 -m GTR+I+G -B 1000 -T 32
