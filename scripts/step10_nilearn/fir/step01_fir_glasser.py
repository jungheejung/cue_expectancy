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
from nilearn.maskers import NiftiSpheresMasker

# mmp.get_fdata().shape
from nilearn.maskers import NiftiMapsMasker

from nilearn.plotting import plot_stat_map
import hcp_utils as hcp
from nilearn.datasets import (load_mni152_template)

def stack_beta(num_delays, first_level_model, contrasts, contrast_pattern):
    """Stack beta maps into one array

    Args:
        num_delays (int): number of FIR delays added to FirstLevelModel
        first_level_model (nilearn.glm.first_level.first_level.FirstLevelModel): nilearn object First level model
        contrasts ([type]): [description]
        contrast_pattern ([type]): [description]

    Returns:
        [type]: [description]
    """

    beta_stack = []
    for ind in np.arange(num_delays):
        contrast_pattern_loop = f"{contrast_pattern}{ind:01d}"
        beta_map = first_level_model.compute_contrast(
                    contrasts[contrast_pattern_loop], output_type="effect_size"
                )
        # print(contrast_pattern_loop)
        beta_stack.append(beta_map)
    return beta_stack

def append_metadata_timeseries(sub, ses, taskname, roi_label, timeseries):
    """Appends metadata with timeseries

    Args:
        sub (str): BIDS format metadata of subject id (e.g. sub-0002)
        ses (str): BIDS format metadata of session (e.g. ses-01)
        taskname (str): labels of task name (e.g. 'pain', 'vicarious', 'cognitive')
        roi_label (pd.DataFrame): list of ROI names
        timeseries_epochCue_cueH_beta (np.array): extracted timeseries. 
                    Shape: # of delay regressors, # ROI. 
                    (e.g. (20, 180) for 20 FIR delays and 180 Glasser ROIS)

    Returns:
        [pd.Dataframe]: time series data per ROI, appended with metadata
    """
    metadf = pd.DataFrame({"sub": np.repeat([sub], len(roi_label)),    
                            "ses": np.repeat([ses], len(roi_label)),   
                            "runtype": np.repeat([taskname], len(roi_label)),  
                            "roi": roi_label['roi']  })
   
    timeseries_df = pd.DataFrame(timeseries.T)
    timeseries_df.columns = ["tr_" + str(i) for i in range(timeseries_df.shape[1])]
    timeseries_append = pd.concat([metadf, timeseries_df], axis=1)
    # epochCue_cueH_dfs.append(timeseries_append)
    return timeseries_append
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
# main_dir = '/Users/h/Documents/projects_local/cue_expectancy'
# fmriprep_dir = '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/'
# sub = 'sub-0002'
# taskname = 'pain'
# onset_dir = f'/Users/h/Documents/projects_local/sandbox/fmriprep_bold'
# %%
metadata = join(main_dir, 'data', 'spacetop_task-social_run-metadata.csv')
metadf = pd.read_csv(metadata)
subject_subset =  metadf[metadf['sub'] == sub]

epochCue_cueH_dfs = [];     epochCue_cueL_dfs = []
epochStim_stimH_dfs = [];   epochStim_stimL_dfs = []
epochStim_cueH_dfs = [];    epochStim_cueL_dfs = []




def plot_timeseries(sub, ses, run_list, taskname, num_delays, TR, timeseries_condA_betastack, timeseries_condB_betastack, epoch_label, contrast_labelA, contrast_labelB):
    plt.plot(timeseries_condA_betastack.T[0], color='red', label=contrast_labelA)
    plt.plot(timeseries_condB_betastack.T[0], color='blue', label=contrast_labelB)
    plt.legend()
    plt.gca().spines['top'].set_visible(False)
    plt.gca().spines['right'].set_visible(False)
    tick_positions = np.arange(num_delays)
    tick_labels = [f'{pos*TR:.2f}' for pos in tick_positions]
    plt.xticks(tick_positions, tick_labels, rotation=45)
    plt.title(f"* Epoch: {epoch_label}\n* Condition: {contrast_labelA} vs. {contrast_labelB}\n* BIDS: {sub} {ses} run-{run_list} {taskname}")
    plt.xlabel('TR')
    plt.ylabel('ROI activation (A.U.)')

for ses_ind in np.arange(len(subject_subset)):
    ses = subject_subset.iloc[ses_ind, subject_subset.columns.get_loc("ses")]
    #ses = 'ses-01' ########DELETED LATER
    subset_df = metadf[(metadf['sub'] == sub) & (metadf['ses'] == ses)]
    task_columns = subset_df.columns[subset_df.eq(taskname).any()]
    run_list = [int(col.split('-')[-1]) for col in task_columns]
    print(f"{sub} {ses} {run_list}")

    
    # ------------------------ load fmri data ------------------------------
    fmriprep_flist = []
    for run_num in run_list:
        flist = sorted(glob.glob(join(fmriprep_dir, sub, ses, 'func', f'{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'), recursive=True))
        fmriprep_flist.append(flist[0])
    func = [image.load_img(fname) for fname in fmriprep_flist]


    # ------------------------ reshape image -------------------------------
    fmri_img = []
    template = load_mni152_template(resolution=3)
    for img in np.arange(len(func)):
        fmri_img.append(image.resample_to_img(func[img], template, interpolation='nearest') )#, target_affine=ref_img.affine, target_shape=ref_img.shape)

    TR = 0.46  
    n_scans = 872  
    frame_times = np.arange(n_scans) * TR  # here are the corresponding frame times

    design_matrices = []
    event_concat = []
    confounds_concat = []


    # -------------- load behavioral and confound data ---------------------
    for run_num in run_list:
        # NOTE: behavioral/onset data
        fname = join(onset_dir, sub, ses, f'{sub}_{ses}_task-cue_acq-mb8_run-{int(run_num):02d}_events.tsv')
        event_df = pd.read_csv(fname)
        event_df['condition_type'] = event_df['cuetype'].astype(str) +'_' + event_df['stimtype'].astype(str)
        cue_df = pd.DataFrame(
            {        
                "trial_type": event_df[event_df['trial_type']=='cue'].cuetype,
                "onset": event_df[event_df['trial_type']=='cue'].onset,
                "duration": event_df[event_df['trial_type']=='cue'].duration
            }
        )

        stim_df = pd.DataFrame(
            {
                "trial_type": event_df[event_df['trial_type']=='stimulus'].condition_type,
                "onset": event_df[event_df['trial_type']=='stimulus'].onset, 
                "duration": event_df[event_df['trial_type']=='stimulus'].duration 
            }
        )
        events = pd.concat([cue_df, stim_df])

        # NOTE: confounds data
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

        event_concat.append(events)
        confounds_concat.append(subset_confounds)

    # ----------------------------------------------------------------------
    #                          first level models
    # ----------------------------------------------------------------------

    first_level_model = FirstLevelModel(t_r=TR, 
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

    # -------------- NOTE: compute contrasts for each regressor ------------------
    sessionwise_contrast = []

    # Initialize empty lists for different conditions and delays
    epochCue_cueH_delay = [[] for _ in range(num_delays)]
    epochCue_cueL_delay = [[] for _ in range(num_delays)]
    epochStim_cueH_delay = [[] for _ in range(num_delays)]
    epochStim_cueL_delay = [[] for _ in range(num_delays)]
    epochStim_stimH_delay = [[] for _ in range(num_delays)]
    epochStim_stimL_delay = [[] for _ in range(num_delays)]

    con_epochCue_cueH = [];    con_epochCue_cueL = []
    con_epochStim_cueH = [];     con_epochStim_cueL = []
    con_epochStim_stimH = [];     con_epochStim_stimL = []
    con_epochStim_cueHgtL = [];     con_epochStim_stimHgtL = []

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
    # ------------ NOTE: Generate contrast names and append to the respective lists----------------
        for delay in range(num_delays):

            delay_names = [f"high_cue_delay_{delay}"]
            contrasts[f"epochCue_cueH_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"low_cue_delay_{delay}"]
            contrasts[f"epochCue_cueL_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"high_cue_high_stim_delay_{delay}", f"high_cue_med_stim_delay_{delay}", f"high_cue_low_stim_delay_{delay}"]
            contrasts[f"epochStim_cueH_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"low_cue_high_stim_delay_{delay}", f"low_cue_med_stim_delay_{delay}", f"low_cue_low_stim_delay_{delay}"]
            contrasts[f"epochStim_cueL_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"high_cue_high_stim_delay_{delay}", f"low_cue_high_stim_delay_{delay}"]
            contrasts[f"epochStim_stimH_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            delay_names = [f"high_cue_low_stim_delay_{delay}", f"low_cue_low_stim_delay_{delay}"]
            contrasts[f"epochStim_stimL_delay_{delay}"] = np.sum([contrasts[name] for name in delay_names if name in contrasts], 0)

            epochCue_cueH_delay[delay].append(contrasts[f"epochCue_cueH_delay_{delay}"])
            epochCue_cueL_delay[delay].append(contrasts[f"epochCue_cueL_delay_{delay}"])
            epochStim_cueH_delay[delay].append(contrasts[f"epochStim_cueH_delay_{delay}"])
            epochStim_cueL_delay[delay].append(contrasts[f"epochStim_cueL_delay_{delay}"])
            epochStim_stimH_delay[delay].append(contrasts[f"epochStim_stimH_delay_{delay}"])
            epochStim_stimL_delay[delay].append(contrasts[f"epochStim_stimL_delay_{delay}"])

        con_epochCue_cueH.append(contrasts["high_cue"])
        con_epochCue_cueL.append(contrasts["low_cue"])
        con_epochStim_cueH.append(contrasts["high_cue_high_stim"] + contrasts["high_cue_med_stim"] + contrasts["high_cue_low_stim"] )
        con_epochStim_cueL.append(contrasts["low_cue_high_stim"] + contrasts["low_cue_med_stim"] + contrasts["low_cue_low_stim"] )
        con_epochStim_stimH.append(contrasts["high_cue_high_stim"] + contrasts["low_cue_high_stim"])
        con_epochStim_stimL.append(contrasts["high_cue_low_stim"] + contrasts["low_cue_low_stim"])
        con_epochStim_cueHgtL.append((contrasts["high_cue_high_stim"] + contrasts["high_cue_med_stim"] + contrasts["high_cue_low_stim"]) - (contrasts["low_cue_high_stim"] + contrasts["low_cue_med_stim"] + contrasts["low_cue_low_stim"]  ))
        # con_epochStim_stimHgtL.append(contrasts["high_cue_low_stim"] - contrasts["low_cue_low_stim"])
        con_epochStim_stimHgtL.append((contrasts["high_cue_high_stim"] + contrasts["low_cue_high_stim"]) - (contrasts["high_cue_med_stim"] + contrasts["low_cue_med_stim"] ) - (contrasts["high_cue_low_stim"] + contrasts["low_cue_low_stim"])  )

    # Update the contrasts dictionary with the generated lists
    for delay in range(num_delays):
        contrasts[f"epochCue_cueH_delay_{delay}"] = epochCue_cueH_delay[delay]
        contrasts[f"epochCue_cueL_delay_{delay}"] = epochCue_cueL_delay[delay]
        contrasts[f"epochStim_cueH_delay_{delay}"] = epochStim_cueH_delay[delay]
        contrasts[f"epochStim_cueL_delay_{delay}"] = epochStim_cueL_delay[delay]
        contrasts[f"epochStim_stimH_delay_{delay}"] = epochStim_stimH_delay[delay]
        contrasts[f"epochStim_stimL_delay_{delay}"] = epochStim_stimL_delay[delay]

    contrasts["epochCue_cueH"] = con_epochCue_cueH
    contrasts["epochCue_cueL"] = con_epochCue_cueL
    contrasts["epochStim_cueH"] = con_epochStim_cueH
    contrasts["epochStim_cueL"] = con_epochStim_cueL
    contrasts["epochStim_stimH"] = con_epochStim_stimH
    contrasts["epochStim_stimL"] = con_epochStim_stimL
    contrasts["epochStim_cueHgtL"] = con_epochStim_cueHgtL
    contrasts["epochStim_stimHgtL"] = con_epochStim_stimHgtL

    #   subset contrasts
    keys_to_subset = ['epochCue_cueH', 'epochCue_cueL', 
                      'epochStim_cueH', 'epochStim_cueL', 
                      'epochStim_stimH', 'epochStim_stimL', 
                      'epochStim_cueHgtL', 'epochStim_stimHgtL']
    subset_dict = dict((key, contrasts[key]) for key in keys_to_subset)

    fig = plt.figure(figsize=(20, 5))
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

    # ---------------- NOTE: load mask and down sample ---------------------
    template = load_mni152_template(resolution=3)
    atlas = join(main_dir, 'resources', 'atlas', 'HCPMMP1_on_MNI152_ICBM2009a_nlin.nii.gz')
    mmp_label = pd.read_csv(join(main_dir,'resources', 'atlas', 'HCPMMP1_on_MNI152_ICBM2009a_nlin.txt'), header=None, names=['roi'])
    mmp = image.load_img(atlas)
    mmp3 = image.resample_to_img(mmp, template, interpolation='nearest') #, target_affine=ref_img.affine, target_shape=ref_img.shape)
    unique_values = set(mmp3.get_fdata().flatten())
    filtered_values = {value for value in unique_values if value != 0.0}


    # ---------------- NOTE: convert 3d atlas into 4d image -----------------
    mask_4d = []
    for value in filtered_values:
        mask = image.math_img('img == {}'.format(value), img=mmp3)
        mask_4d.append(mask)
    mmp4d = image.concat_imgs(mask_4d)

    mmpmasker = maskers.NiftiMapsMasker(
        maps_img=mmp4d,
        memory="nilearn_cache",
        verbose=5,
    )

    # ------ NOTE: extract timeseries for epoch cue, high vs. low cue -------
    # NOTE: stack beta maps (len(epochCue_cueH_beta) == num_delays)

    epochCue_cueH_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochCue_cueH_delay_")
    epochCue_cueL_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochCue_cueL_delay_")
            
    timeseries_epochCue_cueH_beta = mmpmasker.fit_transform(epochCue_cueH_beta)
    timeseries_epochCue_cueL_beta = mmpmasker.fit_transform(epochCue_cueL_beta)
    plot_timeseries(sub=sub, ses=ses, run_list=run_list, taskname=taskname, num_delays=20, TR=TR, 
                    timeseries_condA_betastack=timeseries_epochCue_cueH_beta,
                    timeseries_condB_betastack=timeseries_epochCue_cueL_beta,
                    epoch_label="cue", 
                    contrast_labelA="High cue",
                    contrast_labelB="Low cue" )
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_epoch-cue_cond-cue.png'))
    plt.close()
       

    # NOTE: convert extracted timeseries data into pandas, with metadata
    epochCue_cueH_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochCue_cueH_beta)
    epochCue_cueH_dfs.append(epochCue_cueH_append)

    epochCue_cueL_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochCue_cueL_beta)
    epochCue_cueL_dfs.append(epochCue_cueL_append)

 
    # ------ NOTE: extract timeseries for epoch stim, high vs. low stim -------
    # stack 20 beta images

    epochStim_stimH_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochStim_stimH_delay_")
    epochStim_stimL_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochStim_stimL_delay_")

    timeseries_epochStim_stimH_beta = mmpmasker.fit_transform(epochStim_stimH_beta)
    timeseries_epochStim_stimL_beta = mmpmasker.fit_transform(epochStim_stimL_beta)

    plot_timeseries(sub=sub, ses=ses, run_list=run_list, taskname=taskname, num_delays=20, TR=TR, 
                timeseries_condA_betastack=timeseries_epochStim_stimH_beta,
                timeseries_condB_betastack=timeseries_epochStim_stimL_beta,
                epoch_label="stim", 
                contrast_labelA="High stim",
                contrast_labelB="Low stim" )
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_epoch-stim_cond-stim.png'))
    plt.close()
    # TODO: create a dataframe based on the number of sessions. 
    # append the time series
    # epochStim_stimH_df = pd.DataFrame({"sub": np.repeat([sub], len(mmp_label)),    
    #                            "ses": np.repeat([ses], len(mmp_label)),   
    #                            "runtype": np.repeat([taskname], len(mmp_label)),  
    #                            "roi": mmp_label['roi']  })
   
    # timeseries_epochStim_stimH_df = pd.DataFrame(timeseries_epochStim_stimH_beta.T)
    # timeseries_epochStim_stimH_df.columns = ["tr_" + str(i) for i in range(timeseries_epochStim_stimH_df.shape[1])]
    # epochStim_stimH_append = pd.concat([epochStim_stimH_df, timeseries_epochStim_stimH_df], axis=1)
    epochStim_stimH_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochStim_stimH_beta)
    epochStim_stimH_dfs.append(epochStim_stimH_append)
    
    epochStim_stimL_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochStim_stimL_beta)
    epochStim_stimL_dfs.append(epochStim_stimL_append)

    # ------ NOTE: extract timeseries for epoch stim, high vs. low cue -------
    # epochStim_cueH_beta = []
    # for ind in np.arange(num_delays):
    #     epochStim_cueH_beta_map = first_level_model.compute_contrast(
    #                 contrasts[f"epochStim_cueH_delay_{ind}"], output_type="effect_size"
    #             )
    #     epochStim_cueH_beta.append(epochStim_cueH_beta_map)
        
    # epochStim_cueL_beta = []
    # for ind in np.arange(num_delays):
    #     epochStim_cueL_beta_map = first_level_model.compute_contrast(
    #                 contrasts[f"epochStim_cueL_delay_{ind}"], output_type="effect_size"
    #             )
    #     epochStim_cueL_beta.append(epochStim_cueL_beta_map)

    epochStim_cueH_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochStim_cueH_delay_")
    epochStim_cueL_beta = stack_beta(num_delays=num_delays, first_level_model=first_level_model, contrasts=contrasts, contrast_pattern=f"epochStim_cueL_delay_")

    timeseries_epochStim_cueH_beta = mmpmasker.fit_transform(epochStim_cueH_beta)
    timeseries_epochStim_cueL_beta = mmpmasker.fit_transform(epochStim_cueL_beta)
        
    plot_timeseries(sub=sub, ses=ses, run_list=run_list, taskname=taskname, num_delays=20, TR=TR, 
                timeseries_condA_betastack=timeseries_epochStim_cueH_beta,
                timeseries_condB_betastack=timeseries_epochStim_cueL_beta,
                epoch_label="stim", 
                contrast_labelA="High cue",
                contrast_labelB="Low cue" )
    plt.savefig(join(save_dir, sub, f'{sub}_{ses}_fir-{num_delays}_epoch-stim_cond-cue.png'))
    plt.close()

    epochStim_cueH_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochStim_cueH_beta)
    epochStim_cueH_dfs.append(epochStim_cueH_append)
    epochStim_cueL_append = append_metadata_timeseries(sub=sub, ses=ses, taskname=taskname, roi_label=mmp_label, timeseries=timeseries_epochStim_cueL_beta)
    epochStim_cueL_dfs.append(epochStim_cueL_append)
    
epochCue_cueH_dfs_stack = pd.concat(epochCue_cueH_dfs, ignore_index=True)
epochCue_cueL_dfs_stack = pd.concat(epochCue_cueL_dfs, ignore_index=True)
epochStim_stimH_dfs_stack = pd.concat(epochStim_stimH_dfs, ignore_index=True)
epochStim_stimL_dfs_stack = pd.concat(epochStim_stimL_dfs, ignore_index=True)
epochStim_cueH_dfs_stack = pd.concat(epochStim_cueH_dfs, ignore_index=True)
epochStim_cueL_dfs_stack = pd.concat(epochStim_cueL_dfs, ignore_index=True)

epochCue_cueH_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-cue_cond-cueH_delay-{num_delays}.tsv"), sep='\t', index=False)
epochCue_cueL_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-cue_cond-cueL_delay-{num_delays}.tsv"), sep='\t', index=False)
epochStim_stimH_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-stim_cond-stimH_delay-{num_delays}.tsv"), sep='\t', index=False)
epochStim_stimL_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-stim_cond-stimL_delay-{num_delays}.tsv"), sep='\t', index=False)
epochStim_cueH_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-stim_cond-cueH_delay-{num_delays}.tsv"), sep='\t', index=False)
epochStim_cueL_dfs_stack.to_csv(join(save_dir, sub, f"fir-beta_roi-glasser_task-{taskname}_{sub}_epoch-stim_cond-cueL_delay-{num_delays}.tsv"), sep='\t', index=False)
