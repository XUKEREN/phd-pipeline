#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/Funcotate_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/Funcotate_%A_%a.errcd
#SBATCH --job-name=Funcotate
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname
cd /dir/kerenxu/teeth/FilterMutectCalls_out/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
DATA_SOURCES_FOLDER=/dir/kerenxu/refs/Funcotator_resouorce/funcotator_dataSources.v1.7.20200521s
reference_version="hg38"

## input
input_vcf=($(ls *.filtering.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .filtering.vcf.gz)
prefix="sample"
sample_name=${base#"$prefix"}
output_format="VCF"

## output
output_vcf="$base.funcotated.vcf.gz"

## change directory
cd /dir/kerenxu/teeth/Funcotator_out/

# Run Funcotator:
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/funcotator" \
    Funcotator \
    --data-sources-path $DATA_SOURCES_FOLDER \
    --ref-version $reference_version \
    --output-file-format $output_format \
    -R $ref \
    -V /dir/kerenxu/teeth/FilterMutectCalls_out/$input_vcf \
    -O /dir/kerenxu/teeth/Funcotator_out/$output_vcf \
    --tmp-dir /scratch/kerenxu/tmp/funcotator
