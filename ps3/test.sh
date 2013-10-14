#!/bin/bash

make all

for file in `ls test`; do
    echo $file;
    ./ps3 test/$file > output/$file.asm;
done

make clean