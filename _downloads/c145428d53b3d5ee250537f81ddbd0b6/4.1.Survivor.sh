# filter each vcf for lumpy
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *-smoove.genotyped.vcf.gz | sed -n ${i}p))
   base=$(basename ${input_vcf} -smoove.genotyped.vcf.gz)
   prefix="sample"
   sample_name=${base#"$prefix"}
   output_vcf="$sample_name.somaticSV.smoove.vcf.gz"

   bcftools view $input_vcf -Ou -i 'FMT/GT[1]=="0/0"' | bcftools view -Ou -i 'FMT/GT[0]=="0/1"||FMT/GT[0]=="1/1"' | bcftools view -s ^GM_$sample_name -o somatic/$output_vcf -O z --threads 15

done

## bgzip -d vcf.gz in a directory
for f in *.vcf.gz; do
   bgzip -d "$f"
done

## sort using bcftools
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somaticSV.smoove.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somaticSV.smoove.vcf)
   output_vcf="$base.somaticSV.smoove.sorted.vcf"

   bcftools sort $input_vcf >sorted/$output_vcf

done

# filter each vcf for manta
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somaticSV.vcf.gz | sed -n ${i}p))
   base=$(basename ${input_vcf} .somaticSV.vcf.gz)
   output_vcf="$base.somaticSV.manta.vcf"

   bcftools view $input_vcf -s ^GM_$base -o somatic/$output_vcf

done

## sort using bcftools
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somaticSV.manta.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somaticSV.manta.vcf)
   output_vcf="$base.somaticSV.manta.sorted.vcf"

   bcftools sort $input_vcf >sorted/$output_vcf

done

## only inlude PASSED variants for manta
# SV quality filtering
cd /scratch/kerenxu/wgs.smoking.out/survivor.out/manta.vcf/
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somaticSV.manta.sorted.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somaticSV.manta.sorted.vcf)
   output_vcf="$base.somaticSV.manta.sorted.passed.vcf"

   bcftools view $input_vcf -i "FILTER == 'PASS'" -o /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/manta.passed.vcf/$output_vcf

done

# filter each vcf for delly
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somatic.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somatic.vcf)
   output_vcf="$base.somatic.vcf"

   bcftools view $input_vcf -s TM_$base | bcftools view -i 'FMT/GT=="0/1"||FMT/GT=="1/1"' -o somatic/$output_vcf

done

## sort using bcftools
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somatic.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somatic.vcf)
   output_vcf="$base.somaticSV.delly.sorted.vcf"

   bcftools sort $input_vcf >sorted/$output_vcf

done

## only inlude PASSED variants for delly
# SV quality filtering
cd /scratch/kerenxu/wgs.smoking.out/survivor.out/delly.vcf/
for i in {1..38}; do
   echo "Welcome $i times"
   ## input:
   input_vcf=($(ls *.somaticSV.delly.sorted.vcf | sed -n ${i}p))
   base=$(basename ${input_vcf} .somaticSV.delly.sorted.vcf)
   output_vcf="$base.somaticSV.delly.sorted.passed.vcf"

   bcftools view $input_vcf -i "FILTER == 'PASS'" -o /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/delly.passed.vcf/$output_vcf

done

# run SURVIVOR
cd /dir/wgs.all.smoking/wgs.smoking.out/survivor.out
for i in {1..38}; do
   echo "Welcome $i times"

   ## input:
   cd lumpy.passed.vcf
   input_vcf=($(ls *.somaticSV.smoove.sorted.vcf | sed -n ${i}p))
   sample_name=$(basename ${input_vcf} .somaticSV.smoove.sorted.vcf)

   cd ../

   # delly
   delly_vcf=./delly.passed.vcf/$sample_name.somaticSV.delly.sorted.passed.vcf

   # manta
   manta_vcf=./manta.passed.vcf/$sample_name.somaticSV.manta.sorted.passed.vcf

   # lumpy
   lumpy_vcf=./lumpy.passed.vcf/$sample_name.somaticSV.smoove.sorted.vcf

   ls $delly_vcf $manta_vcf $lumpy_vcf >/dir/wgs.all.smoking/wgs.smoking.out/survivor.out/two_caller/$sample_name.files

   SURVIVOR merge ./two_caller/$sample_name.files 100 2 0 0 0 0 /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/two_caller/$sample_name.merged.vcf

   # perl -ne 'print "$1\n" if /SUPP_VEC=([^,;]+)/' $sample_name.merged.vcf | sed -e 's/\(.\)/\1 /g' > $sample_name.merged.overlapp.txt

done

# This will merge all the vcf files specified in sample_files together using a maximum allowed distance of 1kb, as measured pairwise between breakpoints (begin1 vs begin2, end1 vs end2). Furthermore we ask SURVIVOR only to report calls supported by 2 callers and they have to agree on the type (1) and on the strand (1) of the SV. Note you can change this behavior by altering the numbers from 1 to e.g. 0. In addition, we told SURVIVOR to only compare SV that are at least 30bp long and print the output in sample_merged.vcf.

# run SURVIVOR for at least 1 caller
for i in {1..38}; do
   echo "Welcome $i times"

   ## input:
   cd lumpy.passed.vcf
   input_vcf=($(ls *.somaticSV.smoove.sorted.vcf | sed -n ${i}p))
   sample_name=$(basename ${input_vcf} .somaticSV.smoove.sorted.vcf)

   cd ../

   # delly
   delly_vcf=./delly.passed.vcf/$sample_name.somaticSV.delly.sorted.passed.vcf

   # manta
   manta_vcf=./manta.passed.vcf/$sample_name.somaticSV.manta.sorted.passed.vcf

   # lumpy
   lumpy_vcf=./lumpy.passed.vcf/$sample_name.somaticSV.smoove.sorted.vcf

   ls $delly_vcf $manta_vcf $lumpy_vcf >/dir/wgs.all.smoking/wgs.smoking.out/survivor.out/one_caller/$sample_name.files

   SURVIVOR merge ./one_caller/$sample_name.files 100 1 0 0 0 0 /dir/wgs.all.smoking/wgs.smoking.out/survivor.out/one_caller/$sample_name.merged.vcf

   # perl -ne 'print "$1\n" if /SUPP_VEC=([^,;]+)/' $sample_name.merged.vcf | sed -e 's/\(.\)/\1 /g' > $sample_name.merged.overlapp.txt

done
