#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/dellygeno_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/dellygeno_%A_%a.errcd
#SBATCH --job-name=dellygeno
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

srun hostname

cd /scratch/kerenxu/wgs.smoking.out/delly.out/delly.pre/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/human.hg38.excl.tsv
threads=20

## input:
input_bcf=($(ls *.pre.bcf | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bcf} .pre.bcf)
tumor_bam=/scratch2/kerenxu/wgs.smoking.out/bqsr.bam/TM_$base.aligned.duplicates_marked.recalibrated.bam
normal_bam=/scratch2/kerenxu/wgs.smoking.out/bqsr.bam/G*.aligned.duplicates_marked.recalibrated.bam

## output:
output_bcf=/scratch/kerenxu/wgs.smoking.out/delly.out/delly.geno/$base.geno.bcf

delly_v0.8.7_linux_x86_64bit call -g $ref -v $input_bcf -o $output_bcf -x $exclude_bed $tumor_bam $normal_bam
