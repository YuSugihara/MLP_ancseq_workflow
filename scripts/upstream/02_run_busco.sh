#!/usr/bin/env bash
set -euo pipefail

BUSCO_PROTEIN_DIR="${BUSCO_PROTEIN_DIR:?Set BUSCO_PROTEIN_DIR to the gzipped protein FASTA directory}"
BUSCO_DOWNLOAD_PATH="${BUSCO_DOWNLOAD_PATH:?Set BUSCO_DOWNLOAD_PATH to the BUSCO downloads directory}"
BUSCO_OUTPUT_DIR="${BUSCO_OUTPUT_DIR:-busco_results}"
BUSCO_LINEAGE="${BUSCO_LINEAGE:-embryophyta_odb12}"
THREADS="${THREADS:-32}"

mkdir -p "${BUSCO_OUTPUT_DIR}"

for zipped_fasta in "${BUSCO_PROTEIN_DIR}"/*.fasta.gz; do
    prefix="$(basename "${zipped_fasta}" .gz)"
    pigz -dc "${zipped_fasta}" > "${prefix}"

    busco \
        -m proteins \
        -l "${BUSCO_LINEAGE}" \
        -i "${prefix}" \
        --offline \
        --download_path "${BUSCO_DOWNLOAD_PATH}" \
        -o "${BUSCO_OUTPUT_DIR}/busco_${prefix}" \
        -c "${THREADS}"

    rm -f "${prefix}"
done
