#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/FilterMutectCalls_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/FilterMutectCalls_%A_%a.errcd
#SBATCH --job-name=FilterMutectCalls
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch2/kerenxu/mutect2_out/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

## input:
unfiltered_vcf=($(ls *.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${unfiltered_vcf} .vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}
contamination_table="$base.contamination.table"
maf_segments="$base.segments.table"
artifact_priors_tar_gz="$base.artifact-priors.tar.gz"
mutect_stats="$base.vcf.gz.stats"

## output:
output_vcf="$base.filtering.vcf.gz"
filtering_stats="$base.filtering.vcf.gz.stats"

## change directory:
cd /dir/kerenxu/teeth/FilterMutectCalls_out/

## run gatk:
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/FilterMutectCalls" \
    FilterMutectCalls \
    -V /scratch2/kerenxu/mutect2_out/$unfiltered_vcf \
    -R $ref \
    -O /dir/kerenxu/teeth/FilterMutectCalls_out/$output_vcf \
    --contamination-table /scratch2/kerenxu/CalculateContamination/$contamination_table \
    --tumor-segmentation /scratch2/kerenxu/CalculateContamination/$maf_segments \
    --ob-priors /scratch2/kerenxu/mutect2_out/$artifact_priors_tar_gz \
    -stats /scratch2/kerenxu/mutect2_out/$mutect_stats \
    --filtering-stats /dir/kerenxu/teeth/FilterMutectCalls_out/$filtering_stats \
    --tmp-dir /scratch/kerenxu/tmp/FilterMutectCalls
