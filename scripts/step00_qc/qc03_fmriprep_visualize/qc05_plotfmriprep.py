# stack mean images
# calculate covariance matrix
# identify when a fmap was applied (boundaries)
# based on dashboard, list which runs to exclude

"""
plot correlation across nifti images
identify boundaries between runs
plot correlation values to check distribution
plot z-scored correlation values to see extreme values
use "bad" metadata json to figure out whether certain runs are driving low correlation values
"""

# %%
import nilearn
import pandas as pd 
import matplotlib.pyplot as plt
import os, glob, sys
from nilearn import image
import numpy as np
import seaborn as sns
import re
import nibabel as nib
import json
import argparse
from pathlib import Path
import psutil
# %% -------------------------------------------------------------------
#                               parameters 
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", 
                    type=int, help="slurm id in numbers")
parser.add_argument("--inputdir", 
                    type=str, help="the top directory of fmriprep preprocessed files")
parser.add_argument("--outputdir", 
                    type=str, help="the directory where you want to save your files")
args = parser.parse_args()
slurm_id = args.slurm_id
npydir = args.inputdir
output_dir = args.outputdir

# fmriprep_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/fmriprep'
# fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
# output_dir  = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
# %%
Path(output_dir).mkdir( parents=True, exist_ok=True )
sub_folders = next(os.walk(npydir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id]#f'sub-{sub_list[slurm_id]:04d}'
# %%
# sub = 'sub-0006'
# npydir = '/Volumes/spacetop_data/derivatives/fmriprep_qc/numpy_bold'
print(f" ________ {sub} ________")
taskname = 'task-social'
# flist = glob.glob(os.path.join(fmriprep_dir, sub, '**', 'func', f"{sub}*{taskname}*MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"), recursive = True)
flist = glob.glob(os.path.join(npydir, sub, f"{sub}*{taskname}*MNI152NLin2009cAsym_desc-preproc_bold.npy"), recursive = True)

# %% get shape of nifti --> later used for plot lines
# TODO: load nifti. reshape and get last shape
nii_shape = []
niistack = []
for f in flist:
    # brain_vol = nib.load(f)
    brain_vol = np.load(f, allow_pickle=True)
    x, y, z, n = brain_vol.shape
    nii_shape.append(n)

    nii_reshape = brain_vol.reshape((x * y * z, n))
    niistack.append(nii_reshape)
run_transition = [sum(nii_shape[:i]) + nii_shape[i] for i in range(len(nii_shape))]
middle_indices = [sum(nii_shape[:i]) + nii_shape[i] // 2 for i in range(len(nii_shape))]
reshaped_arr = np.vstack(niistack)
# %% get run ses information --> later used for plot tick values
labels_list = []
for f in sorted(flist):
    match_ses = re.search(r"ses-(\d+)", f)  # Find the match in the filename
    match_run = re.search(r"run-(\d+)", f)  # Find the match in the filename

    if match_ses:
        labels_list.append(f"ses-{match_ses.group(1)}_run-{match_run.group(1)}")
    else:
        print("Pattern not found in the filename.")

# %% -------------------------------------------------------------------
#                 get images and calculate correlation matrix 
# ----------------------------------------------------------------------
print("get images and calculate correlation matrix ")
niistack = []
#for f in sorted(flist):
#    memory_before = psutil.virtual_memory().used
#    print("Memory Usage Before:", memory_before)
#    nii = image.load_img(f)
#    nii_arr = np.asarray(nii.dataobj)#nii.get_fdata()
#    x,y,z,n = nii_arr.shape
#    print(nii_arr.shape)
#    nii_reshape = nii_arr.reshape((x*y*z, n))
#    niistack.append(nii_reshape)
#    memory_after = psutil.virtual_memory().used
#    print("Memory Usage After:", memory_after)
#    memory_used = memory_after - memory_before
#    print("Memory Used by Loading in Data:", memory_used)
#    print(nii.in_memory)
#    nii.uncache()
#    del nii
#    del nii_arr

# def load_data_generator(flist):
#     for f in sorted(flist):
#         memory_before = psutil.virtual_memory().used
#         print("Memory Usage Before:", memory_before)
#         nii = nib.load(f) #image.load_img(f)
#         nii_arr = np.asarray(nii.dataobj)
#         x, y, z, n = nii_arr.shape
#         print(nii_arr.shape)
#         nii_reshape = nii_arr.reshape((x * y * z, n))
#         memory_after = psutil.virtual_memory().used
#         print("Memory Usage After:", memory_after)
#         memory_used = memory_after - memory_before
#         print("Memory Used by Loading in Data:", memory_used)
#         print(nii.in_memory)
#         nii.uncache()
#         del nii
#         del nii_arr
#         yield nii_reshape

# def process_data_generator(flist, output_dir):
#     for f in sorted(flist):
#         nii = nib.load(f)
#         nii_arr = np.asarray(nii.dataobj)
#         x, y, z, n = nii_arr.shape
#         nii_reshape = nii_arr.reshape((x * y * z, n))
#         output_file = os.path.join(output_dir, os.path.splitext(os.path.basename(f))[0] + '.npy')  # Output file path
#         np.save(output_file, nii_reshape)  # Save processed data to disk
#         yield output_file

# Usage: Iterate over the generator
#niistack = []
#data_generator = load_data_generator(flist)
#for data_batch in data_generator:
#    niistack.append(data_batch)
# niistack = []
# output_dir = f'/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep_qc/correlation_bold/{sub}'
# os.makedirs(output_dir, exist_ok=True)
# data_generator = process_data_generator(flist, output_dir)
# for output_file in data_generator:
#     nii_reshape = np.load(output_file)
#     niistack.append(nii_reshape)
#     # Perform any additional operations with the output file if needed
#     print("Processed data saved to:", output_file)
#full_img = image.concat_imgs(sorted(flist))
reshaped_arr = np.vstack(niistack)

# %% np load
npyflist = glob.glob(f'/Volumes/spacetop_data/derivatives/fmriprep_qc/correlation_bold/{sub}/*-preproc_bold.npy')
niistack = []
for f in npyflist:
    arr = np.load(f)
    print(arr.shape)
    niistack.append(arr)
#arr = full_img.get_fdata()
#x,y,z,n = full_img.get_fdata().shape
#print(f"full array size: {arr.shape}")
#reshaped_arr = arr.reshape((x*y*z, n))
print(f"reshaped array size: {reshaped_arr.shape}")
print("correlation matrix")
memory_before = psutil.virtual_memory().used
print("Memory Usage Before:", memory_before)

corr_matrix = np.corrcoef(reshaped_arr, rowvar=False).astype(np.float32)
memory_after = psutil.virtual_memory().used
print("Memory Usage After:", memory_after)

# Calculate the memory used by the correlation matrix
memory_used = memory_after - memory_before
print("Memory Used by Correlation Matrix:", memory_used)

# %% -------------------------------------------------------------------
#                 load bad data metadata
# ----------------------------------------------------------------------
# bad_dict = #TODO: load json
print("load bad data metadata")
with open("./bad_runs.json", "r") as json_file:
    bad_dict = json.load(json_file)
bad_runs = []
if bad_dict.get(sub, 'empty') != 'empty':
    bad_runs = bad_dict[sub]
# For interactive development: bad_runs = "ses-01_run-6"
# For interactive development: np.save(os.path.join(output_dir, f'{sub}_corr_matrix.npy'), corr_matrix)
# %% -------------------------------------------------------------------
#                 plot
# ----------------------------------------------------------------------
print("plot")
# Plot the correlation matrix as a density heatmap
fig, (ax_heatmap, ax_hist, ax_z) = plt.subplots(1, 3, figsize=(12, 4),gridspec_kw={
    # 'height_ratios': [10, 3],
    'width_ratios': [10, 3,3]
    })
# [x] identify when a run ends vs not and add that as tick_positions. Anomaly: there may be runs that are shorter than 872
# [x] Heatmap tick positions. grab size of nifti and create tick positions accordingly
# plot 1 : heatmap _____________________________________________________
sns.heatmap(corr_matrix, cmap='viridis', annot=False, fmt='.2f', square=True, ax=ax_heatmap)
names = np.array(labels_list)
ax_heatmap.set_yticks(middle_indices) 
ax_heatmap.set_yticklabels(names)

# add a strip of gray ___________________________________________________________
from matplotlib.patches import Rectangle
# Convert indices to grid coordinates
N = len(labels_list)
if bad_runs != []:
    for bad_runs_label in bad_runs:
        badrun_index = labels_list.index(bad_runs_label)
        x = run_transition[badrun_index-1] #* (ax_heatmap.get_xlim()[1] - ax_heatmap.get_xlim()[0]) / corr_matrix.shape[1]
        y = run_transition[badrun_index-1] #* (ax_heatmap.get_ylim()[1] - ax_heatmap.get_ylim()[0]) / corr_matrix.shape[0]
        w = nii_shape[badrun_index]# * (ax_heatmap.get_xlim()[1] - ax_heatmap.get_xlim()[0]) / corr_matrix.shape[1]
        h = nii_shape[badrun_index]# * (ax_heatmap.get_ylim()[1] - ax_heatmap.get_ylim()[0]) / corr_matrix.shape[0]

        for _ in range(2):
            ax_heatmap.add_patch(Rectangle((x, y), w, h, fill=False, edgecolor='crimson', lw=4, clip_on=False))
            x, y = y, x  # exchange the roles of x and y
            w, h = h, w  # exchange the roles of w and h

ax_heatmap.tick_params(length=0)
ax_heatmap.set_title(f'{sub} \ncorrelation across niftis')



# ____________________________________________________________________________________

# Add a horizontal lines for any run chunks of nifti images
# TODO: add lines whenever there was a fieldmap applied
# data_points = nii_shape # TODO: fill it in with number of runs
line_colors = np.repeat('g', len(nii_shape)) #'r', 'r', 'g', 'g']
line_styles = np.repeat('--', len(nii_shape)) #, '--', ':', ':']
for point, color, style in zip(run_transition, line_colors, line_styles):
    ax_heatmap.axhline(y=point, color=color, linestyle=style)
    ax_heatmap.axvline(x=point, color=color, linestyle=style)

# plot 2 : correlation values _____________________________________________________
# NOTE: upper triangle correlation values
# correlation value histogram
# https://python-charts.com/distribution/histogram-seaborn/
upper_triangle = corr_matrix[np.triu_indices(corr_matrix.shape[0])]
df = {'x': upper_triangle}
sns.histplot(data = df, y = 'x', bins=30, color='blue', edgecolor='black', ax = ax_hist, kde=True)
ax_hist.margins(y=0)
ax_hist.set_ylabel('correlation coefficient (r)')
# ax_hist.set_title(f'histogram of correlation values') --> add back in if you want titles
# ax_hist.set_xlabel('Values')

# plot 3 : z scores _____________________________________________________
# NOTE: to align the values with the color map, I'm flipping the histogram here
z_scores = (upper_triangle - np.mean(upper_triangle)) / np.std(upper_triangle)  # Calculate z-scores
dfZ = {'x': z_scores}
sns.histplot(data=dfZ, y='x', kde=True, ax=ax_z)  # Use 'y' instead of 'x' to plot on the y-axis
ax_z.hist(z_scores[z_scores > 3], color='red', alpha=0.3, orientation='horizontal')  # Plot histogram horizontally
ax_z.hist(z_scores[z_scores < -3], color='blue', alpha=0.3, orientation='horizontal')  # Plot histogram horizontally
ax_z.margins(y=0)
# ax_z.set_title(f'z-scored correlation coefficient') --> add back in if you want titles
ax_z.set_ylabel('z-scored correlation coefficient')

# save figure _____________________________________________________
fig.tight_layout(pad=2)
plt.savefig(os.path.join(output_dir, f'{sub}_figure_TEST.png'))

plt.close('all')
