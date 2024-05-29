#!/usr/bin/env bash
module load plink/1.9.0
module load plink2/2.00a3.3

plotscript="/home/rdc143/trag_analyses/relatedness/plotrelated.R"
inputpath="/home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_fixedout"

declare -a pids

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe" "Scaf" "Tbux"
do
    mkdir $species
    cd $species
    {
    awk -v species="$species" '$1 ~ "^" species {print $1, $2}' "$inputpath.fam" > keep_list.txt

    # only use samples previously designated as unrelated in prelim qc
    comm -12 <(sort /home/rdc143/trag_analyses/plink/keep_unrelated.txt) <(sort keep_list.txt) > keep_list.txt.tmp
    mv keep_list.txt.tmp keep_list.txt

    # species scale relatedness
    plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --genome --maf 0.05 --geno 0.1
    plink2 --allow-extra-chr --bfile $inputpath --keep keep_list.txt --make-king-table --maf 0.05 --geno 0.1
    Rscript $plotscript plink.genome plink2.kin0 ../$species.pdf

    # locality scale
    for loc in $(cut -c5-7 keep_list.txt | uniq)
    do

        mkdir $loc
        cd $loc
        grep $loc ../keep_list.txt > ./keep_list.txt
        if [ $(wc -l keep_list.txt) -lt 2 ];
        then
            cd ..
            break
        fi

        plink --allow-extra-chr --bfile $inputpath --keep keep_list.txt --genome --maf 0.05 --geno 0.1
        plink2 --allow-extra-chr --bfile $inputpath --keep keep_list.txt --make-king-table --maf 0.05 --geno 0.1
        Rscript $plotscript plink.genome plink2.kin0 ../$species$loc.pdf

        cd ..
    done

    rm ../related.$species.pdf
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=../related.$species.pdf *.pdf
    rm ./*.pdf

    } &> $species.log &
    pids+=($!)

    cd ..
done

# wait for all background processes to finish
for pid in "${pids[@]}"; do
    wait "$pid"
done

rm related.all.pdf
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=related.all.pdf *.pdf
find . -maxdepth 1 -type f -name '*.pdf' ! -name "related.*.pdf" -exec rm {} +
