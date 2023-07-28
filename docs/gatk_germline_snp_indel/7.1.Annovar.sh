#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/annovar_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/annovar_%A_%a.errcd
#SBATCH --job-name=annovar
#SBATCH -c 20
#SBATCH --ntasks=1
#SBATCH --mem=246G
#SBATCH --partition epyc-64

export PATH="/scratch2/kerenxu/tools/htslib/htslib-1.10.2/:$PATH"
export PATH="/scratch2/kerenxu/tools/bcftools/bcftools-1.10.2/:$PATH"

cd /scratch/kerenxu/wgs.smoking.out/HaplotypeCaller.out

WGSNV=/dir/kerenxu/refs/snp_databases/cadd/whole_genome_SNVs.tsv.gz
INDELS=/dir/kerenxu/refs/snp_databases/cadd/InDels.tsv.gz
CADD=/dir/kerenxu/refs/snp_databases/cadd/cadd.hdr
TOPMED=/dir/kerenxu/refs/snp_databases/topmed/bravo-dbsnp-all.tsv.gz

table_annovar.pl smoking.38cohort.filtered.CalculateGenotypePosteriors.GQ_filtered.denovo_anno.vcf.gz /project/desmith_488/kerenxu/refs/snp_databases/humandb/ -buildver hg38 -out annotated -remove -protocol refGene,cytoBand,exac03,ALL.sites.2015_08,avsnp150,dbnsfp42c,gnomad211_genome,clinvar_20210501 -operation g,r,f,f,f,f,f,f -vcfinput --dot2underline --polish -xref /project/desmith_488/kerenxu/tools/annovar/example/gene_fullxref.txt --thread 20 --nastring .

awk '{gsub(/^chr/,""); print}' annotated.hg38_multianno.vcf >annotated.hg38_multianno_no_chr.vcf
bgzip annotated.hg38_multianno_no_chr.vcf
tabix annotated.hg38_multianno_no_chr.vcf.gz
bcftools annotate -a $INDELS -h $CADD -c Chrom,Pos,Ref,Alt,RawScore,PHRED annotated.hg38_multianno_no_chr.vcf.gz -O z -o annotated.hg38_cadd_indel_output.vcf.gz --threads 20
bcftools annotate -a $WGSNV -h $CADD -c Chrom,Pos,Ref,Alt,RawScore,PHRED annotated.hg38_cadd_indel_output.vcf.gz -O z -o annotated.hg38_cadd_wg_output.vcf.gz --threads 20
tabix annotated.hg38_cadd_wg_output.vcf.gz
bcftools annotate -a $TOPMED -h $CADD -c Chrom,Pos,Ref,Alt,TOPMED annotated.hg38_cadd_wg_output.vcf.gz -O z -o anno.hg38_cadd_wgsnv_topmed.vcf.gz --threads 20
tabix anno.hg38_cadd_wgsnv_topmed.vcf.gz

# ANNOVAR download datasets
# download gene databases
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar refGene humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar knownGene humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar ensGene humandb/

# filter-based annotation
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp42c humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar exac03 humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar gnomad211_genome humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar 1000g2015aug humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp150 humandb/
annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20210501 humandb/
annotate_variation.pl -buildver hg38 -downdb cytoBand humandb/

annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp42c humandb/
