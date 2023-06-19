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
output_vcf=anno.hg38_cadd_wgsnv_topmed.passed.filtered.vcf.gz

# apply filters
bcftools view $input_vcf -Ou -i 'FILTER=="PASS"' |
    bcftools view -Ou -i 'INFO/Func_refGene=="."||INFO/Func_refGene=="exonic"||INFO/Func_refGene=="splicing"||INFO/Func_refGene=="exonic\x3bsplicing"||INFO/Func_refGene=="ncRNA_exonic\x3bsplicing"||INFO/Func_refGene=="ncRNA_exonic"||INFO/Func_refGene=="ncRNA_splicing"' |
    bcftools view -Ou -i 'INFO/TOPMED=="."||INFO/TOPMED<=0.001' |
    bcftools view -Ou -i 'INFO/ExAC_ALL=="."||INFO/ExAC_ALL<=0.001' |
    bcftools view -Ou -i 'INFO/QD>2||INFO/QD=="."' |
    bcftools view -Ou -i 'INFO/ExonicFunc_refGene!="synonymous_SNV"' |
    bcftools view -Ou -i 'INFO/CLNSIG!="Benign/Likely_benign"&&INFO/CLNSIG!="Benign"&&INFO/CLNSIG!="Likely_benign"' |
    bcftools view -Ou -i 'FORMAT/GT!="ref"' |
    bcftools view -Ou -i 'FORMAT/AD[*:1]>5||FORMAT/AD[*:1]=="."' |
    bcftools view -Ou -i '(FORMAT/AD[*:1]/FORMAT/DP)>0.2||FORMAT/DP=="."||FORMAT/AD[*:1]=="."' \
        -o $output_vcf -O z --threads 20

# update string to float for AF_gnomad_genome and ALL.sites.2015_08
bcftools view anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.vcf.gz -Ou -i 'INFO/ALL.sites.2015_08=="."||INFO/ALL.sites.2015_08<=0.001' |
    bcftools view -Ou -i 'INFO/AF_gnomad_genome=="."||INFO/AF_gnomad_genome<=0.001' \
        -o anno.hg38_cadd_wgsnv_topmed.passed.filtered.string2float.gnomad_1kg_filtered.vcf.gz -O z --threads 15

# CADD phred score
