#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/split_interval_germline_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/split_interval_germline_%A_%a.errcd
#SBATCH --job-name=split_interval_germline
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /dir/kerenxu/refs/GATK_resource_bundle/interval_files/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list

## for splitting intervals

srun gatk --java-options "-Xms55G" \
      SplitIntervals \
      -L $interval_list \
      -O interval_files_germline \
      -scatter 5 \
      -R $ref \
      -mode BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
      --interval-merging-rule OVERLAPPING_ONLY
