module load gsl/2.5 perl bcftools
input="/home/rdc143/trag_analyses/imputation/ToryTstr/ToryTstr.phased.vcf.gz"

query="TstrBot_0757"

bcftools query -l $input | grep -v "$query" | awk '{print $1 "\t" substr($1, 1, 4) "\t" $2}' > samplemap.tsv

chrs=$(bcftools index -s $input | cut -f1)
for chrom in $chrs; do
    
    mkdir -p $chrom
    cd $chrom
    {
    ### make query file
    bcftools view $input -r $chrom -s $query --max-alleles 2 -O b -o query.$chrom.bcf.gz --threads 10
    bcftools index query.$chrom.bcf.gz

    ### make reference file
    bcftools view $input -r $chrom -s ^$query --max-alleles 2 -O b -o ref.$chrom.bcf.gz --threads 10
    bcftools index ref.$chrom.bcf.gz

    ### make genetic map
    bcftools view query.$chrom.bcf.gz | grep -v ^# | awk 'BEGIN {FS=OFS="\t"} {print $1, $2, $2 * 1.3e-6 }' > genmap.tsv

    ### run rfmix
    rfmix -f query.$chrom.bcf.gz -r ref.$chrom.bcf.gz -m ../samplemap.tsv -g genmap.tsv -o $query.$chrom --chromosome=$chrom --n-threads=10

    } & > $chrom.log &
    cd ..
    
done