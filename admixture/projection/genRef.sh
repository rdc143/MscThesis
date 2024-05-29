echo "id chr pos name A0_freq A1 Bot TanNE TanNW Zim Zam TanS Nam Eth" > Tory_nofarms.8.ref.txt
paste -d" " <( awk -F " " ' { print $1"_"$4, $1, $4, $2, $6, $5 } ' ../pcaone/Tory_nofarms/plink.bim ) ../pcaone/Tory_nofarms/plink.8.P.25.tmp >> Tory_nofarms.8.ref.txt
