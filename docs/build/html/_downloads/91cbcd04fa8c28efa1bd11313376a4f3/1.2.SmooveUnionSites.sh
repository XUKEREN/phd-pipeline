#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/smoove_unionsites_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/smoove_unionsites_%A_%a.errcd
#SBATCH --job-name=smoove_unionsites
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/smoove.out
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/exclude.cnvnator_100bp.GRCh38.20170403.bed
threads=20

# Get the union of sites across all samples
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/smoove_latest.sif smoove merge --name merged.smoove -f $ref --outdir ./ *.genotyped.vcf.gz
