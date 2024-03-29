#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/manta_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/manta_%A_%a.errcd
#SBATCH --job-name=manta
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

srun hostname

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/exclude.cnvnator_100bp.GRCh38.20170403.bed
threads=20

## input:
normal_bam=($(ls GM_*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="GM_"
sample_name=${base#"$prefix"}
tumor_bam="TM_$sample_name.aligned.duplicates_marked.recalibrated.bam"

configManta.py \
    --referenceFasta=$ref \
    --runDir=/scratch/kerenxu/wgs.smoking.out/manta.config/$sample_name \
    --normalBam=$normal_bam \
    --tumorBam=$tumor_bam
