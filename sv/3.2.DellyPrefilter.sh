#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/dellyprefilter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/dellyprefilter_%A_%a.errcd
#SBATCH --job-name=dellycallprefilter
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

srun hostname

cd /scratch/kerenxu/wgs.smoking.out/delly.out/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
exclude_bed=/dir/kerenxu/refs/SV_resource/human.hg38.excl.tsv
threads=20

## input:
input_bcf=($(ls *.bcf | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bcf} .bcf)
sample_list=/dir/wgs.all.smoking/transfer_file_scripts/samples.tsv

## output:
output_bcf=/scratch/kerenxu/wgs.smoking.out/delly.out/delly.pre/$base.pre.bcf

delly_v0.8.7_linux_x86_64bit filter -f somatic -o $output_bcf -s $sample_list $input_bcf
