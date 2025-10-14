#!/bin/bash

#SBATCH --ntasks=3
#SBATCH --cpus-per-task=32
#SBATCH --time=24:00:00
#SBATCH --job-name=reference_based
#SBATCH --output=_tp_out_%j
#SBATCH --error=_tp_error_%j
#SBATCH --partition=condo
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
src=$SLURM_SUBMIT_DIR
module load miniconda3
module load parallel
scontrol show hostname > $src/node_list_${SLURM_JOB_ID}
source $(which env_parallel.bash)
# start with environment with bwa, samtools, and gatk
source activate gatk-env

# index your reference
reference=${src}/reference_based/reference/A_panayensis_panayensis_KU121758_ref
bwa index -p $reference ${reference}.fasta
samtools faidx ${reference}.fasta -o ${reference}.fasta.fai


# align and process alignments
# starts with BWA for aligning, then sorts it, then cleans it
cat $src/sample_list | env_parallel -j 1 --sshdelay 0.1 --sshloginfile $src/node_list_${SLURM_JOB_ID} \
    'bwa mem \
         -t 8 -M \
         -R "@RG\tID:{}\tPL:ILLUMINA\tLB:{}\tSM:{}" \
         $reference \
         $src/clean_reads/{}/split-adapter-quality-trimmed/{}-READ1.fastq.gz \
         $src/clean_reads/{}/split-adapter-quality-trimmed/{}-READ2.fastq.gz \
         | samtools view -b -F 4 - > $src/reference_based/bams/{}_unsort.bam
         samtools sort $src/reference_based/bams/{}_unsort.bam > $src/reference_based/bams/{}_sorted.bam
	 gatk CleanSam -I $src/reference_based/bams/{}_sorted.bam -O $src/reference_based/bams/{}_clean.bam --VALIDATION_STRINGENCY SILENT'

# switch to an environment with bcftools and seqtk (I happened to have one I re-used, can also just have everything in the same env)
source activate psmc-env

# get variants with mpileup, filter to depth > 5, call, convert to fastq, then convert to fasta
cat $src/sample_list | env_parallel -j 1 --sshdelay 0.1 --sshloginfile $src/node_list_${SLURM_JOB_ID} \
        'bcftools mpileup -A -Ovu -f ${reference}.fasta $src/reference_based/bams/{}_clean.bam --threads 32 | \
                  bcftools filter -i "INFO/DP>5" - | \
                  bcftools call -c --threads 32 | vcfutils.pl vcf2fq -Q 30 | \
                  seqtk seq -a > $src/reference_based/consensus/{}_raw.fa'

# replace reference name with taxon name for consensus fastqs
# then append UCE locus IDs and convert low confidence calls to Ns
for i in $(cat sample_list); do
    sed -i "s/A_panayensis_panayensis_KU121758/${i}/g" $src/reference_based/consensus/${i}_raw.fa
    cat $src/reference_based/consensus/${i}_raw.fa |
        awk -F">|_" 'NF>2 {$0=$0" |"$2}1' | \
        sed -e '/^>/! s/[[:lower:]]/N/g' > \
        $src/reference_based/consensus/${i}.fa
done
