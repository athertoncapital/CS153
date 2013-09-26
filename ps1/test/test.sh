#!/bin/bash

cd ..
make all
cd test

for file in `ls`; do echo $file; ../ps1comb $file; done

# for i in $(seq -f "%02g" 1 16); do file=$(find . -name '01cexpr_'$i'*'); echo $i; echo $file; ../ps1comb $file; done