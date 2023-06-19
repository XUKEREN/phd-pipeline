#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/DenoiseReadCounts_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/DenoiseReadCounts_%A_%a.errcd
#SBATCH --job-name=DenoiseReadCounts
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

srun hostname

cd /scratch/kerenxu/wgs.smoking.out/CollectReadCounts/
ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
read_count_pon=/scratch/kerenxu/wgs.smoking.out/CollectReadCounts/cnv.smoking34normal.pon.hdf5

## input:
read_counts=($(ls *.counts.hdf5 | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${read_counts} .counts.hdf5)

## output:
copy_ratio_standardized="$base.standardizedCR.tsv"
copy_ratio_denoised="$base.denoisedCR.tsv"

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
    DenoiseReadCounts \
    --input $read_counts \
    --count-panel-of-normals $read_count_pon \
    --standardized-copy-ratios /scratch/kerenxu/wgs.smoking.out/DenoiseReadCounts/$copy_ratio_standardized \
    --denoised-copy-ratios /scratch/kerenxu/wgs.smoking.out/DenoiseReadCounts/$copy_ratio_denoised \
    --tmp-dir /scratch2/kerenxu/tmp

# Sample intervals must be identical to the original intervals used to build the panel of normals.
