#/bin/bash
set -x

files="data/driver_genes"
CANCER_TYPES=$(ls $files | cut -f 1 | sort | uniq)
CANCER_TYPES=$(echo $CANCER_TYPES | sed 's/.tsv//g')
echo $CANCER_TYPES

# run notebooks for each cancer type
cd notebooks
for CANCER_TYPE in ${CANCER_TYPES[@]}; do
    echo $CANCER_TYPE
    papermill 1.0_mutation_density_analysis_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 1.2_mutation_density_genic_region_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 1.4_mean_mutation_density_wrt_tss_tes.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 2.1_cadd_score_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 2.2_cadd_score_genic_region_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 4.1_overall_survival_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 4.2_DFI_by_cancer_early_stage.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 4.3_PFI_by_cancer_late_stage.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 4.4_PFI_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 6.0_splicing_analysis_pangolin_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 7.0_TFB_effect_analysis_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 7.0_TFB_effect_differential_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
    papermill 8_rna_seq_analyses_by_cancer.ipynb temp.ipynb -p cancer_type $CANCER_TYPE
done

# get locations of passenger mutations in absence of drivers
# for genes with significant differences in survival outcomes, for example -
# papermill 4.5_passenger_mutation_clinical_biomarkers_locs.ipynb temp.ipynb -p param Lung-AdenoCA:KRAS

