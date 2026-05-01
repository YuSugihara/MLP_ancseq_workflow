#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${WORK_DIR}/data/two_mlp_clades"

python -c "import sys; [print('_'.join(line.strip().split('_')[:-1])) for line in sys.stdin]" \
    < "${DATA_DIR}/two_mlp_clades.txt" \
    > "${DATA_DIR}/two_mlp_clades_clean.txt"

samtools faidx -r "${DATA_DIR}/two_mlp_clades_clean.txt" \
    "${DATA_DIR}/all_IPR000916_protein.fasta" | \
    seqtk seq > "${DATA_DIR}/MLP_protein_clade.fasta"

samtools faidx -r "${DATA_DIR}/two_mlp_clades_clean.txt" \
    "${DATA_DIR}/all_IPR000916_cds.fasta" | \
    seqtk seq > "${DATA_DIR}/MLP_cds_clade.fasta"

python3 "${WORK_DIR}/scripts/remove_stop_codon.py" \
    "${DATA_DIR}/MLP_cds_clade.fasta" > \
    "${DATA_DIR}/MLP_cds_clade_noSTOP.fasta"

mafft --maxiterate 1000 \
    --globalpair \
    "${DATA_DIR}/MLP_protein_clade.fasta" > \
    "${DATA_DIR}/MLP_protein_clade.global_aln.fasta"

phykit thread_dna \
    -p "${DATA_DIR}/MLP_protein_clade.global_aln.fasta" \
    -n "${DATA_DIR}/MLP_cds_clade_noSTOP.fasta" > \
    "${DATA_DIR}/MLP_codon_clade.global_aln.fasta"
