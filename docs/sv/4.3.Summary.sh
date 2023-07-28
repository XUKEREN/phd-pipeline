# venn_extract.R
args <- commandArgs(trailingOnly = TRUE)
input=args[1]
library(tidyverse)
library(data.table)
library(vcfR)
read.vcfR(paste0(input,".merged.vcf")) -> a
vcfR2tidy(a) -> a
a <- a$fix %>% select(SVTYPE, SUPP_VEC, SUPP)
a$sample <- paste0(input)
fwrite(a, paste0(input, ".venn.txt"))

# bash file 
cd /scratch/kerenxu/wgs.smoking.out/survivor.out/one_caller/
for i in {1..38}
do
   echo "Welcome $i times"

input_file=(`ls *.merged.vcf | sed -n ${i}p`)
base=$(basename ${input_file} .merged.vcf)
Rscript --vanilla venn_extract.R $base
done

# RUN VENN diagram 
cd /Users/kerenxu/Documents/@USC/00research/2021_teeth_tumor_WGS/Anno_SV/venn.matrix.one_caller/
for i in {1..38}
do
   echo "Welcome $i times"

input_file=(`ls *.venn.txt | sed -n ${i}p`)
base=$(basename ${input_file} .venn.txt)
Rscript --vanilla ../venn_plot.R $base
done

# knotAnnotSV
for i in {1..38}
do
   echo "Welcome $i times"
cd /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/AnnotSV_out_two_caller
input_file=(`ls *.merged.annotated.tsv | sed -n ${i}p`)
base=$(basename ${input_file} .merged.annotated.tsv)

perl /Users/kerenxu/Documents/@USC/00research/2021_teeth_tumor_WGS/tools/knotAnnotSV/knotAnnotSV.pl --annotSVfile /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/AnnotSV_out_two_caller/$input_file --configFile /Users/kerenxu/Documents/@USC/00research/2021_teeth_tumor_WGS/tools/knotAnnotSV/config_AnnotSV.yaml --outDir /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/knotAnnotSV_out_two_caller --genomeBuild hg38
done


# knotAnnotSV for one caller 
for i in {1..38}
do
   echo "Welcome $i times"
cd /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/AnnotSV_out_one_caller
input_file=(`ls *.merged.annotated.tsv | sed -n ${i}p`)
base=$(basename ${input_file} .merged.annotated.tsv)

perl /Users/kerenxu/Documents/@USC/00research/2021_teeth_tumor_WGS/tools/knotAnnotSV/knotAnnotSV.pl --annotSVfile /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/AnnotSV_out_one_caller/$input_file --configFile /Users/kerenxu/Documents/@USC/00research/2021_teeth_tumor_WGS/tools/knotAnnotSV/config_AnnotSV.yaml --outDir /Users/kerenxu/Documents/@USC/00research/2021_WGS_ALL_smoking/sv/knotAnnotSV_out_one_caller --genomeBuild hg38
done