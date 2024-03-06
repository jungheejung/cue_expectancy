import os, glob, re
import pandas as pd
from os.path import join
from pathlib import Path
# load tsv

vif_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/vif'
vif_save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/vif_summary'
singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau'
sub_folders = next(os.walk(singletrial_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]

Path(vif_save_dir).mkdir(parents=True, exist_ok=True)
for sub in sub_list:
    vif_flist = glob.glob(join(vif_dir, f'vif_{sub}_*.tsv'), recursive=True)
    vif_summary_df = pd.DataFrame(columns=['singletrial_fname', 'regressor', 'vif'])

    len(vif_flist)
    for vif_fname in sorted(vif_flist):
        df = pd.read_csv(vif_fname,sep='\t')
        print(df.head())
        model_name = df['modelname'][0]
        # Using regex to extract the keywords following "event-" and "trial-"
        event_match = re.search(r"event-([a-zA-Z0-9]+)_", model_name)
        trial_match = re.search(r"trial-([a-zA-Z0-9]+)_", model_name)

        # Extracted keywords
        event_keyword = event_match.group(1) if event_match else None
        trial_keyword = trial_match.group(1) if trial_match else None

        regressor = f"{event_keyword}__{trial_keyword}"

        # Identify the row for the given event-trial combination and extract the VIF
        vif_row = df[df['feature'] == regressor]
        vif = vif_row['VIF'].values[0] if not vif_row.empty else None

        # Append the information to the summary DataFrame
        vif_summary_df = vif_summary_df.append({
            'singletrial_fname': os.path.basename(vif_fname),
            'regressor': regressor,
            'event': event_keyword,
            'vif': vif}, ignore_index=True)
    vif_summary_df.to_csv(join(vif_save_dir, f"vif_{sub}.tsv"), sep='\t', index=False)
