# Calling Structural Variations

This is an HPC pipeline for calling structural variations using three software from 76 matched tumor-normal whole genome sequencing (WGS) bams from 38 childhood acute lymphoblastic leukemia cases.

## Smoove (lumpy)

- [1.1.PreMergeSVPerSampleSmoove.sh](1.1.PreMergeSVPerSampleSmoove.sh)
- [1.2.SmooveUnionSites.sh](1.2.SmooveUnionSites.sh)
- [1.3.SmooveGenotype.sh](1.3.SmooveGenotype.sh)
- [1.4.SmoovePasteAnnotate.sh](1.4.SmoovePasteAnnotate.sh)

## Manta

- [2.1.PreMergeSVPerSampleMantaconfigure.sh](2.1.PreMergeSVPerSampleMantaconfigure.sh)
- [2.2.MantaWorkflow.sh](2.2.MantaWorkflow.sh)
- [2.3.MantaClean.sh](2.3.MantaClean.sh)

## Delly

- [3.1.DellyPerSampleCall.sh](3.1.DellyPerSampleCall.sh)
- [3.2.DellyPrefilter.sh](3.2.DellyPrefilter.sh)
- [3.3.DellyGeno.sh](3.3.DellyGeno.sh)
- [3.4.DellyPostfilter.sh](3.4.DellyPostfilter.sh)
- [3.5.DellyBcf2vcf.sh](3.5.DellyBcf2vcf.sh)

## Finding variants that were called by at least 2 callers

- [4.1.Survivor.sh](4.1.Survivor.sh)

## Annotate variants

- [4.2.Anno.sh](4.2.Anno.sh)

## Create Venn diagram, histograms and html files

- [4.3.Summary.sh](4.3.Summary.sh)

an example Venn graph:

<p align="center">
<img src='../_static/venn.png' width='400'>
</p>
