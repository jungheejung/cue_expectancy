#!/usr/bin/env python3
# %%
import os
import re
import json
import glob
from datetime import datetime
from os.path import join
from pathlib import Path

import numpy as np
import pandas as pd
import nibabel as nib
import joblib
import h5py

from neuromaps import transforms
from neuromaps.parcellate import Parcellater
from neuromaps.images import dlabel_to_gifti, annot_to_gifti

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# %% load data ____________________________________________________________________
main_dir = '/Users/h/Documents/projects_local/cue_expectancy'
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/'
save_discovery_dir= '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv02_parcel-glasser'
Path(save_discovery_dir).mkdir(exist_ok=True, parents=True)
# singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/'

subdirectories = sorted(glob.glob(join(singletrial_dir, "sub-*")))
flists = []
for subdir in subdirectories:
    sub = os.path.basename(subdir)
    flist = glob.glob(join(singletrial_dir, sub, 
                           f"{sub}_ses-*_run-*_runtype-*_event-cue_trial-*_cuetype-*.nii.gz"))
    flists.append(flist)

flattened_list = [item for sublist in flists for item in sublist]

parcelarray = []
metadata = []


hcplh = annot_to_gifti('/Users/h/Documents/projects_local/cue_expectancy/data/atlas/lh.HCP-MMP1.annot')
hcprh = annot_to_gifti('/Users/h/Documents/projects_local/cue_expectancy/data/atlas/rh.HCP-MMP1.annot')
HCP_fslr_lh = transforms.fsaverage_to_fslr(hcplh, hemi='L', target_density='32k', method='nearest')
HCP_fslr_rh = transforms.fsaverage_to_fslr(hcprh, hemi='R', target_density='32k', method='nearest')
HCP_fslr_rh_update = HCP_fslr_rh
HCP_fslr_rh_update[0].darrays[0].data = np.where(HCP_fslr_rh[0].agg_data() != 0, HCP_fslr_rh[0].agg_data() + 180, HCP_fslr_rh[0].agg_data())
hcp_glasser = (HCP_fslr_lh[0], HCP_fslr_rh_update[0])

for fname in flattened_list:
    metadata.append(os.path.basename(fname))
    singletrialFSLR = transforms.mni152_to_fslr(
        fname, fslr_density='32k', method='linear')
    
    HCPparc = Parcellater(hcp_glasser, 'fsLR', resampling_target='parcellation')
    singletrial_parc = HCPparc.fit_transform(singletrialFSLR, 'fsLR')
    parcelarray.append(singletrial_parc)


# %%
parcel_value = np.vstack(parcelarray)
np.save(join(save_discovery_dir, 'singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.npy'),parcel_value)
np.save(join(main_dir, 'analysis/fmri/nilearn/deriv02_parcel-glasser/singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.npy'),parcel_value)
np.save(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.npy'),parcel_value)

data = {
    "code_generated": "scripts/step10_nilearn/parcel_canlab2023/step01_parcellate_stimepoch_subcortex.py",
    "code_parcellate": """canlab2023_coarse = load_atlas('canlab2023_coarse_fmriprep20_2mm')
    data = fmri_data(canlab2023_coarse)
    data.fullpath = '/Users/h/Desktop/CANLab2023_MNI152NLin2009cAsym_coarse_2mm.nii.gz'
    data.write()
    tbl = table(canlab2023_coarse.labels', canlab2023_coarse.labels_2', canlab2023_coarse.labels_3', canlab2023_coarse.labels_4', canlab2023_coarse.labels_5', canlab2023_coarse.label_descriptions, 'VariableNames', {'coarse labels', 'coarse labels', 'coarser labels', 'coarsest labels', 'source atlas', 'label_description'})
    writetable(tbl, '/Users/h/Desktop/CANLab2023_MNI152NLin2009cAsym_coarse_2mm.csv')
    canlab2023 = '/Users/h/Documents/projects_local/cue_expectancy/data/atlas/CANLab2023_MNI152NLin6Asym_coarse_2mm_cifti_vols.nii.gz'
    parc = Parcellater(parcellation=canlab2023, 
                        space='MNI152', 
                        resampling_target='parcellation')
    parcelarray = []
    metadata = []
    for fname in flattened_list:
        metadata.append(os.path.basename(fname))
        singletrial_parc = parc.fit_transform(fname, 'MNI152') # (1, 595)
        parcelarray.append(singletrial_parc)""",
    "atlas": "Canlab 2023 atlas",
    "python_packages": ["neuromaps", "netneurotools"]
}

with open(join(main_dir,'analysis/fmri/nilearn/deriv02_parcel-glasser', 
               'singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
with open(join(save_discovery_dir,'singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
with open(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
metadatadf = pd.DataFrame(metadata, columns=['singletrial_fname'])

df_split = metadatadf['singletrial_fname'].str.extract(
    r'(?P<sub>sub-\d+)_'
    r'(?P<ses>ses-\d+)_'
    r'(?P<run>run-\d+)_'
    r'runtype-(?P<runtype>\w+)_'
    r'event-(?P<event>\w+)_'
    r'(?P<trial>trial-\d+)_'
    r'cuetype-(?P<cuetype>\w+)'
    
)

df_final = pd.concat([metadatadf, df_split], axis=1)
df_final.head()

df_final.to_csv(join(save_discovery_dir, 'singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.tsv'), 
                sep='\t', index=False, header=True)
df_final.to_csv(join(main_dir, 'analysis/fmri/nilearn/deriv02_parcel-glasser', 
                     'singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.tsv'), 
                sep='\t', index=False, header=True)
df_final.to_csv(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_epoch-cue_atlas-glasser.tsv'), 
                sep='\t', index=False, header=True)
