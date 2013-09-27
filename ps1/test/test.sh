#!/bin/bash

cd test
cd ..
make all > /dev/null
cd test

(for file in `ls | grep .fish`; do echo $file; ../ps1comb $file; done) > output-1.txt

(for file in `ls | grep .fish`; do echo $file; ../ps1yacc $file; done) > output-2.txt

cd ..
make clean
cd test

diff -s output-1.txt output-2.txt

# for i in $(seq -f "%02g" 1 16); do file=$(find . -name '01cexpr_'$i'*'); echo $i; echo $file; ../ps1comb $file; done