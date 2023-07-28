#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/FilterAlignmentArtifacts_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/FilterAlignmentArtifacts_%A_%a.errcd
#SBATCH --job-name=FilterAlignmentArtifacts
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/tmp/FilterMutectCalls/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
realignment_index_bundle=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta.img

## input
input_vcf=($(ls *.filtering.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .filtering.vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}
tumor_reads="T$sample_name.aligned.duplicates_marked.recalibrated.bam"

## output
output_vcf="$base.FilterAlignmentArtifacts.filtered.vcf.gz"

## change directory
cd /dir/kerenxu/teeth/FilterAlignmentArtifacts_out/

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/FilterAlignmentArtifacts" \
    FilterAlignmentArtifacts \
    -R $ref \
    -V /dir/kerenxu/teeth/FilterMutectCalls_out/$input_vcf \
    -I /scratch2/kerenxu/bqsr.bam/$tumor_reads \
    --bwa-mem-index-image $realignment_index_bundle \
    -O /dir/kerenxu/teeth/FilterAlignmentArtifacts_out/$output_vcf \
    --tmp-dir /scratch/kerenxu/tmp/FilterAlignmentArtifacts
