"""
apply a mask of 3mm onto ROI atlas and functional data
extract functional activation per ROI parcel
average and stack back
"""

# %% ----------------------------------------------------------------------
#                               libraries
# ----------------------------------------------------------------------
from os.path import join
import os, glob, re
import argparse
import numpy as np
import pandas as pd
from nilearn import plotting
from nilearn import regions, maskers, masking, image, surface
from nilearn.datasets import (load_mni152_template)
from itertools import chain
from pathlib import Path
def extract_meta(basename):
    # basename = os.path.basename(fname)
    sub_ind = int(re.search(r'sub-(\d+)', basename).group(1))
    ses_ind = int(re.search(r'ses-(\d+)', basename).group(1))
    run_ind = int(re.search(r'run-(\d+)', basename).group(1))
    runtype = re.search(r'runtype-(.*?)_', basename).group(1)
    return sub_ind, ses_ind, run_ind, runtype

# %% ----------------------------------------------------------------------
#            parameters - atlas, atlas labels, functional image
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--maindir", type=str,
                    help="main directory")
parser.add_argument("--task", type=str,
                    help="pain, vicarious, cognitive")
parser.add_argument("--subcortexdir", type=str,
                    help="where the subcortex parcellation files live")
parser.add_argument("--refimg", type=str,
                    help="single trial .nii.gz (used as reference for masking)")
args = parser.parse_args()

main_dir = args.maindir 
task = args.task 
subcortex_dir = args.subcortexdir 
refimg_fname = args.refimg 

singletrial_dir = join(main_dir, 'analysis', 'fmri', 'nilearn','deriv05_singletrialnpy')
save_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv08_parcel', 'subcortex_Tian2020')
singletrials = sorted(glob.glob(join(singletrial_dir, '**', f'*{task}*event-stimulus*.npy'), recursive=True))

# %% ======= NOTE: resample Atlas into 3mm image
subcortex = join(subcortex_dir,'MNIvolumetric', 'Schaefer2018_200Parcels_7Networks_order_Tian_Subcortex_S1_3T_MNI152NLin2009cAsym_2mm.nii.gz')
subcortex_label = join(subcortex_dir,  'Schaefer2018_200Parcels_7Networks_order_Tian_Subcortex_S1_label.txt')
labels = pd.read_csv(subcortex_label, sep='\t', header=None)
template = load_mni152_template(resolution=3)
subcortex_atlas = image.load_img(subcortex)
subcortex_img = image.resample_to_img(subcortex_atlas, template, interpolation='nearest') #, target_affine=ref_img.affine, target_shape=ref_img.shape)
nifti_masker = maskers.NiftiMasker(mask_img=masking.compute_epi_mask(template))

# %% ======== NOTE: extract ROI labels of interest
nested_list = labels[0::2].values.tolist()
labels_list = list(chain(*nested_list))
roi_list = labels_list[:16]
# %% ======= NOTE: create empty dataframe
df_column = ['filename', 'sub', 'ses', 'run', 'runtype', 'trial', 'cuetype', 'stimintensity'] + roi_list
roidf = pd.DataFrame(index=range(len(singletrials)), columns=df_column)
ref_img = image.load_img(refimg_fname)

# %% ----------------------------------------------------------------------
#                               extract ROI values
# ----------------------------------------------------------------------
# %%
for ind, singletrial in enumerate(sorted(singletrials)):
    # get metadata
    basename = os.path.basename(singletrial)
    sub_ind, ses_ind, run_ind, runtype = extract_meta(basename)
    sub = f"sub-{sub_ind:04d}"
    print(f"========== {sub} ROI extraction ==========")
    # mask image (convert npy into native space, and then, resample to MNI 3mm and mask)
    npy = np.load(singletrial)
    masked_func_array = nifti_masker.fit_transform(image.new_img_like(ref_img, npy))
    masked_func_img = nifti_masker.inverse_transform(masked_func_array)
    # create empty numpy to host average ROI value
    roi_data = np.full(masked_func_img.get_fdata().squeeze().shape, np.nan)
    for atlas_index in np.arange(1, len(roi_list)+1): 
        atlas_label = labels.iloc[atlas_index*2-2,0]
        # a) create mask based on atlas index and b) extract functional activation values from mask
        region_mask = (subcortex_img.get_fdata() == atlas_index)
        func_roi = masked_func_img.get_fdata()[region_mask]
        print(f"values in functional data: {len(subcortex_img.get_fdata()[region_mask])}")
        assert np.sum(region_mask) == len(subcortex_img.get_fdata()[region_mask])
        # insert extracted roi values into pandas
        roidf.at[ind, 'filename'] = basename
        roidf.at[ind, atlas_label] = np.mean(func_roi)
        roi_data[region_mask] = np.mean(func_roi)
    roidf['sub']= roidf['filename'].str.extract(r'(sub-\d+)')
    roidf['ses'] = roidf['filename'].str.extract(r'(ses-\d+)')
    roidf['run'] = roidf['filename'].str.extract(r'(run-\d+)')
    roidf['runtype'] = roidf['filename'].str.extract(r'runtype-(\w+)_')
    roidf['trial'] = roidf['filename'].str.extract(r'(trial-\d+)')
    roidf['cuetype'] = roidf['filename'].str.extract(r'(cuetype-\w+)_')
    roidf['stimintensity'] = roidf['filename'].str.extract(r'(stimintensity-\w+)')
    roidf.to_csv(join(save_dir, f'roi-subcortex_task-{task}.tsv'))
    # save results
    Path(join(save_dir, sub)).mkdir(parents=True, exist_ok=True)
    np.save(join(save_dir, sub, os.path.splitext(basename)[0] + '_roi-subcortex_temp-mni3mm.npy'), roi_data)
    # ======= NOTE: save roi_data as .nii.gz
    # masked_avg = image.new_img_like(subcortex_img, roi_data)
    # masked_atlas = image.new_img_like(subcortex_img, nifti_masker.inverse_transform(roi_data))
    # plotting.plot_stat_map(masked_avg, title=f"{} average value of atlas", threshold=.2)
    # masked_avg.to_filename(join(save_dir, os.path.splitext(basename)[0] + '_roi-subcortex_temp-mni3mm.nii.gz'))
# ======= NOTE:  extract metadata and save dataframe
roidf['sub']= roidf['filename'].str.extract(r'(sub-\d+)')
roidf['ses'] = roidf['filename'].str.extract(r'(ses-\d+)')
roidf['run'] = roidf['filename'].str.extract(r'(run-\d+)')
roidf['runtype'] = roidf['filename'].str.extract(r'runtype-(\w+)_')
roidf['trial'] = roidf['filename'].str.extract(r'(trial-\d+)')
roidf['cuetype'] = roidf['filename'].str.extract(r'(cuetype-\w+)_')
roidf['stimintensity'] = roidf['filename'].str.extract(r'(stimintensity-\w+)')

roidf.to_csv(join(save_dir, f'roi-subcortex_task-{task}.tsv'))
