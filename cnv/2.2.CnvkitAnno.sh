#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_anno_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_anno_%A_%a.errcd
#SBATCH --job-name=CNVkit_anno
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

srun hostname

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/cnvkit.out/
gene_info=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/refFlat.txt

## input:
cnr_file=($(ls *.aligned.duplicates_marked.recalibrated.cnr | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${cnr_file} .aligned.duplicates_marked.recalibrated.cnr)
cns_file="$base.aligned.duplicates_marked.recalibrated.cns"
call_cns_file="$base.aligned.duplicates_marked.recalibrated.call.cns"
bintest_cns_file="$base.aligned.duplicates_marked.recalibrated.bintest.cns"

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $cnr_file --output ../cnvkit.out.anno/$cnr_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $cns_file --output ../cnvkit.out.anno/$cns_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $call_cns_file --output ../cnvkit.out.anno/$call_cns_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $bintest_cns_file --output ../cnvkit.out.anno/$bintest_cns_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py batch -h

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $cnr_file
