#!/usr/bin/env bash
module load gsl/2.5 perl bcftools

beagle4=/maps/projects/seqafrica/people/rlk420/bos/imputation/beagle.27Jan18.7e1.jar

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" "Tbux" "Scaf" "ToryTstr"
do
cd $species
{

    bcftools filter -i 'AR2>0.9' results/imputed/all.imputed.vcf.gz -Oz -o results/$species.infofiltered.vcf.gz

    java -Xss5m -Xmx60g -Djava.io.tmpdir=./results -jar $beagle4 gt=results/$species.infofiltered.vcf.gz out=$species.phased nthreads=40 

} &> filter_and_phase.log &
cd ..
done