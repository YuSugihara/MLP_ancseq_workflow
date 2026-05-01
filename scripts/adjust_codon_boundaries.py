#!/usr/bin/env python3
import sys


def adjust_codon_boundaries(input_file, output_file):
    with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
        for line in f_in:
            parts = line.strip().split(":")
            coords = parts[1].split("-")
            start, end = int(coords[0]), int(coords[1])
            codon_start = (start - 1) * 3 + 1
            codon_end = end * 3
            f_out.write(f"{parts[0]}:{codon_start}-{codon_end}\n")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 adjust_codon_boundaries.py input_file output_file")
        sys.exit(1)

    adjust_codon_boundaries(sys.argv[1], sys.argv[2])
