#!/bin/bash

# did same code for everything, just different gene lists and samples
for g in $(cat gene_list_focal.txt); do
    > split/${g}_aplonis_time34.fasta
    for s in $(cat sample_list_time34); do
	cat ${s}/${s}_MitoFinder_megahit_mitfi_Final_Results/${s}_final_genes_NT.fasta | \
	    grep -A1 ${g}$  | sed "s/@/ |/g" >> split/${g}_aplonis_time34.fasta
    done
done

cat split/*time34.fasta > mito_time34/mito_monolith_time34.fasta

for g in $(cat gene_list_focal.txt); do
    > split/${g}_aplonis_time75.fasta
    for s in $(cat sample_list_time75); do
        cat ${s}/${s}_MitoFinder_megahit_mitfi_Final_Results/${s}_final_genes_NT.fasta | \
            grep -A1 ${g}$  | sed "s/@/ |/g" >> split/${g}_aplonis_time75.fasta
    done
done

cat split/*time75.fasta > mito_time34/mito_monolith_time75.fasta

for g in $(cat gene_list.txt); do
    > split/${g}_aplonis_mito136.fasta
    for s in $(cat sample_list_goodmito); do
        cat ${s}/${s}_MitoFinder_megahit_mitfi_Final_Results/${s}_final_genes_NT.fasta | \
            grep -A1 ${g}$  | sed "s/@/ |/g" >> split/${g}_aplonis_mito136.fasta
    done
done

cat split/*_aplonis_mito136.fasta > mitogenome136/mito_monolith136.fasta
