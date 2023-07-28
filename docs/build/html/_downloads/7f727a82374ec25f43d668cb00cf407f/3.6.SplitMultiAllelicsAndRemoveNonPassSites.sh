#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/SplitMultiAllelicsAndRemoveNonPassSites_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/SplitMultiAllelicsAndRemoveNonPassSites_%A_%a.errcd
#SBATCH --job-name=SplitMultiAllelicsAndRemoveNonPassSites
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"
srun hostname
cd /scratch2/kerenxu/chrM/

## input
filtered_vcf=($(ls T*.chrM.merged.filtered.VariantFiltration.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${filtered_vcf} .chrM.merged.filtered.VariantFiltration.vcf.gz)

## output
split_vcf="$base.chrM.merged.filtered.VariantFiltration.split.vcf.gz"
splitAndPassOnly_vcf="$base.chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      LeftAlignAndTrimVariants \
      -R $ref_fasta \
      -V $filtered_vcf \
      -O $split_vcf \
      --split-multi-allelics \
      --dont-trim-alleles \
      --keep-original-ac

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      SelectVariants \
      -V $split_vcf \
      -O $splitAndPassOnly_vcf \
      --exclude-filtered
