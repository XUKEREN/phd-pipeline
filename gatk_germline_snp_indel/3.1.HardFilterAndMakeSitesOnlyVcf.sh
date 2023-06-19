#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/HardFilterAndMakeSitesOnlyVcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/HardFilterAndMakeSitesOnlyVcf_%A_%a.errcd
#SBATCH --job-name=HardFilterAndMakeSitesOnlyVcf
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

for i in {1..38}; do
      echo "Welcome $i times"

      export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

      cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out
      vcf=($(ls *.scattered.vcf.gz | sed -n ${i}p))
      base=$(basename ${vcf} .scattered.vcf.gz)
      excess_het_threshold=54.69
      # ExcessHet is a phred-scaled p-value. We want a cutoff of anything more extreme
      # than a z-score of -4.5 which is a p-value of 3.4e-06, which phred-scaled is 54.69
      variant_filtered_vcf_filename="$base.variant_filtered.vcf.gz"
      sites_only_vcf_filename="$base.sites_only.variant_filtered.vcf.gz"

      # [A] Hard-filter a large cohort callset on ExcessHet using VariantFiltration ExcessHet filtering applies only to callsets with a large number of samples, e.g. hundreds of unrelated samples. Small cohorts should not trigger ExcessHet filtering as values should remain small. Note cohorts of consanguinous samples will inflate ExcessHet, and it is possible to limit the annotation to founders for such cohorts by providing a pedigree file during variant calling.

      #srun gatk --java-options "-Xms59G" \
      #      VariantFiltration \
      #      --filter-expression "ExcessHet > $excess_het_threshold" \
      #      --filter-name ExcessHet \
      #      -O $variant_filtered_vcf_filename \
      #      -V $vcf

      srun gatk --java-options "-Xms59G" \
            MakeSitesOnlyVcf \
            -I $vcf \
            -O $sites_only_vcf_filename
done
