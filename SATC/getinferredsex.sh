for ind in $(cat allinds.txt)
do
  sex=$(grep $ind ./*/*sampleSex.tsv | cut -f2) 
  echo $sex
done