#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_theta_import_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_theta_import_%A_%a.errcd
#SBATCH --job-name=CNVkit_theta_import
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

for i in {1..23}; do # remove sample90707 with low purity(low acuracy), remove sample90581 no results
   echo "Welcome $i times"

   cd /scratch2/kerenxu/theta2.out/

   ## input:
   input_theta=($(ls *.BEST.results | sed -n ${i}p))
   base=$(basename ${input_theta} .BEST.results)
   prefix="sample"
   sample_name=${base#"$prefix"}
   tumor_cns="T$sample_name.aligned.duplicates_marked.recalibrated.cns"

   # From an existing CNVkit reference
   singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py import-theta /scratch2/kerenxu/cnvkit.out/$tumor_cns $input_theta -d /scratch2/kerenxu/theta2.out/

done
