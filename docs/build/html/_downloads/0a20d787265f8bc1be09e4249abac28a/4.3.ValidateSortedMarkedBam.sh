#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/ValidateSortedMarkedBam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/ValidateSortedMarkedBam_%A_%a.errcd
#SBATCH --job-name=ValidateSortedMarkedBam
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/SortAndFixTags/

# input
input_bam=($(ls *.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    ValidateSamFile \
    --INPUT $input_bam \
    --MODE SUMMARY \
    --TMP_DIR /scratch2/kerenxu/tmp