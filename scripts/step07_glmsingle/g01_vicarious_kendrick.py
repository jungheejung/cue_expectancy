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
import itertools
from os.path import join, exists, split
import os, sys, time, glob, re
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
glmsingle_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/GLMsingle'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'

current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# create directory for saving data
datadir = join(main_dir,'analysis','fmri','glmsingle','data')
outputdir = join(main_dir,'analysis','fmri','glmsingle','output')
Path(datadir).mkdir(parents=True, exist_ok=True)
Path(outputdir).mkdir(parents=True, exist_ok=True)
print(f'directory to save example dataset:\n\t{datadir}\n')
print(f'directory to save example1 outputs:\n\t{outputdir}\n')

# %% data _______________________________________________________________
# TODO: flexibly identify runs that match the "task" keyword
# <design>: [ run run run] 1 x run
# each run: time x condition (e.g. TR * 6 conditions)
# <data> brain
# <extra_regressors> should be identical as <design> time x condition
# Feb 11 model: extra regressor: dump all of rating regressors
# TODO: do I need to subtract one frame fr
# sub = 'sub-0051'
# ses = 'ses-04'

sub = sys.argv[1] # 'sub-0051'
task = sys.argv[2] # 'vicarious', 'cognitive
ses_list = [1,3,4]

design = []
extra = []
data = []

sub_ses = list(itertools.product(sub, ses_list))
for i, (sub, ses_ind) in enumerate(sub_ses):
    ses = 'ses-{:02d}'.format(ses_ind)
    beh_list = glob.glob(join(main_dir, 'data', 'dartmouth', 'd02_preprocessed', sub, ses,  f"{sub}_{ses}_task-social_run-*-{task}_beh.csv"))
    Path(join(datadir, sub)).mkdir(parents=True, exist_ok=True)
    Path(join(outputdir, sub)).mkdir(parents=True, exist_ok=True)

for beh_fname in beh_list:
    beh = pd.read_csv(beh_fname)
    ses_num = int(re.findall('\d+', [match for match in beh_fname.split('_') if "ses" in match][0])[0])
    run_num = int(re.findall('\d+', [match for match in beh_fname.split('_') if "run" in match][0])[0])
    ses = 'ses-{:02d}'.format(ses_num)
    run = 'run-{:02d}'.format(run_num)

    # %% building <design> from glmsingle _______________________________________________________________
    cond_name = {'low-cue_low-stim':0,
    'low-cue_med-stim':1,
    'low-cue_high-stim':2,
    'high-cue_low-stim':3,
    'high-cue_med-stim':4,
    'high-cue_high-stim':5}
    cond_name_inv = dict(map(reversed, cond_name.items()))
    condition_type = pd.concat([beh['param_cond_type']-1], ignore_index = True)
    
    ev1 = beh['event01_cue_onset'] - beh['param_trigger_onset'][0]
    ev2 = beh['event02_expect_displayonset'] - beh['param_trigger_onset'][0]
    ev3 = beh['event03_stimulus_displayonset'] - beh['param_trigger_onset'][0]
    ev4 = beh['event04_actual_displayonset'] - beh['param_trigger_onset'][0]
    design_df = pd.DataFrame(columns = ['order', 'onset', 'condition_type', 'cue', 'stim', 'task'])
    onset = ev3
    df_dict = {'order':list(range(len(ev3))), 
    'onset':np.array(ev3), 
    'condition_type':pd.concat([beh['param_cond_type']-1], ignore_index = True), 
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
    
    # <extra regressors> __________________________________________________________________
    xtra_y = 1;
    rating_onset = pd.concat([ev2,ev4],ignore_index = True)
    motion_fname = join(main_dir, 'data', 'dartmouth', 'd05_motion', sub, ses, f"{sub}_{ses}_task-social_run-{run}_confounds-subset.txt")
    # motion_fname = '/Users/h/Dropbox/projects_dropbox/GLMsingle/examples/example1outputs/sub-0053_ses-01_task-social_run-03_confounds-subset.txt'
    motion_df = pd.read_csv(motion_fname, sep = '\t', header = None)
    rating_tr = round(rating_onset/0.46).astype(int)
    # load motion covariates and concat
    rating_df = pd.DataFrame(np.zeros(dim_x), dtype = int)
    for x in rating_tr:
        rating_df.iloc[x-1, 0] = 1
    extra_df = pd.concat([rating_df, motion_df], axis = 1)
    extra.append(np.array(extra_df))

    # <brain data> __________________________________________________________________
    nii_name = join(fmriprep_dir, sub, ses, 'func', f"{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")
    nilearn_data = image.load_img(nii_name) 
    data.append(nilearn_data.get_fdata())

    ses_ind.append(ses_num)

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
tr = 0.46
# print some relevant metadata ___________________________________________
print(f'There are {len(data)} runs in total\n')
print(f'N = {data[0].shape[3]} TRs per run\n')
print(f'The dimensions of the data for each run are: {data[0].shape}\n')
print(f'The stimulus duration is {stimdur} seconds\n')
print(f'XYZ dimensionality is: {data[0].shape[:3]} (one slice only in this example)\n')
print(f'Numeric precision of data is: {type(data[0][0,0,0,0])}\n')
# print(f'There are {np.sum(roi)} voxels in the included visual ROI')
# %% GLM single
outputdir_glmsingle = join(outputdir,sub, task)
Path(join(outputdir_glmsingle)).mkdir(parents=True, exist_ok=True) # (main_dir,'analysis','fmri','glmsingle','output', 'sub-0001', 'task-social')
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
