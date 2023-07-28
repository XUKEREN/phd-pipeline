#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/SNPsVariantRecalibrator_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/SNPsVariantRecalibrator_%A_%a.errcd
#SBATCH --job-name=SNPsVariantRecalibrator
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

# references
hapmap_resource_vcf=/dir/kerenxu/refs/GATK_resource_bundle/hapmap_3.3.hg38.vcf.gz
omni_resource_vcf=/dir/kerenxu/refs/GATK_resource_bundle/1000G_omni2.5.hg38.vcf.gz
one_thousand_genomes_resource_vcf=/dir/kerenxu/refs/GATK_resource_bundle/1000G_phase1.snps.high_confidence.hg38.vcf.gz
dbsnp_resource_vcf=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

# input
sites_only_variant_filtered_vcf=smoking.38cohort.SitesOnlyGatherVcf.vcf.gz
max_gaussians=6

# output
recalibration_filename=smoking.38cohort.snps.recal
tranches_filename=smoking.38cohort.snps.tranches

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp/" \
      VariantRecalibrator \
      -V $sites_only_variant_filtered_vcf \
      -O $recalibration_filename \
      --tranches-file $tranches_filename \
      --trust-all-polymorphic \
      -tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 \
      -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
      -mode SNP \
      --max-gaussians $max_gaussians \
      -resource:hapmap,known=false,training=true,truth=true,prior=15 $hapmap_resource_vcf \
      -resource:omni,known=false,training=true,truth=true,prior=12 $omni_resource_vcf \
      -resource:1000G,known=false,training=true,truth=false,prior=10 $one_thousand_genomes_resource_vcf \
      -resource:dbsnp,known=true,training=false,truth=false,prior=7 $dbsnp_resource_vcf \
      --tmp-dir /scratch/kerenxu/tmp
