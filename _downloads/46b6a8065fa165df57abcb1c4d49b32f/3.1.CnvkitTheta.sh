#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_theta_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_theta_%A_%a.errcd
#SBATCH --job-name=CNVkit_theta
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

srun hostname

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

for i in {1..25}; do
   echo "Welcome $i times"

   cd /scratch2/kerenxu/bqsr.bam/

   ## input:
   input_bam=($(ls T*.aligned.duplicates_marked.recalibrated.bam | sed -n ${i}p))
   base=$(basename ${input_bam} .aligned.duplicates_marked.recalibrated.bam)
   prefix="T"
   sample_name=${base#"$prefix"}
   input_cns_tumor="$base.aligned.duplicates_marked.recalibrated.cns"
   sample_paired_vcf="sample$sample_name.bubbletree.pre.vcf.gz"

   ## output
   readcount_out="sample$sample_name.theta2.interval_count"

   cd /scratch2/kerenxu/cnvkit.out/

   # From an existing CNVkit reference
   singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py export theta /scratch2/kerenxu/cnvkit.out/$input_cns_tumor -r reference.cnn -v /scratch2/kerenxu/mutect2_pair/bubbletree.pre.vcf/$sample_paired_vcf -i T$sample_name -n G$sample_name -z -o /scratch2/kerenxu/cnvkit.out/cnvkit.theta2.interval.count/$readcount_out

done
