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
from pathlib import Path 
import itertools

import os, sys, glob, re
from os.path import join, exists, split
import urllib.request
import copy
import warnings
from tqdm import tqdm
from pprint import pprint
warnings.filterwarnings('ignore')
import time
sys.path.append('/Users/h/Dropbox/projects_dropbox/GLMsingle')
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
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
fmriprep_dir = '/Volumes/spacetop/derivatives/fmriprep'
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
main_dir = '/Volumes/spacetop_projects_social/'
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
# TODO: do I need to subtract one frame from TR?
# run_list = [2,5]

# sub = 'sub-0051'
# ses = 'ses-04'
sub = [sys.argv[1]] # 'sub-0051'
ttl_key = sys.argv[2] # 'early', 'late', 'post', 'plateau'
task = 'pain'
ses_list = [1,3,4]
ttl_dir = {
    'early':'d06_singletrial_SPM_01-pain-early',
    'late':'d06_singletrial_SPM_02-pain-late',
    'post':'d06_singletrial_SPM_03-pain-post',
    'plateau':'d06_singletrial_SPM_04-pain-plateau'
}

# TODO: 
# sub-0056_ses-03_task-social_run-03-pain_events.tsv   
# ses = sys.argv[2]
design = []
extra = []
data = []
ses_ind = []

sub_ses = list(itertools.product(sub, ses_list))
for i, (sub, ses_ind) in enumerate(sub_ses):
    ses = 'ses-{:02d}'.format(ses_ind)
    beh_list = glob.glob(join(main_dir, 'data', 'beh02_preproc', sub, ses,  f"{sub}_{ses}_task-social_run-*-pain_beh.csv"))
    Path(join(datadir, sub)).mkdir(parents=True, exist_ok=True)
    Path(join(outputdir, sub)).mkdir(parents=True, exist_ok=True)

# TODO:
# /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/spm/multivariate/s03_concatnifti/sub-0033
# if pain run, check if sub-0056_ses-03_task-social_run-06-pain_events_ttl.tsv exists 
# metadata_sub-0033_task-social_run-vicarious_ev-stim.csv
# If not, run original beh file. 
for beh_fname in beh_list:
    # extract info from globbed files
    beh_basename = os.path.basename(beh_fname)
    ses_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "ses" in match][0])[0])
    run_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "run" in match][0])[0])
    task_name = re.match("(run)-(\d+)-(\w+)", [match for match in beh_basename.split('_') if "run" in match][0])[3]
    ses = 'ses-{:02d}'.format(ses_num)
    run = 'run-{:02d}'.format(run_num)

    # load csv and clean 
    beh = pd.read_csv(beh_fname)
    # TODO, check if plataeu exists
    # ttl = pd.read_csv(join(main_dir, 'data', 'dartmouth', ttl_dir[ttl_key], sub, f"{sub}_singletrial_{ttl_key}.csv"))
    metafiles = glob.glob(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial*.csv"))
    if len(metafiles) > 1:
        meta = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial_plateau.csv"))
    else:
        meta = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial.csv"))
    rating = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_{ses}_{run}_covariate-circularrating.csv"))
    run_df = meta[((meta['ses'] == ses_num)& (meta['run'] == run_num) & (meta['ev'] == 'stim'))]
    run_df.insert(2, 'cond_name', np.nan)
    # %% building <design> from glmsingle _______________________________________________________________
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='low_stim')), 'cond_name'] = int(0)
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='med_stim')), 'cond_name'] = int(1)
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='high_stim')),'cond_name'] = int(2)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='low_stim')), 'cond_name'] = int(3)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='med_stim')), 'cond_name'] = int(4)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='high_stim')),'cond_name'] = int(5)

    design_df = pd.DataFrame(columns = ['order', 'onset', 'condition_type', 'cue', 'stim', 'task'])
    onset = run_df['onset']
    df_dict = {'order':list(range(len(run_df))), 
    'onset':np.array(run_df['onset']), 
    'condition_type':run_df['cond_name'], 
    'task':task_name}
    design_df = pd.DataFrame.from_dict(df_dict)
    # design_df['condition_name'] = design_df['condition_type'].map(cond_name_inv)
    design_df['tr'] = round(design_df['onset'].apply(lambda x: float(x))/0.46).astype(int) # round(design_df['onset']/0.46).astype(int)
    design_df['condition_type'] = design_df['condition_type'].astype(int)
    dim_x = 872;    dim_y = 6
    order_tr = list(design_df[['tr','condition_type']].apply(tuple, axis = 1))
    design_mat = np.zeros((dim_x, dim_y), dtype = int)
    for el_x, el_y in order_tr:
        design_mat[el_x-1, el_y] = 1
    design.append(design_mat)
    
    xtra_y = 1;
    rating_onset = rating['rating']#pd.concat([ev2,ev4],ignore_index = True)
    motion_fname = join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_{ses}_task-social_{run}_confounds-subset.txt")
    motion_df = pd.read_csv(motion_fname, sep = '\t', header = None)
    rating_tr = round(rating_onset/0.46).astype(int)
    # load motion covariates and concat
    rating_df = pd.DataFrame(np.zeros(dim_x), dtype = int)
    for x in rating_tr:
        rating_df.iloc[x-1, 0] = 1
    extra_df = pd.concat([rating_df, motion_df], axis = 1)
    extra.append(np.array(extra_df))

    nii_name = join(fmriprep_dir, sub, ses, 'func', f"{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")
    nilearn_data = image.load_img(nii_name) 
    data.append(nilearn_data.get_fdata())

    ses_ind.append(ses_num)

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


# %% visualize data
# plot example slice from run 1
plt.figure(figsize=(20,6))
plt.subplot(121)
plt.imshow(data[0][:,:,30,300])
plt.title('example slice from run 1',fontsize=16)
plt.subplot(122)
plt.imshow(data[1][:,:,0,0])
plt.title('example slice from run 2',fontsize=16)

# %%
stimdur = 5
tr = 0.46
# print some relevant metadata
print(f'There are {len(data)} runs in total\n')
print(f'N = {data[0].shape[3]} TRs per run\n')
print(f'The dimensions of the data for each run are: {data[0].shape}\n')
print(f'The stimulus duration is {stimdur} seconds\n')
print(f'XYZ dimensionality is: {data[0].shape[:3]} (one slice only in this example)\n')
print(f'Numeric precision of data is: {type(data[0][0,0,0,0])}\n')
# print(f'There are {np.sum(roi)} voxels in the included visual ROI')
# %%
outputdir_glmsingle = join(outputdir, sub, task_name)
Path(join(outputdir_glmsingle)).mkdir(parents=True, exist_ok=True) # (main_dir,'analysis','fmri','glmsingle','output', 'sub-0001', 'task-social')
opt = dict()

opt['wantlibrary'] = 1
opt['wantglmdenoise'] = 1
opt['wantfracridge'] = 1

opt['wantfileoutputs'] = [1,1,1,1]
opt['wantmemoryoutputs'] = [1,1,1,1]
opt['sessionindicator'] = ses_ind
opt['extra_regressors'] = extra

glmsingle_obj = GLM_single(opt)

pprint(glmsingle_obj.params) # visualize all the hyperparameters
# %%

# this example saves output files to the folder  "example1outputs/GLMsingle"
# if these outputs don't already exist, we will perform the time-consuming call to GLMsingle;
# otherwise, we will just load from disk.

start_time = time.time()

# if not exists(outputdir_glmsingle):

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
    
# else:
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
