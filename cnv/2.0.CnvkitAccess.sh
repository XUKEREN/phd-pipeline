#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/access_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/access_%A_%a.errcd
#SBATCH --job-name=access
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/exclude.cnvnator_100bp.GRCh38.20170403.bed
threads=15

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py access $ref -x $exclude_bed -o cnvkit_access-excludes.hg38.bed
