#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=4:00:00
#SBATCH --job-name=concord
#SBATCH --output=_iqtree_out_%j
#SBATCH --error=_iqtree_error_%j
#SBATCH --partition=debug
##SBATCH --mem=2800G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=egyllenhaal@unm.edu

cd $SLURM_SUBMIT_DIR
module load miniconda3
source activate iqtree-env

# concordance factor analyses for focal trees, both for gene and site concordance
# note site is the only really useful one... gene concordance struggles with toepads

iqtree -t aplonis149_thresh40_trim_astral_75.tre \
       --gcf aplonis149_thresh40_trim_genetrees_75.treefile \
       --scf 5000 -s aplonis_thresh40_trim_149_concat_75per.phylip \
       --prefix concordance_astral149_thresh40_trim_75 -T 32

iqtree -t aplonis_thresh40_trim_149_concat_75per.phylip.treefile \
       --gcf aplonis149_thresh40_trim_genetrees_75.treefile \
       --scf 5000 -s aplonis_thresh40_trim_149_concat_75per.phylip \
       --prefix concordance_iqtree149_thresh40_trim_75 -T 32

iqtree -t aplonis76_concat_75per.phylip.treefile \
       --scf 5000 -s aplonis76_concat_75per.phylip \
       --gcf aplonis76_genetrees_75.treefile \
       --prefix concordance_iqtree76_75 -T 8

iqtree -t svdq_standard.nwk \
       --scf 5000 -s aplonis76_concat_75per.phylip \
       --gcf aplonis76_genetrees_75.treefile \
       --prefix concordance_svdq76_75 -T 8
