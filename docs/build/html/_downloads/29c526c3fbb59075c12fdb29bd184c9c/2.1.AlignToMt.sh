#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/AlignToMt_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/AlignToMt_%A_%a.errcd
#SBATCH --job-name=AlignToMt
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

export PATH="/dir/kx/tools/bwa/:$PATH"
export PATH="/dir/kx/tools/samtools/samtools-1.10/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/
bash_ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta
bwa_commandline="bwa mem -K 100000000 -p -v 3 -t 15 -Y $bash_ref_fasta"

# description: "Uses BWA to align unmapped bam and marks duplicates."
## input:
input_bam=($(ls *.chrM.unmapped.bam | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_bam} .chrM.unmapped.bam)

## output:
output_fastq="$base.chrM.fastq"
output_aligned_bam="$base.chrM.mapped.bam"

output_bam_final="$base.AlignToMt.bam"
metrics_filename="$base.AlignToMt.metrics"

# Gets version of BWA
bwa_version=($(bwa 2>&1 | grep -e '^Version' | sed 's/Version: //'))

# description: "Aligns with BWA and MergeBamAlignment, then Marks Duplicates. Outputs a coordinate sorted bam."

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      SamToFastq \
      --INPUT $input_bam \
      --FASTQ $output_fastq \
      --INTERLEAVE true \
      --NON_PF true

bwa mem -K 100000000 -p -v 3 -t 15 -Y $bash_ref_fasta $output_fastq | samtools view -S -b - >$output_aligned_bam

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      MergeBamAlignment \
      --VALIDATION_STRINGENCY SILENT \
      --EXPECTED_ORIENTATIONS FR \
      --ATTRIBUTES_TO_RETAIN X0 \
      --ATTRIBUTES_TO_REMOVE NM \
      --ATTRIBUTES_TO_REMOVE MD \
      --ALIGNED_BAM $output_aligned_bam \
      --UNMAPPED_BAM $input_bam \
      --OUTPUT $base.mba.bam \
      --REFERENCE_SEQUENCE $bash_ref_fasta \
      --PAIRED_RUN true \
      --SORT_ORDER "unsorted" \
      --IS_BISULFITE_SEQUENCE false \
      --ALIGNED_READS_ONLY false \
      --CLIP_ADAPTERS false \
      --MAX_RECORDS_IN_RAM 2000000 \
      --ADD_MATE_CIGAR true \
      --MAX_INSERTIONS_OR_DELETIONS -1 \
      --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
      --PROGRAM_RECORD_ID "bwamem" \
      --PROGRAM_GROUP_VERSION "$bwa_version" \
      --PROGRAM_GROUP_COMMAND_LINE "$bwa_commandline" \
      --PROGRAM_GROUP_NAME "bwamem" \
      --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
      --ALIGNER_PROPER_PAIR_FLAGS true \
      --UNMAP_CONTAMINANT_READS true \
      --ADD_PG_TAG_TO_READS false \
      --TMP_DIR /scratch2/kerenxu/tmp

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      MarkDuplicates \
      --INPUT $base.mba.bam \
      --OUTPUT $base.md.bam \
      --METRICS_FILE $metrics_filename \
      --VALIDATION_STRINGENCY SILENT \
      --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
      --ASSUME_SORT_ORDER "queryname" \
      --CLEAR_DT "false" \
      --ADD_PG_TAG_TO_READS false \
      --TMP_DIR /scratch2/kerenxu/tmp

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      SortSam \
      --INPUT $base.md.bam \
      --OUTPUT $output_bam_final \
      --SORT_ORDER "coordinate" \
      --CREATE_INDEX true \
      --MAX_RECORDS_IN_RAM 300000 \
      --TMP_DIR /scratch2/kerenxu/tmp
