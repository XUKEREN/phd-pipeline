#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/manta_clean%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/manta_clean_%A_%a.errcd
#SBATCH --job-name=manta_clean
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

cd /scratch2/kerenxu/wgs.smoking.out/bqsr.bam

for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   normal_bam=($(ls GM_*.aligned.duplicates_marked.recalibrated.bam | sed -n ${i}p))
   base=$(basename ${normal_bam} .aligned.duplicates_marked.recalibrated.bam)
   prefix="GM_"
   sample_name=${base#"$prefix"}

   cp /scratch/kerenxu/wgs.smoking.out/manta.config/$sample_name/results/variants/somaticSV.vcf.gz /scratch/kerenxu/wgs.smoking.out/manta.config/manta.out/$sample_name.somaticSV.vcf.gz

   cp /scratch/kerenxu/wgs.smoking.out/manta.config/$sample_name/results/variants/somaticSV.vcf.gz.tbi /scratch/kerenxu/wgs.smoking.out/manta.config/manta.out/$sample_name.somaticSV.vcf.gz.tbi

done
