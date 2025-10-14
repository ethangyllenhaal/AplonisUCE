#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=astral
#SBATCH --output=_astral_out_%j
#SBATCH --error=_astral_error_%j
#SBATCH --partition=condo
#SBATCH --mem=90G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
module load miniconda3
source activate astral-env

astral -i aplonis149_thresh40_trim_genetrees_75.treefile -o aplonis149_thresh40_trim_astral_75.tre

