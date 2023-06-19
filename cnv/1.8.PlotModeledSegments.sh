#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/PlotModeledSegments_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/PlotModeledSegments_%A_%a.errcd
#SBATCH --job-name=PlotModeledSegments
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-76

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

# load R
module load gcc/8.3.0 openblas/0.3.8 r/4.0.0

cd /scratch/kerenxu/wgs.smoking.out/DenoiseReadCounts

ref_dict=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.dict

## input:
denoised_copy_ratios=($(ls *.denoisedCR.tsv | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${denoised_copy_ratios} .denoisedCR.tsv)
het_allelic_counts="$base.hets.tsv"
modeled_segments="$base.modelFinal.seg"

##output
output_dir="/scratch/kerenxu/wgs.smoking.out/PlotModeledSegments"

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    PlotModeledSegments \
    --denoised-copy-ratios $denoised_copy_ratios \
    --allelic-counts /scratch/kerenxu/wgs.smoking.out/ModelSegments/$het_allelic_counts \
    --segments /scratch/kerenxu/wgs.smoking.out/ModelSegments/$modeled_segments \
    --sequence-dictionary $ref_dict \
    --minimum-contig-length 46709983 \
    --maximum-copy-ratio 4.0 \
    --point-size-copy-ratio 0.2 \
    --point-size-allele-fraction 0.4 \
    --output $output_dir \
    --output-prefix $base \
    --tmp-dir /scratch/kerenxu/tmp
