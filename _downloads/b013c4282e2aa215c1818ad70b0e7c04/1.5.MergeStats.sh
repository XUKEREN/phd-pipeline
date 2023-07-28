#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MergeStats_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MergeStats_%A_%a.errcd
#SBATCH --job-name=MergeStats
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch2/kerenxu/mutect2_out_scattered/scatter0/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

## input:
input_stats=($(ls *.vcf.gz.stats | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_stats} .vcf.gz.stats)
prefix="sample"
sample_name=${base#"$prefix"}

## output:
output_stats="$base.vcf.gz.stats"

## change directory:
cd /scratch2/kerenxu/mutect2_out_scattered/

## merge:
srun gatk --java-options "-Xms55G" \
    MergeMutectStats \
    -stats ./scatter0/$input_stats \
    -stats ./scatter1/$input_stats \
    -stats ./scatter2/$input_stats \
    -stats ./scatter3/$input_stats \
    -stats ./scatter4/$input_stats \
    -O ./$output_stats
