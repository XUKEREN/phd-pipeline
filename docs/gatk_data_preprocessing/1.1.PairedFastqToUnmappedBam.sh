#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/fastq2ubam_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/fastq2ubam_%A_%a.errcd
#SBATCH --job-name=fastq2ubam
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

cd /dir/raw_data/

##  input:
fastq_1_path=($(find . -name "*_1.fq.gz" | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${fastq_1_path} _1.fq.gz)
fastq_1=$(basename ${fastq_1_path} _1.fq.gz)_1.fq.gz
fastq_2=$(basename ${fastq_1_path} _1.fq.gz)_2.fq.gz
sample_name=($(echo $base | cut -d '_' -f1))
library_name=($(echo $base | cut -d '_' -f2))
flowcell=($(echo $base | cut -d '_' -f3))
lane=${base: -1}
readgroup_name="$sample_name.$flowcell"."$lane"
platform_unit="$flowcell"."$lane"
platform_name=ILLUMINA

## output:
output_unmapped_bam="$base.unmapped.bam"

## go to each directory
cd $sample_name

srun gatk --java-options "-Xmx55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    FastqToSam \
    --FASTQ $fastq_1 \
    --FASTQ2 $fastq_2 \
    --OUTPUT /scratch/kerenxu/unmapped.bam/$output_unmapped_bam \
    --READ_GROUP_NAME $readgroup_name \
    --SAMPLE_NAME $sample_name \
    --LIBRARY_NAME $library_name \
    --PLATFORM_UNIT $platform_unit \
    --PLATFORM $platform_name \
    --TMP_DIR /scratch/kerenxu/tmp
