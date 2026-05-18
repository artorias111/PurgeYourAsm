#!/usr/bin/env python3
# companion python script to the nextflow script of the same name

import argparse
import os
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--hifi_dir', type=str, required=True)
args = parser.parse_args()

hifi_path = Path(args.hifi_dir).resolve()
files_list = os.listdir(hifi_path)

for f in files_list:
    if 'gz.' in f: # ignore stat files
        continue
    if 'fail' in f: # ignore failed reads
        continue
    if '.fastq.gz' in f:
        basename = hifi_path / f
        curr_file = f

        Path(curr_file).symlink_to(basename)
