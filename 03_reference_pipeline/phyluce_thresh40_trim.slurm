#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=phyluce_clean
#SBATCH --output=_phyluce_out_%j
#SBATCH --error=_phyluce_error_%j
#SBATCH --partition=condo
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
src=$SLURM_SUBMIT_DIR
module load miniconda3
module load parallel
scontrol show hostname > $src/node_list_${SLURM_JOB_ID}
source $(which env_parallel.bash)

source activate phyluce-env

# output consensus into a large monolith fasta
> reference_based/aplonis149_thresh40.fasta
for i in $(cat sample_list); do
    cat reference_based/consensus/thresh0.4/${i}_0.4thresh.fa >> reference_based/aplonis149_thresh40.fasta
done

# seqcap align without trimming and allowing ambiguous sites
phyluce_align_seqcap_align \
    --input reference_based/aplonis149_thresh40.fasta \
    --output aplonis149_thresh40/mafft-nexus-trim/ \
    --taxa 149 \
    --aligner mafft \
    --cores 32 \
    --ambiguous \
    --incomplete-matrix \
    --output-format fasta

source activate trimal-env
mkdir aplonis149_thresh40/mafft-nexus-trim-trimal
mkdir aplonis149_thresh40/mafft-nexus-trim-upper
# convert upper to lowercase and Ns to dashes
# then run trimal
for i in $(ls aplonis149_thresh40/mafft-nexus-trim/ | cut -f 1 -d '.'); do
    awk '/^[^>]/{gsub("N","-");print toupper($0);next;}1' aplonis149_thresh40/mafft-nexus-trim/${i}.fasta | sed 's/?/-/g' \
	> aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_upper.fa
    trimal -in aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_upper.fa -out aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_trim.fa \
	   -keepheader -automated1 -matrix reference_based/trimal_matrix.Degenerated_DNA
    trimal -in aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_trim.fa -out aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_trim_g70.fa \
           -keepheader -gt 0.7
    mv aplonis149_thresh40/mafft-nexus-trim-upper/${i}_t40_trim_g70.fa aplonis149_thresh40/mafft-nexus-trim-trimal/
done

# switch back to phyluce env
source deactivate

# rename alignments
for i in $(ls aplonis149_thresh40/mafft-nexus-trim-trimal/ | cut -f1 -d '_'); do
    mv aplonis149_thresh40/mafft-nexus-trim-trimal/${i}_t40_trim_g70.fa aplonis149_thresh40/mafft-nexus-trim-trimal/${i}.fasta
done


# get summary data
phyluce_align_get_align_summary_data \
    --alignments aplonis149_thresh40/mafft-nexus-trim-trimal/ \
    --input-format fasta --cores 32

# fix file names
phyluce_align_remove_locus_name_from_files \
    --alignments aplonis149_thresh40/mafft-nexus-trim-trimal/ \
    --output aplonis149_thresh40/mafft-nexus-trim-noloc/ \
    --input-format fasta --cores 32

# make 75% complete matrix
phyluce_align_get_only_loci_with_min_taxa \
    --alignments aplonis149_thresh40/mafft-nexus-trim-noloc/ \
    --taxa 149 \
    --percent 0.75 \
    --output aplonis149_thresh40/mafft-nexus-trim-75/ \
    --cores 32

# make concatenated dataset
phyluce_align_concatenate_alignments \
    --alignments aplonis149_thresh40/mafft-nexus-trim-75/ \
    --output aplonis149_thresh40/aplonis_thresh40_trim_149_concat_75per \
    --phylip

# make 95% complete matrix (didn't actually use here)
phyluce_align_get_only_loci_with_min_taxa \
    --alignments aplonis149_thresh40/mafft-nexus-trim-noloc/ \
    --taxa 149 \
    --percent 0.95 \
    --output aplonis149_thresh40/mafft-nexus-trim-95/ \
    --cores 32

phyluce_align_concatenate_alignments \
    --alignments aplonis149_thresh40/mafft-nexus-trim-95/ \
    --output aplonis149_thresh40/aplonis_thresh40_trim_149_concat_95per \
    --phylip
