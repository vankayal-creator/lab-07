#!/bin/bash

overall_status=0

for i in 1 2 3 4
do
    input_dir="Testcase$i"
    output_dir="Testcase${i}Diff"

    testcase_status=0
    has_differences=0
    expected_count=0

    shopt -s nullglob

    for file1 in "$input_dir"/*.1.txt
    do
        file2="${file1%.1.txt}.2.txt"

        [ -f "$file2" ] || continue

        name=$(basename "$file1" .1.txt)
        expected_file="$output_dir/${name}Diff.txt"

        if ! cmp -s "$file1" "$file2"
        then
            has_differences=1
            expected_count=$((expected_count + 1))

            if [ ! -f "$expected_file" ]
            then
                testcase_status=1
                echo "Missing $expected_file" >&2
            elif ! diff -u "$file1" "$file2" | tail -n +3 | cmp -s - <(tail -n +3 "$expected_file")
            then
                testcase_status=1
                echo "Incorrect contents: $expected_file" >&2
            fi
        else
            if [ -e "$expected_file" ]
            then
                testcase_status=1
                echo "Unnecessary file: $expected_file" >&2
            fi
        fi
    done

    if [ "$has_differences" -eq 1 ]
    then
        if [ ! -d "$output_dir" ]
        then
            testcase_status=1
        else
            actual_files=("$output_dir"/*)

            if [ "${#actual_files[@]}" -ne "$expected_count" ]
            then
                testcase_status=1
            fi

            for actual in "${actual_files[@]}"
            do
                if [ ! -f "$actual" ]
                then
                    testcase_status=1
                fi
            done
        fi
    else
        if [ -d "$output_dir" ]
        then
            testcase_status=1
        fi
    fi

    if [ "$testcase_status" -eq 0 ]
    then
        echo "Testcase$i: PASS"
    else
        echo "Testcase$i: FAIL"
        overall_status=1
    fi
done

exit "$overall_status"
