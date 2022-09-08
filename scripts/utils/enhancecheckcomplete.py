import re
from os.path import join 
import os, shutil, glob, sys
from pathlib import Path
import pandas as pd
import logging
from datetime import datetime

def lines_that_start_with(string, fp):
    return [line for line in fp if line.startswith(string)]

date = datetime.now().strftime("%m-%d-%Y")

log_dir = sys.argv[1]
batchscript_dir = Path(log_dir).parents[0]
# log_dir = join(current_dir, 'log')
log_files = glob.glob(join(log_dir, '*.o'))
sub = []
complete = []
incomplete = []
# file = open(fname)
for fname in sorted(log_files):
    with open(fname) as f:
        sub_id = lines_that_start_with('sub:sub-', f)
        sub.append(int(re.findall('\d+', sub_id)[0]))
        for line in f: 
            if line.startswith("FINISH"):
                # sub.append(int(re.findall('\d+', line)[0]))
                complete.append(int(re.findall('\d+', line)[0]))
                
            else:
                incomplete.append(int(re.findall('\d+', line)[0]))
                
        for line in f:
            
            if line.startswith("FINISH"):
                sub.append(int(re.findall('\d+', line)[0]))
            else:
                incomplete 


with open( join(batchscript_dir, 'complete_{date}.txt'), "w") as output:
    output.write(str(sub))
