#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/LiftoverAndCombineVcfs_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/LiftoverAndCombineVcfs_%A_%a.errcd
#SBATCH --job-name=LiftoverAndCombineVcfs
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

srun hostname

cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta

# input
CallShiftedMt_raw_vcf=($(ls T*.chrM.CallShiftedMt.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${CallShiftedMt_raw_vcf} .chrM.CallShiftedMt.vcf.gz)
CallMt_raw_vcf="$base.chrM.vcf.gz"

# Chain file to lift over from shifted reference to original chrM
shift_back_chain=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/ShiftBack.chain

# output
shifted_back_vcf="$base.chrM.shifted_back.vcf.gz"
rejected_vcf="$base.chrM.rejected.vcf.gz"
merged_vcf="$base.chrM.merged.vcf.gz"

# description: "Lifts over shifted vcf of control region and combines it with the rest of the chrM calls."
srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      LiftoverVcf \
      -I $CallShiftedMt_raw_vcf \
      -O $shifted_back_vcf \
      -R $ref_fasta \
      --CHAIN $shift_back_chain \
      --REJECT $rejected_vcf

srun gatk --java-options "-Xms55G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      MergeVcfs \
      -I $shifted_back_vcf \
      -I $CallMt_raw_vcf \
      -O $merged_vcf
