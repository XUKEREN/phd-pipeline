#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/SitesOnlyGatherVcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/SitesOnlyGatherVcf_%A_%a.errcd
#SBATCH --job-name=SitesOnlyGatherVcf
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

output_vcf_name=smoking.38cohort.SitesOnlyGatherVcf.vcf.gz

# ls *.sites_only.variant_filtered.vcf.gz > inputs.list # remmeber to sort the list by chrs.

# --ignore-safety-checks makes a big performance difference so we include it in our invocation.
# This argument disables expensive checks that the file headers contain the same set of
# genotyped samples and that files are in order by position of first record.
srun gatk --java-options "-Xms59G" \
    GatherVcfsCloud \
    --ignore-safety-checks \
    --gather-type BLOCK \
    --input inputs.list \
    --output $output_vcf_name

tabix $output_vcf_name
