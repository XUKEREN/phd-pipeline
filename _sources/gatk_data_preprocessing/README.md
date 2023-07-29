# Data pre-processing for variant discovery GATK4

An HPC workflow that pre-processes 50 matched tumor-normal whole genome sequencing (WGS) fastq files from 25 childhood acute lymphoblastic leukemia cases. WGS data were from Illumina NovaSeq 6000 Sequencing. Check out [gatk doc](https://gatk.broadinstitute.org/hc/en-us/articles/360035535912-Data-pre-processing-for-variant-discovery) for more details.

This workflow was written according to the following GATK official WDLs:

- Detailed versions:
  - https://github.com/gatk-workflows/gatk4-genome-processing-pipeline/blob/master/tasks/UnmappedBamToAlignedBam.wdl
  - https://github.com/gatk-workflows/gatk4-genome-processing-pipeline/blob/master/WholeGenomeGermlineSingleSample.wdl
- Simple version:
  - https://github.com/gatk-workflows/gatk4-data-processing/blob/master/processing-for-variant-discovery-gatk4.wdl
  - Detailed documents for this simple version: https://github.com/broadgsa/gatk/blob/master/doc_archive/methods/Reference_implementation:_PairedEndSingleSampleWf_pipeline.md#SortAndFixTags
- Other tutorials:
  - [A practical introduction to GATK 4 on Biowulf (NIH HPC)](https://hpc.nih.gov/training/gatk_tutorial/bqsr.html)
  - [(howto) Recalibrate base quality scores = run BQSR](<https://github.com/broadgsa/gatk/blob/master/doc_archive/tutorials/(howto)_Recalibrate_base_quality_scores_%3D_run_BQSR.md>)

## The main steps in the preprocessing workflow. A figure from GITC.

<p align="center">
<img src='../_static/MainStepsInPreprocessingWorkflow.png' width='250'>
</p>

## Step 0: QC

- [0.1.Fastqc.sh](./0.1.Fastqc.sh)

## Step 1: Fastqs to Unmapped BAMs

- [1.1.PairedFastqToUnmappedBam.sh](1.1.PairedFastqToUnmappedBam.sh)
- [1.2.ValidateSamFile.sh](1.2.ValidateSamFile.sh)
- [1.3.SortSam.sh](1.3.SortSam.sh)

## Step 2: Unmapped BAMs to Mapped BAMs

- [2.1.Bwa.sh](2.1.Bwa.sh)
- [2.2.SortAlignedBam.sh](2.2.SortAlignedBam.sh)
- [2.3.ValidateAlignedBam.sh](2.3.ValidateAlignedBam.sh)
- [2.4.CheckIfAltAwareAlign.sh](2.4.CheckIfAltAwareAlign.sh)

## Step 3: Merge Unmapped BAMs and Mapped BAMs

- [3.1.MergeBamAlignment.sh](3.1.MergeBamAlignment.sh)
- [3.2.ValidateMergedBam.sh](3.2.ValidateMergedBam.sh)
- [3.3.CountReads.sh](3.3.CountReads.sh)

## Step 4: MarkDuplicates

- [4.1.MarkDuplicates.sh](4.1.MarkDuplicates.sh)
- [4.2.SortAndFixTags.sh](4.2.SortAndFixTags.sh)
- [4.3.ValidateSortedMarkedBam.sh](4.3.ValidateSortedMarkedBam.sh)

## Step 5: Base Quality Score Recalibration

- [5.1.BaseRecalibrator.sh](5.1.BaseRecalibrator.sh)
- [5.2.BqsrPlot.sh](5.2.BqsrPlot.sh)
- [5.3.BqsrPlot.Rmd](5.3.BqsrPlot.Rmd)
