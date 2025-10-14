#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=aplonis_mito
#SBATCH --output=_mito_out_%j
#SBATCH --error=_mito_error_%j
#SBATCH --partition=condo
#SBATCH --mem=90G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
module load miniconda3
source activate phyluce-env

# gets alignments from monolith

phyluce_align_seqcap_align \
    --input mito_time75/mito_monolith_time75.fasta \
    --output mito_time75/mafft-nexus/ \
    --taxa 75 \
    --aligner mafft \
    --cores 32 \
    --incomplete-matrix

phyluce_align_get_align_summary_data \
    --alignments mito_time75/mafft-nexus/ \
    --cores 32

# polishing alignment and setting completeness

phyluce_align_remove_locus_name_from_files \
    --alignments mito_time75/mafft-nexus/ \
    --output mito_time75/mafft-nexus-clean/ \
    --cores 32

# make phylip output

phyluce_align_concatenate_alignments \
    --alignments mito_time75/mafft-nexus-clean/ \
    --output mito_time75/aplonis_mito_time75_nexus \
    --nexus
