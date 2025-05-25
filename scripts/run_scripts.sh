#/bin/bash
set -x

python scripts/0_get_mutations_by_cancer_type.py
python scripts/0.1_get_genome_wide_mutation_data.py
python scripts/0.2_get_top_driver_genes.py

# process mutation data for all cancer types
files="data/snv_mv_indels_by_cancer_subtype"
CANCER_TYPES=$(ls $files | cut -f 1 | sort | uniq)
CANCER_TYPES=$(echo $CANCER_TYPES | sed 's/.tsv//g')
echo $CANCER_TYPES
for CANCER_TYPE in ${CANCER_TYPES[@]}; do
    echo $CANCER_TYPE
    python scripts/0.3_get_driver_mutation_status.py --cancer_type $CANCER_TYPE
done
