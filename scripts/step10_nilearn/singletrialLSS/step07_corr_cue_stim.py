#!/usr/bin/env python
"""
calculate the correlation betweeen cue nifti and stimulus nifti
from parameter
find if pair exists
if so, calculate correlation
add it to pandas row
"""

import os, glob, re
from nilearn import image
from nilearn import plotting
import numpy as np
import pandas as pd
import argparse
from pathlib import Path

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

def extract_bids_num(filename: str, key: str) -> int:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.
    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    bids_num =  int(re.findall(r'\d+', bids_info_rmext[0] )[0].lstrip('0'))
    return bids_num

def extract_bids(filename: str, key: str) -> str:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.
    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    print(bids_info_rmext)
    # 'filename.ext1.ext2'.split(os.extsep, 1)
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    return bids_info_rmext[0]

# %% load same trial, cuee and stimulus
# calculate dot product
# glob stimulus niftis, from that, extract inforrmation and grab corresponding cue nifti
parser = argparse.ArgumentParser()
parser.add_argument("--runtype", type=str,
                    help="type of task: pain, cognitive, vicarious")
args = parser.parse_args()
runtype = args.runtype

output = pd.DataFrame()
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
nilearn_dir = os.path.join(main_dir, 'analysis', 'fmri', 'nilearn')
singletrial_dir = os.path.join(nilearn_dir, 'singletrial')
sub_list = next(os.walk(singletrial_dir))[1]

# %%
for sub in sorted(sub_list):
    stim_flist = glob.glob(os.path.join(singletrial_dir, sub,
                    f'{sub}_*runtype-{runtype}_event-stimulus_trial-*.nii.gz'))
    for stim_fpath in sorted(stim_flist):
        #stim_fpath = stim_flist[0]
        stim_fname = os.path.basename(stim_fpath)
        sub_num = extract_bids_num(stim_fname, 'sub')
        ses_num = extract_bids_num(stim_fname, 'ses')
        run_num = extract_bids_num(stim_fname, 'run')
        trial_num = extract_bids_num(stim_fname, 'trial')

        cue = glob.glob(os.path.join(singletrial_dir, sub,
                        f'sub-{sub_num:04d}_ses-{ses_num:02d}_run-{run_num:02d}_runtype-{runtype}_event-cue_trial-{trial_num:03d}*.nii.gz'))[0]
                    
        cue_img = image.load_img(cue)
        stim_img = image.load_img(stim_fpath)
        display = plotting.plot_stat_map(cue_img,display_mode='mosaic',
                            cut_coords=(5, 4, 10),
                            title="display_mode='z', cut_coords=5")
        dotprod = np.dot(cue_img.get_data().ravel().T, stim_img.get_data().ravel())
        corr = np.corrcoef(cue_img.get_data().ravel().T, stim_img.get_data().ravel())[0][1]

        # save data to pandas dataframe
        dictionary = {'sub': sub_num,
                    'ses': ses_num,
                    'run': run_num,
                    'runtype': runtype,
                    #'event': event,
                    'trial':trial_num,
                    'dotprod': dotprod,
                    'corr': corr
                    }
        output = output.append(dictionary, ignore_index=True)
    save_fname = os.path.join(nilearn_dir, 'deriv04_corrcuestim', f"sub-{sub_num:04d}_runtype-{runtype}_desc-singletrialcorrelation_x-cue_y-stim.csv")
    output.to_csv(save_fname, sep = '/t')
# %%
# sub-0061_ses-01_run-06_runtype-pain_event-stimulus_trial-000_cuetype-high_stimintensity-low.nii.gz
# print(sorted(img_flist)[0:10])
# img_flist = sorted(img_flist)

# # 3. resample space
# signature_img = image.load_img(signature_fname)
# resampled_nps = image.resample_img(signature_img,
#                                 target_affine=stacked_singletrial.affine,
#                                 target_shape=stacked_singletrial.shape[0:3],
#                                 interpolation='nearest')

# #  4. apply signature
# nps_array = image.get_data(resampled_nps)
# singletrial_array = image.get_data(stacked_singletrial)
# len_singletrialstack = singletrial_array.shape[-1]
# vectorize_singletrial = singletrial_array.reshape(
#     np.prod(list(singletrial_array.shape[0:3])), len_singletrialstack)
# nps_extract = np.dot(nps_array.reshape(-1), vectorize_singletrial)
# nps_df = pd.DataFrame({'singletrial_fname': [os.path.basename(
#     basename) for basename in img_flist], signature_key: nps_extract})