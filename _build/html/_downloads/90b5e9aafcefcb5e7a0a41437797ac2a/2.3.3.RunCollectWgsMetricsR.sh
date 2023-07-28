#!/bin/bash
# script to run Rscript in a loop
cd /scratch2/kerenxu/chrM/
for i in {1..50}; do
      echo "Welcome $i times"

      input_file=($(ls *.AlignToMt.bam.CollectWgsMetrics.metrics.txt | sed -n ${i}p))
      base=$(basename ${input_file} .AlignToMt.bam.CollectWgsMetrics.metrics.txt)
      Rscript --vanilla CollectWgsMetrics.R $base
done
