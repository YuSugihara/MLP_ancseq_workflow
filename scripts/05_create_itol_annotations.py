#!/usr/bin/env python3
import csv
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
IPR000916_TREE_FILE = ROOT / "data/ipr000916_full_tree/IPR000916_protein_regions_renamed.fasta.m100.famsa_aln.fasta.vft.midroot.tree"
ANCSEQ_TREE_FILE = ROOT / "data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta.midrooted.treefile"
ANCSEQ_ALIGNMENT_FILE = ROOT / "data/anceseq_results_v1.3.0/00_tree/MLP_codon_clade.global_aln.fasta"
METADATA_FILE = ROOT / "data/metadata/ncbi_meta_data_sorted.tsv"
REFERENCE_MLP_FASTA = ROOT / "data/reference_MLP_protein.fasta"
OUT_DIR = ROOT / "data/itol_annotations"

COLORS = {
    "Cucumis": "#4CAF50",
    "Cucurbita": "#F28E2B",
    "Other": "#6a6a6a",
    "Reference MLP": "#000000",
}

CUCURBITA_SPECIES_COLORS = {
    "Cucurbita ficifolia": "#FB9FB9",
    "Cucurbita maxima": "#F5A456",
    "Cucurbita moschata": "#F6D481",
    "Cucurbita pepo": "#C94D6C",
}

REFERENCE_MLP_SPECIES = {
    "MLP-PG1": "Cucurbita pepo",
    "MLP-GR3": "Cucurbita pepo",
    "LcMLP2": "Luffa cylindrica",
    "CmMLP1": "Cucurbita moschata",
    "CmMLP3": "Cucurbita moschata",
    "CfMLP1": "Cucurbita ficifolia",
    "CfMLP2": "Cucurbita ficifolia",
}

SITE_NUCLEOTIDE_COLORS = {
    "A": "#4E79A7",
    "C": "#59A14F",
    "G": "#F28E2B",
    "T": "#E15759",
    "-": "#BDBDBD",
    "N": "#6a6a6a",
}

CODON_COLORS = {
    "TGG": "#4E79A7",
    "TTG": "#E15759",
    "TCG": "#59A14F",
}

AMINO_ACID_COLORS = {
    "W": "#4E79A7",
    "L": "#E15759",
    "S": "#59A14F",
    "-": "#BDBDBD",
    "X": "#6a6a6a",
}


def read_tree_tips(tree_file):
    tree_text = tree_file.read_text().strip()
    return re.findall(r"(?<=[(,])([^(),:;]+):[0-9.eE+-]+", tree_text)


def read_accession_to_species(metadata_file):
    mapping = {}
    with metadata_file.open(newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        for row in reader:
            species = row["Species"].strip()
            mapping[row["Assembly Accession"]] = species
    return mapping


def read_reference_mlp_ids(reference_fasta):
    ids = []
    with reference_fasta.open() as handle:
        for line in handle:
            if line.startswith(">"):
                ids.append(line[1:].strip().split()[0])
    return ids


def read_fasta(fasta_file):
    records = {}
    current_id = None
    chunks = []
    with fasta_file.open() as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                if current_id is not None:
                    records[current_id] = "".join(chunks)
                current_id = line[1:].split()[0]
                chunks = []
            else:
                chunks.append(line)
    if current_id is not None:
        records[current_id] = "".join(chunks)
    return records


def species_for_tip(tip, accession_to_species, reference_ids):
    for reference_id in reference_ids:
        if tip.startswith(f"{reference_id}_") or tip == reference_id:
            return REFERENCE_MLP_SPECIES.get(reference_id, "Reference MLP")

    accession = "_".join(tip.split("_")[:2])
    return accession_to_species.get(accession, "Other")


def category_for_tip(tip, accession_to_species, reference_ids):
    species = species_for_tip(tip, accession_to_species, reference_ids)
    if species == "Reference MLP":
        return "Reference MLP"

    genus = species.split()[0] if species else "Other"
    if genus == "Cucumis":
        return "Cucumis"
    if genus == "Cucurbita":
        return "Cucurbita"
    return "Other"


def write_label_styles(tips, accession_to_genus, reference_ids, output_file, dataset_label):
    with output_file.open("w") as out:
        out.write("DATASET_STYLE\n")
        out.write("SEPARATOR TAB\n")
        out.write(f"DATASET_LABEL\t{dataset_label}\n")
        out.write("COLOR\t#000000\n")
        out.write("LEGEND_TITLE\tGenus\n")
        out.write("LEGEND_SHAPES\t2\t2\t2\n")
        out.write(f"LEGEND_COLORS\t{COLORS['Cucumis']}\t{COLORS['Cucurbita']}\t{COLORS['Other']}\n")
        out.write("LEGEND_LABELS\tCucumis\tCucurbita\tOther\n")
        out.write("DATA\n")
        for tip in tips:
            category = category_for_tip(tip, accession_to_genus, reference_ids)
            if category == "Reference MLP":
                continue
            out.write(f"{tip}\tlabel\tnode\t{COLORS[category]}\t1\tnormal\n")


def write_reference_symbols(tips, reference_ids, output_file):
    reference_tips = [
        tip
        for tip in tips
        if any(tip.startswith(f"{reference_id}_") or tip == reference_id for reference_id in reference_ids)
    ]

    with output_file.open("w") as out:
        out.write("DATASET_SYMBOL\n")
        out.write("SEPARATOR TAB\n")
        out.write("DATASET_LABEL\tReference MLP tips\n")
        out.write(f"COLOR\t{COLORS['Reference MLP']}\n")
        out.write("MAXIMUM_SIZE\t16\n")
        out.write("LEGEND_TITLE\tReference sequences\n")
        out.write("LEGEND_SHAPES\t2\n")
        out.write(f"LEGEND_COLORS\t{COLORS['Reference MLP']}\n")
        out.write("LEGEND_SHAPE_INVERT\t1\n")
        out.write("LEGEND_LABELS\tReference MLP\n")
        out.write("DATA\n")
        for tip in reference_tips:
            out.write(f"{tip}\t2\t12\t{COLORS['Reference MLP']}\t1\t1\tReference MLP border\n")
            out.write(f"{tip}\t2\t8\t#ffffff\t1\t1\tReference MLP fill\n")


def ancseq_symbol_for_tip(tip, accession_to_species, reference_ids):
    species = species_for_tip(tip, accession_to_species, reference_ids)
    category = category_for_tip(tip, accession_to_species, reference_ids)

    if species in CUCURBITA_SPECIES_COLORS:
        return species, CUCURBITA_SPECIES_COLORS[species]
    if category == "Cucumis":
        return "Cucumis", COLORS["Cucumis"]
    if category == "Reference MLP":
        return "Reference MLP", COLORS["Reference MLP"]
    return "Other", COLORS["Other"]


def write_ancseq_tip_symbols(tips, accession_to_species, reference_ids, output_file):
    legend_labels = [
        "Cucumis",
        "Cucurbita ficifolia",
        "Cucurbita maxima",
        "Cucurbita moschata",
        "Cucurbita pepo",
        "Other",
    ]
    legend_colors = [
        COLORS["Cucumis"],
        CUCURBITA_SPECIES_COLORS["Cucurbita ficifolia"],
        CUCURBITA_SPECIES_COLORS["Cucurbita maxima"],
        CUCURBITA_SPECIES_COLORS["Cucurbita moschata"],
        CUCURBITA_SPECIES_COLORS["Cucurbita pepo"],
        COLORS["Other"],
    ]

    with output_file.open("w") as out:
        out.write("DATASET_SYMBOL\n")
        out.write("SEPARATOR TAB\n")
        out.write("DATASET_LABEL\tAncestral reconstruction tree tip symbols\n")
        out.write("COLOR\t#000000\n")
        out.write("MAXIMUM_SIZE\t12\n")
        out.write("LEGEND_TITLE\tTaxon group\n")
        out.write("LEGEND_SHAPES\t" + "\t".join(["2"] * len(legend_labels)) + "\n")
        out.write("LEGEND_COLORS\t" + "\t".join(legend_colors) + "\n")
        out.write("LEGEND_LABELS\t" + "\t".join(legend_labels) + "\n")
        out.write("DATA\n")
        for tip in tips:
            label, color = ancseq_symbol_for_tip(tip, accession_to_species, reference_ids)
            out.write(f"{tip}\t2\t8\t{color}\t1\t1\t{label}\n")


def write_ancseq_reference_labels(tips, reference_ids, output_file):
    with output_file.open("w") as out:
        out.write("LABELS\n")
        out.write("SEPARATOR TAB\n")
        out.write("DATA\n")
        for tip in tips:
            if any(tip == reference_id for reference_id in reference_ids):
                out.write(f"{tip}\t{tip}\n")
            else:
                out.write(f"{tip}\t \n")


def translate_codon(codon):
    genetic_code = {
        "TTT": "F", "TTC": "F", "TTA": "L", "TTG": "L",
        "TCT": "S", "TCC": "S", "TCA": "S", "TCG": "S",
        "TAT": "Y", "TAC": "Y", "TAA": "*", "TAG": "*",
        "TGT": "C", "TGC": "C", "TGA": "*", "TGG": "W",
        "CTT": "L", "CTC": "L", "CTA": "L", "CTG": "L",
        "CCT": "P", "CCC": "P", "CCA": "P", "CCG": "P",
        "CAT": "H", "CAC": "H", "CAA": "Q", "CAG": "Q",
        "CGT": "R", "CGC": "R", "CGA": "R", "CGG": "R",
        "ATT": "I", "ATC": "I", "ATA": "I", "ATG": "M",
        "ACT": "T", "ACC": "T", "ACA": "T", "ACG": "T",
        "AAT": "N", "AAC": "N", "AAA": "K", "AAG": "K",
        "AGT": "S", "AGC": "S", "AGA": "R", "AGG": "R",
        "GTT": "V", "GTC": "V", "GTA": "V", "GTG": "V",
        "GCT": "A", "GCC": "A", "GCA": "A", "GCG": "A",
        "GAT": "D", "GAC": "D", "GAA": "E", "GAG": "E",
        "GGT": "G", "GGC": "G", "GGA": "G", "GGG": "G",
    }
    if "-" in codon:
        return "-"
    return genetic_code.get(codon.upper(), "X")


def alignment_columns_for_ungapped_codon(sequence, amino_acid_position):
    first_nt = (amino_acid_position - 1) * 3 + 1
    last_nt = amino_acid_position * 3
    observed = 0
    columns = []
    for column, nucleotide in enumerate(sequence, start=1):
        if nucleotide != "-":
            observed += 1
        if first_nt <= observed <= last_nt:
            columns.append(column)
        if observed == last_nt:
            break
    if len(columns) != 3:
        raise ValueError(f"Amino acid position {amino_acid_position} exceeds sequence length")
    return columns


def write_ancseq_codon_symbols(tips, alignment_file, target_id, amino_acid_position, output_file):
    records = read_fasta(alignment_file)
    alignment_columns = alignment_columns_for_ungapped_codon(records[target_id], amino_acid_position)
    target_codon = "".join(records[target_id][column - 1] for column in alignment_columns).upper()

    observed_codons = []
    for tip in tips:
        codon = "".join(records[tip][column - 1] for column in alignment_columns).upper()
        if codon not in CODON_COLORS:
            CODON_COLORS[codon] = "#6a6a6a"
        if codon not in observed_codons:
            observed_codons.append(codon)

    with output_file.open("w") as out:
        out.write("DATASET_SYMBOL\n")
        out.write("SEPARATOR TAB\n")
        out.write(f"DATASET_LABEL\t{target_id} amino acid position {amino_acid_position} codon\n")
        out.write("COLOR\t#000000\n")
        out.write("MAXIMUM_SIZE\t12\n")
        out.write(f"LEGEND_TITLE\t{target_id} amino acid {amino_acid_position} codon (alignment columns {alignment_columns[0]}-{alignment_columns[-1]})\n")
        out.write("LEGEND_SHAPES\t" + "\t".join(["2"] * len(observed_codons)) + "\n")
        out.write("LEGEND_COLORS\t" + "\t".join(CODON_COLORS[codon] for codon in observed_codons) + "\n")
        out.write("LEGEND_LABELS\t" + "\t".join(observed_codons) + "\n")
        out.write("DATA\n")
        for tip in tips:
            codon = "".join(records[tip][column - 1] for column in alignment_columns).upper()
            size = 10 if codon == target_codon else 8
            out.write(f"{tip}\t2\t{size}\t{CODON_COLORS[codon]}\t1\t-1\t{codon}\n")

    return alignment_columns, target_codon


def write_ancseq_amino_acid_symbols(tips, alignment_file, target_id, amino_acid_position, output_file):
    records = read_fasta(alignment_file)
    alignment_columns = alignment_columns_for_ungapped_codon(records[target_id], amino_acid_position)
    target_codon = "".join(records[target_id][column - 1] for column in alignment_columns).upper()
    target_aa = translate_codon(target_codon)

    observed_aas = []
    for tip in tips:
        codon = "".join(records[tip][column - 1] for column in alignment_columns).upper()
        amino_acid = translate_codon(codon)
        if amino_acid not in AMINO_ACID_COLORS:
            AMINO_ACID_COLORS[amino_acid] = "#6a6a6a"
        if amino_acid not in observed_aas:
            observed_aas.append(amino_acid)

    with output_file.open("w") as out:
        out.write("DATASET_SYMBOL\n")
        out.write("SEPARATOR TAB\n")
        out.write(f"DATASET_LABEL\t{target_id} amino acid position {amino_acid_position}\n")
        out.write("COLOR\t#000000\n")
        out.write("MAXIMUM_SIZE\t12\n")
        out.write(f"LEGEND_TITLE\t{target_id} amino acid {amino_acid_position} (alignment columns {alignment_columns[0]}-{alignment_columns[-1]})\n")
        out.write("LEGEND_SHAPES\t" + "\t".join(["2"] * len(observed_aas)) + "\n")
        out.write("LEGEND_COLORS\t" + "\t".join(AMINO_ACID_COLORS[aa] for aa in observed_aas) + "\n")
        out.write("LEGEND_LABELS\t" + "\t".join(observed_aas) + "\n")
        out.write("DATA\n")
        for tip in tips:
            codon = "".join(records[tip][column - 1] for column in alignment_columns).upper()
            amino_acid = translate_codon(codon)
            size = 10 if amino_acid == target_aa else 8
            out.write(f"{tip}\t2\t{size}\t{AMINO_ACID_COLORS[amino_acid]}\t1\t-1\t{amino_acid}\n")

    return alignment_columns, target_aa


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    ipr000916_tips = read_tree_tips(IPR000916_TREE_FILE)
    ancseq_tips = read_tree_tips(ANCSEQ_TREE_FILE)
    accession_to_species = read_accession_to_species(METADATA_FILE)
    reference_ids = read_reference_mlp_ids(REFERENCE_MLP_FASTA)

    write_label_styles(
        ipr000916_tips,
        accession_to_species,
        reference_ids,
        OUT_DIR / "ipr000916_tip_label_colors_itol.txt",
        "IPR000916 tip label colors",
    )
    write_reference_symbols(
        ipr000916_tips,
        reference_ids,
        OUT_DIR / "ipr000916_reference_mlp_symbols_itol.txt",
    )
    write_ancseq_tip_symbols(
        ancseq_tips,
        accession_to_species,
        reference_ids,
        OUT_DIR / "ancseq_tip_symbols_itol.txt",
    )
    write_ancseq_reference_labels(
        ancseq_tips,
        reference_ids,
        OUT_DIR / "ancseq_reference_mlp_labels_itol.txt",
    )
    codon_columns, codon_state = write_ancseq_codon_symbols(
        ancseq_tips,
        ANCSEQ_ALIGNMENT_FILE,
        "MLP-GR3",
        121,
        OUT_DIR / "ancseq_mlp_gr3_aa121_codon_symbols_itol.txt",
    )
    _, amino_acid_state = write_ancseq_amino_acid_symbols(
        ancseq_tips,
        ANCSEQ_ALIGNMENT_FILE,
        "MLP-GR3",
        121,
        OUT_DIR / "ancseq_mlp_gr3_aa121_symbols_itol.txt",
    )

    print(f"IPR000916 tree tips: {len(ipr000916_tips)}")
    print(f"IPR000916 reference MLP tips: {sum(1 for tip in ipr000916_tips if any(tip.startswith(f'{rid}_') or tip == rid for rid in reference_ids))}")
    print(f"Ancestral reconstruction tree tips: {len(ancseq_tips)}")
    print(f"MLP-GR3 amino acid position 121: alignment columns {codon_columns[0]}-{codon_columns[-1]}, codon {codon_state}, amino acid {amino_acid_state}")
    print(f"Wrote annotations to {OUT_DIR}")


if __name__ == "__main__":
    main()
