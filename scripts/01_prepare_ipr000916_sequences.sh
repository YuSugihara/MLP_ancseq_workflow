#!/usr/bin/env bash
set -euo pipefail

RAW_NLRTRACKER_DIR="${RAW_NLRTRACKER_DIR:?Set RAW_NLRTRACKER_DIR to the NLRtracker result directory}"
RAW_HELIXER_PROTEIN_DIR="${RAW_HELIXER_PROTEIN_DIR:?Set RAW_HELIXER_PROTEIN_DIR to the Helixer protein FASTA directory}"
RAW_HELIXER_CDS_DIR="${RAW_HELIXER_CDS_DIR:?Set RAW_HELIXER_CDS_DIR to the Helixer CDS FASTA directory}"

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${WORK_DIR}/data"
OUT_DIR="${WORK_DIR}/data/ipr000916_extraction"
METADATA="${DATA_DIR}/metadata/ncbi_meta_data_sorted.tsv"
LIST_FILE="${DATA_DIR}/metadata/NCBI_list.txt"
REFERENCE_MLP_CDS="${DATA_DIR}/reference_MLP_cds.fasta"
REFERENCE_MLP_PROTEIN="${DATA_DIR}/reference_MLP_protein.fasta"

mkdir -p "${OUT_DIR}"/{protein,cds,gene_ids,protein_regions,cds_regions,gff,MLP_output}

seqkit translate --trim "${REFERENCE_MLP_CDS}" | seqtk seq > "${REFERENCE_MLP_PROTEIN}"

shopt -s nullglob
for result_path in "${RAW_NLRTRACKER_DIR}"/*.zip "${RAW_NLRTRACKER_DIR}"/nlrtracker_*; do
    result_basename="$(basename "${result_path}")"
    result_basename="${result_basename%.zip}"
    clean_basename="$(echo "${result_basename}" | sed 's/nlrtracker_//')"
    ncbi_id="$(echo "${clean_basename}" | cut -d '_' -f 1,2)"

    if ! grep -Fxq "${ncbi_id}" "${LIST_FILE}"; then
        continue
    fi

    if [[ -d "${result_path}" ]]; then
        interpro_gff="${result_path}/interpro_result.gff"
        tmp_dir=""
    else
        tmp_dir="${OUT_DIR}/${result_basename}"
        unzip -q "${result_path}" "*interpro_result.gff" -d "${OUT_DIR}"
        interpro_gff="${tmp_dir}/interpro_result.gff"
    fi

    grep 'Name=PF00407;status=T;Dbxref="InterPro:IPR000916"' \
        "${interpro_gff}" > \
        "${OUT_DIR}/gff/${clean_basename}_IPR000916.gff"

    if [[ -n "${tmp_dir}" ]]; then
        rm -rf "${tmp_dir}"
    fi

    cut -f 1 "${OUT_DIR}/gff/${clean_basename}_IPR000916.gff" | \
        sort -u > "${OUT_DIR}/gene_ids/${clean_basename}_IPR000916.gene_ids.txt"

    awk '{print $1":"$4"-"$5}' "${OUT_DIR}/gff/${clean_basename}_IPR000916.gff" | \
        sort -u > "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916.protein_regions.txt"

    protein_fasta_gz="${clean_basename}.gz"
    protein_fasta="${protein_fasta_gz%.gz}"
    cds_fasta_gz="$(echo "${clean_basename}" | sed 's/_helixer_protein\.fasta/_helixer_cds.fasta/').gz"
    cds_fasta="${cds_fasta_gz%.gz}"

    cp "${RAW_HELIXER_PROTEIN_DIR}/${protein_fasta_gz}" "${OUT_DIR}/"
    cp "${RAW_HELIXER_CDS_DIR}/${cds_fasta_gz}" "${OUT_DIR}/"
    pigz -d "${OUT_DIR}/${protein_fasta_gz}"
    pigz -d "${OUT_DIR}/${cds_fasta_gz}"

    samtools faidx -r "${OUT_DIR}/gene_ids/${clean_basename}_IPR000916.gene_ids.txt" \
        "${OUT_DIR}/${protein_fasta}" | \
        seqtk seq > "${OUT_DIR}/protein/${clean_basename}_IPR000916_protein.fasta"

    samtools faidx -r "${OUT_DIR}/gene_ids/${clean_basename}_IPR000916.gene_ids.txt" \
        "${OUT_DIR}/${cds_fasta}" | \
        seqtk seq > "${OUT_DIR}/cds/${clean_basename}_IPR000916_cds.fasta"

    samtools faidx -r "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916.protein_regions.txt" \
        "${OUT_DIR}/${protein_fasta}" | \
        seqtk seq > "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions.fasta"

    python3 "${WORK_DIR}/scripts/adjust_codon_boundaries.py" \
        "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916.protein_regions.txt" \
        "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916.codon_regions.txt"

    samtools faidx -r "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916.codon_regions.txt" \
        "${OUT_DIR}/${cds_fasta}" | \
        seqtk seq > "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions.fasta"

    sed "s/:/_/g" "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions.fasta" > \
        "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions_clean.fasta"
    python3 "${WORK_DIR}/scripts/rename_fasta_headers.py" \
        "${METADATA}" \
        "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions_clean.fasta" \
        "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions_renamed.fasta"

    python3 "${WORK_DIR}/scripts/rename_fasta_headers.py" \
        "${METADATA}" \
        "${OUT_DIR}/protein/${clean_basename}_IPR000916_protein.fasta" \
        "${OUT_DIR}/protein/${clean_basename}_IPR000916_protein_renamed.fasta"

    sed "s/:/_/g" "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions.fasta" > \
        "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions_clean.fasta"
    python3 "${WORK_DIR}/scripts/rename_fasta_headers.py" \
        "${METADATA}" \
        "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions_clean.fasta" \
        "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions_renamed.fasta"

    python3 "${WORK_DIR}/scripts/rename_fasta_headers.py" \
        "${METADATA}" \
        "${OUT_DIR}/cds/${clean_basename}_IPR000916_cds.fasta" \
        "${OUT_DIR}/cds/${clean_basename}_IPR000916_cds_renamed.fasta"

    rm -f "${OUT_DIR}/protein_regions/${clean_basename}_IPR000916_protein_regions_clean.fasta"
    rm -f "${OUT_DIR}/cds_regions/${clean_basename}_IPR000916_cds_regions_clean.fasta"
    rm -f "${OUT_DIR}/${protein_fasta}" "${OUT_DIR}/${cds_fasta}"
    rm -f "${OUT_DIR}/${protein_fasta}.fai" "${OUT_DIR}/${cds_fasta}.fai"
done

grep 'Name=PF00407;status=T;Dbxref="InterPro:IPR000916"' \
    "${DATA_DIR}/MLP_protein_interpro_result.gff" > \
    "${OUT_DIR}/MLP_output/MLP_IPR000916.gff"

cut -f 1 "${OUT_DIR}/MLP_output/MLP_IPR000916.gff" | \
    sort -u > "${OUT_DIR}/MLP_output/MLP_IPR000916.gene_ids.txt"

awk '{print $1":"$4"-"$5}' "${OUT_DIR}/MLP_output/MLP_IPR000916.gff" | \
    sort -u > "${OUT_DIR}/MLP_output/MLP_IPR000916.protein_regions.txt"

samtools faidx -r "${OUT_DIR}/MLP_output/MLP_IPR000916.gene_ids.txt" \
    "${REFERENCE_MLP_PROTEIN}" | \
    seqtk seq > "${OUT_DIR}/MLP_output/MLP_IPR000916_protein.fasta"

samtools faidx -r "${OUT_DIR}/MLP_output/MLP_IPR000916.gene_ids.txt" \
    "${REFERENCE_MLP_CDS}" | \
    seqtk seq > "${OUT_DIR}/MLP_output/MLP_IPR000916_cds.fasta"

samtools faidx -r "${OUT_DIR}/MLP_output/MLP_IPR000916.protein_regions.txt" \
    "${REFERENCE_MLP_PROTEIN}" | \
    seqtk seq > "${OUT_DIR}/MLP_output/MLP_IPR000916_protein_regions.fasta"

python3 "${WORK_DIR}/scripts/adjust_codon_boundaries.py" \
    "${OUT_DIR}/MLP_output/MLP_IPR000916.protein_regions.txt" \
    "${OUT_DIR}/MLP_output/MLP_IPR000916.codon_regions.txt"

samtools faidx -r "${OUT_DIR}/MLP_output/MLP_IPR000916.codon_regions.txt" \
    "${REFERENCE_MLP_CDS}" | \
    seqtk seq > "${OUT_DIR}/MLP_output/MLP_IPR000916_cds_regions.fasta"

sed "s/:/_/g" "${OUT_DIR}/MLP_output/MLP_IPR000916_protein_regions.fasta" > \
    "${OUT_DIR}/MLP_output/MLP_IPR000916_protein_regions_renamed.fasta"
sed "s/:/_/g" "${OUT_DIR}/MLP_output/MLP_IPR000916_cds_regions.fasta" > \
    "${OUT_DIR}/MLP_output/MLP_IPR000916_cds_regions_renamed.fasta"

cat "${OUT_DIR}"/protein_regions/*_renamed.fasta \
    "${OUT_DIR}/MLP_output/MLP_IPR000916_protein_regions_renamed.fasta" > \
    "${WORK_DIR}/data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta"

cat "${OUT_DIR}"/cds_regions/*_renamed.fasta \
    "${OUT_DIR}/MLP_output/MLP_IPR000916_cds_regions_renamed.fasta" > \
    "${WORK_DIR}/data/ipr000916_full_tree/IPR000916_cds_regions_renamed.fasta"

cat "${OUT_DIR}"/protein/*_renamed.fasta \
    "${REFERENCE_MLP_PROTEIN}" > \
    "${WORK_DIR}/data/two_mlp_clades/all_IPR000916_protein.fasta"

cat "${OUT_DIR}"/cds/*_renamed.fasta \
    "${REFERENCE_MLP_CDS}" > \
    "${WORK_DIR}/data/two_mlp_clades/all_IPR000916_cds.fasta"
