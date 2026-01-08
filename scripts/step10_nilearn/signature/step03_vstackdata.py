import pandas as pd
import glob
from pathlib import Path

# Get all CSV files in directory
csv_files = sorted(glob.glob('smb://dartfs-hpc.dartmouth.edu/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab/sub-*_CANlab_applyNPS_singletrial_rampupplateau_epoch-cue.csv'))

# Read and concatenate
df_list = [pd.read_csv(file) for file in csv_files]
combined_df = pd.concat(df_list, ignore_index=True)

# Save
combined_df.to_csv('signature-NPS_sub-all_runtype-pain_event-cue.csv', index=False)