#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TREE_DIR="${WORK_DIR}/data/ipr000916_full_tree"
FASTA_PREFIX="${TREE_DIR}/IPR000916_protein_regions_renamed.fasta.m100"

midroot() {
    python -c "import ete4,sys; t=ete4.Tree('$1'); t.set_outgroup(t.get_midpoint_outgroup()); print(t.write())"
}

seqkit seq -m 100 "${TREE_DIR}/IPR000916_protein_regions_renamed.fasta" > \
    "${FASTA_PREFIX}.fasta"

famsa -t 10 \
    -refine_mode on \
    "${FASTA_PREFIX}.fasta" \
    "${FASTA_PREFIX}.famsa_aln.fasta"

VeryFastTree -threads 10 \
    "${FASTA_PREFIX}.famsa_aln.fasta" > \
    "${FASTA_PREFIX}.famsa_aln.fasta.vft.tree"

midroot "${FASTA_PREFIX}.famsa_aln.fasta.vft.tree" > \
    "${FASTA_PREFIX}.famsa_aln.fasta.vft.midroot.tree"
