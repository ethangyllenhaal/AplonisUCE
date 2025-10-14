# Data from: Phylogeny of Pacific starlings (genus Aplonis) reveals cryptic diversity and diverse biogeographic patterns

Last updated 14 October 2025

Repository for scripts and input files used in a subspecies-level phylogeny of the genus Aplonis.

This README describes the scripts and data files used for the afforementioned project. Each section corresponds to a zipped directory in the Dryad repository and folder on GitHub. \*\*\* denotes files in the Dryad only (mostly large alignment files or similar).

## Read processing (01_read_processing)

Raw reads are housed at NCBI's Sequencing Read Archive (PRJNA1336315).

aplonis-illumiprocessor.conf - Configuration file for illumiprocessor, made following standard Phyluce specifications.

illumiprocessor.slurm - Slurm script for running illumiprocessor to get cleaned reads. Originally run as part of longer script that was not used for final analyses, so subset to only the relevant command.

read_count.slurm - Script for counting the number of cleaned reads in each sample.

sample_list - Simple text list of all samples.

## Tissue pipeline to generate reference (02_tissue_pipeline)

Note that this was run for all tissue samples, but only one was used. Toepad samples were too fragmented for timely assemblies, so this naturally led to mostly tissue samples being considered. Only one (A_panayensis_panayensis_KU121758) was used for a reference.

velvet_parallel.slurm - Slurm script for running phyluce's wrapper around velvet per sample in parallel (default runs many at a time, this allowed more flexibility). Note that this was re-run at least once, although better samples finished faster.

sample_list_tissue - Simple text list of all tissue samples.

A_panayensis_panayensis_KU121758_ref.fasta - Fasta of the best assembly, used for pseudoreference downstream.

## Reference-based pipeline (03_reference_pipeline)

This is the stage that actually made input for all analyses, off the basis of the high quality reference in the de novo assembly step. This section is a bit complicated, so has a sub-README. In short, reference_pipeline.slurm is run remotely from the main working directory, then 2_trim_ambig.py is run from a directory with consensus seqeunces (script from https://datadryad.org/dataset/doi:10.5061/dryad.n5tb2rbsp, trims conensis sequence based on ambiguous bases), then further phyluce scripts are run from the main directory.

README_toepad - Supplemental README describing how it is run.

reference_pipeline.slurm - Pipeline for making consensus sequence, note prior note about trimming with the python script form Smith et al. 2020. Pipeline itself is heavily inspired by Smith et al. 2020, and compensates for the difficulties default phyluce has with toepads, as de novo assemblies are a lot harder. Note that the threshold used for the trimming script is 40%, so it was run like ""python 2_trim_ambig.py 0.4".

calc_contigs_stats.sh - Script for calculating contig stats, run on the consensus sequence, use samples list in step 1.

phyluce_thresh40_trim.slurm - Script for running phyluce, side-stepping some of it for trimming with trimal.

phyluce_aplonis76.slurm - The same as above but subset for select analyses using one per subspecies-level unit.

\*\*\* aplonis_\*phylip  - Phylip files output by phyluce for scripts noted above.

## Mitogenome pipeline (04_mitogenome)

run_mitofinder.slurm - Script used for tissue and toepad mitogenomes. Originally run separately to ease of computing. Note that these use a singularity image of mitofinder. Didn't work out how to use singularity parallelized across nodes, I'm sure there's a way to do it, but this was fast enough and I had time to spare. Both use NCBI OK542103.1 (Acridotheres tristis) as a reference.

sample_list\* - Sample lists used for dating subsets or full (goodmito) analyses.

gene_list.txt and gene_list_focal.txt - Simple text files of gene names used for dating (_focal) and phylogenetic analyses.

split_genes.sh - Shell script used for splitting out gene-specific fastas with all species in them. A "monolith" of all of these is then spit out for phyluce to use.

phyluce_mito\*.slurm - Scripts for hijacking phyluce for making concatenated mitochondrial datasets, either for dating (time\*) or phylogenetic analyses.

aplonis_mito_time\*\_nexus.nexus - Two nexus files with cytB and ND2 for use in data analyses.

aplonis_mito136_concat_75per.phylip - Phylip used for tree building (not divergence times).

## Phylogenetics (05_phylogenies)

sed_crcm.sh - Script for fixing some character issues with the CRCM samples.

iqtree.slurm - Script for "basic" iqtree runs, all the same command for different alignments.

make_genetrees.slurm - Script for making genetrees for astral/iqtree.

iqtree_concordance.slurm - Script for iqtree concordance factor runs, takes in any phylogeny, sequence alignment, and optionally gene tree sets (latter doesn't work well with UCE target capture on toepads).

astral.slurm - Slurm script for running ASTRAL.

\*.stat - Concordance factor stat output, used for examining in detail manually or with evaluate_concordance_factors.R.

\*tree, \*treefile, and \*tre (other than aplonis149_thresh40_trim_genetrees_75.treefile)- Assorted tree file outputs, as described in their name, with cf denoting concordance factors attached to the nodes. 

\*\*\* aplonis149_thresh40_trim_genetrees_75.treefile - A file of gene trees for the focal dataset, used for concordance factors and astral.

evaluate_concordance_factors.R - R script for analyzing concordance factors, inspired or fully drawing from this post by Rob Lanfear: https://www.robertlanfear.com/blog/files/concordance_factors.html.

aplonis76_concat_75per.nexus - Input nexus file used for SVDQuartets, using charsets file output by Phyluce to generate partitions. \[Analysis credit to Michael Andersen\]

aplonis76_concat_75per.charsets - Charsets file of subspecies-level dataset.

svdq_standardBoot.log - Log file for SVDQuartets run. \[Analysis credit to Michael Andersen\]

## Divergence dating (06_divergence_dating)

Divergence dating using a constraint of the IQtree topology for given datasets and mtDNA for rates. Note that only 75 of 76 subspecies made it to the subspecies-level dataset, but all 34 species-level tips made it.

aplonis_mito_time\*.xml - XML files for running BEAST, includes the mtDNA allignments and constraint tree. \[Analysis credit to Michael Andersen\]

aplonis_mito_time75-tree_logcombined.tre - Time calibrated tree from BEAST used for LTT plots.

ltt_plot.R - R script for plotting LTT data across taxonomic scales.

## Biogeography (07_biogeography)

BioGeoBear analysis was run for two levels, subspecies (75 tips) and species (34 tips). All analysis credit to Michael Andersen for this section.

aplonis_mito_time\*-tree.logcombined.newick - Phylogenies used for running BioGeoBEARS, time calibrated based on IQTree topology and mtDNA rates.

aplonis_\*\_BioGeoBear.R - R scripts for running species and subspecies level BioGeoBEARS analyses.

time\*\_geography.txt - Geography files for running BioGeoBEARS. Codings are in order as follows: Continental (C), Wallacean (W), Sahul (S), Near Melanesia (N), Far Melanesia (F), Polynesia (P), and Micronesia (M).

## Supplemental Files

Table_S1_Sampling.xlsx - Sampling table for the study. The Full_table tab contains the full data, while subset contains what is in the supplemental appendix submitted to the journal. Full description: Sampling table for all specimens used in this study. Abbreviated sheet is shown here, and columns in order are: genus, species, subspecies, sample country, sample island or locality, institution, voucher or other specimen ID, tissue specimen ID, sample source (preserved tissue or dry toepad), number of loci recovered, and mean length of those loci. Full sheet has the following additional columns: sorting order, sample country, sample name (as used in scripts), inclusion in the subspecies-level time tree, inclusion in the mitogenome tree, NCBI SRA accession, number of cleaned reads, and total length of loci.
