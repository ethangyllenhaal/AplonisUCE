#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --time=48:00:00
#SBATCH --job-name=aplonis_phyluce
#SBATCH --output=_velvet_out_%j
#SBATCH --error=_velvet_error_%j
#SBATCH --partition=bigmem-3TB
#SBATCH --mem=2800G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

# run on bigmem node!

cd $SLURM_SUBMIT_DIR
src=$SLURM_SUBMIT_DIR
module load miniconda3
source activate phyluce-env # phyluce as installed from their github
module load parallel
scontrol show hostname > $src/node_list_${SLURM_JOB_ID}
source $(which env_parallel.bash)

# make config files in a subfolder
for i in $(cat sample_list_tissue); do
    echo "[samples]" > velvet/parallel/confs/${i}_velvet.conf
    echo ${i}:/carc/scratch/projects/andersen2016005/EFG_stuff/aplonis_uce/clean_reads/${i} >> velvet/parallel/confs/${i}_velvet.conf
done

# assembly, per sample in parallel
cat $src/sample_list_assemble | env_parallel -j 8 --sshdelay 0.1 --sshloginfile $src/node_list_${SLURM_JOB_ID} \
    'phyluce_assembly_assemblo_velvet \
         --config $src/velvet/parallel/confs/{}_velvet.conf \
         --output $src/velvet/parallel/{} \
         --kmer 55 \
         --subfolder split-adapter-quality-trimmed \
         --cores 8 \
         --log-path $src/logs'
