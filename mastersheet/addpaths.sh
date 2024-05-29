#!/bin/bash

sed 's/\r$//' trag_master.tsv > input.tsv
# Input TSV file
input_file="/home/rdc143/trag/input.tsv"

# Output file to store the result
output_file="/home/rdc143/trag/trag_master_wfiles.tsv"

search_directory="/maps/projects/seqafrica/scratch/albrecht/rawfastq/2023april/"

# Extract the header and store it in a variable
header=$(head -n 1 "$input_file")

# Create a header for the output file, including the new columns
echo -e "$header\tFile1\tFile2" > "$output_file"

# Process the rows, skipping the header
tail -n +2 "$input_file" | while IFS=$'\t' read -r -a fields; do

    pattern=${fields[2]}
    pattern=$( echo $pattern | tr -d '"')

    file_paths1=()
    file_paths2=()

#    IFS=$'\t'

    for file_path in $(find "$search_directory" -name "*1.fq.gz" | grep "$pattern"); do
        file_paths1+=("$file_path")
    done

    for file_path in $(find "$search_directory" -name "*2.fq.gz" | grep "$pattern"); do
        file_paths2+=("$file_path")
    done

    if [ ${#file_paths1[@]} -eq ${#file_paths2[@]} ]; then
        # Iterate over the arrays and add lines to the output file
        for ((i=0; i<${#file_paths1[@]}; i++)); do
            output_line="${fields[0]}"
            for ((j=1; j<${#fields[@]}; j++)); do
                output_line+="\t${fields[$j]}"
            done
            output_line+="\t${file_paths1[$i]}\t${file_paths2[$i]}"
            echo -e "$output_line" >> "$output_file"
            #echo -e "${fields[*]}\t${file_paths1[$i]}\t${file_paths2[$i]}" >> "$output_file"
        done
    else
        # Handle the case where the number of paths for File1 and File2 is not equal
        echo "Error: Unequal number of paths for File1 and File2 for pattern '$pattern'"
    fi
done
