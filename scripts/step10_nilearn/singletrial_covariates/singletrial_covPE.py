# %%
import numpy as np
import os, glob, re
import json
import pathlib
import statsmodels 
import pandas as pd
from statsmodels.stats import multitest
import scipy
import nilearn
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like
import matplotlib.pyplot as plt
from itertools import product
from os.path import join
import numpy.ma as ma
from pathlib import Path
import nibabel as nib

# %% DEP
def extract_ses_and_run(flist):
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r'ses-(\d+)', path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r'run-(\d+)', path)
        if run_match:
            unique_run.add(run_match.group(0))

    # Print the unique values of 'ses' and 'run'
    print(f"Unique ses values: {sorted(unique_ses)}")
    print(f"Unique run values: {sorted(unique_run)}")
    return list(sorted(unique_ses)), list(sorted(unique_run))
# %% -------------------------------------------------------------------
#                               argparse
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
parser.add_argument("-t", "--tasktype",
                    choices=['pain','vicarious','cognitive','all'], help="specify runtype name (e.g. pain, cognitive, variance)")
parser.add_argument("--fmri-event", 
                    choices=['cue','stimulus'], help="which fmri epoch event are you selecting?")
parser.add_argument("--beh-regressor", type=str, 
                    help="specify regressor that you'll correlate")
parser.add_argument("--beh-savename", type=str, 
                    help="specify covariate name for saving files")
parser.add_argument("--savedir", type=str, 
                    help="directory where the correlation maps will live")
args = parser.parse_args()
slurm_id = args.slurm_id 
task = args.tasktype #pain
fmri_event = args.fmri_event
beh_regressor = args.beh_regressor # event02_expect_angle
beh_savename = args.beh_savename #expectrating
save_dir = args.savedir

# %% -------------------------------------------------------------------
#                               parameters 
# ----------------------------------------------------------------------
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# main_dir = '/Volumes/spacetop_projects_cue'
beta_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv05_singletrialnpy')
beh_dir = join(main_dir, 'data', 'beh', 'beh02_preproc')
canlab_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'
# canlab_dir = '/Users/h/Documents/MATLAB/CanlabCore'
sub_list = sorted(next(os.walk(beta_dir))[1])
sub = sub_list[slurm_id]
Path(join(save_dir, beh_savename, task)).mkdir(parents = True, exist_ok = True)
# %% -------------------------------------------------------------------

#                        load bad_dict and reformat 
# ----------------------------------------------------------------------
# This json file keeps track of all the runs and subjects we need to exclude
# we need to reformat becase the dictionary values are aligned with the fmriprep output filenames
# in other words, we need to zeropad some elements so that they are harmonized with the nilearn single trials
print("load bad data metadata")

with open(join(main_dir, 'scripts/step00_qc/qc03_fmriprep_visualize/bad_runs.json'), "r") as json_file:
    bad_dict = json.load(json_file)
padded_dict = {}
for subject, runs in bad_dict.items():
    padded_runs = [f"{run.split('_')[0]}_{run.split('_')[1].split('-')[0] + '-' + run.split('_')[1].split('-')[1].zfill(2)}" for run in runs]
    padded_dict[subject] = padded_runs


# %% -------------------------------------------------------------------
#                        create brain mask
# ----------------------------------------------------------------------
# Here, we create a brain mask based on brainmask_canlab.nii; 
# We also use sample single trial as target shape and target affine
imgfname = join(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial', 'sub-0060', f'sub-0060_ses-01_run-05_runtype-vicarious_event-{fmri_event}_trial-011_cuetype-low_stimintensity-low.nii.gz')
ref_img = image.load_img(imgfname)

mask = image.load_img(join(canlab_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii'))
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)

nifti_masker = nilearn.maskers.NiftiMasker(mask_img= mask_img,
                                           smoothing_fwhm=6,
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)

# %% -------------------------------------------------------------------
#                        main correlation
# ----------------------------------------------------------------------
#for sub in sub_list:
print(f"_____________{sub}_____________")
subwise_stack = []
# 01 glob files filter if needed using bad_json ____________________
nii_flist = sorted(glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*{fmri_event}*.npy")))
filtered_files = [file_path for file_path in nii_flist 
                      if not any(subject in file_path and run in file_path 
                                 for subject, runs in padded_dict.items() 
                                 for run in runs)]
print(filtered_files)
# %%02 extract metadata from filenames _______________________________
keyword_names = ["sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"] # Define the desired keyword names
dfs = [
    pd.DataFrame(
        [dict(zip(keyword_names, re.findall(r'-(.*?)(?:_|$)', os.path.splitext(os.path.basename(nii_fname))[0])))]
        )
    for nii_fname in filtered_files
]
metadf = pd.concat(dfs, ignore_index=True)
for column in ['sub', 'ses', 'run']:
    metadf[column] = metadf[column].apply(lambda x: str(x).lstrip('0') if (isinstance(x, str) and x != '000') else str(x))
for column in ['trial']:
    metadf[column] = metadf[column].apply(lambda x: str(x).lstrip('0') if x != '000' else '0')

# %% 03 load behavioral data ___________________________________________
# beh_flist = sorted(glob.glob(
#     join(main_dir, 'data', 'beh', 'beh02_preproc', sub, '**', f"{sub}_*{task}_beh.csv"), recursive=True))
# dfs = [pd.read_csv(beh_fname) for beh_fname in beh_flist]
# behdf = pd.concat(dfs, axis=0)
# behdf['trial'] = behdf.groupby('param_run_num').cumcount()
# behdf['sub'] = behdf['src_subject_id']
# behdf['ses'] = behdf['session_id']
# behdf['run'] = behdf['param_run_num']

# beh_flist =
if task == 'vicarious':
    keyword = 'vic'
elif task == 'cognitive':
    keyword = 'cog' 
beh_fname = join(main_dir,f'data/RL/modelfit_jepma_0525/table_{keyword}.csv')
behdf = pd.read_csv(beh_fname)
# count trials based on transition
behdf['trial'] = behdf.groupby(['src_subject_id', 'session_id', 'param_run_num']).cumcount()
new_columns = {'src_subject_id': 'sub', 
               'session_id': 'ses', 
               'param_run_num': 'run',
               }
behdf = behdf.rename(columns=new_columns)
# beh_subset = 
# %% 04 grab intersection of metadata and behavioral data ______________
metadf = metadf.reset_index(drop=True)
behdf = behdf.reset_index(drop=True)
keys = ['sub', 'ses', 'run', 'trial']
metadf[keys] = metadf[keys].astype(int)
behdf[keys] = behdf[keys].astype(int)
intersection = pd.merge(behdf, metadf, on=keys, how='inner')
intersection['beh_demean'] = intersection[beh_regressor].sub(intersection[beh_regressor].mean())
flist = []
intersection.to_csv(join(save_dir,beh_savename, task, f"{sub}_task-{task}_beh-{beh_savename}_intersection.csv"))

# %% 05 using intersection, grab nifti/npy _____________________________
for index, row in intersection.iterrows():
    fname = sorted(glob.glob(join(beta_dir, sub, f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}_runtype-{row['runtype']}_event-{row['event']}_trial-{row['trial']:03d}_*.npy")))
    flist.append(fname)
flatlist=[]
for sublist in flist:
    for element in sublist:
        flatlist.append(element)
if flist != []:
    subwise_stack = [np.load(fpath).ravel() for fpath in sorted(flatlist)]
subwise  = np.vstack(subwise_stack)

# %% 06 apply mask _____________________________________________________
x,y,z=ref_img.shape
singlemasked = []
for index in range(subwise.shape[0]):
    singlemasked.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, subwise[index].reshape(x,y,z)))
    )
fmri_masked_single = np.vstack(singlemasked)

# %% 07 calculate correlation with behavioral value ____________________
runwise_correlations = []
for run, run_indices in intersection.groupby(['ses', 'run']).groups.items():
    print(run, run_indices)
    beh_subset = intersection['beh_demean'].iloc[run_indices]
    fmri_subset = fmri_masked_single[run_indices, :]
    # if there's a nan in the beh_regressor, mask it
    b=ma.masked_invalid(beh_subset)
    msk = (~b.mask)
    correlations = np.apply_along_axis(lambda col: np.corrcoef(col, beh_subset[msk].squeeze())[0, 1], axis=0, arr=fmri_subset[msk])
    fisherz_run = np.arctanh(correlations)
    runwise_correlations.append(fisherz_run)
avg_run = np.mean(np.vstack(runwise_correlations), axis = 0)
corr_subjectnifti = nifti_masker.inverse_transform(avg_run)
print(corr_subjectnifti.shape)
print(corr_subjectnifti)

# %% Save the resampled image using the reference affine
resampled_image = image.resample_to_img(corr_subjectnifti, ref_img)
plot = plotting.plot_stat_map(resampled_image,  display_mode = 'mosaic', title = f'task-{task} corr w/ {fmri_event} and {beh_savename}', cut_coords = 8)
plot.savefig(join(save_dir ,beh_savename, task, f'{sub}_task-{task}_corr_x-{fmri_event}_y-{beh_savename}.png'))
resampled_image.to_filename(join(save_dir, beh_savename, task, f'{sub}_task-{task}_corr_x-{fmri_event}_y-{beh_savename}.nii.gz'))


# %%
