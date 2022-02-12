#!/usr/bin/env python3

"""glm single example tutorial
"""
# %%
import numpy as np
import pandas as pd
import scipy
import scipy.stats as stats
import scipy.io as sio
import matplotlib.pyplot as plt
import nibabel as nib
import nilearn
from nilearn import image

import os
from os.path import join, exists, split
import sys
import time
import urllib.request
import copy
import warnings
from tqdm import tqdm
from pprint import pprint
warnings.filterwarnings('ignore')

import glmsingle
from glmsingle.glmsingle import GLM_single

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# %% directories _______________________________________________________________
# get path to the directory to which GLMsingle was installed
glmsingle_dir = '/Users/h/Dropbox/projects_dropbox/GLMsingle'

# create directory for saving data
social_influence_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/fmri/glmsingle'
datadir = os.path.join(social_influence_dir, 'examples', 'data')
os.makedirs(datadir,exist_ok=True)

# create directory for saving outputs from example 1
outputdir = join(glmsingle_dir,'examples','example1outputs')

print(f'directory to save example dataset:\n\t{datadir}\n')
print(f'directory to save example1 outputs:\n\t{outputdir}\n')

# %% data _______________________________________________________________
# identify onset of stimulus. 
# identify which TR, mark 1
# build a pd 
# afterwards, build a matrix
# run2 = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/examples/data/sub-0051_ses-04_task-social_run-02-vicarious_beh.csv'
# run5 = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/examples/data/sub-0051_ses-04_task-social_run-05-vicarious_beh.csv'
# r2 = pd.read_csv(run2)
# r5 = pd.read_csv(run5)
run_list = [2,5]
design = []
sub = 'sub-0051'
ses = 'ses-04'
for r in run_list:
    df = pd.read_csv(f"/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/examples/data/{sub}_{ses}_task-social_run-{r:02d}-vicarious_beh.csv")
    # %% building pandas dataframe from glmsingle _______________________________________________________________
    # dictionary for condition mapping 
    cond_name = {'low-cue_low-stim':1,
    'low-cue_med-stim':2,
    'low-cue_high-stim':3,
    'high-cue_low-stim':4,
    'high-cue_med-stim':5,
    'high-cue_high-stim':6}
    cond_name_inv = dict(map(reversed, cond_name.items()))

    # construct data frame based on behavioral data
    condition_type = pd.concat([df['param_cond_type']]*4, ignore_index = True)
    stim_dir = pd.Series([1,4,5,4]).repeat(12)
    ev1 = df['event01_cue_onset'] - df['param_trigger_onset'][0]
    ev2 = df['event02_expect_displayonset'] - df['param_trigger_onset'][0]
    ev3 = df['event03_stimulus_displayonset'] - df['param_trigger_onset'][0]
    ev4 = df['event04_actual_displayonset'] - df['param_trigger_onset'][0]

    # empty dataframe
    new_df = pd.DataFrame(columns = ['order', 'onset', 'condition_type', 'cue', 'stim', 'task'])
    onset = pd.concat([ev1,ev2,ev3,ev4])
    cond = pd.Series(['cue','expect','stim','actual'])
    cond_string = cond.repeat(12)
    df_dict = {'order':list(range(len(cond_string))), 
    'onset':np.array(onset), 
    'condition_type':condition_type, 
    'cue':0, 
    'stim':0, 
    'task':'vicarious'}
    new_df = pd.DataFrame.from_dict(df_dict)
    new_df['condition_name'] = new_df['condition_type'].map(cond_name_inv)
    new_df['cue'] = new_df['condition_name'].str.split('_', 1).str[0]
    new_df['stim'] = new_df['condition_name'].str.split('_', 1).str[1]

    new_df['tr'] = round(new_df['onset']/0.46).astype(int)

    dim_x = 872
    dim_y = 48
    order_tr = list(new_df[[ 'tr', 'order']].apply(tuple, axis = 1))
    design_mat = np.zeros((dim_x, dim_y), dtype = int)
    for el in order_tr:
        if el[0] < dim_x and el[1] < dim_y:
            design_mat[el[0], el[1]] = 1
    design.append(design_mat)

# %% visualize design
plt.figure(figsize=(20,20))
plt.subplot(121)
plt.imshow(design[0],origin = 'lower', interpolation='none')
plt.title('example design matrix from run 1',fontsize=16)
plt.xlabel('conditions',fontsize=16)
plt.ylabel('time (TR)',fontsize=16);
plt.subplot(122)
plt.imshow(design[1],origin = 'lower', interpolation='none')
plt.title('example design matrix from run 2',fontsize=16)
plt.xlabel('conditions',fontsize=16)
plt.ylabel('time (TR)',fontsize=16);

# %%
# nii_r2 = '/Users/h/Dropbox/projects_dropbox/GLMsingle/sub-0051_ses-04_task-social_acq-mb8_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
# data_r2 = image.load_img(nii_r2) #shape: (73, 86, 73, 872)
# nii_r5= '/Users/h/Dropbox/projects_dropbox/GLMsingle/sub-0051_ses-04_task-social_acq-mb8_run-5_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
# data_r5 = image.load_img(nii_r5) #shape: (73, 86, 73, 872)
# %%
run_list = [2,5]
data = []
sub = 'sub-0051'
ses = 'ses-04'
for r in run_list:
    nii_fpath = '/Users/h/Dropbox/projects_dropbox/GLMsingle'
    nii_name = os.path.join(nii_fpath, f"{sub}_{ses}_task-social_acq-mb8_run-{r}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")
    nilearn_data = image.load_img(nii_name) 
    data.append(nilearn_data.get_fdata())
# %% visualize data
# plot example slice from run 1
plt.figure(figsize=(20,6))
plt.subplot(121)
plt.imshow(data[0][:,:,0,0])
plt.title('example slice from run 1',fontsize=16)
plt.subplot(122)
plt.imshow(data[1][:,:,0,0])
plt.title('example slice from run 2',fontsize=16)

# %%
stimdur = 5
# print some relevant metadata
print(f'There are {len(data)} runs in total\n')
print(f'N = {data[0].shape[3]} TRs per run\n')
print(f'The dimensions of the data for each run are: {data[0].shape}\n')
print(f'The stimulus duration is {stimdur} seconds\n')
print(f'XYZ dimensionality is: {data[0].shape[:3]} (one slice only in this example)\n')
print(f'Numeric precision of data is: {type(data[0][0,0,0,0])}\n')
# print(f'There are {np.sum(roi)} voxels in the included visual ROI')
# %%
outputdir_glmsingle = join(outputdir,'GLMsingle')

opt = dict()

# set important fields for completeness (but these would be enabled by default)
opt['wantlibrary'] = 1
opt['wantglmdenoise'] = 1
opt['wantfracridge'] = 1

# for the purpose of this example we will keep the relevant outputs in memory
# and also save them to the disk
opt['wantfileoutputs'] = [1,1,1,1]
opt['wantmemoryoutputs'] = [1,1,1,1]
opt['sessionindicator'] = [1,1]

# running python GLMsingle involves creating a GLM_single object
# and then running the procedure using the .fit() routine
glmsingle_obj = GLM_single(opt)

# visualize all the hyperparameters
pprint(glmsingle_obj.params)
# %%
tr = 0.46
# this example saves output files to the folder  "example1outputs/GLMsingle"
# if these outputs don't already exist, we will perform the time-consuming call to GLMsingle;
# otherwise, we will just load from disk.

start_time = time.time()

if not exists(outputdir_glmsingle):

    print(f'running GLMsingle...')
    
    # run GLMsingle
    results_glmsingle = glmsingle_obj.fit(
       design,
       data,
       stimdur,
       tr,
       outputdir=outputdir_glmsingle)
    
    # we assign outputs of GLMsingle to the "results_glmsingle" variable.
    # note that results_glmsingle['typea'] contains GLM estimates from an ONOFF model,
    # where all images are treated as the same condition. these estimates
    # could be potentially used to find cortical areas that respond to
    # visual stimuli. we want to compare beta weights between conditions
    # therefore we are not going to include the ONOFF betas in any analyses of 
    # voxel reliability
    
else:
    print(f'loading existing GLMsingle outputs from directory:\n\t{outputdir_glmsingle}')
    
    # load existing file outputs if they exist
    results_glmsingle = dict()
    results_glmsingle['typea'] = np.load(join(outputdir_glmsingle,'TYPEA_ONOFF.npy'),allow_pickle=True).item()
    results_glmsingle['typeb'] = np.load(join(outputdir_glmsingle,'TYPEB_FITHRF.npy'),allow_pickle=True).item()
    results_glmsingle['typec'] = np.load(join(outputdir_glmsingle,'TYPEC_FITHRF_GLMDENOISE.npy'),allow_pickle=True).item()
    results_glmsingle['typed'] = np.load(join(outputdir_glmsingle,'TYPED_FITHRF_GLMDENOISE_RR.npy'),allow_pickle=True).item()

elapsed_time = time.time() - start_time

print(
    '\telapsed time: ',
    f'{time.strftime("%H:%M:%S", time.gmtime(elapsed_time))}'
)
# %%
output_fname = '/Users/h/Dropbox/projects_dropbox/GLMsingle/examples/example1outputs/GLMsingle/TYPED_FITHRF_GLMDENOISE_RR.npy'
