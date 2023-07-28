#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/dellybcf2vcf_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/dellybcf2vcf_%A_%a.errcd
#SBATCH --job-name=dellybcf2vcf
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

cd /scratch/kerenxu/wgs.smoking.out/delly.out/delly.post.somatic/

for i in {1..38}; do
   echo "Welcome $i times"
   input_bcf=($(ls *.somatic.bcf | sed -n ${i}p))
   echo ${input_bcf}
   base=$(basename ${input_bcf} .somatic.bcf)

   output_vcf=/scratch/kerenxu/wgs.smoking.out/delly.out/delly.post.somatic/somatic.vcf/${base}.somatic.vcf

   bcftools view $input_bcf >$output_vcf

done

# bgzip vcf in a directory
for f in *.vcf; do
   bgzip "$f"
done
