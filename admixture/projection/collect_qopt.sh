inputpath="/home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly"



for spec in "Tory_nofarms" "Tstr" "Timb" "Tspe"
do 
    cd $spec
    # get header with pop names
    paste -d " " <(echo "loc id") <(head $(ls *.qopt | head -n1) -n1) > ../$spec.qopts
    for ind in $(cat ind.lst)
    do
        paste -d " " <(grep $ind $inputpath.fam | cut -c1-7) <(echo $ind) <(tail -n1 $ind.qopt) >> ../$spec.qopts
    done
    cd ..
done