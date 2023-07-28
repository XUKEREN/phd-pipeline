#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/PasteAnnotate_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/PasteAnnotate_%A_%a.errcd
#SBATCH --job-name=PasteAnnotate
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

srun hostname

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/smoove.out
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/exclude.cnvnator_100bp.GRCh38.20170403.bed
threads=20

# paste all the single sample VCFs
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/smoove_latest.sif smoove paste --name smoking_38 results_genotyped/*.vcf.gz

# annotate the variants with exons, UTRs that overlap from a GFF and annotate high-quality heterozygotes
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/smoove_latest.sif smoove annotate --gff /dir/kerenxu/refs/SV_resource/Homo_sapiens.GRCh38.104.gff3.gz smoking_38.smoove.square.vcf.gz | bgzip -c >smoking_38.smoove.square.anno.vcf.gz

# ftp://ftp.ensembl.org/pub/current_gff3/homo_sapiens/ to download gff3
