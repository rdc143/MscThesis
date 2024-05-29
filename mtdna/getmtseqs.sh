module use --append /projects/popgen/apps/Modules/modulefiles
module load angsd/0.934

rm mtdna.fa

cat tragmain.lst | while read bam
do
angsd -doCounts 1 -doFasta 2 -i $bam -out tmp -r NC_006853.1: 
name=$(basename $bam)
echo ">$name" >> mtdna.fa
zcat tmp.fa.gz | tail -n +2  >> mtdna.fa
rm tmp.fa.gz
rm tmp.arg
done
