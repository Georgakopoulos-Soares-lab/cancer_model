#!/bin/bash
#SBATCH --chdir=/storage/group/izg5139/default/akshatha/cancer_mutation_model
#SBATCH -o /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/sei.out
#SBATCH -e /storage/group/izg5139/default/akshatha/cancer_mutation_model/logs/sei.err
#SBATCH --account=izg5139_a_gpu
#SBATCH --partition=sla-prio
#SBATCH --mem=8G
#SBATCH --gpus=1

source /storage/home/abn5461/work/miniforge3/bin/activate /storage/work/abn5461/.conda/envs/sei-cuda

SEI_PATH=/storage/group/izg5139/default/external/sei-framework
PROJECT_PATH=/storage/group/izg5139/default/akshatha/cancer_mutation_model

files=${PROJECT_PATH}/data/driver_genes
CANCER_TYPES=$(ls $files | cut -f 1 | sort | uniq)
CANCER_TYPES=$(echo $CANCER_TYPES | sed 's/.tsv//g')
echo $CANCER_TYPES

for CANCER_TYPE in ${CANCER_TYPES[@]}; do
    echo $CANCER_TYPE
    vcf_file=${PROJECT_PATH}/data/fabian_input/${CANCER_TYPE}_input.vcf
    output_dir=${PROJECT_PATH}/sei_pred_output
    seq_class_output_dir=${PROJECT_PATH}/sei_seq_class_output

    # Check if the VCF file exists
    echo $vcf_file
    if [ ! -f $vcf_file ]; then
        echo "VCF file not found for ${CANCER_TYPE}. Skipping..."
        continue
    fi

    # Check if the output directories exists, if not create it
    if [ ! -d $output_dir ]; then
        mkdir -p $output_dir
    fi
    
    if [ ! -d $seq_class_output_dir ]; then
        mkdir -p $seq_class_output_dir
    fi

    cd ${SEI_PATH}

    # # Run variant effect prediction
    # echo "Running variant effect prediction for ${CANCER_TYPE}..."
    # echo "sh 1_variant_effect_prediction.sh $vcf_file hg19 $output_dir --cuda"
    # sh 1_variant_effect_prediction.sh $vcf_file hg19 $output_dir --cuda

    # Run sequence class prediction
    echo "Running sequence class prediction for ${CANCER_TYPE}..."
    ref_filepath=${output_dir}/chromatin-profiles-hdf5/${CANCER_TYPE}_input.ref_predictions.h5
    alt_filepath=${output_dir}/chromatin-profiles-hdf5/${CANCER_TYPE}_input.alt_predictions.h5
    if [ ! -f $ref_filepath ]; then
        echo "Reference predictions file not found for ${CANCER_TYPE}. Skipping..."
        continue
    fi
    if [ ! -f $alt_filepath ]; then
        echo "Alternate predictions file not found for ${CANCER_TYPE}. Skipping..."
        continue
    fi
    sh 2_varianteffect_sc_score.sh ${ref_filepath} ${alt_filepath} ${seq_class_output_dir} [--no-tsv]
done
