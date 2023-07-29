#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/MarkDuplicates_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/MarkDuplicates_%A_%a.errcd
#SBATCH --job-name=MarkDuplicates
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch/kerenxu/merged.bam/

# input
sample_name=($(cat /dir/kerenxu/novogene_0811/transfer_script/id_list.txt | sed -n ${SLURM_ARRAY_TASK_ID}p))
input_bam=$(ls ${sample_name}*.bam)
input_bam_prefix=$(printf " --INPUT %s" $input_bam)
prefix=" --INPUT "
input_bam_list=${input_bam_prefix#"$prefix"}

## output:
output_bam="$sample_name.aligned.unsorted.duplicates_marked.bam"
metrics_filename="$sample_name.duplicate_metrics"

srun gatk --java-options "-Xmx55G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
      MarkDuplicates \
      --INPUT $input_bam_list \
      --OUTPUT /scratch2/kerenxu/MarkDuplicates.bam/$output_bam \
      --METRICS_FILE /scratch2/kerenxu/MarkDuplicates.bam/$metrics_filename \
      --VALIDATION_STRINGENCY SILENT \
      --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
      --ASSUME_SORT_ORDER "queryname" \
      --CREATE_MD5_FILE true \
      --TMP_DIR /scratch/kerenxu/tmp

# set 2500 because of patterned flowcell
# NovaSeq 6000 for HWI-ST1276: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM3484363
# NovaSeq 6000 System uses patterned flowcell: https://www.illumina.com/systems/sequencing-platforms/novaseq/specifications.html
