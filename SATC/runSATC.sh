#!/usr/bin/env bash

for species in "Tory" "Tder" "Tstr" "Timb" "Tspe"
do 
  mkdir -p $species
  rm $species.txt
  for ind in $(cat ../sitesfilter_lists/$species.txt) 
  do
    name=$(basename $ind | cut -f1 -d '.' )
    echo /maps/projects/popgen/data/tragelaphines/*/$name.Cattle.idxstats.txt >> $species.txt
    
  done
  
  Rscript satc.R --useMedian TRUE -i $species.txt -o ./$species/$species

done