#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=48:00:00
#SBATCH --job-name=aplonis_phyluce
#SBATCH --output=_count_out_%j
#SBATCH --error=_count_error_%j
#SBATCH --partition=condo
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
src=$SLURM_SUBMIT_DIR

module load parallel
scontrol show hostname > $src/node_list_${SLURM_JOB_ID}
source $(which env_parallel.bash)

# clears prior file
> clean_read_count.txt

# in parallel, each rep outputs a like that is "sample_name\tR1_count\tR2_count" to the output file
cat $src/sample_list | env_parallel -j 32 --sshloginfile $src/node_list_${SLURM_JOB_ID} \
    'paste <(echo {}) \
           <(echo $(zcat $src/clean_reads/{}/split-adapter-quality-trimmed/{}-READ1.fastq.gz | wc -l)/4|bc) \
           <(echo $(zcat $src/clean_reads/{}/split-adapter-quality-trimmed/{}-READ2.fastq.gz | wc -l)/4|bc) \
           >> $src/clean_read_count.txt'
