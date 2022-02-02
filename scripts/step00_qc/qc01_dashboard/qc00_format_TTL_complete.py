
#!/usr/bin/env python3
"""
identify how many participants have been fMRIprep-ed. 
"""
# %% libraries
import os, glob
import pandas as pd
import numpy as np
from datetime import datetime

biopac_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/biopac/dartmouth/b03_extract_ttl'
filename = glob.glob(os.path.join(biopac_dir, 'sub-*'))

df = pd.DataFrame(sorted(filename), columns=['filename'])
df["complete"] = df["filename"].apply(lambda path: os.path.splitext(os.path.basename(path))[0])
date = datetime.now().strftime("%m-%d-%Y")

# save file:
dashboard = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step00_qc/qc01_dashboard'
df.to_csv(os.path.join(dashboard, f"biopac-complete_{date}.csv"), index = False)