#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CalculateGenotypePosteriors_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CalculateGenotypePosteriors_%A_%a.errcd
#SBATCH --job-name=CalculateGenotypePosteriors
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
population_vcf=/dir/kerenxu/refs/GATK_resource_bundle/1000G_phase3_v4_20130502.sites.hg38.vcf
input_vcf=smoking.38cohort.filtered.vcf.gz
output_vcf=smoking.38cohort.filtered.CalculateGenotypePosteriors.vcf.gz

srun gatk --java-options "-Xms59G" \
    CalculateGenotypePosteriors \
    -R $ref \
    -V $input_vcf \
    -supporting $population_vcf \
    -O $output_vcf
