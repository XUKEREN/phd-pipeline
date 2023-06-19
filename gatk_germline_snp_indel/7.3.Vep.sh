#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/vep_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/vep_%A_%a.errcd
#SBATCH --job-name=vep
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

source activate /dir/kerenxu/miniconda3/envs/maf-summary

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

## input:
input_vcf=anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.vcf.gz
output_vcf=anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.vep.vcf

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

# run vcf2maf with VEP annotation
/dir/kerenxu/miniconda3/envs/maf-summary/bin/vep --species homo_sapiens --assembly GRCh38 --offline --dir $HOME/.vep --fasta $ref --input_file $input_vcf --output_file $output_vcf --everything --fork 20 --cache --vcf
