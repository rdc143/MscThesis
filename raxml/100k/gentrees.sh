module use --append /projects/popgen/apps/Modules/modulefiles
module load angsd/0.934
module load bedtools/

rm -f 100k.tre

for thread in {0..9}
do

start_range=$((0 + (thread * 100)))
stop_range=$((99 + (thread * 100)))

{
for tree in $(seq $start_range $stop_range)
do
  
  echo "starting tree no. "$tree
  
  rm -rf ./$tree
  mkdir $tree
  cd $tree
  
  bedtools random -g /maps/projects/popgen/people/rdc143/QCSeq/sites_filters/samplesbased_genocalls/depth/results/beds/BosTau9nonRepeat_autosomes_depth.bed -n 1 -l 100000 > random_window.bed
  
  window=$(awk 'BEGIN {OFS=":"} {print $1,$2"-"$3}' random_window.bed)
  
  cat ../raxmlbams.lst | while read bam
  do
    angsd -doCounts 1 -doFasta 2 -i $bam -out tmp -r $window -basesPerLine 100000
    name=$(basename $bam)
    echo ">$name" >> window.fa
    zcat tmp.fa.gz > tmp.fa
    bedtools getfasta -fi tmp.fa -bed random_window.bed -fo stdout | tail -n +2 >> window.fa
    rm tmp.fa
    rm tmp.fa.gz
    rm tmp.arg
  done

  raxmlHPC-PTHREADS -m GTRGAMMA -s window.fa -n $tree -T 10 -p 1337
  
  cd ..
done
} &

done
wait

for tree in {0..999}
do
cat $tree/RAxML_bestTree.$tree >> ./100k.tre
done
