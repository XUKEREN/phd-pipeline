#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MakeSitesOnlyVcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MakeSitesOnlyVcf_%A_%a.errcd
#SBATCH --job-name=MakeSitesOnlyVcf
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

# ExcessHet is a phred-scaled p-value. We want a cutoff of anything more extreme
# than a z-score of -4.5 which is a p-value of 3.4e-06, which phred-scaled is 54.69
vcf=anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.vcf.gz
sites_only_vcf_filename=anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.sites_only.vcf.gz

srun gatk --java-options "-Xms230G" \
      MakeSitesOnlyVcf \
      -I $vcf \
      -O $sites_only_vcf_filename

# upload these to pecanpie medal ceremony and CADD website
# use 1018 candidate genes for pecanpie "gene_list_final_withoutHL.txt"

# CADD requires 2MB limit
bcftools annotate -x INFO,FILTER $sites_only_vcf_filename >anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.sites_only.5columns.vcf
bgzip anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.sites_only.5columns.vcf

# check status
# https://cadd.gs.washington.edu/check_avail/GRCh38-v1.6_anno_7683e48c960cf18f61808a8b9addfa87.tsv.gz
