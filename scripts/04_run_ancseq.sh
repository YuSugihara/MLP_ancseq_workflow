#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${WORK_DIR}/data/two_mlp_clades"
RESULTS_DIR="${WORK_DIR}/data/anceseq_results_v1.3.0"

midroot() {
    python -c "import ete4,sys; t=ete4.Tree('$1'); t.set_outgroup(t.get_midpoint_outgroup()); print(t.write())"
}

ancseq \
    -s "${DATA_DIR}/MLP_codon_clade.global_aln.fasta" \
    -m DNA \
    --outgroup GCA_036507275.1_Cucurbitales_Sicyos_edulis_Helixer_CM071850.1_001929.1 \
    -o "${RESULTS_DIR}"

midroot "${RESULTS_DIR}/00_tree/MLP_codon_clade.global_aln.fasta.treefile" > \
    "${RESULTS_DIR}/00_tree/MLP_codon_clade.global_aln.fasta.midrooted.treefile"
