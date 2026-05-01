# Step 05: Create iTOL annotations

## Purpose

Generate iTOL annotation files for visualizing the IPR000916 tree and the ancestral sequence reconstruction tree.

## Inputs

- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree)
- [data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta.midrooted.treefile](../data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta.midrooted.treefile)
- [data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta](../data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta)
- [data/metadata/ncbi_meta_data_sorted.tsv](../data/metadata/ncbi_meta_data_sorted.tsv)
- [data/reference_MLP_protein.fasta](../data/reference_MLP_protein.fasta)

## Command

```bash
scripts/05_create_itol_annotations.sh
```

## Outputs

- [data/itol_annotations/ipr000916_tip_label_colors_itol.txt](../data/itol_annotations/ipr000916_tip_label_colors_itol.txt)
- [data/itol_annotations/ipr000916_reference_mlp_symbols_itol.txt](../data/itol_annotations/ipr000916_reference_mlp_symbols_itol.txt)
- [data/itol_annotations/ancseq_tip_symbols_itol.txt](../data/itol_annotations/ancseq_tip_symbols_itol.txt)
- [data/itol_annotations/ancseq_reference_mlp_labels_itol.txt](../data/itol_annotations/ancseq_reference_mlp_labels_itol.txt)
- [data/itol_annotations/ancseq_mlp_gr3_aa121_symbols_itol.txt](../data/itol_annotations/ancseq_mlp_gr3_aa121_symbols_itol.txt)
- [data/itol_annotations/ancseq_mlp_gr3_aa121_codon_symbols_itol.txt](../data/itol_annotations/ancseq_mlp_gr3_aa121_codon_symbols_itol.txt)

These files color or mark tree tips by taxon group, retain labels for reference MLP sequences in the ancestral sequence reconstruction tree, and annotate the codon and amino acid states corresponding to position 121 of `MLP-GR3`.
