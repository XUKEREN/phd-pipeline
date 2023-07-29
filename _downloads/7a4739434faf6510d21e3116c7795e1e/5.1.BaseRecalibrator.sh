#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/BaseRecalibrator_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/BaseRecalibrator_%A_%a.errcd
#SBATCH --job-name=BaseRecalibrator
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/SortAndFixTags/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list
known_sites_snp=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf
known_sites_indel=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz

## caution: some vcf.gz automatically becomes vcf after downloading from GCP, change the name from vcf to vcf.gz

## input:
input_bam=($(ls *.aligned.unsorted.duplicates_marked.aligned.duplicate_marked.sorted.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.unsorted.duplicates_marked.aligned.duplicate_marked.sorted.bam)

## output:
recalibration_report="$base.recal_data.csv"
output_bam="$base.aligned.duplicates_marked.recalibrated.bam"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      BaseRecalibrator \
      -R $ref \
      -I $input_bam \
      --use-original-qualities \
      -O /scratch2/kerenxu/bqsr.bam/$recalibration_report \
      --known-sites $known_sites_snp \
      --known-sites $known_sites_indel \
      -L $interval_list \
      --tmp-dir /scratch/kerenxu/tmp

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      ApplyBQSR \
      -R $ref \
      -I $input_bam \
      -O /scratch2/kerenxu/bqsr.bam/$output_bam \
      -L $interval_list \
      -bqsr /scratch2/kerenxu/bqsr.bam/$recalibration_report \
      --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 \
      --add-output-sam-program-record \
      --create-output-bam-md5 \
      --use-original-qualities \
      --tmp-dir /scratch/kerenxu/tmp
