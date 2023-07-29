#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_plot_chr21_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_plot_chr21_%A_%a.errcd
#SBATCH --job-name=CNVkit_plot_chr21
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

# load R
module load gcc/8.3.0 openblas/0.3.8 r/4.0.0

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/cnvkit.out/

for i in {1..38}; do
   echo "Welcome $i times"

   ## input:
   cnr_file=($(ls T*.aligned.duplicates_marked.recalibrated.cnr | sed -n ${i}p))
   base=$(basename ${cnr_file} .aligned.duplicates_marked.recalibrated.cnr)

   # scatter
   singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py scatter -s $base.aligned.duplicates_marked.recalibrated.cn{s,r} -c chr21 -g RUNX1 --output $base.chr21.scatter.png

done
