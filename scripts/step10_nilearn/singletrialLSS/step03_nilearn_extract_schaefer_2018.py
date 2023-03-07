# %%
import argparse
import numpy as np
import os, glob
import pandas as pd
from nilearn import image
from nilearn.maskers import NiftiLabelsMasker
from nilearn import datasets
# load all of the single trials based on keyword
# concatenate list of images
img_filters = [('sub', 61),
('run', '*'),
('ses', '*'),
('event', 'stimulus')]
for img_filter in img_filters:
    print(img_filter)

parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
                    help="specify slurm array id")
parser.add_argument("--session-num", type=int,
                    help="specify session number")
parser.add_argument("--run-num", type=int,
                    help="specify run number")
parser.add_argument("--event-type", choices=['cue', 'expectrating', 'stimulus', 'outcomerating'],
                    help="specify hemisphere")
args = parser.parse_args()

# 0. parameters
print(args.slurm_id)
slurm_id = [args.slurm_id] # e.g. 1, 2
ses_num = args.session_num # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
run_num = args.run_num # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
# run_type = args.runtype
runtype = 'runtype-pain'
event = 'stimulus'
nilearn_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn'
nilearn_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn'
onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM'
singletrial_dir = os.path.join(nilearn_dir, 'singletrial')
save_extract_dir = os.path.join(nilearn_dir, 'parcel_schaefer_2018')
sub_folders = next(os.walk(onset_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
# TODO; TEST for now, feed in subject id directly
# sub = sub_list[slurm_id]
sub = f'sub-{sub_list[slurm_id]:04d}'
ses = 'ses-{:02d}'.format(ses_num)
run = 'run-{:02d}'.format(run_num)
print(f" ________ {sub} {ses} {run} ________")
# %%
# sub = 'sub-0111'
# ses = 'ses-01'
# run = 'run-05'

img_flist = glob.glob(os.path.join(singletrial_dir, sub, f'{sub}_{ses}_{run}_{runtype}_event-{event}_trial-*.nii.gz'))
img_flist = sorted(img_flist)
key = 'run'
bids_info = [[match for match in os.path.basename(beh_fname).split('_') if key in match][0] for beh_fname in img_flist]
# %%
stacked_singletrial = image.concat_imgs(sorted(img_flist))

# %%
# run them through nifti masker
dataset = datasets.fetch_atlas_schaefer_2018()
atlas_filename = dataset.maps
# labels = dataset.labels
labels = np.insert(dataset.labels, 0, 'Background')
masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                           memory='nilearn_cache', verbose=5)
time_series = masker.fit_transform(stacked_singletrial) # (trials, parcels)
# %% stack metadata
labels_utfstring = [x.decode('utf-8')  for x in labels[1:] ]
singletrial_vstack_beta = pd.DataFrame(time_series, columns = labels_utfstring)
flist_basename = [os.path.basename(m) for m in sorted(img_flist)]
singletrial_vstack_beta.insert(0, 'singletrial_fname', flist_basename)

save_fname = os.path.join(save_extract_dir, sub, f'{sub}_{sub}_{run}_{runtype}_event-{event}_metadata.tsv')
singletrial_vstack_beta.to_csv(save_fname)

