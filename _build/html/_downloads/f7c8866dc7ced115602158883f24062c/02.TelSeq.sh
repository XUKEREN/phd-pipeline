#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/telseq_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/telseq_%A_%a.errcd
#SBATCH --job-name=telseq
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/bqsr.bam

input_bam=($(ls *.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.duplicates_marked.recalibrated.bam)
output=$base.telseq.out

singularity exec /dir/SINGULARITY_CACHEDIR/telseq_latest.sif telseq $input_bam >/scratch2/kerenxu/telomere.length/telseq.out/$output
