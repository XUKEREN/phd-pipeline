#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_%A_%a.errcd
#SBATCH --job-name=CNVkit
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/exclude.cnvnator_100bp.GRCh38.20170403.bed
threads=20
gene_info=/dir/kerenxu/refs/SV_resource/Homo_sapiens.GRCh38.104.gff3
access_bed=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/cnvkit_access-excludes.hg38.bed
gene_info=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/refFlat.txt

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py batch TM_*.aligned.duplicates_marked.recalibrated.bam -n GM_*.aligned.duplicates_marked.recalibrated.bam -m wgs -f $ref --annotate $gene_info --access $access_bed --output-reference cnvkit_reference.cnn -d /scratch/kerenxu/wgs.smoking.out/cnvkit.out/ --diagram --scatter -p $threads

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam/ds_samples
# Reusing a reference for additional samples with DS
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py batch TM_*.aligned.duplicates_marked.recalibrated.bam -r cnvkit_reference.cnn -m wgs -d /scratch/kerenxu/wgs.smoking.out/cnvkit.out/ --diagram --scatter -p $threads
