inputpath="/home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly"


for spec in "Tstr" "Timb" "Tspe" # removed Tory_nofarms for now
do
    mkdir $spec
    cd $spec

    ### gen list of inds not in admix but in inputpath, make sure its only id
    grep $spec $inputpath.fam | cut -f2 | grep -v -F -f <(awk '{print $2}' /home/rdc143/trag_analyses/admixture/pcaone/$spec/plink.fam) > ind.lst

    for ind in $(cat ind.lst)
    do
        grep $ind $inputpath.fam > keep.tmp
        plink --allow-extra-chr --bfile /home/rdc143/trag_analyses/plink/BosTau9_tragmain2_sites_variable_noindels_8dp_5missing_nomultipoly  --keep keep.tmp --make-bed --out $ind
        rm keep.tmp


        ### rename chromosomes to fit ref format
        awk 'BEGIN {FS = "\t"; OFS = "\t"} {
            if (!($1 in mapping)) {
                mapping[$1] = ++counter;
            }
            $1 = mapping[$1];
            print;
        }' $ind.bim > $ind.bim.tmp

        mv $ind.bim.tmp $ind.bim

        ### rename id to fit ref format
        awk -v OFS='\t' '{$2 = $1"_"$4}1' $ind.bim > $ind.bim.tmp
        mv $ind.bim.tmp $ind.bim

        fastNGSadmix -plink $ind -fname ../$spec*.ref.txt -Nname ../$spec*.nind -out $ind -whichPops all
    done    
    cd ..
done