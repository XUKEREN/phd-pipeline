#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/OrientationBias_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/OrientationBias_%A_%a.errcd
#SBATCH --job-name=OrientationBias
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /dir/kerenxu/teeth/mutect2_out/scatter0/

## input:
input_f1r2_tar_gz=($(ls *.f1r2.tar.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_f1r2_tar_gz} .f1r2.tar.gz)

## output:
output_f1r2_tar_gz="$base.artifact-priors.tar.gz"

## change directory:
cd /scratch2/kerenxu/mutect2_out/

## run:

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/orientationbias" \
    LearnReadOrientationModel \
    -I /dir/kerenxu/teeth/mutect2_out/scatter0/$input_f1r2_tar_gz \
    -I /dir/kerenxu/teeth/mutect2_out/scatter1/$input_f1r2_tar_gz \
    -I /dir/kerenxu/teeth/mutect2_out/scatter2/$input_f1r2_tar_gz \
    -I /dir/kerenxu/teeth/mutect2_out/scatter3/$input_f1r2_tar_gz \
    -I /dir/kerenxu/teeth/mutect2_out/scatter4/$input_f1r2_tar_gz \
    -O /scratch2/kerenxu/mutect2_out/$output_f1r2_tar_gz \
    --tmp-dir /scratch/kerenxu/tmp/orientationbias
