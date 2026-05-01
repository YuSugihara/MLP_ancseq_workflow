# Step 02: Build the full IPR000916 tree

## Purpose

Filter the combined IPR000916 protein-region FASTA to sequences at least 100 amino acids long, align the retained proteins, infer a broad protein-region tree, and midpoint-root it. This tree was used to select the IPR000916 clade set analyzed by ancestral sequence reconstruction.

## Input

- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta)

## Command

```bash
scripts/02_build_full_ipr000916_tree.sh
```

The script uses:

```bash
seqkit seq -m 100
famsa -t 10 -refine_mode on
VeryFastTree -threads 10
midroot
```

## Outputs

- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.fasta](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.fasta)
- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta)
- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.tree](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.tree)
- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree)

## Notes

The selected tip labels are stored in [data/two_mlp_clades/two_mlp_clades.txt](../data/two_mlp_clades/two_mlp_clades.txt).
