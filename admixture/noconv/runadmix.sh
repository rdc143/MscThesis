#!/usr/bin/env bash
module load plink/1.9.0

inputpath=$"/maps/projects/seqafrica/scratch/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly"
threads=40
admixit=5 # no. of runs of admixture for each K

for species in "Tory" "Tder" "Tstr" "Timb" "Scaf" "Tspe" ## removed Tbux, only one location
#for species in "Scaf"
do

{
mkdir $species
cd $species

###inds in species
awk -v species="$species" '$1 ~ "^" species {print $1, $2}' "$inputpath.fam" > keep_list.txt

K=$(cut --delimiter " " -f1 keep_list.txt | sort | uniq | wc -l) #no. of sampling localities/countries

###gen plink file for input
plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --maf 0.01 --geno 0.1 --make-bed --out plink

# change chr names
awk 'BEGIN {FS = "\t"; OFS = "\t"} {
    if (!($1 in mapping)) {
        mapping[$1] = ++counter;
    }
    $1 = mapping[$1];
    print;
}' plink.bim > plink.bim.tmp

mv plink.bim.tmp plink.bim


for i in $(seq 2 $((K+3)))
do
if [ $i -gt 9 ]; then
        break
fi

###run admix a no. of times
for j in $(seq 1 $admixit)
do

admixture plink.bed $i -j$threads --seed $j
mv plink.$i.P plink.$i.P.$j.tmp
mv plink.$i.Q plink.$i.Q.$j.tmp
grep Loglikelihood: ../$species.log | tail -n1 | cut -f2 --delimiter " " >> ll.$i.txt 

done

###keep admix res with best ll
bestit=$(awk '{print $1, NR}' ll.$i.txt | sort -nr | head -n1 | cut -d' ' -f2)
mv plink.$i.P.$bestit.tmp plink.$i.P 
mv plink.$i.Q.$bestit.tmp plink.$i.Q
rm ./*.tmp

###eval
nind=$(wc -l plink.fam | cut -f1 --delimiter " ")

if [[ $nind -gt $threads ]]
then
evalAdmix -plink plink -fname plink.$i.P -qname plink.$i.Q -P $threads -o output.corres.$i.txt
else
evalAdmix -plink plink -fname plink.$i.P -qname plink.$i.Q -P $nind -o output.corres.$i.txt
fi

Rscript ../plotAdmix.R plink.fam plink.$i.Q output.corres.$i.txt $species.$i.pdf

done
###combine pdfs
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$species.all.pdf *.pdf

cd ..
} &> $species.log & 

done
