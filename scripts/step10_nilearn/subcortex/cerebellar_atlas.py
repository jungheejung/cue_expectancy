# %%----------------------------------------------------------------------
#                               libraries
# ----------------------------------------------------------------------
import os, glob, re
from os.path import join
import numpy as np
import pandas as pd
from nilearn import plotting
from nilearn import regions, maskers, masking, image, surface
from nilearn.datasets import (load_mni152_template)
from pathlib import Path
import argparse
# glob through the single trial files
# apply mask on these numpy. 
# # extract values and average them
# save in a pandas
# ideally, columns sub, ses, run, cerebellum index

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
parser.add_argument("--cerebellumdir", type=str,
                    help="where the cerebellum parcellation files live")
parser.add_argument("--refimg", type=str,
                    help="single trial .nii.gz (used as reference for masking)")
args = parser.parse_args()

main_dir = args.maindir 
task = args.task 
cerebellum_dir = args.cerebellumdir 
refimg_fname = args.refimg 

# %%################# local dir for testing
main_dir = '/Volumes/spacetop_projects_cue'
task = 'pain'
cerebellum_dir = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/cerebellar_atlases'
refimg_fname = join(main_dir, 'analysis/fmri/nilearn/singletrial/sub-0061/sub-0061_ses-04_run-06_runtype-pain_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz')
##########################################
# %%

singletrial_dir = join(main_dir, 'analysis', 'fmri', 'nilearn','deriv05_singletrialnpy')
save_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv08_parcel', 'cerebellum_King2019')
singletrials = sorted(glob.glob(join(singletrial_dir, '**', f'*{task}*event-stimulus*.npy'), recursive=True))
print(singletrial_dir)

# high_cue = '/Users/h/Documents/projects_local/sandbox/cue/sub-avg_ses-avg_run-avg_task-pain_event-stimulus_cuetype-high.nii.gz'
# flist = glob.glob(join(npy_dir, f"*event-stimulus*cuetype-high.npy"))

# npystack = []
# for fname in flist: 
#     # TODO: stack numpys
#     nparr = np.load(fname)
#     npystack.append(nparr)

ref_img = image.load_img(refimg_fname)
# %% ======= NOTE: resample Atlas into 3mm image
cerebellum = join(cerebellum_dir,'King_2019', 'atl-MDTB10_space-MNI_dseg.nii')
cerebellum_atlas = image.load_img(cerebellum)
cerebellum_label = join(cerebellum_dir, 'King_2019', 'atl-MDTB10.tsv')
labels = pd.read_csv(cerebellum_label, sep='\t')

template = load_mni152_template(resolution=3)
# subcortex_atlas = image.load_img(subcortex)
cerebellum_img = image.resample_to_img(cerebellum_atlas, template, interpolation='nearest') #, target_affine=ref_img.affine, target_shape=ref_img.shape)
nifti_masker = maskers.NiftiMasker(mask_img=masking.compute_epi_mask(template))
# %% ======= NOTE: create empty dataframe
df_column = ['filename', 'sub', 'ses', 'run', 'runtype', 'trial', 'cuetype', 'stimintensity'] + list(labels.name)
roidf = pd.DataFrame(index=range(len(singletrials)), columns=df_column)
# ref_img = image.load_img(refimg_fname)

# %%
for ind, singletrial in enumerate(sorted(singletrials)):
    # load single trial and get metadata
    basename = os.path.basename(singletrial)
    sub_ind, ses_ind, run_ind, runtype = extract_meta(basename)
    sub = f"sub-{sub_ind:04d}"
    print(f"========== {sub} ROI extraction ==========")
# 
# mask image
    npy = np.load(singletrial)
    masked_func_array = nifti_masker.fit_transform(image.new_img_like(ref_img, npy))
    masked_func_img = nifti_masker.inverse_transform(masked_func_array)
# create empty numpy to host average ROI values
    roi_data = np.full(masked_func_img.get_fdata().squeeze().shape, np.nan)
    for atlas_index in np.arange(len(labels)): 
        atlas_label = labels.loc[atlas_index,'name']
# # a) create mask based on atlas index and b) extract functional activation values from mask
        region_mask = (cerebellum_img.get_fdata() == atlas_index + 1)
        func_roi = masked_func_img.get_fdata()[region_mask]
# insert extracted roi values into pandas
        roidf.at[ind, 'filename'] = basename
        roidf.at[ind, atlas_label] = np.mean(func_roi)
        roi_data[region_mask] = np.mean(func_roi)
    masked_roi = image.new_img_like(template, region_mask)
    plot = plotting.plot_glass_brain(masked_roi, title=f"{atlas_label}")
    plot.savefig(f'/scratch/f0042x1/spacetop/roi{sub}.png')
    roidf['sub']= roidf['filename'].str.extract(r'(sub-\d+)')
    filtered_df = roidf[roidf['sub'] == sub]
# plot to see roi
    masked_roi = image.new_img_like(template, region_mask)
    plot = plotting.plot_glass_brain(masked_roi, title=f"{atlas_label}")
# save results
    Path(join(save_dir, sub)).mkdir(parents=True, exist_ok=True)
    np.save(join(save_dir, sub, os.path.splitext(basename)[0] + '_roi-cerebellum_temp-mni3mm.npy'), roi_data)
    filtered_df.to_csv(join(save_dir, sub, f'roi-cerebellum_task-{task}_{sub}.tsv'))
# %%
