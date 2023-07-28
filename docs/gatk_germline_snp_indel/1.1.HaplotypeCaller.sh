#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/HaplotypeCaller_scatter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/HaplotypeCaller_scatter_%A_%a.errcd
#SBATCH --job-name=0scatter
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/interval_files/interval_files_germline/0000-scattered.interval_list

## input:
normal_bam=($(ls G*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="GM_"
sample_name=${base#"$prefix"}

## output:
output_vcf="sample$sample_name.g.vcf.gz"

# HaplotypeCaller per-sample in GVCF mode
# needs to set the mem to MAX-1GB
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
  HaplotypeCaller \
  -R $ref \
  -I $normal_bam \
  -L $interval_list \
  -O /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/0000/$output_vcf \
  -G StandardAnnotation -G StandardHCAnnotation -G AS_StandardAnnotation \
  -GQB 10 -GQB 20 -GQB 30 -GQB 40 -GQB 50 -GQB 60 -GQB 70 -GQB 80 -GQB 90 \
  -ERC GVCF \
  --tmp-dir /scratch/kerenxu/tmp
