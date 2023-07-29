# CNV calling pipeline

This is a pipeline for calling copy number variations from 76 matched tumor-normal whole genome sequencing (WGS) bams from 38 childhood acute lymphoblastic leukemia cases. BAM files have been preprocessed by the [data preprocessing pipeline](../gatk_data_preprocessing/). Check out these GATK best practice documents:

- [cnv_somatic_pair_workflow WDL](https://github.com/broadinstitute/gatk/blob/master/scripts/cnv_wdl/somatic/cnv_somatic_pair_workflow.wdl)
- [(How to part I) Sensitively detect copy ratio alterations and allelic segments](https://gatk.broadinstitute.org/hc/en-us/articles/360035531092)
- [(How to part II) Sensitively detect copy ratio alterations and allelic segments](https://gatk.broadinstitute.org/hc/en-us/articles/360035890011--How-to-part-II-Sensitively-detect-copy-ratio-alterations-and-allelic-segments)
- [legacy tutorial](https://sites.google.com/a/broadinstitute.org/legacy-gatk-forum-discussions/tutorials/11683--how-to-part-ii-sensitively-detect-copy-ratio-alterations-and-allelic-segments)

## GATK somatic CNV calling pipeline:

from `0.0.ExtractIntervalfromPON.sh` to `1.9.FuncotateSegments.sh`

Best practice workflow. A figure from GITC.

<p align="center">
<img src='../_static/gatkcnv.png' width='300'>
</p>

## CNVkit pipeline

from `2.0.CnvkitAccess.sh` to `2.3.1.Iamp21CnvkitPlot.sh`

## Preprocessing to create Theta inputs

- [3.1.CnvkitTheta.sh](3.1.CnvkitTheta.sh)
- [3.2.CnvkitImportTheta.sh](3.2.CnvkitImportTheta.sh)

## Gistic pipeline

- [4.1.GisticCnvkitExportSeg.sh](4.1.GisticCnvkitExportSeg.sh)
- [4.2.GisticMergeSegment.R](4.2.GisticMergeSegment.R)
- [4.3.Gistic.sh](4.3.Gistic.sh)
