#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --output=/scratch2/kerenxu/output/gistic_%A_%a.out
#SBATCH --error=/scratch2/kerenxu/error/gistic_%A_%a.errcd
#SBATCH --job-name=gistic
#SBATCH -c 15
#SBATCH --ntasks=1
#SBATCH --mem=59G
#SBATCH --partition debug

cd /dir/kerenxu/tools/gistic-2.0.23/

## input:
seg_file=/scratch/kerenxu/gistic.seg/gistic_38_input.seg
## output directory
basedir=/scratch1/kerenxu/gistic.out

refgenefile=/dir/kerenxu/tools/gistic-2.0.23/refgenefiles/hg38.UCSC.add_miR.160920.refgene.mat

# default
./gistic2 -b $basedir -seg $seg_file -refgene $refgenefile -genegistic 1 -smallmem 0 -conf 0.75 -savegene 1 -maxseg 4000 -qvt 0.25

# qvalue 0.01
./gistic2 -b $basedir -seg $seg_file -refgene $refgenefile -genegistic 1 -smallmem 0 -conf 0.75 -savegene 1 -maxseg 4000 -qvt 0.01

# try arm level
./gistic2 -b $basedir -seg $seg_file -refgene $refgenefile -genegistic 1 -smallmem 0 -broad 1 -brlen 0.7 -twoside 1 -conf 0.99 -gcm extreme -armpeel 1 -savegene 1 -qvt 0.25
