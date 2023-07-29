#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CollectWgsMetrics_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CollectWgsMetrics_%A_%a.errcd
#SBATCH --job-name=CollectWgsMetrics
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta
coverage_cap=100000

## input:
input_bam=($(ls *.AlignToMt.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .AlignToMt.bam)

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      CollectWgsMetrics \
      --INPUT $input_bam \
      --VALIDATION_STRINGENCY SILENT \
      --REFERENCE_SEQUENCE $ref_fasta \
      --OUTPUT $base.AlignToMt.bam.CollectWgsMetrics.metrics.txt \
      --USE_FAST_ALGORITHM true \
      --READ_LENGTH 151 \
      --COVERAGE_CAP $coverage_cap \
      --INCLUDE_BQ_HISTOGRAM true \
      --THEORETICAL_SENSITIVITY_OUTPUT $base.AlignToMt.bam.CollectWgsMetrics.theoretical_sensitivity.txt \
      --TMP_DIR /scratch2/kerenxu/tmp
