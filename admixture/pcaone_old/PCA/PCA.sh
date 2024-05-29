#!/usr/bin/env bash
module load plink/1.9.0

inputpath=$"/maps/projects/seqafrica/scratch/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly_norelated"

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" ## removed Tbux and Scaf

do
{
mkdir $species
cd $species

###gen plink file for input
awk -v species="$species" '$1 ~ "^" species {print $1, $2}' "$inputpath.fam" > keep_list.txt
plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --maf 0.05 --geno 0.1 --mind 0.1 --make-bed --out plink_pre

if [ "$species" = "Tder" ]
then
nice PCAone -k 7 -b plink_pre -n 20
else
nice PCAone -k 20 -b plink_pre -n 20
fi

Rscript -e 'pdf("plot.pdf");df=read.table("pcaone.eigvecs", h=F);plot(df[,1:2], xlab="PC1", ylab="PC2");dev.off();'
} &
done
