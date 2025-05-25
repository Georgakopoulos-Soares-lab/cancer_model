#!/bin/bash
#SBATCH --chdir=/storage/group/izg5139/default/akshatha/cancer_mutation_model
#SBATCH -o /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/annotate.out
#SBATCH -e /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/annotate.err
#SBATCH --account=izg5139_bc
#SBATCH --partition=sla-prio
#SBATCH --ntasks-per-node=30

source /storage/home/abn5461/work/miniforge3/bin/activate /storage/home/abn5461/work/miniforge3/envs/cancer-model 

files="data/snv_mv_indels_by_cancer_subtype"
CANCER_TYPES=$(ls $files | cut -f 1 | sort | uniq)
CANCER_TYPES=$(echo $CANCER_TYPES | sed 's/.tsv//g')
echo $CANCER_TYPES

for CANCER_TYPE in ${CANCER_TYPES[@]}; do
 echo $CANCER_TYPE
 python /storage/group/izg5139/default/akshatha/cancer_mutation_model/scripts/1_annotate_mutations.py --cancer_type $CANCER_TYPE
done
