#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MergeBamOuts_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MergeBamOuts_%A_%a.errcd
#SBATCH --job-name=MergeBamOuts
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /dir/kerenxu/teeth/mutect2_out/scatter0/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

## input:
input_bam=($(ls *.tumor_normal.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .tumor_normal.bam)
prefix="sample"
sample_name=${base#"$prefix"}

## output:
unsorted_out_bam="$base.tumor_normal.unsorted.out.bam"
output_bam="$base.tumor_normal.bam"

## change directory:
cd /scratch2/kerenxu/mutect2_out/

## merge:
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/MergeBamOuts" \
    GatherBamFiles \
    -I /dir/kerenxu/teeth/mutect2_out/scatter0/$input_bam \
    -I /dir/kerenxu/teeth/mutect2_out/scatter1/$input_bam \
    -I /dir/kerenxu/teeth/mutect2_out/scatter2/$input_bam \
    -I /dir/kerenxu/teeth/mutect2_out/scatter3/$input_bam \
    -I /dir/kerenxu/teeth/mutect2_out/scatter4/$input_bam \
    -O /scratch2/kerenxu/mutect2_out/$unsorted_out_bam \
    -R $ref \
    --TMP_DIR /scratch/kerenxu/tmp/MergeBamOuts

# We must sort because adjacent scatters may have overlapping (padded) assembly regions, hence
# overlapping bamouts

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/MergeBamOuts" \
    SortSam \
    -I /scratch2/kerenxu/mutect2_out/$unsorted_out_bam \
    -O /scratch2/kerenxu/mutect2_out/$output_bam \
    --SORT_ORDER coordinate \
    -VALIDATION_STRINGENCY LENIENT \
    --TMP_DIR /scratch/kerenxu/tmp/MergeBamOuts

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/MergeBamOuts" \
    BuildBamIndex \
    -I /scratch2/kerenxu/mutect2_out/$output_bam \
    -VALIDATION_STRINGENCY LENIENT \
    --TMP_DIR /scratch/kerenxu/tmp/MergeBamOuts
