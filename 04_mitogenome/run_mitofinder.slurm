#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=ap_mito
#SBATCH --output=_mito_out_%j
#SBATCH --error=_mito_error_%j
#SBATCH --partition=general
#SBATCH --mem=90G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

module load singularity
module load parallel
source $(which env_parallel.bash)

dir=$SLURM_SUBMIT_DIR
scontrol show hostname > $dir/node_list_${SLURM_JOB_ID}

# runs mitofinder vs 
for i in $(cat sample_list); do
singularity run --bind $dir /projects/shared/singularity/mitofinder_v1.4.1.sif --megahit \
                 -j ${i} \
                 -1 clean_reads/${i}/split-adapter-quality-trimmed/${i}-READ1.fastq.gz \
                 -2 clean_reads/${i}/split-adapter-quality-trimmed/${i}-READ2.fastq.gz \
                 -r A_tristis_OK542103_ref.gb \
                 --min-contig-size 500 \
                 --override -o 2 -p 32 -m 90
done
