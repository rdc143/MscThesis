#!/usr/bin/env bash
module load plink/1.9.0

inputpath="/home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout"

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" "Scaf" "Tbux"
do
    mkdir $species -p
    cd $species
    {
        awk -v species="$species" '$1 ~ "^" species {print $1, $2}' "$inputpath.fam" > keep_list.txt
        
        # only use samples previously designated as unrelated in prelim qc
        comm -12 <(sort /home/rdc143/trag_analyses/plink/keep_unrelated.txt) <(sort keep_list.txt) > keep_list.txt.tmp
        mv keep_list.txt.tmp keep_list.txt
        
        plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --distance square 1-ibs --geno 0.1

        Rscript ../plot.R plink.mdist $species


    } &> $species.log &
    cd ..

done

wait
rm IBS.all.pdf
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=IBS.all.pdf ./*/*.pdf