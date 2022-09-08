import re
from os.path import join 
import os, shutil, glob, sys
from pathlib import Path
import pandas as pd
import logging
from datetime import datetime

date = datetime.now().strftime("%m-%d-%Y")

log_dir = sys.argv[1]
batchscript_dir = Path(log_dir).parents[0]
# log_dir = join(current_dir, 'log')
log_files = glob.glob(join(log_dir, '*.o'))
sub = []
# file = open(fname)
for fname in sorted(log_files):
    with open(fname) as f:
        for line in f:
            if line.startswith("FINISH") :
                sub.append(int(re.findall('\d+', line)[0]))

sorted_sub = sorted(sub)
with open( join(batchscript_dir,f'complete_{date}.txt'), "w") as output:
    output.write(str(sorted_sub))
