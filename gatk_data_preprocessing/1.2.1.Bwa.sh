#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/bwa_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/bwa_%A_%a.errcd
#SBATCH --job-name=bwa
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
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

## input:
fastq_1_path=($(find . -name "*_1.fq.gz" | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${fastq_1_path} _1.fq.gz)
fastq_1=$(basename ${fastq_1_path} _1.fq.gz)_1.fq.gz
fastq_2=$(basename ${fastq_1_path} _1.fq.gz)_2.fq.gz
sample_name=($(echo $base | cut -d '_' -f1))

## output:
output_aligned_bam="$base.aligned.bam"

## go to each directory
cd $sample_name

srun bwa mem $ref -t 15 $fastq_1 $fastq_2 | samtools view -S -b >/scratch/kerenxu/teeth.aligned.bam/$output_aligned_bam
