#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/BWAindeximage_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/BWAindeximage_%A_%a.errcd
#SBATCH --job-name=BWAindeximage
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /dir/kerenxu/refs/GATK_resource_bundle/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch/kerenxu/tmp/bwaindeximage" \
     BwaMemIndexImageCreator \
     -I $ref \
     -O resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta.img \
     --tmp-dir /scratch/kerenxu/tmp/bwaindeximage
