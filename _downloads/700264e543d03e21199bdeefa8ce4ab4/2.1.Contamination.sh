#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/contamination_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/contamination_%A_%a.errcd
#SBATCH --job-name=contamination
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/bqsr.bam/

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
interval_list=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_wgs_calling_regions.hg38.interval_list
gnomad=/dir/kerenxu/somatic_hg38/af-only-gnomad.hg38.vcf.gz
pon=/dir/kerenxu/somatic_hg38/1000g_pon.hg38.vcf.gz
variants_for_contamination=/dir/kerenxu/somatic_hg38/small_exac_common_3.hg38.vcf.gz

## input:
normal_bam=($(ls G*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="G"
sample_name=${base#"$prefix"}
tumor_bam="T$sample_name.aligned.duplicates_marked.recalibrated.bam"

## output:
normal_pileups="$base.pileups.table"
tumor_pileups="T$sample_name.pileups.table"
contamination_table="sample$sample_name.contamination.table"
segments_table="sample$sample_name.segments.table"

### GetPileupSummaries

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    GetPileupSummaries \
    -R $ref \
    -I $normal_bam \
    -V $variants_for_contamination \
    -L $variants_for_contamination \
    -O /scratch2/kerenxu/CalculateContamination/$normal_pileups \
    --tmp-dir /scratch2/kerenxu/tmp

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    GetPileupSummaries \
    -R $ref \
    -I $tumor_bam \
    -V $variants_for_contamination \
    -L $variants_for_contamination \
    -O /scratch2/kerenxu/CalculateContamination/$tumor_pileups \
    --tmp-dir /scratch2/kerenxu/tmp

## CalculateContamination

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    CalculateContamination \
    -I /scratch2/kerenxu/CalculateContamination/$tumor_pileups \
    -O /scratch2/kerenxu/CalculateContamination/$contamination_table \
    --tumor-segmentation /scratch2/kerenxu/CalculateContamination/$segments_table \
    -matched /scratch2/kerenxu/CalculateContamination/$normal_pileups \
    --tmp-dir /scratch2/kerenxu/tmp
