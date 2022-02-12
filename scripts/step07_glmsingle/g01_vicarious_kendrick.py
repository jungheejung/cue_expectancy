#!/usr/bin/env python3

"""glm single example tutorial
"""
# %%
from doctest import DocFileCase
import numpy as np
import pandas as pd
import scipy
import scipy.stats as stats
import scipy.io as sio
import matplotlib.pyplot as plt
import nibabel as nib
import nilearn
from nilearn import image
from pathlib import Path 

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
glmsingle_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/GLMsingle'

current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# create directory for saving data
datadir = join(main_dir,'analysis','fmri','glmsingle','data')
os.makedirs(datadir,exist_ok=True)
# create directory for saving outputs from example 1
outputdir = join(main_dir,'analysis','fmri','glmsingle','output')
print(f'directory to save example dataset:\n\t{datadir}\n')
print(f'directory to save example1 outputs:\n\t{outputdir}\n')

# %% data _______________________________________________________________
# TODO: flexibly identify runs that match the "task" keyword
# <design>: [ run run run] 1 x run
# each run: time x condition (e.g. TR * 6 conditions)
# <data> brain
# <extra_regressors> should be identical as <design> time x condition
# Feb 11 model: extra regressor: dump all of rating regressors
# TODO: do I need to subtract one frame from TR?
run_list = [2,5]
design = []
sub = 'sub-0051'
ses = 'ses-04'
extra = []
task = 'pain'
ses_num = 4
run_num = 2
for r in run_list:
    DocFileCase = pd.read_csv(f"/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/examples/data/{sub}_{ses}_task-social_run-{r:02d}-vicarious_beh.csv")
    # ttl = pd.read_csv("/Volumes/spacetop_projects_social/data/dartmouth/d06_singletrial_SPM_01-pain-early/sub-0033/sub-0033_singletrial_early.csv")
    # run_df = ttl[((ttl['ses'] == ses_num)& (ttl['run'] == run_num)) & (ttl['ev'] == '')]
    # run_df.insert(2, 'cond_name', np.nan)
    # %% building <design> from glmsingle _______________________________________________________________
    # dictionary for condition mapping 
    cond_name = {'low-cue_low-stim':0,
    'low-cue_med-stim':1,
    'low-cue_high-stim':2,
    'high-cue_low-stim':3,
    'high-cue_med-stim':4,
    'high-cue_high-stim':5}
    # run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='low_stim')), 'cond_name'] = int(0)
    # run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='med_stim')), 'cond_name'] = int(1)
    # run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='high_stim')),'cond_name'] = int(2)
    # run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='low_stim')), 'cond_name'] = int(3)
    # run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='med_stim')), 'cond_name'] = int(4)
    # run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='high_stim')),'cond_name'] = int(5)



    cond_name_inv = dict(map(reversed, cond_name.items()))
    condition_type = pd.concat([df['param_cond_type']-1], ignore_index = True)
    # stim_dir = pd.Series([1,4,5,4]).repeat(12)
    ev1 = df['event01_cue_onset'] - df['param_trigger_onset'][0]
    ev2 = df['event02_expect_displayonset'] - df['param_trigger_onset'][0]
    ev3 = df['event03_stimulus_displayonset'] - df['param_trigger_onset'][0]
    ev4 = df['event04_actual_displayonset'] - df['param_trigger_onset'][0]
    design_df = pd.DataFrame(columns = ['order', 'onset', 'condition_type', 'cue', 'stim', 'task'])
    onset = ev3
    df_dict = {'order':list(range(len(ev3))), 
    'onset':np.array(ev3), 
    'condition_type':pd.concat([df['param_cond_type']-1], ignore_index = True), 
    'task':'vicarious'}
    design_df = pd.DataFrame.from_dict(df_dict)
    design_df['condition_name'] = design_df['condition_type'].map(cond_name_inv)
    design_df['tr'] = round(design_df['onset']/0.46).astype(int)

    dim_x = 872;    dim_y = 6
    order_tr = list(design_df[[ 'tr', 'condition_type']].apply(tuple, axis = 1))
    design_mat = np.zeros((dim_x, dim_y), dtype = int)
    for el_x, el_y in order_tr:
        design_mat[el_x-1, el_y] = 1
    design.append(design_mat)
    
    xtra_y = 1;
    rating_onset = pd.concat([ev2,ev4],ignore_index = True)
    motion_fname = '/Users/h/Dropbox/projects_dropbox/GLMsingle/examples/example1outputs/sub-0053_ses-01_task-social_run-03_confounds-subset.txt'
    motion_df = pd.read_csv(motion_fname, sep = '\t', header = None)
    rating_tr = round(rating_onset/0.46).astype(int)
    # load motion covariates and concat
    rating_df = pd.DataFrame(np.zeros(dim_x), dtype = int)
    for x in rating_tr:
        rating_df.iloc[x-1, 0] = 1
    extra_df = pd.concat([rating_df, motion_df], axis = 1)
    extra.append(np.array(extra_df))


# %% visualize design
def forceAspect(ax,aspect=1):
    im = ax.get_images()
    extent =  im[0].get_extent()
    ax.set_aspect(abs((extent[1]-extent[0])/(extent[3]-extent[2]))/aspect)

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
# forceAspect(plt,aspect=1)
# plt.gca().set_aspect('equal')
# %%
# fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))
# fig.tight_layout(pad=3)
# ax1.imshow(design[0])
# ax2.imshow(design[1])
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
opt['wantglmdenoise'] = 0
opt['wantfracridge'] = 1

# for the purpose of this example we will keep the relevant outputs in memory
# and also save them to the disk
opt['wantfileoutputs'] = [1,1,1,1]
opt['wantmemoryoutputs'] = [1,1,1,1]
opt['sessionindicator'] = [1,1]
opt['extra_regressor'] = extra

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
