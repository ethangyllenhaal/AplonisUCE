#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=48:00:00
#SBATCH --job-name=aplonis_phyluce
#SBATCH --output=_illumi_out_%j
#SBATCH --error=_illumi_error_%j
#SBATCH --partition=condo
#SBATCH --mem=90G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
module load miniconda3
source activate phyluce-env # contains phyluce, installed from their github

# cleaning reads

illumiprocessor \
    --input raw_reads/phyluce_raw \
    --output clean_reads \
    --config aplonis-illumiprocessor.conf \
    --cores 8
