# Step 01: Prepare IPR000916 sequences

## Purpose

Extract IPR000916/PF00407 regions from InterProScan results, map protein-region coordinates onto CDS coordinates, rename headers with taxonomy metadata, and concatenate the protein and CDS region FASTA files used downstream.

The broader proteome dataset was generated with Helixer. InterProScan output was obtained as part of the NLRtracker run described in [Step 00](00_generate_proteome_dataset.md).

## Inputs

Repository inputs:

- [data/reference_MLP_cds.fasta](../data/reference_MLP_cds.fasta): reference MLP CDS sequences
- [data/reference_MLP_protein.fasta](../data/reference_MLP_protein.fasta): reference MLP protein sequences
- [data/MLP_protein_interpro_result.gff](../data/MLP_protein_interpro_result.gff): InterProScan output for the reference MLP proteins
- [data/metadata/NCBI_list.txt](../data/metadata/NCBI_list.txt)
- [data/metadata/ncbi_meta_data_sorted.tsv](../data/metadata/ncbi_meta_data_sorted.tsv)
- [scripts/adjust_codon_boundaries.py](../scripts/adjust_codon_boundaries.py)
- [scripts/rename_fasta_headers.py](../scripts/rename_fasta_headers.py)

External inputs required to regenerate the full extraction:

- NLRtracker result directories or archives containing InterProScan GFF output
- Helixer protein FASTA files
- Helixer CDS FASTA files

Set these paths before running the script:

```bash
export RAW_NLRTRACKER_DIR=/path/to/nlrtracker_results
export RAW_HELIXER_PROTEIN_DIR=/path/to/Helixer_results/protein
export RAW_HELIXER_CDS_DIR=/path/to/Helixer_results/cds
```

## Command

```bash
scripts/01_prepare_ipr000916_sequences.sh
```

## Outputs

- [data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta](../data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta)
- [data/ipr000916_full_tree/IPR000916_cds_regions_renamed.fasta](../data/ipr000916_full_tree/IPR000916_cds_regions_renamed.fasta)
- [data/two_mlp_clades/all_IPR000916_protein.fasta](../data/two_mlp_clades/all_IPR000916_protein.fasta)
- [data/two_mlp_clades/all_IPR000916_cds.fasta](../data/two_mlp_clades/all_IPR000916_cds.fasta)

## Notes

Protein sequences derived from the Helixer proteome dataset are renamed with assembly accession, order, species, and original sequence ID. Reference MLP sequence headers are standardized by replacing coordinate separators with underscores.
