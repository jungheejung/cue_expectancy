#!/usr/bin/env python3
"""
identify how many participants have been fMRIprep-ed. 
"""
# %% libraries
import os, glob
import pandas as pd
import numpy as np
from datetime import datetime

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
filename = glob.glob(os.path.join(fmriprep_dir, '*.html'))

df = pd.DataFrame(filename, columns=['filename'])
df["complete"] = df["filename"].apply(lambda path: os.path.splitext(os.path.basename(path))[0])
date = datetime.now().strftime("%m-%d-%Y")

# save file:
social = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step00_qc/qc01_dashboard'
df.to_csv(os.path.join(social, f"fmriprep-complete_{date}.csv"), index = False)