#!/usr/bin/env python3
import sys
from Bio import SeqIO

if len(sys.argv) != 2:
    sys.stderr.write(f"Usage: {sys.argv[0]} <input.fasta>\n")
    sys.exit(1)

infile = sys.argv[1]

for rec in SeqIO.parse(infile, "fasta"):
    s = str(rec.seq)
    su = s.upper()
    if len(su) % 3 == 0 and su[-3:] in {"TAA", "TAG", "TGA"}:
        s = s[:-3]
    sys.stdout.write(f">{rec.id}\n{s}\n")
