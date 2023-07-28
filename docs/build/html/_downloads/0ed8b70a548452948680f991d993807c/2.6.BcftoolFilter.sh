#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/filter1_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/filter1_%A_%a.errcd
#SBATCH --job-name=filter1
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main

export PATH="/dir/kerenxu/tools/htslib/htslib-1.10.2/:$PATH"
export PATH="/dir/kerenxu/tools/bcftools/bcftools-1.10.2/:$PATH"

cd /dir/kerenxu/teeth/Funcotator_out/

for i in {1..25}; do
   echo "Welcome $i times"
   input_vcf=($(ls *.funcotated.vcf.gz | sed -n ${i}p))
   echo ${input_vcf}
   base=$(basename ${input_vcf} .funcotated.vcf.gz)
   prefix="sample"
   sample_name=${base#"$prefix"}
   tumor_sample_name="T$sample_name"

   output_vcf=${base}.funcotated.bcftools.filtered.tumoronly.vcf.gz

   bcftools view $input_vcf -Ou -i 'FILTER=="PASS"' | bcftools view -Ou -i 'FMT/DP[0]>=10' | bcftools view -Ou -i 'FMT/DP[1]>=14' | bcftools view -Ou -i '(FORMAT/AD[*:1]/FORMAT/DP)>=0.1' | bcftools view -s $tumor_sample_name -o ../BCFtools.filter.tumoronly/$output_vcf -O z --threads 15
done

cd /dir/kerenxu/teeth/BCFtools.filter.tumoronly/

for i in {1..25}; do
   echo "Welcome $i times"
   input_vcf=($(ls *.vcf.gz | sed -n ${i}p))
   echo ${input_vcf}
   tabix ${input_vcf}

   output_vcf=$(basename ${input_vcf} .funcotated.bcftools.filtered.tumoronly.vcf.gz).funcotated.bcftools.filtered.tumoronly.chr1to22.vcf.gz

   bcftools view $input_vcf -Ou --regions chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 -o ../BCFtools.filter.tumoronly.autosomal/$output_vcf -O z --threads 15

done
