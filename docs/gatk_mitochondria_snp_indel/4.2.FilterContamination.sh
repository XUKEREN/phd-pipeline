#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/FilterContamination_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/FilterContamination_%A_%a.errcd
#SBATCH --job-name=FilterContamination
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"
srun hostname
cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta

## input vcf
input_vcf=($(ls *.chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz)

# check if there is contamination
for i in {1..50}; do
  input_vcf=($(ls *.chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz | sed -n ${i}p))
  base=$(basename ${input_vcf} .chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz)

  more $base/contamination.txt
done
