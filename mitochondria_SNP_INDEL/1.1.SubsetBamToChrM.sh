#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/SubsetBamToChrM_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/SubsetBamToChrM_%A_%a.errcd
#SBATCH --job-name=SubsetBamToChrM
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/wgs.smoking.out/SortAndFixTags/

## input:
input_bam=($(ls *.aligned.duplicate_marked.sorted.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .aligned.duplicate_marked.sorted.bam)
input_bai="$base.aligned.duplicate_marked.sorted.bai"
contig_name="chrM"

## output:
output_bam="$base.chrM.bam"

# "Subsets a whole genome bam to just Mitochondria reads"
# ref_fasta: "Reference is only required for cram input. If it is provided ref_fasta_index and ref_dict are also required."
srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/chrM" \
  PrintReads \
  -L $contig_name \
  --read-filter MateOnSameContigOrNoMappedMateReadFilter \
  --read-filter MateUnmappedAndUnmappedReadFilter \
  -I $input_bam \
  --read-index $input_bai \
  -O /scratch2/kerenxu/wgs.smoking.out/chrM/$output_bam \
  --tmp-dir /scratch2/kerenxu/tmp/chrM
