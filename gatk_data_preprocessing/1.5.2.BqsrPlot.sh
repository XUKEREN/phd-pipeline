#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/bqsrplot_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/bqsrplot_%A_%a.errcd
#SBATCH --job-name=bqsrplot
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/bqsr.bam/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list
known_sites_snp=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf
known_sites_indel=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz

## caution: some vcf.gz automatically becomes vcf after downloading from GCP, change the name from vcf to vcf.gz

## input:
input_bam=($(ls *.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.duplicates_marked.recalibrated.bam)
recalibration_report_pre="$base.recal_data.csv"

## output:
recalibration_report="$base.post.recal_data.csv"
OUTCSV="$base.AnalyzeCovariates.csv"

# Do a second pass to analyze covariation remaining after recalibration

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      BaseRecalibrator \
      -R $ref \
      -I $input_bam \
      -O $recalibration_report \
      --known-sites $known_sites_snp \
      --known-sites $known_sites_indel \
      -L $interval_list \
      --tmp-dir /scratch/kerenxu/tmp

# Generate before/after plots

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      AnalyzeCovariates \
      --before $recalibration_report_pre \
      --after $recalibration_report \
      --csv $OUTCSV \
      --tmp-dir /scratch/kerenxu/tmp
