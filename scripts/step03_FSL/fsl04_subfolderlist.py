#!/usr/bin/env python
# encoding: utf-8
"""
subfolderlist.py
extract subfolders, save into txt file for job array submission
"""

# 1. libraries and directories __________________________________________
import os, glob, sys, time, shutil
import numpy as np
import fileinput
import itertools

main_dir = os.path.join('/dartfs-hpc','rc','lab','C','CANlab',
'labdata','projects','spacetop','social', 'analysis', 'fmri', 'fsl', 'multivariate', 'isolate_ev')

os.chdir(main_dir)
filesDepth4 = glob.glob('*/*/*/*')
save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step03_FSL'
df = pd.DataFrame([sub.split("/") for sub in filesDepth4])
df.to_csv(os.path.join(save_dir, 'fsl05_jobarraylist.txt'), sep = ',', index=False, header = False)

# with open(os.path.join(save_dir, 'fsl05_jobarraylist.txt'), 'w') as f:
#     for item in filesDepth4:
#         f.write("%s\n" % item)