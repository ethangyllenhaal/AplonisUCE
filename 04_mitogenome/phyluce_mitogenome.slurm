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
    --input mitogenome136/mito_monolith136.fasta \
    --output mitogenome136/mafft-nexus/ \
    --taxa 136 \
    --aligner mafft \
    --cores 32 \
    --incomplete-matrix

phyluce_align_get_align_summary_data \
    --alignments mitogenome136/mafft-nexus/ \
    --cores 32

# polishing alignment and setting completeness

phyluce_align_remove_locus_name_from_files \
    --alignments mitogenome136/mafft-nexus/ \
    --output mitogenome136/mafft-nexus-clean/ \
    --cores 32

# get incomplete matrices, not done for time tree
phyluce_align_get_only_loci_with_min_taxa \
    --alignments mitogenome136/mafft-nexus-clean/ \
    --taxa 136 \
    --percent 0.75 \
    --output mitogenome136/mafft-nexus-75/ \
    --cores 32

# make phylip output

phyluce_align_concatenate_alignments \
    --alignments mitogenome136/mafft-nexus-75/ \
    --output mitogenome136/aplonis_mito136_concat_75per \
    --phylip
