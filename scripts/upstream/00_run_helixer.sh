#!/usr/bin/env bash
set -euo pipefail

GENOME_DIR="${GENOME_DIR:?Set GENOME_DIR to the directory containing gzipped genome FASTA files}"
HELIXER_OUTPUT_DIR="${HELIXER_OUTPUT_DIR:-Helixer_results}"
HELIXER_SIF="${HELIXER_SIF:?Set HELIXER_SIF to the Helixer Singularity image}"
HELIXER_MODEL="${HELIXER_MODEL:?Set HELIXER_MODEL to the Helixer land plant model file}"
HELIXER_POST_BIN="${HELIXER_POST_BIN:?Set HELIXER_POST_BIN to the HelixerPost binary directory}"

TEMP_DIR_NAME="temp_$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)"
mkdir -p \
    "${HELIXER_OUTPUT_DIR}/genome" \
    "${HELIXER_OUTPUT_DIR}/cds" \
    "${HELIXER_OUTPUT_DIR}/protein" \
    "${HELIXER_OUTPUT_DIR}/gff" \
    "${HELIXER_OUTPUT_DIR}/log" \
    "${HELIXER_OUTPUT_DIR}/${TEMP_DIR_NAME}"

for zipped_fasta in "${GENOME_DIR}"/*.gz; do
    fasta_file="$(basename "${zipped_fasta}" .gz)"
    prefix="$(basename "${fasta_file}" .fasta)"
    prefix="$(basename "${prefix}" .fna)"
    prefix="$(basename "${prefix}" .fa)"

    pigz -dc "${zipped_fasta}" > "${fasta_file}"

    singularity run --nv \
        --env PATH="${HELIXER_POST_BIN}:$PATH" \
        "${HELIXER_SIF}" \
        Helixer.py \
        --lineage land_plant \
        --species Helixer \
        --fasta-path "${fasta_file}" \
        --gff-output-path "${prefix}_helixer.gff" \
        --subsequence-length 64152 \
        --overlap-offset 32076 \
        --overlap-core-length 48114 \
        --model-filepath "${HELIXER_MODEL}" \
        --temporary-dir "${HELIXER_OUTPUT_DIR}/${TEMP_DIR_NAME}" \
        > "${prefix}_helixer.log" \
        2>&1

    gffread -x "${prefix}_helixer_cds.fasta" \
        -g "${fasta_file}" \
        "${prefix}_helixer.gff"

    gffread -y "${prefix}_helixer_protein.fasta" \
        -g "${fasta_file}" \
        "${prefix}_helixer.gff"

    pigz "${prefix}_helixer_cds.fasta"
    pigz "${prefix}_helixer_protein.fasta"
    pigz "${prefix}_helixer.gff"

    rm -f "${fasta_file}" "${fasta_file}.fai"

    mv "${zipped_fasta}" "${HELIXER_OUTPUT_DIR}/genome/"
    mv "${prefix}_helixer_cds.fasta.gz" "${HELIXER_OUTPUT_DIR}/cds/"
    mv "${prefix}_helixer_protein.fasta.gz" "${HELIXER_OUTPUT_DIR}/protein/"
    mv "${prefix}_helixer.gff.gz" "${HELIXER_OUTPUT_DIR}/gff/"
    mv "${prefix}_helixer.log" "${HELIXER_OUTPUT_DIR}/log/"
done

rm -rf "${HELIXER_OUTPUT_DIR:?}/${TEMP_DIR_NAME}"
