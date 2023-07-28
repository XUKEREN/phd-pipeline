#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/sortubam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/sortubam_%A_%a.errcd
#SBATCH --job-name=sortubam
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"
export PATH="/dir/kerenxu/tools/bwa/:$PATH"
export PATH="/dir/kerenxu/tools/bwa/bwakit/:$PATH"
export PATH="/dir/kerenxu/tools/samtools/samtools-1.10/:$PATH"

srun hostname

cd /scratch/kerenxu/unmapped.bam/

# input
input_bam=($(ls *.unmapped.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .unmapped.bam)

# output
sorted_bam_name="$base.sorted.unmapped.bam"

srun gatk --java-options "-Xmx55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    SortSam \
    --INPUT $input_bam \
    --OUTPUT /scratch/kerenxu/teeth.sorted.unmapped.bam/$sorted_bam_name \
    --SORT_ORDER queryname \
    --TMP_DIR /scratch/kerenxu/tmp
