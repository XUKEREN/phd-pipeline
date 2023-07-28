#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch/kerenxu/output/GetContamination_%A_%a.out
#SBATCH --error=/scratch/kerenxu/error/GetContamination_%A_%a.errcd
#SBATCH --job-name=GetContamination
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition main
#SBATCH --array=1-50

export PATH="/dir/kerenxu/tools/gatk-4.1.8.1/:$PATH"
srun hostname
cd /scratch2/kerenxu/chrM/
ref_fasta=/dir/kerenxu/refs/GATK_resource_bundle/chrM_ref/Homo_sapiens_assembly38.chrM.fasta

## input vcf
input_vcf=($(ls *.chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz | sed -n ${SLURM_ARRAY_TASK_ID}p))
base=$(basename ${input_vcf} .chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf.gz)

# description: "Uses new Haplochecker to estimate levels of contamination in mitochondria"

mkdir $base
cp $input_vcf $base/$input_vcf
PARENT_DIR="$(dirname "$input_vcf")"
cd $base
bgzip -d $input_vcf

java -jar /dir/kerenxu/tools/haplocheckCLI/haplocheckCLI/haplocheckCLI.jar "${PARENT_DIR}"

sed 's/\"//g' output >output-noquotes

grep "Sample" output-noquotes >headers
FORMAT_ERROR="Bad contamination file format"
if [ $(awk '{print $2}' headers) != "Contamination" ]; then
  echo $FORMAT_ERROR
  exit 1
fi
if [ $(awk '{print $6}' headers) != "HgMajor" ]; then
  echo $FORMAT_ERROR
  exit 1
fi
if [ $(awk '{print $8}' headers) != "HgMinor" ]; then
  echo $FORMAT_ERROR
  exit 1
fi
if [ $(awk '{print $14}' headers) != "MeanHetLevelMajor" ]; then
  echo $FORMAT_ERROR
  exit 1
fi
if [ $(awk '{print $15}' headers) != "MeanHetLevelMinor" ]; then
  echo $FORMAT_ERROR
  exit 1
fi

grep -v "SampleID" output-noquotes >output-data
awk -F "\t" '{print $2}' output-data >contamination.txt
awk -F "\t" '{print $6}' output-data >major_hg.txt
awk -F "\t" '{print $8}' output-data >minor_hg.txt
awk -F "\t" '{print $14}' output-data >mean_het_major.txt
awk -F "\t" '{print $15}' output-data >mean_het_minor.txt

rm $base.chrM.merged.filtered.VariantFiltration.splitAndPassOnly.vcf
