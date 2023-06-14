#!/usr/bin/env python
"""Creates single trial beta maps 
# order of operations 
# 0. argparse
# 0. parameters
# 1. load behavioral data and restructure for BIDS 
# 2. Setup glm paramters and extract confounds from fmriprep confounds.tsv
# 3. Fit glm model per trial
"""
# %%
import os, re, glob
import argparse
import matplotlib.pyplot as plt
import nibabel as nib
import numpy as np
import pandas as pd
from pathlib import Path
from nilearn.datasets import fetch_language_localizer_demo_dataset
from nilearn.glm.first_level import first_level_from_bids
from nilearn.glm.first_level import FirstLevelModel
from nilearn import image, plotting

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

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

def restructure_task_cue_beh(beh_fname):
    import pandas as pd
    import numpy as np
    beh = pd.read_csv(beh_fname, sep = '\t')
    beh_tsv = os.path.basename(beh_fname)

    sub_num = int([match for match in beh_tsv.split('_') if "sub" in match][0].split('-')[1])
    ses_num = int([match for match in beh_tsv.split('_') if "ses" in match][0].split('-')[1])
    run_num = int([match for match in beh_tsv.split('_') if "run" in match][0].split('-')[1])
    runtype = [match for match in beh_tsv.split('_') if "runtype" in match][0].split('-')[1]
    sub = f"sub-{sub_num:04d}"
    ses = f"ses-{ses_num:02d}"
    run = f"run-{run_num:02d}"
    # sub-0133_ses-01_run-06_runtype-pain_event-stimulus_trial-011.nii.gz
    # f"{sub}_{ses}_{run}_runtype-{runtype}_event-cue_trial-{trial_num:03d}.nii.gz"
    cuetype_list = beh.pmod_cuetype.str.split('_').str.get(0)
    stimtype_list = beh.pmod_stimtype.str.split('_').str.get(0)
    trial_list = pd.DataFrame(beh.index.tolist())
    
    onset01_cue = pd.DataFrame({
        'onset' : list(beh['onset01_cue']),
        'duration' : list(np.repeat(1,len(beh['onset01_cue']))),
        'trial_type' : list(np.repeat('cue',len(beh['onset01_cue']))),
        'sub': list(np.repeat(sub,len(beh['onset01_cue']))),
        'ses': list(np.repeat(ses,len(beh['onset01_cue']))),
        'run': list(np.repeat(run,len(beh['onset01_cue']))),
        'runtype': list(np.repeat(runtype,len(beh['onset01_cue']))),
        'eventtype': list(np.repeat('cue',len(beh['onset01_cue']))),
        'trialnum': list(range(len(beh['onset01_cue']))),
        'cuetype':beh.pmod_cuetype,
        'stimtype':beh.pmod_stimtype,
        'expectrating':beh.pmod_expectangle,
        'outcomerating':list(np.repeat(np.nan,len(beh['onset01_cue']))),
        'singletrial_fname': [f"{sub}_{ses}_{run}_runtype-{runtype}_event-cue_trial-{i:03d}_cuetype-{cuetype_list[i]}.nii.gz" for i in range(len(beh['onset01_cue']))]#for trial_num in range(len(beh['onset01_cue']))]
    })
    onset02_expectrating = pd.DataFrame({
        'onset' : list(beh['onset02_ratingexpect']),
        'duration' : list(beh['pmod_expectRT']),
        'trial_type' : list(np.repeat('expectrating',len(beh['onset02_ratingexpect']))),
        'sub': list(np.repeat(sub,len(beh['onset02_ratingexpect']))),
        'ses': list(np.repeat(ses,len(beh['onset02_ratingexpect']))),
        'run': list(np.repeat(run,len(beh['onset02_ratingexpect']))),
        'runtype': list(np.repeat(runtype,len(beh['onset02_ratingexpect']))),
        'eventtype': list(np.repeat('expectrating',len(beh['onset02_ratingexpect']))),
        'trialnum': list(range(len(beh['onset02_ratingexpect']))),
        'cuetype':beh.pmod_cuetype,
        'stimtype':beh.pmod_stimtype,
        'expectrating':beh.pmod_expectangle,
        'outcomerating':list(np.repeat(np.nan,len(beh['onset02_ratingexpect']))),
        'singletrial_fname': [f"{sub}_{ses}_{run}_runtype-{runtype}_event-expectrating_trial-{i:03d}_cuetype-{cuetype_list[i]}.nii.gz" for i in range(len(beh['onset02_ratingexpect']))]
    })

    onset03_stim = pd.DataFrame({
        'onset' : list(beh['onset03_stim']),
        'duration' : list(np.repeat(5,len(beh['onset03_stim']))),
        'trial_type' : list(np.repeat('stimulus',len(beh['onset03_stim']))),
        # 'full_trial_type' : list('event-stimulus_cue-' + beh.pmod_cuetype.str.split('_').str.get(0) + '_stim-' + beh.pmod_stimtype.str.split('_').str.get(0)),
        'sub': list(np.repeat(sub,len(beh['onset03_stim']))),
        'ses': list(np.repeat(ses,len(beh['onset03_stim']))),
        'run': list(np.repeat(run,len(beh['onset03_stim']))),
        'runtype': list(np.repeat(runtype,len(beh['onset03_stim']))),
        'eventtype': list(np.repeat('stimulus',len(beh['onset03_stim']))),
        'trialnum': list(range(len(beh['onset03_stim']))),
        'cuetype':beh.pmod_cuetype,
        'stimtype':beh.pmod_stimtype,
        'expectrating':beh.pmod_expectangle,
        'outcomerating':beh.pmod_outcomeangle,
        'singletrial_fname': [f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-{i:03d}_cuetype-{cuetype_list[i]}_stimintensity-{stimtype_list[i]}.nii.gz" for i in range(len(beh['onset03_stim']))]
    })

    onset04_outcomerating = pd.DataFrame({
        'onset' : list(beh['onset04_ratingoutcome']),
        'duration' : list(beh['pmod_outcomeRT']),
        'trial_type' : list(np.repeat('outcomerating',len(beh['onset04_ratingoutcome']))),
        # 'full_trial_type' : list('event-outcomerating_cue-' + beh.pmod_cuetype.str.split('_').str.get(0) + '_stim-' + beh.pmod_stimtype.str.split('_').str.get(0)),
        # TODO: pick up here. you want to construct a nifti filename that includes all of the major parameters: eventtype, cue, stimintensity
        'sub': list(np.repeat(sub,len(beh['onset04_ratingoutcome']))),
        'ses': list(np.repeat(ses,len(beh['onset04_ratingoutcome']))),
        'run': list(np.repeat(run,len(beh['onset04_ratingoutcome']))),
        'runtype': list(np.repeat(runtype,len(beh['onset04_ratingoutcome']))),
        'eventtype': list(np.repeat('outcomerating',len(beh['onset04_ratingoutcome']))),
        'trialnum': list(range(len(beh['onset04_ratingoutcome']))),
        'cuetype':beh.pmod_cuetype,
        'stimtype':beh.pmod_stimtype,
        'expectrating':beh.pmod_expectangle,
        'outcomerating':beh.pmod_outcomeangle,
        'singletrial_fname': [f"{sub}_{ses}_{run}_runtype-{runtype}_event-outcomerating_trial-{i:03d}_cuetype-{cuetype_list[i]}_stimintensity-{stimtype_list[i]}.nii.gz" for i in range(len(beh['onset04_ratingoutcome']))]
    })
    events_df = pd.concat([onset01_cue, onset02_expectrating, onset03_stim, onset04_outcomerating])
    events_df = events_df.reset_index(drop=True)
    return events_df

def utils_globrunlist(beh_list, key = 'run',stringlist_to_keep = ['ttl'] ):
    """
    parameters
    ==========
    beh_list: list of fullpath globs from a given directory

    key: str 
        a keyword. Based on this keyword, we'll identify whether there are duplicates. default "run"
    string_to_keep: 
        a keyword. If we find a matching run, we need a criterion string to identify which filepaths to remove 
        and which filespaths to keep
        
        e.g. 
        ['/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-01_runtype-pain_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-01_runtype-pain_events_ttl.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-04_runtype-cognitive_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-02_runtype-vicarious_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-06_runtype-pain_events_ttl.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-06_runtype-pain_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-03_runtype-cognitive_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-05_runtype-vicarious_events.tsv']
    return
    ======
    ['/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-01_runtype-pain_events_ttl.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-04_runtype-cognitive_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-02_runtype-vicarious_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-06_runtype-pain_events_ttl.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-03_runtype-cognitive_events.tsv',
            '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-05_runtype-vicarious_events.tsv']

    """
    import os, glob
    import pandas as pd
    import numpy as np
    
    bids_info = [[match for match in os.path.basename(beh_fname).split('_') if key in match][0] for beh_fname in beh_list]
    duprun_list = np.where(pd.DataFrame(bids_info).duplicated(keep=False))
    duprun_idx = list(duprun_list[0])
    matched_list = [l for l in beh_list if any(k in l for k in stringlist_to_keep)]
    st = set(matched_list)   
    ttl_idx = [i for i, e in enumerate(beh_list) if e in st]
    remove_idx = list(set(duprun_idx) ^ set(ttl_idx))
    beh_list_copy = beh_list
    for index in sorted(remove_idx, reverse=True):
        del beh_list_copy[index]

    return beh_list_copy

# 0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
parser.add_argument("--session-num", type=int,
                    help="specify slurm array id")
# parser.add_argument("--run-num", type=int,
#                     help="specify slurm array id")
# parser.add_argument("-r", "--runtype",
#                     choices=['pain','vicarious','cognitive','all'], help="specify runtype name (e.g. pain, cognitive, variance)")
args = parser.parse_args()

# 0. parameters ________________________________________________________________________________
print(args.slurm_id)
slurm_id = args.slurm_id # e.g. 1, 2
# sub_num = args.subject_num # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
ses_num = args.session_num # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
#run_num = args.run_num # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
# run_type = args.runtype

onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM'
save_events_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
save_singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
save_fig_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/figure/fmri/nilearn/singletrial'
sub_folders = next(os.walk(onset_dir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
# TODO; TEST for now, feed in subject id directly
# sub = sub_list[slurm_id]
sub = sub_list[slurm_id]#f'sub-{sub_list[slurm_id]:04d}'
ses = 'ses-{:02d}'.format(ses_num)
#run = 'run-{:02d}'.format(run_num)
print(f" ________ {sub} {ses} ________")

subject_beh_dir = os.path.join(onset_dir, sub, ses)
save_designmatrix_dir = os.path.join(save_fig_dir, sub)

# 1. load behavioral data and restructure for BIDS  ________________________________________________________________________________
# 1-1) load tsv file. If _ttl.tsv exists, then load that one

beh_list = glob.glob(os.path.join(onset_dir, sub, ses, f'{sub}_{ses}_task-cue_*runtype-*.tsv'))

# key = 'run'
# bids_info = [[match for match in os.path.basename(beh_fname).split('_') if key in match][0] for beh_fname in beh_list]
# duprun_list = np.where(pd.DataFrame(bids_info).duplicated(keep=False))
# duprun_idx = list(duprun_list[0])
# matched_list = [l for l in beh_list if any(k in l for k in ['ttl'])]
# st = set(matched_list)   
# ttl_idx = [i for i, e in enumerate(beh_list) if e in st]
# remove_idx = list(set(duprun_idx) ^ set(ttl_idx))
# beh_list_copy = beh_list
# for index in sorted(remove_idx, reverse=True):
#     del beh_list_copy[index]
beh_clean_list = utils_globrunlist(beh_list, key = 'run', stringlist_to_keep=['ttl'])

for beh_fname in beh_clean_list:
    run_info = [match for match in os.path.basename(beh_fname).split('_') if "run" in match][0]
    run_num = int(re.findall(r'\d+', run_info )[0].lstrip('0'))
    run_type = [match for match in os.path.basename(beh_fname).split('_') if "runtype" in match][0].split('-')[1]
    run = f"run-{run_num:02d}"
    print(f"{run_num} {run_type}")
    # 1-2) restructure for BIDS format. Columns have onset/duration/trial_type
    events_df = restructure_task_cue_beh(beh_fname)
    # TODO: later save it to source BIDS dir
    save_events_fname = f'{sub}_{ses}_task-cue_acq-mb8_{run}_events.tsv'
    save_events_sub_dir = os.path.join(save_events_dir, sub, ses)
    Path(save_events_sub_dir).mkdir(parents = True, exist_ok = True)
    events_df.to_csv(os.path.join(save_events_sub_dir, save_events_fname))
    print(events_df.head())
    # NOTE: FUTURE REFERENCE. IF YOU NEED TO FIND THE EVENTS BASED ON THE KEYWRODS
    # regex = re.compile(r'event-(.+?)_')
    # events_df.trial_type.str.extract(regex)


    # %% 2. Setup glm paramters and extract confounds from fmriprep confounds.tsv ___________________________________________________________
    glm_parameters = {'drift_model':None,
    'drift_order': 1,
    'fir_delays': [0],
    # 'high_pass': 0.01, This parameter specifies the cut frequency of the high-pass filter in Hz for the design matrices. Used only if drift_model is ‘cosine’. Default=0.01.
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
    lss_beta_maps = {cond: [] for cond in events_df['trial_type'].unique()}
    lss_design_matrices = []
    fmri_file = os.path.join(fmriprep_dir, sub, ses, 'func', f'{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz')
    confounds_file = os.path.join(fmriprep_dir, sub, ses, 'func', f'{sub}_{ses}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv')
    confounds = pd.read_csv(confounds_file, sep = '\t')
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
    print("grabbed all the confounds and fmri data")
    subset_confounds.head()
    # %% 3. Fit glm model per trial ________________________________________________________________________________
    # TODO: identify the index where trial type is stimulus and cue
    singletrial_list = events_df.loc[(events_df['trial_type'] == 'cue') | (events_df['trial_type'] == 'stimulus')].index.tolist()
    for i_trial in singletrial_list:
        print(f"trial number: {i_trial}")
        # step 1) isolate each event
        lss_events_df, trial_condition = lss_transformer(events_df, i_trial)
        condition_name = trial_condition.split('__')[0]
        trial_num =  trial_condition.split('__')[1]
        fullfname = events_df.singletrial_fname[i_trial]
        description = fullfname.replace(".nii.gz", "")
        print(description)
        # step 2) compute and collect beta maps
        lss_glm = FirstLevelModel(**glm_parameters)
        lss_glm.fit(fmri_file, 
                    events = lss_events_df[['onset', 'duration', 'trial_type']], 
                    confounds = subset_confounds.fillna(0))

        beta_map = lss_glm.compute_contrast(
            trial_condition,
            output_type='effect_size',
        )
        # step 3) save the design matrices and plot this for reference
        fig, axes = plt.subplots(ncols=1, figsize=(20, 10))
        # save_designmatrix_dir = os.path.join(save_singletrial_dir, sub)
        save_figname = description + '.png'
        Path(save_designmatrix_dir).mkdir(parents = True, exist_ok = True)
        designmtx = plotting.plot_design_matrix(
            lss_glm.design_matrices_[0],
            output_file = os.path.join(save_designmatrix_dir, save_figname)
            )

        # step 4) save beta map as isolated nifti
        # Drop the trial number from the condition name to get the original name
        beta_map.header['descrip'] = description
        lss_beta_maps[condition_name].append(beta_map)
        save_singletrial_subdir = os.path.join(save_singletrial_dir, sub)
        Path(save_singletrial_subdir).mkdir(parents = True, exist_ok = True)
        nib.save(beta_map, os.path.join(save_singletrial_subdir, events_df.singletrial_fname[i_trial]))

    # step 5) concatenate the lists of 3D maps into a single 4D beta series for each condition, if we want
    # for name, maps in lss_beta_maps.items():
    #     if len(maps) !=0:
    #         print(name)
    #         concat_map = image.concat_imgs(maps)
    #         description = f"{sub}_{ses}_{run}_runtype-{run_type}_event-{name}_concat"
    #         concat_map.header['descrip'] = description
    #         nib.save(concat_map, os.path.join(save_singletrial_dir, description + '.nii.gz'))
