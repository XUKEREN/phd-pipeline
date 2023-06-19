#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CollectAllelicCounts_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CollectAllelicCounts_%A_%a.errcd
#SBATCH --job-name=CollectAllelicCounts
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
processed_interval_list=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/wgs_coverage_regions.hg38.preprocessed.interval_list
common_sites=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/somatic-hg38_af-only-gnomad.hg38.AFgt0.02.interval_list

## input:
input_bam=($(ls *.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.duplicates_marked.recalibrated.bam)

## output:
allelic_counts="$base.allelicCounts.tsv"

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/CollectAllelicCounts" \
    CollectAllelicCounts \
    -L $common_sites \
    --input $input_bam \
    --reference $ref \
    --minimum-base-quality 20 \
    --output /scratch/kerenxu/wgs.smoking.out/CollectAllelicCounts/$allelic_counts \
    --tmp-dir /scratch2/kerenxu/tmp/CollectAllelicCounts
