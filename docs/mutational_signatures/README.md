# Mutational Signatures Pipelines

This is a pipeline that detects mutational signatures from VCF files that have been processed by [GATK Mutect2 pipeline](../gatk_somatic_snv_indel/). This pipeline uses 5 different algorithms.

## Sigprofiler

- [step1.Sigprofiler.py](./step1.Sigprofiler.py)

## pmsignature

- [step2.Pmsignature.R](./step2.Pmsignature.R)

## deconstructSigs

- [step3.DeconstructSigs.R](step3.DeconstructSigs.R)

## Signal website

- [step4.SignalSummary.Rmd](step4.SignalSummary.Rmd)
- [step4.SignalKataegis.Rmd](step4.SignalKataegis.Rmd)

## FitMS

- [step5.FitMS.Rmd](./step5.FitMS.Rmd)
