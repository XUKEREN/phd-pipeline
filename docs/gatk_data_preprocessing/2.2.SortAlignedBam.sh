#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/sortabam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/sortabam_%A_%a.errcd
#SBATCH --job-name=sortalignedbam
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

cd /scratch/kerenxu/teeth.aligned.bam/

# input
input_bam=($(ls *.aligned.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.bam)

# output
sorted_bam_name="$base.sorted.aligned.bam"

srun gatk --java-options "-Xmx55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    SortSam \
    --INPUT $input_bam \
    --OUTPUT /scratch2/kerenxu/teeth.sorted.aligned.bam/$sorted_bam_name \
    --SORT_ORDER queryname \
    --TMP_DIR /scratch2/kerenxu/tmp
