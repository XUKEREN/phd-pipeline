#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/FinalGatherVcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/FinalGatherVcf_%A_%a.errcd
#SBATCH --job-name=FinalGatherVcf
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

output_vcf_name=smoking.38cohort.filtered.vcf.gz

# ls *.filtered.vcf.gz > inputs.list # remmeber to sort the list by chrs.

# --ignore-safety-checks makes a big performance difference so we include it in our invocation.
# This argument disables expensive checks that the file headers contain the same set of
# genotyped samples and that files are in order by position of first record.
srun gatk --java-options "-Xms230G" \
    GatherVcfsCloud \
    --ignore-safety-checks \
    --gather-type BLOCK \
    --input inputs.list \
    --output $output_vcf_name

tabix $output_vcf_name

ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict
evaluation_interval_list=/dir/kerenxu/refs/GATK_resource_bundle/wgs_evaluation_regions.hg38.interval_list
dbsnp_vcf=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

# Collect variant calling metrics from GVCF output
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    CollectVariantCallingMetrics \
    --INPUT $output_vcf_name \
    --OUTPUT smoking.38cohort \
    --DBSNP $dbsnp_vcf \
    --SEQUENCE_DICTIONARY $ref_dict \
    --TARGET_INTERVALS $evaluation_interval_list \
    --THREAD_COUNT 8 \
    --TMP_DIR /scratch2/kerenxu/tmp
