#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/bedtointerval_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/bedtointerval_%A_%a.errcd
#SBATCH --job-name=bedtointerval
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict

srun gatk --java-options "-Xms55G" \
      BedToIntervalList \
      I=pon.bed \
      O=pon.interval_list \
      SD=$ref_dict
