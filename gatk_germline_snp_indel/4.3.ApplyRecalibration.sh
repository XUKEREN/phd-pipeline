#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/ApplyVQSR_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/ApplyVQSR_%A_%a.errcd
#SBATCH --job-name=ApplyVQSR
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

# input
input_vcf=($(ls *.scattered.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .scattered.vcf.gz)
indels_recalibration=smoking.38cohort.indels.recal
indels_tranches=smoking.38cohort.indels.tranches
indel_filter_level=99.0
snps_recalibration=smoking.38cohort.snps.recal
snps_tranches=smoking.38cohort.snps.tranches
snp_filter_level=99.7

# output
tmp_indel_recalibrated_vcf=$base.tmp.indel.recalibrated.vcf
recalibrated_vcf_filename=$base.filtered.vcf.gz

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp/" \
      ApplyVQSR \
      -O $tmp_indel_recalibrated_vcf \
      -V $input_vcf \
      --recal-file $indels_recalibration \
      --tranches-file $indels_tranches \
      --truth-sensitivity-filter-level $indel_filter_level \
      --create-output-variant-index true \
      -mode INDEL \
      --tmp-dir /scratch/kerenxu/tmp

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp/" \
      ApplyVQSR \
      -O $recalibrated_vcf_filename \
      -V $tmp_indel_recalibrated_vcf \
      --recal-file $snps_recalibration \
      --tranches-file $snps_tranches \
      --truth-sensitivity-filter-level $snp_filter_level \
      --create-output-variant-index true \
      -mode SNP \
      --tmp-dir /scratch/kerenxu/tmp
