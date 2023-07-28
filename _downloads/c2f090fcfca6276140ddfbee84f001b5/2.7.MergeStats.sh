#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MergeStats_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MergeStats_%A_%a.errcd
#SBATCH --job-name=MergeStats
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/

# input
shifted_stats=($(ls G*.chrM.CallShiftedMt.vcf.gz.stats | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${shifted_stats} .chrM.CallShiftedMt.vcf.gz.stats)
non_shifted_stats="$base.chrM.vcf.gz.stats"

# output
raw_combined_stats="$base.chrM.vcf.gz.raw.combined.stats"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    MergeMutectStats \
    --stats $shifted_stats \
    --stats $non_shifted_stats \
    -O $raw_combined_stats
