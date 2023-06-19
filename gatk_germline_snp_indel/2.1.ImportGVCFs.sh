#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/ImportGVCFs_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/ImportGVCFs_%A_%a.errcd
#SBATCH --job-name=ImportGVCFs
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

# make sample_name-map file

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
sample_name_map=/scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out/cohort.sample_map
batch_size=38 # 38 samples

interval=($(cat /dir/kerenxu/refs/chrom_num.text | sed -n ${SLURM_ARRAY_TASK_ID}p))
workspace_dir_name="workspace_dir_name_$interval"

# change work dir
cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

# caution: remove workspace_dir_name if there is any before the new run rm -rf ${workspace_dir_name}
# The memory setting here is very important and must be several GB lower
# than the total memory allocated to the VM because this tool uses
# a significant amount of non-heap memory for native libraries.
# Also, testing has shown that the multithreaded reader initialization
# does not scale well beyond 5 threads, so don't increase beyond that.

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp/GenomicsDBImport" \
    GenomicsDBImport \
    --genomicsdb-workspace-path $workspace_dir_name \
    --batch-size $batch_size \
    -L $interval \
    --sample-name-map $sample_name_map \
    --reader-threads 5 \
    --merge-input-intervals \
    --tmp-dir /scratch2/kerenxu/tmp/GenomicsDBImport

# tar -cf $workspace_dir_name.tar $workspace_dir_name
