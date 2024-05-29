#!/usr/bin/env bash
module load gsl/2.5 perl bcftools

input="/maps/projects/seqafrica/scratch/rdc143/trag_analyses/imputation/rename/BosTau9_tragmain2_sites_variable_noindels_renamed.bcf.gz"

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" "Tbux" "Scaf" "ToryTstr"
do
cd $species

### concat
#bash /maps/projects/seqafrica/people/rlk420/bos/imputation/concat.sh -i Bostau9_tragmain2_sites_variable_noindels_renamed_$species.bcf.gz -o results -f 0.05

### plot
Rscript ../plot-r2-vs-maf.R results/imputed/all.imputed.vcf.gz.stats $species.r2vMAF
cd ..
done