from nilearn import image
from nilearn.maskers import NiftiLabelsMasker
from nilearn import datasets
import numpy as np
import os, glob
import pandas as pd
# load all of the single trials based on keyword
# concatenate list of images
img_filters = [('sub', 61),
('run', '*'),
('ses', '*'),
('event', 'stimulus')]
for img_filter in img_filters:
    print(img_filter)

sub = f'sub-{sub_num:04d}'
nilearn_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn'
singletrial_dir = os.path.join(nilearn_dir, 'singletrial')
save_extract_dir = os.path.join(nilearn_dir, 'parcel_schaefer_2018')
img_flist = glob.glob(os.path.join(singletrial_dir, sub, f'{sub}_{ses}*event-{event}_trial-*.nii.gz'))


stacked_singletrial = image.concat_imgs(img_flist)

# run them through nifti masker
dataset = datasets.fetch_atlas_schaefer_2018()
atlas_filename = dataset.maps
# labels = dataset.labels
labels = np.insert(dataset.labels, 0, 'Background')
masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                           memory='nilearn_cache', verbose=5)
time_series = masker.fit_transform(stacked_singletrial)
labels_utfstring = [x.decode('utf-8')  for x in dataset.labels ][1:]
singletrial_vstack_beta = pd.DataFrame(time_series, columns = labels_utfstring)
fname = f'{sub}_{sub}*event-{event}_trial-*.nii.gz'
singletrial_vstack_beta.to_csv(fname)