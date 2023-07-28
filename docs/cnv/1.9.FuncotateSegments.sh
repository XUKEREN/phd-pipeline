#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/FuncotateSegments_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/FuncotateSegments_%A_%a.errcd
#SBATCH --job-name=FuncotateSegments
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname
cd /scratch/kerenxu/wgs.smoking.out/CallCopyRatioSegments

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
DATA_SOURCES_FOLDER=/dir/kerenxu/refs/Funcotator_resouorce/funcotator_dataSources.v1.7.20200521s
reference_version="hg38"

## input
input_seg_file=($(ls *.called.seg | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_seg_file} .called.seg)

## outptut
out_seg_tsv="$base.funcotated.tsv"

# Run FuncotateSegments:
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    FuncotateSegments \
    --data-sources-path $DATA_SOURCES_FOLDER \
    --ref-version $reference_version \
    --output-file-format SEG \
    -R $ref \
    --segments $input_seg_file \
    -O /scratch/kerenxu/wgs.smoking.out/FuncotateSegments/$out_seg_tsv \
    --tmp-dir /scratch/kerenxu/tmp
