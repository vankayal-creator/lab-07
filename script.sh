#!/bin/bash

for i in 1 2 3 4
do
    input_dir="Testcase$i"
    output_dir="Testcase${i}Diff"

    rm -rf "$output_dir"

    for file1 in "$input_dir"/*.1.txt
    do
        [ -f "$file1" ] || continue

        file2="${file1%.1.txt}.2.txt"

        [ -f "$file2" ] || continue

        if ! diff -q "$file1" "$file2" > /dev/null
        then
            mkdir -p "$output_dir"

            name=$(basename "$file1" .1.txt)

            diff -u "$file1" "$file2" > "$output_dir/${name}Diff.txt"
        fi
    done
done
