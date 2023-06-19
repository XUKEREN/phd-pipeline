#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MergeVCFs_Haplotype_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MergeVCFs_Haplotype_%A_%a.errcd
#SBATCH --job-name=MergeVCFs
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/0000/

## input:
input_vcf=($(ls *.g.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .g.vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}

## output:
output_vcf="$input_vcf"

## change directory:
cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/

## merge:
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/MergeVCFsGermline" \
    MergeVcfs \
    -I ./0000/$input_vcf \
    -I ./0001/$input_vcf \
    -I ./0002/$input_vcf \
    -I ./0003/$input_vcf \
    -I ./0004/$input_vcf \
    -O ./$output_vcf \
    --TMP_DIR /scratch2/kerenxu/tmp/MergeVCFsGermline
