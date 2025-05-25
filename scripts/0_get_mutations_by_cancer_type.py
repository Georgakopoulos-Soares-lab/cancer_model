import os
import pandas as pd

# input files
ICGC_MUT_DATA = "data/datasets/PCAWG/mutations/snv_mnv_indel/final_consensus_passonly.snv_mnv_indel.icgc.public.maf"
TCGA_MUT_DATA = "data/datasets/PCAWG/mutations/snv_mnv_indel/final_consensus_passonly.snv_mnv_indel.tcga.controlled.maf"
ICGC_DRIVER_MUTATIONS = "data/datasets/PCAWG/driver_mutations/TableS3_panorama_driver_mutations_ICGC_samples.public.tsv"
TCGA_DRIVER_MUTATIONS = "data/datasets/PCAWG/driver_mutations/TableS3_panorama_driver_mutations_TCGA_samples.controlled.tsv"

# output files/dir
MUT_DATA_BY_CANCER_SUBTYPE = "data/snv_mv_indels_by_cancer_subtype"
CANCER_SUBTYPE_COUNTS = "metadata/cancer_subtypes_counts.tsv"
if not os.path.exists(MUT_DATA_BY_CANCER_SUBTYPE):
    os.makedirs(MUT_DATA_BY_CANCER_SUBTYPE)

# mutation data from ICGC and TCGA
icgc_mut_data_df = pd.read_csv(ICGC_MUT_DATA, sep="\t")
tcga_mut_data_df = pd.read_csv(TCGA_MUT_DATA, sep="\t")
mut_data_df = pd.concat([icgc_mut_data_df, tcga_mut_data_df], ignore_index=True)
mut_data_df = mut_data_df[["Hugo_Symbol", "Chromosome", "Start_position", "End_position", "Strand", "Reference_Allele", "Tumor_Seq_Allele1", "Tumor_Seq_Allele2", "Variant_Classification", "Tumor_Sample_Barcode", "Project_Code", "Donor_ID"]]
mut_data_df.rename(columns={"Donor_ID": "Patient_ID"}, inplace=True)
mut_data_df["mutation"] = mut_data_df["Chromosome"].astype(str) + ":" + mut_data_df["Start_position"].astype(str) + "-" + mut_data_df["End_position"].astype(str) + ":" + mut_data_df["Reference_Allele"] + ":" + mut_data_df["Tumor_Seq_Allele2"]
mut_data_df["mutation_loc"] = mut_data_df["Chromosome"].astype(str) + ":" + mut_data_df["Start_position"].astype(str) + ":" + mut_data_df["Reference_Allele"] + ":" + mut_data_df["Tumor_Seq_Allele2"]
mut_data_df.drop(["Chromosome", "Start_position", "End_position", "Reference_Allele", "Tumor_Seq_Allele1", "Tumor_Seq_Allele2"], axis=1, inplace=True)
mut_data_df.rename(columns={"Hugo_Symbol": "gene"}, inplace=True)
print("Number of mutations:", mut_data_df.shape[0])

# get driver mutations from PCAWG resource (ICGC samples)
drivers_icgc = pd.read_csv(ICGC_DRIVER_MUTATIONS, sep="\t")
drivers_tcga = pd.read_csv(TCGA_DRIVER_MUTATIONS, sep="\t")
drivers_pcawg = pd.concat([drivers_icgc, drivers_tcga])
drivers_pcawg = drivers_pcawg[["sample_id", "ttype", "chr", "pos", "ref", "alt", "top_category"]]
drivers_pcawg = drivers_pcawg[drivers_pcawg["top_category"].isin(["mutational", "germline"])]
drivers_pcawg["mutation_loc"] = drivers_pcawg["chr"].astype(str) + ":" + drivers_pcawg["pos"].astype(str) + ":" + drivers_pcawg["ref"] + ":" + drivers_pcawg["alt"]
drivers_pcawg.drop(["chr", "pos", "ref", "alt", "top_category"], axis=1, inplace=True)
drivers_pcawg.rename(columns={"sample_id": "Tumor_Sample_Barcode", "ttype": "Project_Code"}, inplace=True)
drivers_pcawg.drop_duplicates(inplace=True)
cancer_subtypes = mut_data_df["Project_Code"].unique()
for cancer_subtype in cancer_subtypes:
	cancer_subtype_mut_data_df = mut_data_df[mut_data_df["Project_Code"] == cancer_subtype]
	print(f"Number of mutations in {cancer_subtype} Cancer: {cancer_subtype_mut_data_df.shape[0]}")
	drivers = drivers_pcawg[drivers_pcawg["Project_Code"] == cancer_subtype]
	drivers.loc[:, "driver"] = True
	cancer_subtype_mut_data_df = pd.merge(cancer_subtype_mut_data_df, drivers, on=["Tumor_Sample_Barcode", "mutation_loc"], how="left")
	cancer_subtype_mut_data_df["driver"].fillna(False, inplace=True)
	cancer_subtype_mut_data_df.drop(["Project_Code_x", "Project_Code_y"], axis=1, inplace=True)
	print(f"Saving {cancer_subtype} Cancer data for {cancer_subtype_mut_data_df.shape[0]} mutations")
	cancer_subtype_mut_data_df.to_csv(f"{MUT_DATA_BY_CANCER_SUBTYPE}/{cancer_subtype}.tsv", sep="\t", index=False)
      
# get cancer subtype counts
cancer_subtype_counts = mut_data_df.groupby("Project_Code")["Tumor_Sample_Barcode"].nunique().reset_index()
cancer_subtype_counts.rename(columns={"Tumor_Sample_Barcode": "Sample_Count"}, inplace=True)
cancer_subtype_counts.sort_values("Sample_Count", ascending=False, inplace=True)
print("Saving cancer subtype counts")
cancer_subtype_counts.to_csv(CANCER_SUBTYPE_COUNTS, sep="\t", index=False)
print(f"Total number of samples: {cancer_subtype_counts['Sample_Count'].sum()}")
