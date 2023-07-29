#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CallMt_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CallMt_%A_%a.errcd
#SBATCH --job-name=CallMt
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta

## input
input_bam=($(ls T*.AlignToMt.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .AlignToMt.bam)
max_reads_per_alignment_start=75

# Everything is called except the control region.
output_vcf="$base.chrM.vcf.gz"
output_bam="$base.chrM.bam"

# "Mutect2 for calling Snps and Indels"

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
        Mutect2 \
        -R $ref_fasta \
        -I $input_bam \
        --read-filter MateOnSameContigOrNoMappedMateReadFilter \
        --read-filter MateUnmappedAndUnmappedReadFilter \
        -O $output_vcf \
        --bam-output $output_bam \
        -L chrM:576-16024 \
        --annotation StrandBiasBySample \
        --mitochondria-mode \
        --max-reads-per-alignment-start $max_reads_per_alignment_start \
        --max-mnp-distance 0 \
        --tmp-dir /scratch2/kerenxu/tmp
