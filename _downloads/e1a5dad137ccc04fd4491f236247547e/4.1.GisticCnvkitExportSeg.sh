export PATH="/dir/kerenxu/SINGULARITY_CACHEDIR/:$PATH"

for i in {1..38}; do
   echo "Welcome $i times"

   cd /scratch/kerenxu/wgs.smoking.out/cnvkit.out

   ## input:
   input_cns=($(ls T*.aligned.duplicates_marked.recalibrated.cns | sed -n ${i}p))
   base=$(basename ${input_cns} .aligned.duplicates_marked.recalibrated.cns)

   # From an existing CNVkit reference
   singularity exec /dir/kerenxu/SINGULARITY_CACHEDIR/cnvkit_latest.sif cnvkit.py export seg $input_cns -o /scratch/kerenxu/gistic.seg/$base.seg

done
