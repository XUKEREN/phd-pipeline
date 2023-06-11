#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MT2scatter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MT2scatter_%A_%a.errcd
#SBATCH --job-name=MT2scatter
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/bqsr.bam/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/interval_files/interval_files/0000-scattered.interval_list
gnomad=/dir/kerenxu/somatic_hg38/af-only-gnomad.hg38.vcf.gz
pon=/dir/kerenxu/somatic_hg38/1000g_pon.hg38.vcf.gz

## input:
normal_bam=($(ls G*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="G"
sample_name=${base#"$prefix"}
tumor_bam="T$sample_name.aligned.duplicates_marked.recalibrated.bam"

## output:
output_vcf="$base.vcf.gz"
output_bam="$base.tumor_normal.bam"
output_tar_gz="$base.f1r2.tar.gz"

srun gatk --java-options "-Xms59G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    Mutect2 \
    -R $ref \
    -I $tumor_bam \
    -I $normal_bam \
    -normal $base \
    --germline-resource $gnomad \
    -pon $pon \
    -L $interval_list \
    -O /dir/kerenxu/teeth/mutect2_out/scatter0/$output_vcf \
    --bam-output /dir/kerenxu/teeth/mutect2_out/scatter0/$output_bam \
    --f1r2-tar-gz /dir/kerenxu/teeth/mutect2_out/scatter0/$output_tar_gz \
    --tmp-dir /scratch2/kerenxu/tmp
