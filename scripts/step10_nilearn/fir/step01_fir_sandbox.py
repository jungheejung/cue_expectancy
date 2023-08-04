# %% [markdown]
# # Outline
# * load image
# * concat
# * load event tsv
# * concat
# * first level with fir
# 
# TODO: add csf and white matter
# TODO: plot timeseries
# TODO: grab pain, vicarious, cognitive respectively 
# 
# https://nilearn.github.io/dev/auto_examples/04_glm_first_level/plot_predictions_residuals.html

# %%
from os.path import join
import os, glob, re, pathlib
import argparse
import pandas as pd
import numpy as np
from nilearn.glm.first_level import FirstLevelModel
from nilearn.plotting import plot_contrast_matrix, plot_design_matrix

import matplotlib.pyplot as plt
from nilearn.plotting import plot_event
from nilearn import glm, image, plotting, maskers, masking
from nilearn.datasets import load_mni152_template
import matplotlib.pyplot as plt

from nilearn.plotting import plot_stat_map


# %%
# ----------------------------------------------------------------------
#                           paramters
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
parser.add_argument("--taskname", type=str,
                    help="specify slurm array id")
parser.add_argument("--firdelay", type=int,
                    help="how many TRs of delay")
args = parser.parse_args()
slurm_id = args.slurm_id # e.g. 1, 2
taskname = args.taskname 
num_delays = int(args.firdelay)
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids'
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
sub_folders = next(os.walk(fmriprep_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id] #f'sub-{sub_list[slurm_id]:04d}'
save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/glm/fir'
pathlib.Path(join(save_dir, sub)).mkdir(parents=True, exist_ok=True)

# local prototype __________________________________________
# fmriprep_dir = '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/'
# sub = 'sub-0002'
# onset_dir = f'/Users/h/Documents/projects_local/sandbox/fmriprep_bold/{sub}/beh'
# %%
metadata = join(main_dir, 'data', 'spacetop_task-social_run-metadata.csv')
metadf = pd.read_csv(metadata)
subject_subset =  metadf[metadf['sub'] == sub]


stimhighdfs = []
stimlowdfs = []
cuehighdfs = []
cuelowdfs = []

for ses_ind in np.arange(len(subject_subset)):
    ses = subject_subset.iloc[ses_ind, subject_subset.columns.get_loc("ses")]
    #ses = 'ses-01' ########DELETED LATER
    subset_df = metadf[(metadf['sub'] == sub) & (metadf['ses'] == ses)]
    task_columns = subset_df.columns[subset_df.eq('pain').any()]
    run_list = [int(col.split('-')[-1]) for col in task_columns]
    print(f"{sub} {ses} {run_list}")
    # ----------------------------------------------------------------------
    #                           load fmri data
    # ----------------------------------------------------------------------

    fmriprep_flist = []
    for run_num in run_list:
        flist = sorted(glob.glob(join(fmriprep_dir, sub, ses, 'func', f'{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'), recursive=True))
        fmriprep_flist.append(flist[0])
    fmri_img = [image.load_img(fname) for fname in fmriprep_flist]

    
    tr = 0.46  
    n_scans = 872  
    frame_times = np.arange(n_scans) * tr  # here are the corresponding frame times

    design_matrices = []
    event_concat = []
    confounds_concat = []
    # ----------------------------------------------------------------------
    #                     load behavioral and confound data
    # ----------------------------------------------------------------------

    for run_num in run_list:
        # load file and reconstruct column "condition_type"
        fname = join(onset_dir, sub, ses, f'{sub}_{ses}_task-cue_acq-mb8_run-{int(run_num):02d}_events.tsv')
        event_df = pd.read_csv(fname)
        event_df['condition_type'] = event_df['cuetype'].astype(str) +'_' + event_df['stimtype'].astype(str)
        # create events dictionary for nilearn
        events = pd.DataFrame(
            {
                "trial_type": event_df[event_df['trial_type']=='stimulus'].condition_type, #trial_types,
                "onset": event_df[event_df['trial_type']=='stimulus'].onset, #onsets,
                "duration": event_df[event_df['trial_type']=='stimulus'].duration #durations,
            }
        )
        confounds_fname = join(fmriprep_dir, sub, ses, 'func', f'{sub}_{ses}_task-social_acq-mb8_run-{int(run_num)}_desc-confounds_timeseries.tsv')
        confounds = pd.read_csv(confounds_fname, sep = '\t')
        filter_col = [col for col in confounds if col.startswith('motion')]
        default_csf_24dof = ['csf', 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2',
                                    'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2',
                                    'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', 
                                    'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', 
                                    'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', 
                                    'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2']
        filter_col.extend(default_csf_24dof)
        dummy = pd.DataFrame(np.eye(len(confounds))).loc[:,0:5]
        dummy.rename(columns = {0:'dummy_00',
                            1:'dummy_01',
                            2:'dummy_02',3:'dummy_03',4:'dummy_04',5:'dummy_05'}, inplace=True)
        subset_confounds = pd.concat([confounds[filter_col], dummy], axis = 1)
        subset_confounds = subset_confounds.fillna(subset_confounds.mean())
        print("grabbed all the confounds and fmri data")
        # subset_confounds.head()
        event_concat.append(events)
        confounds_concat.append(subset_confounds)

    # ----------------------------------------------------------------------
    #                          first level models
    # ----------------------------------------------------------------------

    first_level_model = FirstLevelModel(t_r=0.46, 
                                        hrf_model="fir", 
                                        fir_delays=np.arange(20),
                                        # drift_model="polynomial",
                                        # drift_order=3,
                                        noise_model='ols',
                                        smoothing_fwhm=6,
                                        minimize_memory=False)
    first_level_model = first_level_model.fit(fmri_img, 
                                            events=event_concat,
                                            confounds=confounds_concat
                                            )
    design_matrix = first_level_model.design_matrices_[0]
    plotting.plot_design_matrix(design_matrix)
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_design_matrix.png'))
    plt.close()
    # ----------------------------------------------------------------------
    #                  compute contrasts for each regressor
    # ----------------------------------------------------------------------

    sessionwise_contrast = []



    # Initialize empty lists for different conditions and delays
    cue_high_delay = [[] for _ in range(num_delays)]
    cue_low_delay = [[] for _ in range(num_delays)]
    stim_high_delay = [[] for _ in range(num_delays)]
    stim_low_delay = [[] for _ in range(num_delays)]

    contrasts_cue_high = []
    contrasts_cue_low = []
    contrasts_stim_high = []
    contrasts_stim_low = []
    contrasts_cue_hightGTlow = []
    contrasts_stim_highGTlow = []

    for i in np.arange(len(first_level_model.design_matrices_)):
        design_matrix = first_level_model.design_matrices_[i]
        contrast_matrix = np.eye(design_matrix.shape[1])
        contrasts = {
            column: contrast_matrix[i]
            for i, column in enumerate(design_matrix.columns)
        }
        print(f"number of columns: {len(design_matrix.columns)}")
        conditions = events.trial_type.unique()

        for condition in conditions:
            contrasts[condition] = np.sum(
                [
                    contrasts[name]
                    for name in design_matrix.columns
                    if name.startswith(condition)
                ],
                0,
            )

        # Generate contrast names and append to the respective lists
        for delay in range(num_delays):
            delay_names = [f"high_cue_high_stim_delay_{delay}",
                        f"high_cue_med_stim_delay_{delay}",
                        f"high_cue_low_stim_delay_{delay}"]
            contrasts[f"cue_high_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"low_cue_high_stim_delay_{delay}",
                        f"low_cue_med_stim_delay_{delay}",
                        f"low_cue_low_stim_delay_{delay}"]
            contrasts[f"cue_low_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"high_cue_high_stim_delay_{delay}", f"low_cue_high_stim_delay_{delay}"]
            contrasts[f"stim_high_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"high_cue_low_stim_delay_{delay}", f"low_cue_low_stim_delay_{delay}"]
            contrasts[f"stim_low_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            cue_high_delay[delay].append(contrasts[f"cue_high_delay_{delay}"])
            cue_low_delay[delay].append(contrasts[f"cue_low_delay_{delay}"])
            stim_high_delay[delay].append(contrasts[f"stim_high_delay_{delay}"])
            stim_low_delay[delay].append(contrasts[f"stim_low_delay_{delay}"])

        contrasts_cue_high.append(contrasts["high_cue_high_stim"])
        contrasts_cue_low.append(contrasts["low_cue_high_stim"])
        contrasts_stim_high.append(contrasts["high_cue_low_stim"])
        contrasts_stim_low.append(contrasts["low_cue_low_stim"])
        contrasts_cue_hightGTlow.append(contrasts["high_cue_high_stim"] - contrasts["low_cue_high_stim"])
        contrasts_stim_highGTlow.append(contrasts["high_cue_low_stim"] - contrasts["low_cue_low_stim"])

    # Update the contrasts dictionary with the generated lists
    for delay in range(num_delays):
        contrasts[f"cue_high_delay_{delay}"] = cue_high_delay[delay]
        contrasts[f"cue_low_delay_{delay}"] = cue_low_delay[delay]
        contrasts[f"stim_high_delay_{delay}"] = stim_high_delay[delay]
        contrasts[f"stim_low_delay_{delay}"] = stim_low_delay[delay]

    contrasts["cue_high"] = contrasts_cue_high
    contrasts["cue_low"] = contrasts_cue_low
    contrasts["stim_high"] = contrasts_stim_high
    contrasts["stim_low"] = contrasts_stim_low
    contrasts["cue_highGTlow"] = contrasts_cue_hightGTlow
    contrasts["stim_highGTlow"] = contrasts_stim_highGTlow



    
    for i in np.arange(len(first_level_model.design_matrices_)):
        plot_contrast_matrix(contrasts["cue_highGTlow"][i], first_level_model.design_matrices_[i])

    for i in np.arange(len(first_level_model.design_matrices_)):
        plot_contrast_matrix(contrasts["cue_high"][i], first_level_model.design_matrices_[i])

    for i in np.arange(len(first_level_model.design_matrices_)):
        plot_contrast_matrix(contrasts["stim_high_delay_5"][i], first_level_model.design_matrices_[i])

    #   subset contrasts

    keys_to_subset = ['cue_high', 'cue_low', 'stim_high', 'stim_low', 'cue_highGTlow', 'stim_highGTlow']
    subset_dict = dict((key, contrasts[key]) for key in keys_to_subset)

    fig = plt.figure(figsize=(11, 3))
    for index, (contrast_id, contrast_val) in enumerate(subset_dict.items()):
        ax = plt.subplot(1, len(subset_dict), 1 + index)
        z_map = first_level_model.compute_contrast(
            contrast_val, output_type="z_score"
        )
        plotting.plot_stat_map(
            z_map,
            display_mode="z",
            threshold=3.0,
            title=contrast_id,
            axes=ax,
            cut_coords=1,
        )
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_statmap.png'))
    plt.close()

    # ----------------------------------------------------------------------
    #                          extract beta value
    # ----------------------------------------------------------------------
    # ======= NOTE: high stim, low stim
    stim_high_beta = []
    for ind in np.arange(20):
        stim_high_beta_map = first_level_model.compute_contrast(
                    contrasts[f"stim_high_delay_{ind}"], output_type="effect_size"
                )
        stim_high_beta.append(stim_high_beta_map)
        

    stim_low_beta = []
    for ind in np.arange(20):
        stim_low_beta_map = first_level_model.compute_contrast(
                    contrasts[f"stim_low_delay_{ind}"], output_type="effect_size"
                )
        stim_low_beta.append(stim_low_beta_map)

    from nilearn.maskers import NiftiSpheresMasker
    seed_masker = NiftiSpheresMasker([(0,0,1)], radius=10)
    stim_high_beta_roi = []
    for ind in np.arange(len(stim_high_beta)):
        seed_time_series = seed_masker.fit_transform(stim_high_beta[ind])
        stim_high_beta_roi.append(seed_time_series)

    stim_low_beta_roi = []
    for ind in np.arange(len(stim_low_beta)):
        seed_time_series = seed_masker.fit_transform(stim_low_beta[ind])
        stim_low_beta_roi.append(seed_time_series)
        
    plt.plot(np.array(stim_high_beta_roi).flatten(), color='red', label='High stim')
    plt.plot(np.array(stim_low_beta_roi).flatten(), color='blue', label='Low stim')
    plt.legend()
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_stim.png'))
    plt.close()
    # TODO: create a dataframe based on the number of sessions. 
    # append the time series
    stimhighdf = pd.DataFrame({    "sub": [sub],    "ses": [ses],    "runtype": [taskname]    })
    stimhighbeta = np.array(stim_high_beta_roi).flatten()
    for i, value in enumerate(stimhighbeta):
        stimhighdf[f"tr_{i}"] = value
    stimhighdfs.append(stimhighdf)
    stimlowdf = pd.DataFrame({    "sub": [sub],    "ses": [ses],    "runtype": [taskname]    })
    stimlowbeta = np.array(stim_low_beta_roi).flatten()
    for i, value in enumerate(stimlowbeta):
        stimlowdf[f"tr_{i}"] = value
    stimlowdfs.append(stimlowdf)

    # ======= NOTE: low cue high cue
    cue_high_beta = []
    for ind in np.arange(20):
        cue_high_beta_map = first_level_model.compute_contrast(
                    contrasts[f"cue_high_delay_{ind}"], output_type="effect_size"
                )
        cue_high_beta.append(cue_high_beta_map)
        
    cue_low_beta = []
    for ind in np.arange(20):
        cue_low_beta_map = first_level_model.compute_contrast(
                    contrasts[f"cue_low_delay_{ind}"], output_type="effect_size"
                )
        cue_low_beta.append(cue_low_beta_map)
        
    from nilearn.maskers import NiftiSpheresMasker
    seed_masker = NiftiSpheresMasker([(0,0,1)], radius=10)
    cue_high_beta_roi = []
    for ind in np.arange(len(cue_high_beta)):
        seed_time_series = seed_masker.fit_transform(cue_high_beta[ind])
        cue_high_beta_roi.append(seed_time_series)

    cue_low_beta_roi = []
    for ind in np.arange(len(cue_low_beta)):
        seed_time_series = seed_masker.fit_transform(cue_low_beta[ind])
        cue_low_beta_roi.append(seed_time_series)
        

    plt.plot(np.array(cue_high_beta_roi).flatten(), color='red', label='High cue')
    plt.plot(np.array(cue_low_beta_roi).flatten(), color='blue', label='Low cue')
    plt.legend()
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_cue.png'))
    plt.close()

    cuehighdf = pd.DataFrame({    "sub": [sub],    "ses": [ses],    "runtype": [taskname]    })
    cuehighbeta = np.array(cue_high_beta_roi).flatten()
    for i, value in enumerate(cuehighbeta):
        cuehighdf[f"tr_{i}"] = value
    cuehighdfs.append(cuehighdf)

    cuelowdf = pd.DataFrame({    "sub": [sub],    "ses": [ses],    "runtype": [taskname]    })
    cuelowbeta = np.array(cue_low_beta_roi).flatten()
    for i, value in enumerate(cuelowbeta):
        cuelowdf[f"tr_{i}"] = value
    cuelowdfs.append(cuelowdf)
    
stimhighdfs_stack = pd.concat(stimhighdfs, ignore_index=True)
stimlowdfs_stack = pd.concat(stimlowdfs, ignore_index=True)
cuehighdfs_stack = pd.concat(cuehighdfs, ignore_index=True)
cuelowdfs_stack = pd.concat(cuelowdfs, ignore_index=True)

stimhighdfs_stack.to_csv(join(save_dir, sub, f"fir-beta_task-{taskname}_{sub}_cond-stimhigh_delay-{num_delays}.tsv"), sep='\t', index=False)
stimlowdfs_stack.to_csv(join(save_dir, sub, f"fir-beta_task-{taskname}_{sub}_cond-stimlow_delay-{num_delays}.tsv"), sep='\t', index=False)
cuehighdfs_stack.to_csv(join(save_dir, sub, f"fir-beta_task-{taskname}_{sub}_cond-cuehigh_delay-{num_delays}.tsv"), sep='\t', index=False)
cuelowdfs_stack.to_csv(join(save_dir, sub, f"fir-beta_task-{taskname}_{sub}_cond-cuelow_delay-{num_delays}.tsv"), sep='\t', index=False)
