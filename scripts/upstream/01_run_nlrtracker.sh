#!/usr/bin/env bash
set -euo pipefail

HELIXER_PROTEIN_DIR="${HELIXER_PROTEIN_DIR:?Set HELIXER_PROTEIN_DIR to the Helixer protein FASTA directory}"
NLRTRACKER_MODULE_LIST="${NLRTRACKER_MODULE_LIST:?Set NLRTRACKER_MODULE_LIST to the NLRtracker InterProScan module list}"
NLRTRACKER_OUTPUT_DIR="${NLRTRACKER_OUTPUT_DIR:-nlrtracker_results}"
THREADS="${THREADS:-32}"

mkdir -p "${NLRTRACKER_OUTPUT_DIR}"

for zipped_fasta in "${HELIXER_PROTEIN_DIR}"/*_protein.fasta.gz; do
    fasta="$(basename "${zipped_fasta}" .gz)"
    pigz -dc "${zipped_fasta}" > "${fasta}"

    NLRtracker.sh \
        -s "${fasta}" \
        -o "nlrtracker_${fasta}" \
        -c "${THREADS}" \
        -d "${NLRTRACKER_MODULE_LIST}"

    rm -f "${fasta}"
    mv "nlrtracker_${fasta}" "${NLRTRACKER_OUTPUT_DIR}/"
done
