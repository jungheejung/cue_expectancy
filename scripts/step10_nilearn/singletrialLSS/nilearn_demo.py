# %%
import os, re
import matplotlib.pyplot as plt
import nibabel as nib
import numpy as np
import pandas as pd
from nilearn.datasets import fetch_language_localizer_demo_dataset
from nilearn.glm.first_level import first_level_from_bids
from nilearn.glm.first_level import FirstLevelModel
from nilearn import image, plotting
# %%
data_dir, _ = fetch_language_localizer_demo_dataset()
models, models_run_imgs, events_dfs, models_confounds = \
    first_level_from_bids(
        data_dir,
        'languagelocalizer',
        img_filters=[('desc', 'preproc')],
    )

# Grab the first subject's model, functional file, and events DataFrame
standard_glm = models[0]
fmri_file = models_run_imgs[0][0]
events_df = events_dfs[0][0]

# We will use first_level_from_bids's parameters for the other models
glm_parameters = standard_glm.get_params()
# We need to override one parameter (signal_scaling) with the value of
# scaling_axis
glm_parameters['signal_scaling'] = standard_glm.scaling_axis
# %% NOTE: test _____________________________________________________________________
data_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/'
models, models_run_imgs, events_dfs, models_confounds = \
    first_level_from_bids(  
        data_dir, task_label = 'social', 
        img_filters=[('desc', 'preproc'), ('run', '02')], derivatives_folder = 'fmriprep'
    )


# %%
def lss_transformer(df, row_number):
    """Label one trial for one LSS model.

    Parameters
    ----------
    df : pandas.DataFrame
        BIDS-compliant events file information.
    row_number : int
        Row number in the DataFrame.
        This indexes the trial that will be isolated.

    Returns
    -------
    df : pandas.DataFrame
        Update events information, with the select trial's trial type isolated.
    trial_name : str
        Name of the isolated trial's trial type.
    """
    df = df.copy()

    # Determine which number trial it is *within the condition*
    trial_condition = df.loc[row_number, 'trial_type']
    trial_type_series = df['trial_type']
    trial_type_series = trial_type_series.loc[
        trial_type_series == trial_condition
    ]
    trial_type_list = trial_type_series.index.tolist()
    trial_number = trial_type_list.index(row_number)

    # We use a unique delimiter here (``__``) that shouldn't be in the
    # original condition names.
    # Technically, all you need is for the requested trial to have a unique
    # 'trial_type' *within* the dataframe, rather than across models.
    # However, we may want to have meaningful 'trial_type's (e.g., 'Left_001')
    # across models, so that you could track individual trials across models.
    trial_name = f'{trial_condition}__{trial_number:03d}'
    df.loc[row_number, 'trial_type'] = trial_name
    return df, trial_name
# Loop through the trials of interest and transform the DataFrame for LSS
lss_beta_maps = {cond: [] for cond in events_df['trial_type'].unique()}
lss_design_matrices = []

for i_trial in range(events_df.shape[0]):
    lss_events_df, trial_condition = lss_transformer(events_df, i_trial)

    # Compute and collect beta maps
    lss_glm = FirstLevelModel(**glm_parameters)
    lss_glm.fit(fmri_file, lss_events_df)

    # We will save the design matrices across trials to show them later
    lss_design_matrices.append(lss_glm.design_matrices_[0]) 

    beta_map = lss_glm.compute_contrast(
        trial_condition,
        output_type='effect_size',
    )

    # Drop the trial number from the condition name to get the original name
    condition_name = trial_condition.split('__')[0]
    lss_beta_maps[condition_name].append(beta_map)

# We can concatenate the lists of 3D maps into a single 4D beta series for
# each condition, if we want
lss_beta_maps = {
    name: image.concat_imgs(maps) for name, maps in lss_beta_maps.items()
}
# %%
type(lss_design_matrices) # list
len(lss_design_matrices) # 24
lss_design_matrices[0].shape # (229,10)

# %% behavioral data putting data into 
beh_fname = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-01_runtype-pain_events_ttl.tsv'
# extract info from globbed files
sub_num = int(re.findall('\d+', [match for match in os.path.basename(beh_fname).split('_') if "ses" in match][0])[0])
ses_num = int(re.findall('\d+', [match for match in os.path.basename(beh_fname).split('_') if "ses" in match][0])[0])
run_num = int(re.findall('\d+', [match for match in os.path.basename(beh_fname).split('_') if "run" in match][0])[0])
run_type = [match for match in os.path.basename(beh_fname).split('_') if "runtype" in match][0].split('-')[1]

sub = f'sub-{sub_num:04d}'
ses = 'ses-{:02d}'.format(ses_num)
run = 'run-{:02d}'.format(run_num)

# load csv and clean 
beh = pd.read_csv(beh_fname, sep = '\t')

onset01_cue = pd.DataFrame({
    'onset' : list(beh['onset01_cue']),
    'duration' : list(np.repeat(1,len(beh['onset01_cue']))),
    'trial_type' : list(np.repeat('cue',len(beh['onset04_ratingoutcome']))),
    'full_trial_type' : list('event-cue_cue-' + beh.pmod_cuetype.str.split('_').str.get(0))
})

onset02_expectrating = pd.DataFrame({
    'onset' : list(beh['onset02_ratingexpect']),
    'duration' : list(beh['pmod_expectRT']),
    'trial_type' : list(np.repeat('expectrating',len(beh['onset02_ratingexpect']))),
    'full_trial_type' : list('event-expectrating_cue-' + beh.pmod_cuetype.str.split('_').str.get(0))
})

onset03_stim = pd.DataFrame({
    'onset' : list(beh['onset03_stim']),
    'duration' : list(np.repeat(5,len(beh['onset03_stim']))),
    'trial_type' : list(np.repeat('stimulus',len(beh['onset03_stim']))),
    'full_trial_type' : list('event-stim_cue-' + beh.pmod_cuetype.str.split('_').str.get(0) + '_stim-' + beh.pmod_stimtype.str.split('_').str.get(0))
})

onset04_outcomerating = pd.DataFrame({
    'onset' : list(beh['onset04_ratingoutcome']),
    'duration' : list(beh['pmod_outcomeRT']),
    'trial_type' : list(np.repeat('outcomerating',len(beh['onset04_ratingoutcome']))),
    'full_trial_type' : list('event-outcomerating_cue-' + beh.pmod_cuetype.str.split('_').str.get(0) + '_stim-' + beh.pmod_stimtype.str.split('_').str.get(0))
})

# TODO: later change to events_df
# %%
onset_df = pd.concat([onset01_cue, onset02_expectrating, onset03_stim, onset04_outcomerating])
onset_df = onset_df.reset_index(drop=True)
# NOTE: FUTURE REFERENCE. IF YOU NEED TO FIND THE EVENTS BASED ON THE KEYWRODS
regex = re.compile(r'event-(.+?)_')
onset_df.trial_type.str.extract(regex)
onset_df
# %%
lss_events_df, trial_condition = lss_transformer(onset_df, 33)
# %%
glm_parameters = {'drift_model':None,
 'drift_order': 1,
 'fir_delays': [0],
 'high_pass': 0.01,
 'hrf_model': 'spm', #
 'mask_img': None,
#  'memory': Memory(location=None),
#  'memory_level': 1,
 'min_onset': -24,
 'minimize_memory': True,
 'n_jobs': 1,
 'noise_model': 'ols', #'ar1',
 'random_state': None,
 'signal_scaling': 0,
 'slice_time_ref': 0.0,
 'smoothing_fwhm': None,
 'standardize': False, #
 'subject_label': '01', # 
 't_r': 0.46, #
 'target_affine': None, #
 'target_shape': None, #
 'verbose': 0}
# %%
lss_beta_maps = {cond: [] for cond in onset_df['trial_type'].unique()}
fmriprep_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/fmri/demo/'
fmri_file = os.path.join(fmriprep_dir, 'sub-0061_ses-01_task-social_acq-mb8_run-6_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz')
confounds_file = os.path.join(fmriprep_dir, 'sub-0061_ses-01_task-social_acq-mb8_run-6_desc-confounds_timeseries.tsv')
confounds = pd.read_csv(confounds_file, sep = '\t')
subset_confounds = confounds[['csf', 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2',
                                 'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2',
                                 'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', 
                                 'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', 
                                 'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', 
                                 'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2']]

events_df = onset_df

# %%
# TODO: identify the index where trial type is stimulus and cue
for i_trial in [33,34,35,36]:
    lss_events_df, trial_condition = lss_transformer(events_df, i_trial)

    # Compute and collect beta maps
    lss_glm = FirstLevelModel(**glm_parameters)
    lss_glm.fit(fmri_file, events = lss_events_df, confounds = subset_confounds.fillna(0))

    # We will save the design matrices across trials to show them later
    lss_design_matrices.append(lss_glm.design_matrices_[0])

    beta_map = lss_glm.compute_contrast(
        trial_condition,
        output_type='effect_size',
    )

    # Drop the trial number from the condition name to get the original name
    condition_name = trial_condition.split('__')[0]
    trial_num =  trial_condition.split('__')[1]
    description = f"{sub}_{ses}_{run}_runtype-{run_type}_event-{condition_name}_trial-{trial_num}"
    beta_map.header['descrip'] = description
    lss_beta_maps[condition_name].append(beta_map)
    nib.save(beta_map, description + '.nii')
    
    # lss_beta_maps['stimulus'][0].header['descrip']
# We can concatenate the lists of 3D maps into a single 4D beta series for
# each condition, if we want
lss_beta_maps = {
    name: image.concat_imgs(maps) for name, maps in lss_beta_maps.items()
}

for name, maps in lss_beta_maps.items():
    if isinstance(maps):
        print(name, maps)
for name, maps in lss_beta_maps.items():
    if len(maps) !=0:
        print(name, maps)
# %%
fig, axes = plt.subplots(ncols=1, figsize=(20, 10))
plotting.plot_design_matrix(
       lss_design_matrices[28]
     
    )
fig.show()
# %%
from nilearn import plotting
plotting.plot_img(lss_beta_maps['stimulus'][2], colorbar=True, cbar_tick_format="%i")
plt.show()
# TODO:
# load run wise fmridata
# load run-wise behavioral data
# tweak the behavioral data so that it matches BIDS format
# feed it into lss_glm. 
# run this per subject, session, run
# %%
stimulus_concat = image.concat_imgs(lss_beta_maps['stimulus'])

print(lss_beta_maps['stimulus'][0].header)