#!/usr/bin/env bash
module load angsd
shopt -s extglob

rm results.txt
rm LRTmat.txt 
touch LRTmat.txt

echo "ind  invar var" >> results.txt

for ind in $(cat ../../sitesfilter_lists/Tstr.txt)
do
  name=$(basename $ind | cut -f1 -d '.' )
  angsd -dohetplas 1 -i /maps/projects/popgen/data/tragelaphines/!(*.mapping)/$name.Cattle.bam -r NC_006853.1: -out $name
  value=$(Rscript -e "tab <- read.table('$name.hetGL', header=T);table(tab[,10] > 24)" | tail -n1)
  echo $name $value >> results.txt

  cut -f 10 $name.hetGL | tail -n+2 > LRT.tmp
  paste -d "\t" LRTmat.txt LRT.tmp > LRTmat.txt.tmp
  mv LRTmat.txt.tmp LRTmat.txt 
  rm LRT.tmp
done

head -n 15000 LRTmat.txt > LRTmat.txt.tmp
mv LRTmat.txt.tmp LRTmat.txt 

Rscript -e "tab <- read.table('results.txt', header=T);png('hetplas.png');barplot(tab[,3], col=(tab[,1] == 'TstrBot_0757'));dev.off()"
