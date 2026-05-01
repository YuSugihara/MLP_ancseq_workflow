# MLP ancestral sequence reconstruction workflow

This repository documents the workflow used to reconstruct ancestral sequences for an MLP-centered clade set selected from a broad IPR000916 protein-region phylogeny. The selected sequences were realigned, converted into a codon alignment, and analyzed with `ancseq`.

The ancestral sequence reconstruction output is available in [data/anceseq_results_v1.3.0](data/anceseq_results_v1.3.0/).

## Repository Contents

- [data/](data/): input and intermediate FASTA, metadata, alignment, and tree files
- [data/metadata/busco_summary.tsv](data/metadata/busco_summary.tsv): BUSCO summary for the assemblies listed in [data/metadata/NCBI_list.txt](data/metadata/NCBI_list.txt)
- [data/ipr000916_full_tree/](data/ipr000916_full_tree/): combined IPR000916 region sequences and the broad protein-region tree
- [data/two_mlp_clades/](data/two_mlp_clades/): selected IPR000916 clade sequences and codon alignment used for ancestral sequence reconstruction
- [data/anceseq_results_v1.3.0/](data/anceseq_results_v1.3.0/): ancestral sequence reconstruction output
- [data/itol_annotations/](data/itol_annotations/): iTOL annotation files for tree visualization
- [scripts/](scripts/): scripts used to regenerate each workflow step
- [docs/](docs/): step-by-step workflow documentation

## Workflow

0. [Generate the proteome dataset](docs/00_generate_proteome_dataset.md)
1. [Prepare IPR000916 sequences](docs/01_prepare_ipr000916_sequences.md)
2. [Build the full IPR000916 tree](docs/02_build_full_ipr000916_tree.md)
3. [Prepare the clade set for ancestral sequence reconstruction](docs/03_prepare_asr_clade_set.md)
4. [Run ancestral sequence reconstruction](docs/04_run_ancestral_sequence_reconstruction.md)
5. [Create iTOL annotations](docs/05_create_itol_annotations.md)

## Software Requirements

Versions below are the versions used in the local environment when preparing this repository.

| Tool                             | Version       | URL                                                                                |
| -------------------------------- | ------------- | ---------------------------------------------------------------------------------- |
| SeqKit                           | 2.10.0        | [github.com/shenwei356/seqkit](https://github.com/shenwei356/seqkit)               |
| SeqTK                            | 1.5-r133      | [github.com/lh3/seqtk](https://github.com/lh3/seqtk)                               |
| SAMtools                         | 1.22.1        | [github.com/samtools/samtools](https://github.com/samtools/samtools)               |
| Helixer                          | 0.3.5         | [github.com/weberlab-hhu/Helixer](https://github.com/weberlab-hhu/Helixer)         |
| InterProScan                     | 5.65-97.0     | [github.com/ebi-pf-team/interproscan](https://github.com/ebi-pf-team/interproscan) |
| pigz                             | 2.8           | [github.com/madler/pigz](https://github.com/madler/pigz)                           |
| FAMSA                            | 2.4.1-45c9b2b | [github.com/refresh-bio/FAMSA](https://github.com/refresh-bio/FAMSA)               |
| VeryFastTree                     | 4.0.5         | [github.com/citiususc/veryfasttree](https://github.com/citiususc/veryfasttree)     |
| MAFFT                            | 7.526         | [mafft.cbrc.jp/alignment/software](https://mafft.cbrc.jp/alignment/software/)      |
| PhyKIT                           | 1.11.0        | [github.com/JLSteenwyk/PhyKIT](https://github.com/JLSteenwyk/PhyKIT)               |
| ancseq                           | 1.3.0         | [github.com/YuSugihara/ancseq](https://github.com/YuSugihara/ancseq)               |
| IQ-TREE                          | 3.0.1         | [github.com/iqtree/iqtree3](https://github.com/iqtree/iqtree3)                     |
| Python                           | 3.13.5        | [python.org](https://www.python.org/)                                              |
| ETE Toolkit (`ete4`)             | 4.3.0         | [github.com/etetoolkit/ete](https://github.com/etetoolkit/ete)                     |
| Biopython                        | 1.85          | [github.com/biopython/biopython](https://github.com/biopython/biopython)           |

For details on `ancseq`, see Sugihara et al. (2025), PLOS Genetics: [https://doi.org/10.1371/journal.pgen.1011653](https://doi.org/10.1371/journal.pgen.1011653).
