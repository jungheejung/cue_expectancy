
# %%
from nilearn import image, plotting
from nilearn import datasets
import numpy as np

# %% 
plotting.plot_img('/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/fmri/demo/sub-0061_ses-01_run-06_runtype-pain_event-cue_trial-001.nii.gz')
# %%
dataset = datasets.fetch_atlas_schaefer_2018(data_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/fmri')
atlas_filename = dataset.maps
labels = dataset.labels
dataset.labels = np.insert(dataset.labels, 0, 'Background')
fmri_filenames = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/fmri/demo/sub-0061_ses-01_task-social_acq-mb8_run-6_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
singletrial_fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/fmri/demo/sub-0061_ses-01_run-06_runtype-pain_event-cue_trial-001.nii.gz'
# %%
from nilearn.maskers import NiftiLabelsMasker
masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                           memory='nilearn_cache', verbose=5)


# Here we go from nifti files to the signal time series in a numpy
# array. Note how we give confounds to be regressed out during signal
# extraction
time_series = masker.fit_transform(fmri_filenames)
# %%
time_series.shape

# %% correlation matrix
from nilearn.connectome import ConnectivityMeasure
correlation_measure = ConnectivityMeasure(kind='correlation')
correlation_matrix = correlation_measure.fit_transform([time_series])[0]
# Mask the main diagonal for visualization:
np.fill_diagonal(correlation_matrix, 0)
# The labels we have start with the background (0), hence we skip the
# first label
# matrices are ordered for block-like representation
plotting.plot_matrix(correlation_matrix, figure=(10, 8), labels=dataset.labels[1:],
                     vmax=0.8, vmin=-0.8, title="Confounds",
                     reorder=True)
# %%
