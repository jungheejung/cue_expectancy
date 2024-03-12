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
import matplotlib.pyplot as plt
import seaborn as sns
import nibabel as nib
import joblib
import h5py

from sklearn.model_selection import GroupKFold, cross_val_score, KFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import make_scorer, mean_squared_error

from nilearn import image, masking, plotting
from nilearn.input_data import NiftiLabelsMasker, NiftiMapsMasker
from nilearn.image import resample_to_img, math_img, new_img_like

import neuromaps
from neuromaps import datasets as neuromaps_datasets
from neuromaps.datasets import fetch_annotation, fetch_fslr
from neuromaps.parcellate import Parcellater
from neuromaps.images import dlabel_to_gifti
from neuromaps.transforms import fsaverage_to_fslr

from netneurotools import datasets as nntdata

from surfplot import Plot

from sklearn.metrics import confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

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
# singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/'

subdirectories = sorted(glob.glob(join(singletrial_dir, "sub-*")))
flists = []
for subdir in subdirectories:
    sub = os.path.basename(subdir)
    flist = glob.glob(join(singletrial_dir, sub, 
                           f"{sub}_ses-*_run-*_runtype-*_event-stimulus_trial-*_cuetype-*_stimintensity-*.nii.gz"))
    flists.append(flist)

flattened_list = [item for sublist in flists for item in sublist]
flattened_list[0]
# %%
schaefer = nntdata.fetch_schaefer2018('fslr32k')['400Parcels7Networks']
parcelarray = []
metadata = []
for fname in flattened_list:
    metadata.append(os.path.basename(fname))
    singletrialFSLR = neuromaps.transforms.mni152_to_fslr(
        fname, fslr_density='32k', method='linear')
    parc = Parcellater(dlabel_to_gifti(schaefer), 'fsLR')
    singletrial_parc = parc.fit_transform(singletrialFSLR, 'fsLR')
    parcelarray.append(singletrial_parc)
# %%
parcel_value = np.vstack(parcelarray)
np.save(join(singletrial_dir, 'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.npy'),parcel_value)
np.save(join(main_dir, 'analysis/fmri/nilearn/singletrial_rampupplateau/singletrial_rampupplateau_task-pvc_atlas-schaefer2018.npy'),parcel_value)
np.save(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_atlas-schaefer2018.npy'),parcel_value)

data = {
    "code_generated": "scripts/step10_nilearn/singletrialLSS/step07_parcellate.py",
    "code_parcellate": """schaefer = nntdata.fetch_schaefer2018('fslr32k')['400Parcels7Networks']
                        parcelarray = []
                        metadata = []
                        for fname in flattened_list:
                            metadata.append(os.path.basename(fname))
                            singletrialFSLR = neuromaps.transforms.mni152_to_fslr(fname, fslr_density='32k', method='linear')
                            parc = Parcellater(dlabel_to_gifti(schaefer), 'fsLR')
                            singletrial_parc = parc.fit_transform(singletrialFSLR, 'fsLR')
                            parcelarray.append(singletrial_parc)""",
    "atlas": "Schaefer2018_400Parcels_7Networks_order",
    "python_packages": ["neuromaps", "netneurotools"]
}

with open(join(main_dir,'analysis/fmri/nilearn/singletrial_rampupplateau', 
               'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
with open(join(singletrial_dir,'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
with open(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_atlas-schaefer2018.json'), 'w') as json_file:
    json.dump(data, json_file, indent=4)
metadatadf = pd.DataFrame(metadata, columns=['singletrial_fname'])

df_split = metadatadf['singletrial_fname'].str.extract(
    r'(?P<sub>sub-\d+)_'
    r'(?P<ses>ses-\d+)_'
    r'(?P<run>run-\d+)_'
    r'runtype-(?P<runtype>\w+)_'
    r'event-(?P<event>\w+)_'
    r'(?P<trial>trial-\d+)_'
    r'cuetype-(?P<cuetype>\w+)_'
    r'stimintensity-(?P<stimintensity>\w+)'
)

df_final = pd.concat([metadatadf, df_split], axis=1)
df_final.head()
df_final.to_csv(join(singletrial_dir, 'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.tsv'), 
                sep='\t', index=False, header=True)
df_final.to_csv(join('/Volumes/seagate/cue_singletrials/singletrial_rampupplateau_task-pvc_atlas-schaefer2018.tsv'), 
                sep='\t', index=False, header=True)
