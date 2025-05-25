#!/bin/bash
#SBATCH --chdir=/storage/group/izg5139/default/akshatha/cancer_mutation_model
#SBATCH -o /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/pred_borzoi_drivers.out
#SBATCH -e /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/pred_borzoi_drivers.err
#SBATCH --account=izg5139_p_gpu
#SBATCH --partition=sla-prio
#SBATCH --mem=16G
#SBATCH --gpus=1
#SBATCH --time=4-00:00:00

source /storage/home/abn5461/work/miniforge3/bin/activate /storage/home/abn5461/work/miniforge3/envs/cancer-model 
 
files="data/driver_genes" # only process cancer types with driver genes
CANCER_TYPES=$(ls $files | cut -f 1 | sort | uniq)
CANCER_TYPES=$(echo $CANCER_TYPES | sed 's/.tsv//g')
echo $CANCER_TYPES

for CANCER_TYPE in ${CANCER_TYPES[@]}; do
    echo $CANCER_TYPE
    python prediction_using_borzoi/get_borzoi_predictions.py --cancer_type $CANCER_TYPE
    python prediction_using_borzoi/get_borzoi_predictions_high_cadd_mut.py --cancer_type $CANCER_TYPE
    python prediction_using_borzoi/get_borzoi_predictions_drivers.py --cancer_type $CANCER_TYPE
done
