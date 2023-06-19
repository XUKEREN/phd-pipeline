#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/removeInfoFieldAnnotationsFromVcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/removeInfoFieldAnnotationsFromVcf_%A_%a.errcd
#SBATCH --job-name=removeInfoFieldAnnotationsFromVcf
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

export PATH="/dir/kerenxu/tools/gatk-4.2.2.0/:$PATH"


cd /dir/kerenxu/refs/Funcotator_resouorce_germline/
info_annotations_to_remove=`cat gnomad_info_annotations_to_remove.txt`
input_vcf_file=gnomad.exomes.r2.1.sites.liftoverToHg38.INFO_ANNOTATIONS_FIXED.vcf.gz
output_vcf_file=gnomad.exomes.r2.1.sites.liftoverToHg38.INFO_ANNOTATIONS_FIXED.selectvariants.vcf.gz

cd /dir/kerenxu/refs/Funcotator_resouorce_germline/funcotator_dataSources.v1.7.20200521g/gnomAD_exome/hg38

srun gatk --java-options "-Xms59G" \
            SelectVariants \
                -V $input_vcf_file \
                -O $output_vcf_file \
                --drop-info-annotation $info_annotations_to_remove


##### create file gnomad_info_annotations_to_remove.txt in python
output_file = open('gnomad_info_annotations_to_remove.txt', 'w')

for month in info_annotations_to_remove:
    output_file.write(month + ' --drop-info-annotation ')

output_file.close()