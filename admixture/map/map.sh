for pair in "Tory 8" "Tder 3" "Tstr 6" "Timb 7" "Tspe 6"
do

arr=( $pair )
species=${arr[0]}
k=${arr[1]}

Rscript map.R $species $k
done