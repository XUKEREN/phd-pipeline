#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/dellypersamplecall_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/dellypersamplecall_%A_%a.errcd
#SBATCH --job-name=dellycall
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/human.hg38.excl.tsv
threads=20

## input:
normal_bam=($(ls GM_*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="GM_"
sample_name=${base#"$prefix"}
tumor_bam="TM_$sample_name.aligned.duplicates_marked.recalibrated.bam"

delly_v0.8.7_linux_x86_64bit call -x $exclude_bed -o /scratch/kerenxu/wgs.smoking.out/delly.out/$sample_name.bcf -g $ref $tumor_bam $normal_bam
