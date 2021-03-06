#!/bin/bash

# Set Variables
CDHIT=cdhit/cd-hit-est
FASTA=$(sed "s/.*\///" <<< ${1})
THRESHOLD=${2}
WORD=${3}
TYPE=${4}

ASSESS=../../scripts/cdhit_assess_by_gene.py

# Run CD-HIT
./${CDHIT} -c ${THRESHOLD} -T 0 -M 0 -n ${WORD} -d 0 -i $1 -o ${THRESHOLD}_${FASTA}

# Delete representative sequences file
rm ${THRESHOLD}_${FASTA}

# Perform Clustering Assessment
python ${ASSESS} ${1} ${THRESHOLD}_${FASTA}.clstr ${THRESHOLD}_${FASTA}.tsv

# Organize Results
mkdir -p ${TYPE}/${THRESHOLD}_${FASTA}_assessment
mv *.clstr *.tsv *json *txt ${TYPE}/${THRESHOLD}_${FASTA}_assessment/