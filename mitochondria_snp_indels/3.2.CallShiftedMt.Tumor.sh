#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CallShiftedMt_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CallShiftedMt_%A_%a.errcd
#SBATCH --job-name=CallShiftedMt
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta

## input
input_bam=($(ls T*.AlignToShiftedMt.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .AlignToShiftedMt.bam)
max_reads_per_alignment_start=75

# Everything is called except the control region.
# remmeber to change the chrM region for shifted bams
output_vcf="$base.chrM.CallShiftedMt.vcf.gz"
output_bam="$base.chrM.CallShiftedMt.bam"

# "Mutect2 for calling Snps and Indels"
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
        Mutect2 \
        -R $ref_fasta \
        -I $input_bam \
        --read-filter MateOnSameContigOrNoMappedMateReadFilter \
        --read-filter MateUnmappedAndUnmappedReadFilter \
        -O $output_vcf \
        --bam-output $output_bam \
        -L chrM:8025-9144 \
        --annotation StrandBiasBySample \
        --mitochondria-mode \
        --max-reads-per-alignment-start $max_reads_per_alignment_start \
        --max-mnp-distance 0 \
        --tmp-dir /scratch2/kerenxu/tmp
