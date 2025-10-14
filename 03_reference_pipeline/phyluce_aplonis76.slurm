#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=4:00:00
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
> tp_clean/aplonis76.fasta
for i in $(cat sample_list_aplonis76); do
    cat tp_clean/consensus/thresh0.4/${i}_0.4thresh.fa >> tp_clean/aplonis76.fasta
done

# seqcap align without trimming and allowing ambiguous sites
phyluce_align_seqcap_align \
    --input tp_clean/aplonis76.fasta \
    --output aplonis76/mafft-nexus-trim/ \
    --taxa 76 \
    --aligner mafft \
    --cores 8 \
    --ambiguous \
    --incomplete-matrix \
    --output-format fasta

source activate trimal-env
mkdir aplonis76/mafft-nexus-trim-trimal
mkdir aplonis76/mafft-nexus-trim-upper
# convert upper to lowercase and Ns to dashes
# then run trimal
for i in $(ls aplonis76/mafft-nexus-trim/ | cut -f 1 -d '.'); do
    awk '/^[^>]/{gsub("N","-");print toupper($0);next;}1' aplonis76/mafft-nexus-trim/${i}.fasta | sed 's/?/-/g' \
	> aplonis76/mafft-nexus-trim-upper/${i}_upper.fa
    trimal -in aplonis76/mafft-nexus-trim-upper/${i}_upper.fa -out aplonis76/mafft-nexus-trim-upper/${i}_trim.fa \
	   -keepheader -automated1 -matrix tp_clean/trimal_matrix.Degenerated_DNA
    trimal -in aplonis76/mafft-nexus-trim-upper/${i}_trim.fa -out aplonis76/mafft-nexus-trim-upper/${i}_trim_g70.fa \
           -keepheader -gt 0.7
done

# switch back to phyluce env
source deactivate
# rename alignments
for i in $(ls aplonis76/mafft-nexus-trim/ | cut -f 1 -d '.'); do
    mv aplonis76/mafft-nexus-trim-upper/${i}_trim_g70.fa aplonis76/mafft-nexus-trim-trimal/${i}.fasta
done

# get summary data
phyluce_align_get_align_summary_data \
    --alignments aplonis76/mafft-nexus-trim-trimal/ \
    --input-format fasta --cores 8

# fix file names
phyluce_align_remove_locus_name_from_files \
    --alignments aplonis76/mafft-nexus-trim-trimal/ \
    --output aplonis76/mafft-nexus-trim-noloc/ \
    --input-format fasta --cores 8

# make 75% complete matrix
phyluce_align_get_only_loci_with_min_taxa \
    --alignments aplonis76/mafft-nexus-trim-noloc/ \
    --taxa 76 \
    --percent 0.75 \
    --output aplonis76/mafft-nexus-trim-75/ \
    --cores 8

# make concatenated dataset
phyluce_align_concatenate_alignments \
    --alignments aplonis76/mafft-nexus-trim-75/ \
    --output aplonis76/aplonis76_concat_75per \
    --phylip

