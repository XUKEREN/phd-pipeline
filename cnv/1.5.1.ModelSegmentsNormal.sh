#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/ModelSegmentsNormal_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/ModelSegmentsNormal_%A_%a.errcd
#SBATCH --job-name=N_ModelSegments
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch/kerenxu/wgs.smoking.out/DenoiseReadCounts/

## input:
denoised_copy_ratios=($(ls GM_*.denoisedCR.tsv | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${denoised_copy_ratios} .denoisedCR.tsv)
prefix="GM_"
sample_name=${base#"$prefix"}
allelic_counts="/scratch/kerenxu/wgs.smoking.out/CollectAllelicCounts/GM_$sample_name.allelicCounts.tsv"
# normal_allelic_counts="/scratch2/kerenxu/CollectAllelicCounts/G$sample_name.allelicCounts.tsv"
# min_total_allele_count=30

## output:
output_dir="/scratch/kerenxu/wgs.smoking.out/ModelSegments"

# default values are min_total_allele_count_ = 0 in matched-normal mode
#                                            = 30 in case-only mode
# Int default_min_total_allele_count = if defined(normal_allelic_counts) then 0 else 30
# Int min_total_allele_count_ = select_first([min_total_allele_count, default_min_total_allele_count])

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    ModelSegments \
    --denoised-copy-ratios $denoised_copy_ratios \
    --allelic-counts $allelic_counts \
    --output $output_dir \
    --output-prefix $base \
    --tmp-dir /scratch/kerenxu/tmp
