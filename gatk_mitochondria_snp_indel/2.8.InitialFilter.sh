#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/InitialFilter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/InitialFilter_%A_%a.errcd
#SBATCH --job-name=InitialFilter
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"
srun hostname
cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta
blacklisted_sites=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/blacklist_sites.hg38.chrM.bed

## input
raw_vcf=($(ls G*.chrM.merged.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${raw_vcf} .chrM.merged.vcf.gz)
raw_vcf_stats="$base.chrM.vcf.gz.raw.combined.stats"
max_alt_allele_count=4
vaf_filter_threshold=0

## output
filtered_vcf="$base.chrM.merged.filtered.vcf.gz"
output_vcf="$base.chrM.merged.filtered.VariantFiltration.vcf.gz"

# description: "Mutect2 Filtering for calling Snps and Indels"
# vaf_filter_threshold: "Hard cutoff for minimum allele fraction. All sites with VAF less than this cutoff will be filtered.
# f_score_beta: "F-Score beta balances the filtering strategy between recall and precision. The relative weight of recall to precision."

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
        FilterMutectCalls \
        -V $raw_vcf \
        -R $ref_fasta \
        -O $filtered_vcf \
        --stats $raw_vcf_stats \
        --max-alt-allele-count $max_alt_allele_count \
        --mitochondria-mode \
        --min-allele-fraction $vaf_filter_threshold

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
        VariantFiltration -V $filtered_vcf \
        -O $output_vcf \
        --apply-allele-specific-filters \
        --mask $blacklisted_sites \
        --mask-name "blacklisted_site"
