#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/ValidateGVCFs_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/ValidateGVCFs_%A_%a.errcd
#SBATCH --job-name=ValidateGVCFs
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list
dbsnp_vcf=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/

## input:
input_vcf=($(ls *.g.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .g.vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/ValidateVariants" \
      ValidateVariants \
      -V $input_vcf \
      -R $ref \
      -L $interval_list \
      -gvcf \
      --validation-type-to-exclude ALLELES \
      --dbsnp $dbsnp_vcf \
      --tmp-dir /scratch2/kerenxu/tmp/ValidateVariants
