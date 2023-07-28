#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CollectReadCounts_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CollectReadCounts_%A_%a.errcd
#SBATCH --job-name=CollectReadCounts
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
processed_interval_list=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/wgs_coverage_regions.hg38.preprocessed.interval_list

## input:
input_bam=($(ls *.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.duplicates_marked.recalibrated.bam)

## output:
counts_file="$base.counts.hdf5"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    CollectReadCounts \
    -L $processed_interval_list \
    --input $input_bam \
    --reference $ref \
    --format HDF5 \
    --interval-merging-rule OVERLAPPING_ONLY \
    --output /scratch/kerenxu/wgs.smoking.out/CollectReadCounts/$counts_file \
    --tmp-dir /scratch2/kerenxu/tmp
