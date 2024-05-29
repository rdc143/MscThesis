awk '{
    if (!($1 in mapping)) {
        mapping[$1] = ++counter;
    }
    $1 = mapping[$1];
    print;
}' testmaf.bim > testmaf_changed.bim