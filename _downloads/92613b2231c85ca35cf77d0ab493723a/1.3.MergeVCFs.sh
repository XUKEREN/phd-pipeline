#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MergeVCFs_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MergeVCFs_%A_%a.errcd
#SBATCH --job-name=MergeVCFs
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/mutect2_out_scattered/scatter0/

## input:
input_vcf=($(ls *.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}

## output:
output_vcf="$input_vcf"

## change directory:
cd /scratch2/kerenxu/mutect2_out_scattered/

## merge:
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/MergeVCFs" \
    MergeVcfs \
    -I ./scatter0/$input_vcf \
    -I ./scatter1/$input_vcf \
    -I ./scatter2/$input_vcf \
    -I ./scatter3/$input_vcf \
    -I ./scatter4/$input_vcf \
    -O ./$output_vcf \
    --TMP_DIR /scratch2/kerenxu/tmp/MergeVCFs
