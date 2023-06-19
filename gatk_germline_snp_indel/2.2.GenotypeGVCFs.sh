#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/GenotypeGVCFs_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/GenotypeGVCFs_%A_%a.errcd
#SBATCH --job-name=GenotypeGVCFs
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64
#SBATCH --array=1-38

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"

ref=/dir/kerenxu/refs/GATK_resource_bundle/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
batch_size=38 # 38 samples
dbsnp_vcf=/dir/kerenxu/refs/GATK_resource_bundle/Homo_sapiens_assembly38.dbsnp138.vcf

interval=($(cat /dir/kerenxu/refs/chrom_num.text | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$interval
workspace_dir_name="workspace_dir_name_$base"
WORKSPACE=$workspace_dir_name

# output
output_vcf_filename="$base.scattered.vcf.gz"

# change working dir
cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

# tar -xf $workspace_dir_name.tar

srun gatk --java-options "-Xms230G -Djava.io.tmpdir=/scratch2/kerenxu/tmp" \
      GenotypeGVCFs \
      -R $ref \
      -O $output_vcf_filename \
      -D $dbsnp_vcf \
      -G StandardAnnotation -G AS_StandardAnnotation \
      --only-output-calls-starting-in-intervals \
      -V gendb://$WORKSPACE \
      -L $interval \
      --merge-input-intervals \
      --tmp-dir /scratch2/kerenxu/tmp
