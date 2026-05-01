# Step 03: Prepare the clade set for ancestral sequence reconstruction

## Purpose

Use selected tip labels from the full IPR000916 tree to extract the protein and CDS sequences used for ancestral sequence reconstruction. Terminal stop codons are removed from CDS sequences, proteins are aligned with MAFFT global-pair mode, and CDS sequences are threaded onto the protein alignment.

## Inputs

- [data/two_mlp_clades/two_mlp_clades.txt](../data/two_mlp_clades/two_mlp_clades.txt)
- [data/two_mlp_clades/all_IPR000916_protein.fasta](../data/two_mlp_clades/all_IPR000916_protein.fasta)
- [data/two_mlp_clades/all_IPR000916_cds.fasta](../data/two_mlp_clades/all_IPR000916_cds.fasta)
- [scripts/remove_stop_codon.py](../scripts/remove_stop_codon.py)

The clade labels were selected from:
[data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree).

## Command

```bash
scripts/03_prepare_asr_clade_set.sh
```

## Outputs

- [data/two_mlp_clades/two_mlp_clades_clean.txt](../data/two_mlp_clades/two_mlp_clades_clean.txt)
- [data/two_mlp_clades/MLP_protein_clade.fasta](../data/two_mlp_clades/MLP_protein_clade.fasta)
- [data/two_mlp_clades/MLP_cds_clade.fasta](../data/two_mlp_clades/MLP_cds_clade.fasta)
- [data/two_mlp_clades/MLP_cds_clade_noSTOP.fasta](../data/two_mlp_clades/MLP_cds_clade_noSTOP.fasta)
- [data/two_mlp_clades/MLP_protein_clade.global_aln.fasta](../data/two_mlp_clades/MLP_protein_clade.global_aln.fasta)
- [data/two_mlp_clades/MLP_codon_clade.global_aln.fasta](../data/two_mlp_clades/MLP_codon_clade.global_aln.fasta)

## Notes

The final codon alignment used by `ancseq` is [data/two_mlp_clades/MLP_codon_clade.global_aln.fasta](../data/two_mlp_clades/MLP_codon_clade.global_aln.fasta).
