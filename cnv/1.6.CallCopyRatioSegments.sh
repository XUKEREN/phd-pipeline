#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CallCopyRatioSegments_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CallCopyRatioSegments_%A_%a.errcd
#SBATCH --job-name=CallCopyRatioSegments
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/ModelSegments

## input:
copy_ratio_segments=($(ls *.cr.seg | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${copy_ratio_segments} .cr.seg)

## output:
output_segments="/scratch/kerenxu/wgs.smoking.out/CallCopyRatioSegments/$base.called.seg"

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    CallCopyRatioSegments \
    --input $copy_ratio_segments \
    --neutral-segment-copy-ratio-lower-bound 0.9 \
    --neutral-segment-copy-ratio-upper-bound 1.1 \
    --outlier-neutral-segment-copy-ratio-z-score-threshold 2.0 \
    --calling-copy-ratio-z-score-threshold 2.0 \
    --output $output_segments \
    --tmp-dir /scratch2/kerenxu/tmp
