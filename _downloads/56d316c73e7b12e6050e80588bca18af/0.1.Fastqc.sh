#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/fastqc_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/fastqc_%A_%a.errcd
#SBATCH --job-name=fastqc
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

cd /dir/raw_data/

##  input:
fastq_1_path=($(find . -name "*_1.fq.gz" | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${fastq_1_path} _1.fq.gz)
fastq_1=$(basename ${fastq_1_path} _1.fq.gz)_1.fq.gz
fastq_2=$(basename ${fastq_1_path} _1.fq.gz)_2.fq.gz
sample_name=($(echo $base | cut -d '_' -f1))

## go to each directory
cd $sample_name

fastqc --noextract -t 6 $fastq_1 $fastq_2 --outdir /scratch/kerenxu/fastqc_out/

######## multiqc to check the output #####################

# find all the fq.gz files in subdirectories
find . -name "*.fq.gz" >fastq.file.list
