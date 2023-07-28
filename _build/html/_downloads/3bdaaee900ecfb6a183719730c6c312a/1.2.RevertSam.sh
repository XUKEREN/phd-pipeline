#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/RevertSam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/RevertSam_%A_%a.errcd
#SBATCH --job-name=RevertSam
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/

## input:
input_bam=($(ls *.chrM.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .chrM.bam)

## output:
output_bam="$base.chrM.unmapped.bam"

# description: "Removes alignment information while retaining recalibrated base qualities and original alignment tags"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    RevertSam \
    --INPUT $input_bam \
    --OUTPUT_BY_READGROUP false \
    --OUTPUT $output_bam \
    --VALIDATION_STRINGENCY LENIENT \
    --ATTRIBUTE_TO_CLEAR FT \
    --ATTRIBUTE_TO_CLEAR CO \
    --SORT_ORDER queryname \
    --RESTORE_ORIGINAL_QUALITIES false \
    --TMP_DIR /scratch2/kerenxu/tmp
