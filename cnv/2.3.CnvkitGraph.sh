#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CNVkit_plot_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CNVkit_plot_%A_%a.errcd
#SBATCH --job-name=CNVkit_plot
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-25

# load R
module load gcc/8.3.0 openblas/0.3.8 r/4.0.0

export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

cd /scratch2/kerenxu/cnvkit.out/
gene_info=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/refFlat.txt

## input:
cnr_file=($(ls *.aligned.duplicates_marked.recalibrated.cnr | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${cnr_file} .aligned.duplicates_marked.recalibrated.cnr)
cns_file="$base.aligned.duplicates_marked.recalibrated.cns"
call_cns_file="$base.aligned.duplicates_marked.recalibrated.call.cns"
bintest_cns_file="$base.aligned.duplicates_marked.recalibrated.bintest.cns"

# scatter
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py scatter -s TR_95_T.cn{s,r}

# scatter with BAF
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py scatter -s T90499.aligned.duplicates_marked.recalibrated.cn{s,r} -v /scratch2/kerenxu/mutect2_out_scattered/sample1638184.vcf.gz -i T1638184 -n G1638184 --output 1638184.baf.scatter.pdf

# diagram
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py diagram -s Sample.cns Sample.cnr

# heatmap
singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py heatmap *.recalibrated.cns --output cnvkit.heatmap.pdf

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py heatmap *.recalibrated.call.cns --output cnvkit.call.heatmap.pdf

## check arguements

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py heatmap -h

# trash

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $cns_file --output ../cnvkit.out.anno/$cns_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $call_cns_file --output ../cnvkit.out.anno/$call_cns_file

singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnv_annotate.py annotate $gene_info cnv_file $bintest_cns_file --output ../cnvkit.out.anno/$bintest_cns_file
