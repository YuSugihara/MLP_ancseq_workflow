# Step 00: Generate the proteome dataset

## Purpose

Generate the proteome dataset used for the IPR000916 search. Gene models were predicted from genome assemblies with Helixer, and the resulting protein FASTA files were processed with NLRtracker. The InterProScan GFF output used in Step 01 comes from the NLRtracker output directories.

BUSCO was run on the Helixer-derived proteomes to summarize proteome completeness. The filtered summary for the assemblies used in this repository is available at [data/metadata/busco_summary.tsv](../data/metadata/busco_summary.tsv).

## Inputs

- Genome FASTA files for the assemblies listed in [data/metadata/NCBI_list.txt](../data/metadata/NCBI_list.txt)
- Helixer Singularity image and land plant model
- NLRtracker installation with its InterProScan module list
- BUSCO lineage dataset `embryophyta_odb12`

## Commands

Generate Helixer gene models, CDS FASTA files, protein FASTA files, and GFF files:

```bash
scripts/upstream/00_run_helixer.sh
```

Run NLRtracker on the Helixer-derived protein FASTA files:

```bash
scripts/upstream/01_run_nlrtracker.sh
```

Run BUSCO on the Helixer-derived proteomes:

```bash
scripts/upstream/02_run_busco.sh
```

## Outputs

- Helixer-derived protein FASTA files
- Helixer-derived CDS FASTA files
- NLRtracker result directories containing InterProScan GFF output
- [data/metadata/busco_summary.tsv](../data/metadata/busco_summary.tsv)
