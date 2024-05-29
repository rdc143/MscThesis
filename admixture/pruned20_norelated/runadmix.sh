#!/usr/bin/env bash
module load plink/1.9.0

inputpath=$"/maps/projects/seqafrica/scratch/rdc143/trag_analyses/bed/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly_norelated"
threads=50
admixit=100 # max no. of runs of admixture for each K

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" ## removed Tbux and Scaf
#for species in "Tder"
do

{
mkdir $species
cd $species


###inds in species
awk -v species="$species" '$1 ~ "^" species {print $1, $2}' "$inputpath.fam" > keep_list.txt

K=$(cut --delimiter " " -f1 keep_list.txt | sort | uniq | wc -l) #no. of sampling localities/countries


###gen plink file for input
plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --maf 0.05 --geno 0.1 --mind 0.1 --make-bed --out plink_pre


# change variant ID's
awk '{$2 = $1"_"$4}1' plink_pre.bim > plink_pre.bim.tmp
mv plink_pre.bim.tmp plink_pre.bim


# ld prune
plink --allow-extra-chr --bfile plink_pre --indep-pairwise 500 25 0.2
plink --allow-extra-chr --bfile plink_pre --make-bed --out plink --extract plink.prune.in


# change chr names
awk 'BEGIN {FS = "\t"; OFS = "\t"} {
    if (!($1 in mapping)) {
        mapping[$1] = ++counter;
    }
    $1 = mapping[$1];
    print;
}' plink.bim > plink.bim.tmp

mv plink.bim.tmp plink.bim


### admixture convergence loop
for i in $(seq 2 $((K+3)))
do
if [ $i -gt 9 ]; then
        break
fi

### run admix a no. of times
for j in $(seq 1 $admixit)
do

nice admixture plink.bed $i -j$threads --seed $j
mv plink.$i.P plink.$i.P.$j.tmp
mv plink.$i.Q plink.$i.Q.$j.tmp

grep Loglikelihood: ../$species.log | tail -n1 | cut -f2 --delimiter " " >> ll.$i.txt 
CONV=`Rscript -e "r<-read.table('./ll.$i.txt');r<-r[order(-r[,1]),];cat(sum(r[1]-r<10),'\n')"` # how many top ll's are roughly equal

		if [ $CONV -gt 2 ]  #-gt 2 = greater than 2
		then
		    bestit=$(awk '{print $1, NR}' ll.$i.txt | sort -nr | head -n1 | cut -d' ' -f2)
        mv plink.$i.P.$bestit.tmp plink.$i.P 
        mv plink.$i.Q.$bestit.tmp plink.$i.Q
        rm ./*.tmp
		break
		fi

done

###eval
nind=$(wc -l plink.fam | cut -f1 --delimiter " ")

if [[ $nind -gt $threads ]]
then
evalAdmix -plink plink -fname plink.$i.P -qname plink.$i.Q -P $threads -o output.corres.$i.txt
else
evalAdmix -plink plink -fname plink.$i.P -qname plink.$i.Q -P $nind -o output.corres.$i.txt
fi

Rscript /maps/projects/seqafrica/scratch/rdc143/trag_analyses/admixture/plotAdmix.R plink.fam plink.$i.Q output.corres.$i.txt $species.$i.pdf

done
###combine pdfs
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=../$species.all.pdf *.pdf

cd ..
} &> $species.log & 

done
