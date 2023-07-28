#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/validateabam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/validateabam_%A_%a.errcd
#SBATCH --job-name=validateabam
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/teeth.aligned.bam/

# input
input_bam=($(ls *.aligned.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))

srun gatk --java-options "-Xmx55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    ValidateSamFile \
    --INPUT $input_bam \
    --MODE SUMMARY \
    --TMP_DIR /scratch/kerenxu/tmp
