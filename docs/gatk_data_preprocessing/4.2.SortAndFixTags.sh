#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/SortAndFixTags_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/SortAndFixTags_%A_%a.errcd
#SBATCH --job-name=SortAndFixTags
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=89G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/MarkDuplicates.bam/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

# input
input_bam=($(ls *.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .bam)

# output
output_bam="$base.aligned.duplicate_marked.sorted.bam"

srun gatk --java-options "-Xms80G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      SortSam \
      --INPUT $input_bam \
      --OUTPUT /dev/stdout \
      --SORT_ORDER "coordinate" \
      --CREATE_INDEX false \
      --CREATE_MD5_FILE false \
      --TMP_DIR /scratch2/kerenxu/tmp |
      gatk --java-options "-Xms80G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
            SetNmMdAndUqTags \
            --INPUT /dev/stdin \
            --OUTPUT /scratch/kerenxu/SortAndFixTags/$output_bam \
            --CREATE_INDEX true \
            --CREATE_MD5_FILE true \
            --REFERENCE_SEQUENCE $ref \
            --TMP_DIR /scratch2/kerenxu/tmp
