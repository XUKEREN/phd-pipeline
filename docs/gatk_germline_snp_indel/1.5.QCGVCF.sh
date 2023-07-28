#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CollectVariantCallingMetrics_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CollectVariantCallingMetrics_%A_%a.errcd
#SBATCH --job-name=CollectVariantCallingMetrics
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict
evaluation_interval_list=/dir/kerenxu/refs/GATK_resource_bundle/wgs_evaluation_regions.hg38.interval_list
dbsnp_vcf=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/

## input:
input_vcf=($(ls *.g.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .g.vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}

# Collect variant calling metrics from GVCF output
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/CollectVariantCallingMetrics" \
      CollectVariantCallingMetrics \
      --INPUT $input_vcf \
      --OUTPUT $base \
      --DBSNP $dbsnp_vcf \
      --SEQUENCE_DICTIONARY $ref_dict \
      --TARGET_INTERVALS $evaluation_interval_list \
      --GVCF_INPUT true \
      --TMP_DIR /scratch2/kerenxu/tmp/CollectVariantCallingMetrics
