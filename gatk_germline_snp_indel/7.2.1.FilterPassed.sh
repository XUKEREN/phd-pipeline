#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/filter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/filter_%A_%a.errcd
#SBATCH --job-name=filter
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/tools/htslib/htslib-1.10.2/:$PATH"
export PATH="/dir/kerenxu/tools/bcftools/bcftools-1.10.2/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

input_vcf=anno.hg38_cadd_wgsnv_topmed.vcf.gz
output_vcf=anno.hg38_cadd_wgsnv_topmed.passed.vcf.gz

# first step to remove variants that did not pass VQSR
bcftools view $input_vcf -Ou -i 'FILTER=="PASS"' -o $output_vcf -O z --threads 20
