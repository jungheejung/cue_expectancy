#!/usr/bin/env python3
import os, glob
from pathlib import Path

a = []
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
#main_dir = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/'
rmd_dir = os.path.join(main_dir,'scripts/step02_R_bookdown')
filelist = glob.glob(os.path.join(rmd_dir, '*.Rmd'))

for fpath in filelist:
    with open(fpath) as file:
        for line in file:
            if line.startswith('library('):
                a.append(line)
uniquelist = (list(set(a)))
save_fname = os.path.join(rmd_dir, 'librarylist.txt')
with open(save_fname, 'w') as fp:
    fp.write('\n'.join(sorted(list(set(a)))))

# %%
