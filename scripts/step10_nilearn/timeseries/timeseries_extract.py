# ----------------------------------------------------------------------
#                               libraries
# ----------------------------------------------------------------------
import argparse
from os.path import join
import os, glob, re
import pandas as pd
import numpy as np
from nilearn import maskers, masking, image
from nilearn.datasets import (load_mni152_template)
import matplotlib.pyplot as plt

def extract_timecourse_condition(behdf, column_name, level_name, time_series, prior_event_sec, after_event_sec):
    """extract_timecourse_condition

    Args:
        behdf (pd.DataFrame): dataframe with onset time and condition type metadata
        column_name (str): Which column to reference from the behavioral dataframe
        level_name (str): which level from a given factor?
        time_series (np.array): array from masker extraction 
        prior_event_sec (int): how many seconds do you want to extract prior to event onset?
        after_event_sec (int): how many seconds to you want to extract after event onset?
        # TR_timepoints ([type]): [description]

    Returns:
        results_interval: np.array of trial x timepoints values
    """
    TR=0.46
    rounded_intervals = np.round(behdf.loc[behdf[column_name] == level_name,'onset03_stim']).astype(int)
    result_intervals = []

    for rounded_index in rounded_intervals:
        start_index = max(0, int(rounded_index) - int(np.round(prior_event_sec / TR)))
        end_index = min(len(time_series), int(rounded_index) + int(np.round(after_event_sec / TR)) )
        interval = time_series[start_index:end_index]
        result_intervals.append(interval)

    result_intervals = np.vstack(result_intervals)
    return result_intervals

def extract_meta(basename):
    sub_ind = int(re.search(r'sub-(\d+)', basename).group(1))
    ses_ind = int(re.search(r'ses-(\d+)', basename).group(1))
    run_ind = int(re.search(r'run-(\d+)', basename).group(1))
    # runtype = re.search(r'runtype-(.*?)_', basename).group(1)
    return sub_ind, ses_ind, run_ind

def extract_timecourse_condition_per_beh(behdf, column_name,time_series, prior_event_sec, after_event_sec):
    """extract_timecourse_condition

    Args:
        behdf (pd.DataFrame): dataframe with onset time and condition type metadata
        column_name (str): Which column to reference from the behavioral dataframe
        level_name (str): which level from a given factor?
        time_series (np.array): array from masker extraction 
        prior_event_sec (int): how many seconds do you want to extract prior to event onset?
        after_event_sec (int): how many seconds to you want to extract after event onset?
        # TR_timepoints ([type]): [description]

    Returns:
        results_interval: np.array of trial x timepoints values
    """
    TR=0.46
    rounded_intervals = np.round(behdf[column_name]).astype(int)
    result_intervals = []

    for rounded_index in rounded_intervals:

        start_index = max(0, int(rounded_index) - int(np.round(prior_event_sec / TR)))
        end_index = min(len(time_series), int(rounded_index) + int(np.round(after_event_sec / TR)) )
        interval = time_series[start_index:end_index]
        result_intervals.append(interval)

    result_intervals = np.vstack(result_intervals)
    return result_intervals


# ----------------------------------------------------------------------
#                               parameters
# ----------------------------------------------------------------------
# 0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
args = parser.parse_args()
print(args.slurm_id)
slurm_id = args.slurm_id 

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
beh_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM'
save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv08_parcel/subcortex_Tian2020_timeseries'
subcortex_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/other_repos/subcortex/Group-Parcellation/3T/Cortex-Subcortex'
sub_folders = next(os.walk(fmriprep_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id]
print(f"---------- {sub} -----------")
fmriprep_flist = glob.glob(join(fmriprep_dir, sub, '**', 'func', f'{sub}_*_task-social_acq-mb8_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'))

# ----------------------------------------------------------------------
#                               subcortex map
# ----------------------------------------------------------------------
subcortex = join(subcortex_dir,'MNIvolumetric','Schaefer2018_200Parcels_7Networks_order_Tian_Subcortex_S1_3T_MNI152NLin2009cAsym_2mm.nii.gz')
subcortex_label = join(subcortex_dir,'Schaefer2018_200Parcels_7Networks_order_Tian_Subcortex_S1_label.txt')
labels = pd.read_csv(subcortex_label, sep='\t', header=None)
template = load_mni152_template(resolution=3)

masker = maskers.NiftiLabelsMasker(
    labels_img=subcortex,
    standardize=False,#"zscore_sample",
    standardize_confounds=True,
    memory="nilearn_cache",
    verbose=5
)

# ----------------------------------------------------------------------
#                              timeseries extraction
# ----------------------------------------------------------------------
for roi_index in np.arange(17):
    beh_fname = []
    stacked_dfs = []
    for fmri_fname in sorted(fmriprep_flist):
        
        # NOTE: load behavioral file, nifti image, fmriprep derived confound file
        sub_ind, ses_ind, run_ind = extract_meta(os.path.basename(fmri_fname))
        sub = f"sub-{sub_ind:04d}"; ses = f"ses-{ses_ind:02d}"; run = f"run-{run_ind:02d}"; 
        confounds = join(fmriprep_dir, sub, ses, 'func', f"{sub}_{ses}_task-social_acq-mb8_run-{run_ind}_desc-confounds_timeseries.tsv") #'sub-0002_ses-01_task-social_acq-mb8_run-1_desc-confounds_timeseries.tsv'
        # fmri_fname = '/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'
        beh_fname = glob.glob(join(beh_dir, sub, ses, f'{sub}_{ses}_task-cue_{run}_runtype-{runtype}_events.tsv')) #'/Users/h/Documents/projects_local/sandbox/fmriprep_bold/sub-0002_ses-01_task-cue_run-01_runtype-pain_events.tsv'
        if beh_fname != []:
            behdf = pd.read_csv(beh_fname[0], sep='\t')
            behdf['trial'] = behdf.index
            confoundsdf = pd.read_csv(confounds, sep='\t')
            atlas_label = labels.iloc[(roi_index+1)*2-2,0]
            confounds_subset = confoundsdf[['csf', 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2',
                                            'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2',
                                            'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', 
                                            'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', 
                                            'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', 
                                            'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2']]
            column_means = confounds_subset.mean()
            for column in confounds_subset.columns:
                confounds_subset[column].fillna(column_means[column], inplace=True)


            time_series = masker.fit_transform(
                fmri_fname, confounds=confounds_subset)

            output = extract_timecourse_condition_per_beh(behdf,column_name='onset03_stim', time_series=time_series.T[roi_index], prior_event_sec=-3, after_event_sec=10)
            metadf = pd.concat([behdf, pd.DataFrame(output)], axis=1)
            sub_ind, ses_ind, run_ind = extract_meta(os.path.basename(beh_fname))
            bidsdf = pd.DataFrame({'sub':[f"sub-{sub_ind:04d}"], 
                                'ses':[f"ses-{ses_ind:02d}"],
                                'run':[f"run-{run_ind:02d}"],
                                'runtype':[runtype]
                                })
            bidsmerge = pd.concat([bidsdf] * len(behdf), ignore_index=True)
            nifti_extraction = pd.concat([bidsmerge, behdf, pd.DataFrame(output)], axis=1)
            stacked_dfs.append(nifti_extraction)

    concatenated_df = pd.concat(stacked_dfs, ignore_index=True)
    concatenated_df.to_csv(join(save_dir, f"{sub}_singletrialextract-{atlas_label}.tsv"), sep='\t')
    # Sort the concatenated DataFrame based on the desired column(s)
    # sorted_df = concatenated_df.sort_values(by='column_name_to_sort')