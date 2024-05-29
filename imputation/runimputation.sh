#!/usr/bin/env bash
module load gsl/2.5 perl bcftools

input="/maps/projects/seqafrica/scratch/rdc143/trag_analyses/imputation/rename/BosTau9_tragmain2_sites_variable_noindels_renamed.bcf.gz"

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" "Tbux" "Scaf"
do
mkdir $species
cd $species

{
bcftools view -S <(bcftools query -l $input | grep $species ) $input -O b -o Bostau9_tragmain2_sites_variable_noindels_renamed_$species.bcf.gz --threads 20
bcftools index Bostau9_tragmain2_sites_variable_noindels_renamed_$species.bcf.gz --threads 20
bash /maps/projects/seqafrica/people/rlk420/bos/imputation/beagle4-imputation.sh -i Bostau9_tragmain2_sites_variable_noindels_renamed_$species.bcf.gz -o results -f 0.05
} &> $species.log & 

cd ..
done

mkdir ToryTstr
cd ToryTstr
bcftools view -S <(bcftools query -l $input | grep -e '^Tory' -e '^Tstr') $input -O b -o Bostau9_tragmain2_sites_variable_noindels_renamed_ToryTstr.bcf.gz --threads 20
bcftools index Bostau9_tragmain2_sites_variable_noindels_renamed_ToryTstr.bcf.gz --threads 20
bash /maps/projects/seqafrica/people/rlk420/bos/imputation/beagle4-imputation.sh -i Bostau9_tragmain2_sites_variable_noindels_renamed_ToryTstr.bcf.gz -o results -f 0.05