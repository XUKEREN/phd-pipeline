#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/telhunter_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/telhunter_%A_%a.errcd
#SBATCH --job-name=telhunter
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/bqsr.bam

normal_bam=($(ls G*.aligned.duplicates_marked.recalibrated.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
prefix="G"
sample_name=${base#"$prefix"}
tumor_bam="T$sample_name.aligned.duplicates_marked.recalibrated.bam"
BANDING_FILE=/refs_dir/cytoband_autosome_sex_chroms.hg38.bed

OUTPUT_DIRECTORY=/scratch2/kerenxu/telomere.length/telomerehunter.out

singularity exec /dir/SINGULARITY_CACHEDIR/telomerehunter_latest.sif telomerehunter -ibt $tumor_bam -ibc $normal_bam -o $OUTPUT_DIRECTORY -p $sample_name -pl --removeDuplicates -b $BANDING_FILE
