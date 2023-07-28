#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/splitinterval_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/splitinterval_%A_%a.errcd
#SBATCH --job-name=splitinterval
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /dir/refs/GATK_resource_bundle/interval_files/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list

srun gatk --java-options "-Xms55G" \
    SplitIntervals \
    -R $ref \
    -L $interval_list \
    -scatter 5 \
    -O interval_files
