#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/PreprocessIntervals_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/PreprocessIntervals_%A_%a.errcd
#SBATCH --job-name=PreprocessIntervals
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/wgs_coverage_regions.hg38.interval_list
blacklist_intervals=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/CNV_and_centromere_blacklist.hg38liftover.list

# intervals can be found here: https://console.cloud.google.com/storage/browser/gatk-test-data/intervals
# different interval list compared to the one used for Mutect2
# should not include sex chr in the interval list for WGS
# A reasonable blacklist for excluded intervals (-XL) can be found at:
#   hg19: gs://gatk-best-practices/somatic-b37/CNV_and_centromere_blacklist.hg19.list
#   hg38: gs://gatk-best-practices/somatic-hg38/CNV_and_centromere_blacklist.hg38liftover.list (untested)

srun gatk --java-options "-Xms180G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    PreprocessIntervals \
    -L $interval_list \
    -XL $blacklist_intervals \ 
--sequence-dictionary $ref_dict \
    --reference $ref \
    --padding 0 \
    --bin-length 1000 \
    --interval-merging-rule OVERLAPPING_ONLY \
    --output wgs_coverage_regions.hg38.preprocessed.interval_list \
    --tmp-dir /scratch/kerenxu/tmp
