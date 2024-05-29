#mv BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_maf02_gk_eland.bim BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_maf02_gk_eland_oldname.bim
awk 'BEGIN {FS = "\t"; OFS = "\t"} {
    if (!($1 in mapping)) {
        mapping[$1] = ++counter;
    }
    $1 = mapping[$1];
    print;
}' BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_maf02_gk_eland_oldname.bim > BosTau9_tragmain_sites_variable_noindels_nomultipoly_nomissing_maf02_gk_eland.bim
