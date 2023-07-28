# GATK4 mitochondria SNPs and INDELs pipeline

This is an HPC workflow to call SNPs and INDELs in the mitochondrial genome from matched tumor-normal whole genome sequencing (WGS) data from 25 childhood acute lymphoblastic leukemia cases. This workflow is largely based on [GATK's best practice WDL](https://github.com/broadinstitute/gatk/blob/master/scripts/mitochondria_m2_wdl/MitochondriaPipeline.wdl). Check out [GATK's doc](https://github.com/broadinstitute/gatk-docs/blob/master/blog-2012-to-2019/2019-03-05-New!_Mitochondrial_Analysis_with_Mutect2.md?id=23598) for more details.

## Step 0: Download GATK's public reference databases

- [0.1.Download.sh](./0.1.Download.sh)

## Step 1: Subset a whole genome bam to just Mitochondria reads and remove alignment information

- [1.1.SubsetBamToChrM.sh](./1.1.SubsetBamToChrM.sh)
- [1.2.RevertSam.sh](./1.2.RevertSam.sh)

## Step 2: Align unmapped bam, mark duplicates, collect coverage information, and call SNPs and INDELs from normal bams

- [2.1.AlignToMt.sh](./2.1.AlignToMt.sh)
- [2.2.AlignToShiftedMt.sh](./2.2.AlignToShiftedMt.sh)
- [2.3.1.CollectWgsMetrics.sh](./2.3.1.CollectWgsMetrics.sh)
- [2.3.2.CollectWgsMetrics.R](./2.3.2.CollectWgsMetrics.R)
- [2.3.3.RunCollectWgsMetricsR.sh](./2.3.3.RunCollectWgsMetricsR.sh)
- [2.4.CallMt.Germline.sh](./2.4.CallMt.Germline.sh)
- [2.5.CallShiftedMt.Germline.sh](./2.5.CallShiftedMt.Germline.sh)
- [2.6.LiftoverAndCombineVcfs.sh](./2.6.LiftoverAndCombineVcfs.sh)
- [2.7.MergeStats.sh](./2.7.MergeStats.sh)
- [2.8.InitialFilter.sh](./2.8.InitialFilter.sh)
- [2.9.SplitMultiAllelicsAndRemoveNonPassSites.sh](./2.9.SplitMultiAllelicsAndRemoveNonPassSites.sh)

## Step 3: Call SNPs and INDELs from tumor bams

- [3.1.CallMt.Tumor.sh](./3.1.CallMt.Tumor.sh)
- [3.2.CallShiftedMt.Tumor.sh](./3.2.CallShiftedMt.Tumor.sh)
- [3.3.LiftoverAndCombineVcfs.Tumor.sh](./3.3.LiftoverAndCombineVcfs.Tumor.sh)
- [3.4.MergeStats.Tumor.sh](./3.4.MergeStats.Tumor.sh)
- [3.5.InitialFilter.Tumor.sh](./3.5.InitialFilter.Tumor.sh)
- [3.6.SplitMultiAllelicsAndRemoveNonPassSites.sh](./3.6.SplitMultiAllelicsAndRemoveNonPassSites.sh)

## Step 4: Estimate levels of contamination in mitochondria

- [4.1.GetContamination.sh](./4.1.GetContamination.sh)
- [4.2.FilterContamination.sh](./4.2.FilterContamination.sh)
