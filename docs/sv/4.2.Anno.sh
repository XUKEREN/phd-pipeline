#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch2/kerenxu/output/AnnotSV_%A_%a.out
#SBATCH --error=/scratch2/kerenxu/error/AnnotSV_%A_%a.errcd
#SBATCH --job-name=AnnotSV
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main

cd /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/two_caller

for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.merged.vcf | sed -n ${i}p))

   $ANNOTSV/bin/AnnotSV -SVinputFile /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/two_caller/$input_vcf -genomeBuild GRCh38 -outputDir /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/AnnotSV_out_two_caller -SVminSize 10 -hpo "HP:0006721"
done

# upload  $ANNOTSV/etc/AnnotSV/application.properties file  to enable Exomiser_gene_pheno_score annotation
