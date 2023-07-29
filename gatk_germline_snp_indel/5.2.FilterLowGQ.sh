#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/VariantFiltration_filterlowGQ_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/VariantFiltration_filterlowGQ_%A_%a.errcd
#SBATCH --job-name=VariantFiltration
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
input_vcf=smoking.38cohort.filtered.CalculateGenotypePosteriors.vcf.gz
output_vcf=smoking.38cohort.filtered.CalculateGenotypePosteriors.GQ_filtered.vcf.gz
output_vcf_denovo=smoking.38cohort.filtered.CalculateGenotypePosteriors.GQ_filtered.denovo_anno.vcf.gz

srun gatk --java-options "-Xms59G" \
    VariantFiltration \
    -R $ref \
    -V /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/$input_vcf \
    --genotype-filter-expression "GQ < 20" \
    --genotype-filter-name "lowGQ" \
    -O /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/$output_vcf

# find de novo variants would be better to have ped file
# Rarity – Allele frequency across all samples sequenced is low
srun gatk --java-options "-Xms59G" \
    VariantAnnotator \
    -R $ref \
    -V /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/$output_vcf \
    -A PossibleDeNovo \
    -O /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/$output_vcf_denovo
