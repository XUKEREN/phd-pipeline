#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/AnnotateIntervals_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/AnnotateIntervals_%A_%a.errcd
#SBATCH --job-name=AnnotateIntervals
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict
preprocessed_interval_list=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/wgs_coverage_regions.hg38.preprocessed.interval_list

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    AnnotateIntervals \
    -L $preprocessed_interval_list \
    --reference $ref \
    --interval-merging-rule OVERLAPPING_ONLY \
    --output wgs_coverage_regions.hg38.preprocessed.annotated.tsv \
    --tmp-dir /scratch/kerenxu/tmp
