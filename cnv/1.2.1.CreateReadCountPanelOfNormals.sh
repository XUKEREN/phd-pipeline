#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/CreateReadCountPanelOfNormals_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/CreateReadCountPanelOfNormals_%A_%a.errcd
#SBATCH --job-name=CreateReadCountPanelOfNormals
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/CollectReadCounts

annotated_intervals=/dir/kerenxu/refs/GATK_resource_bundle/somatic_cnv/wgs_coverage_regions.hg38.preprocessed.annotated.tsv

# input
input=$(ls G*.counts.hdf5)
input_prefix=$(printf " --input %s" $input)
prefix=" --input "
input_list=${input_prefix#"$prefix"}

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch/kerenxu/tmp" \
    CreateReadCountPanelOfNormals \
    --input $input_list \
    --annotated-intervals $annotated_intervals \
    --output cnv.smoking34normal.pon.hdf5 \
    --tmp-dir /scratch/kerenxu/tmp
