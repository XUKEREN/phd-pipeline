# get the total number of reads of a BAM file (may include unmapped and duplicated multi-aligned reads)
samtools view -c SAMPLE.bam

# counting only mapped (primary aligned) reads
samtools view -c -F 260 SAMPLE.bam

samtools flagstat *.bam
