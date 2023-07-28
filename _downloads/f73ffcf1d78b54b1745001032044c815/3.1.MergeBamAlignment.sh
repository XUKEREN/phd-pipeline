#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/mergebam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/mergebam_%A_%a.errcd
#SBATCH --job-name=mergebam
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/teeth.sorted.unmapped.bam/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

# input
unmapped_bam=($(ls *.sorted.unmapped.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${unmapped_bam} .sorted.unmapped.bam)
aligned_bam="$base.sorted.aligned.bam"
output_bam="$base.bam"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      MergeBamAlignment \
      --VALIDATION_STRINGENCY SILENT \
      --EXPECTED_ORIENTATIONS FR \
      --ATTRIBUTES_TO_RETAIN X0 \
      --ALIGNED_BAM /scratch2/kerenxu/teeth.sorted.aligned.bam/$aligned_bam \
      --UNMAPPED_BAM $unmapped_bam \
      --OUTPUT /scratch/kerenxu/merged.bam/$output_bam \
      --REFERENCE_SEQUENCE $ref \
      --PAIRED_RUN true \
      --SORT_ORDER "unsorted" \
      --IS_BISULFITE_SEQUENCE false \
      --ALIGNED_READS_ONLY false \
      --CLIP_ADAPTERS false \
      --MAX_RECORDS_IN_RAM 2000000 \
      --ADD_MATE_CIGAR true \
      --MAX_INSERTIONS_OR_DELETIONS -1 \
      --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
      --PROGRAM_RECORD_ID "bwamem" \
      --PROGRAM_GROUP_VERSION "0.7.12-r1039" \
      --PROGRAM_GROUP_COMMAND_LINE "bwa mem $ref -t 15" \
      --PROGRAM_GROUP_NAME "bwamem" \
      --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
      --ALIGNER_PROPER_PAIR_FLAGS true \
      --UNMAP_CONTAMINANT_READS true \
      --TMP_DIR /scratch/kerenxu/tmp
