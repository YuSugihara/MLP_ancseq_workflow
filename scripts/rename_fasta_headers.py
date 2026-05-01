#!/usr/bin/env python3
import sys
import csv
import re


def load_metadata(metadata_file):
    """Load metadata from TSV file and create lookup dictionary"""
    metadata = {}
    with open(metadata_file, "r") as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            accession = row["Assembly Accession"]
            order = row["Order"].replace(" ", "_").replace(";", "_")
            species = row["Species"].replace(" ", "_").replace(";", "_")
            metadata[accession] = {"order": order, "species": species}
    return metadata


def rename_fasta_headers(input_fasta, output_fasta, metadata):
    """Rename FASTA headers with taxonomic information"""
    with open(input_fasta, "r") as f_in, open(output_fasta, "w") as f_out:
        for line in f_in:
            if line.startswith(">"):
                # Extract assembly accession from sequence ID
                seq_id = line.strip()[1:]  # Remove '>'

                # Extract assembly accession (format: GCA_XXXXXXXXX.X or GCF_XXXXXXXXX.X) using input_fasta
                assembly_acc = "_".join(input_fasta.split("/")[-1].split("_")[0:2])
                # Get metadata for the assembly accession
                order = metadata[assembly_acc]["order"]
                species = metadata[assembly_acc]["species"]
                # Create new header with taxonomic information
                new_header = f">{assembly_acc}_{order}_{species}_{seq_id}\n"
                f_out.write(new_header)
            else:
                # Write sequence lines as-is
                f_out.write(line)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(
            "Usage: python3 rename_fasta_headers.py metadata.tsv input.fasta output.fasta"
        )
        sys.exit(1)

    metadata_file = sys.argv[1]
    input_fasta = sys.argv[2]
    output_fasta = sys.argv[3]

    metadata = load_metadata(metadata_file)
    rename_fasta_headers(input_fasta, output_fasta, metadata)
    print(f"Renamed FASTA headers written to {output_fasta}")
