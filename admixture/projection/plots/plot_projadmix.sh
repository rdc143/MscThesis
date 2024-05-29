### Tory_nofarms
cat ../../pcaone/Tory_nofarms/plink.8.Q.25.tmp <(tail -n+2 ../Tory_nofarms.qopts | cut -f 3- -d " ") > Tory_nofarms.Q 
cat <(cut -c 1-12 ../../pcaone/Tory_nofarms/plink.fam ) <(tail -n+2 ../Tory_nofarms.qopts | cut -f 1-2 -d " ") > Tory_nofarms.names
nproj=$(wc -l ../Tory_nofarms/ind.lst | cut -f1 -d " ")

Rscript plotAdmix_noeval.R Tory_nofarms.names Tory_nofarms.Q $nproj Tory_nofarms.pdf

### Tstr
cat ../../pcaone/Tstr/plink.6.Q <(tail -n+2 ../Tstr.qopts | cut -f 3- -d " ") > Tstr.Q 
cat <(cut -c 1-12 ../../pcaone/Tstr/plink.fam ) <(tail -n+2 ../Tstr.qopts | cut -f 1-2 -d " ") > Tstr.names
nproj=$(wc -l ../Tstr/ind.lst | cut -f1 -d " ")

Rscript plotAdmix_noeval.R Tstr.names Tstr.Q $nproj Tstr.pdf

### Timb
cat ../../pcaone/Timb/plink.7.Q <(tail -n+2 ../Timb.qopts | cut -f 3- -d " ") > Timb.Q 
cat <(cut -c 1-12 ../../pcaone/Timb/plink.fam ) <(tail -n+2 ../Timb.qopts | cut -f 1-2 -d " ") > Timb.names
nproj=$(wc -l ../Timb/ind.lst | cut -f1 -d " ")

Rscript plotAdmix_noeval.R Timb.names Timb.Q $nproj Timb.pdf

### Tspe
cat ../../pcaone/Tspe/plink.6.Q <(tail -n+2 ../Tspe.qopts | cut -f 3- -d " ") > Tspe.Q 
cat <(cut -c 1-12 ../../pcaone/Tspe/plink.fam ) <(tail -n+2 ../Tspe.qopts | cut -f 1-2 -d " ") > Tspe.names
nproj=$(wc -l ../Tspe/ind.lst | cut -f1 -d " ")

Rscript plotAdmix_noeval.R Tspe.names Tspe.Q $nproj Tspe.pdf