#!/usr/bin/env python
"""Creates single trial beta maps 
# order of operations 
# 0. argparse
# 0. parameters
# 1. load behavioral data and restructure for BIDS 
"""

"""NOTE: TTL2 has been creating issues. Need to use original onset time
"""
# %%
import os, re, glob
from os.path import join
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

# %%

### local
main_dir = '/Users/h/Documents/projects_local/cue_expectancy'
onset_dir = join(main_dir,'data', 'fmri', 'fmri01_onset', 'onset02_SPM' )
save_events_dir = join(main_dir,'data', 'beh', 'beh03_bids')
###
# onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM'
# save_events_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids'

sub_folders = next(os.walk(onset_dir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]

# 1. load behavioral data and restructure for BIDS  ________________________________________________________________________________
# %%1-1) load tsv file. If _ttl.tsv exists, then load that one
for sub in sub_list:
    ses_folders = next(os.walk(join(onset_dir, sub)))[1]
    ses_list = [i for i in sorted(ses_folders) if i.startswith('ses-')]
    for ses in ses_list:
        beh_list = glob.glob(os.path.join(onset_dir, sub, ses, f'{sub}_{ses}_task-cue_*runtype-*events.tsv'))

        for beh_fname in beh_list:
            run_info = [match for match in os.path.basename(beh_fname).split('_') if "run" in match][0]
            run_num = int(re.findall(r'\d+', run_info )[0].lstrip('0'))
            run_type = [match for match in os.path.basename(beh_fname).split('_') if "runtype" in match][0].split('-')[1]
            run = f"run-{run_num:02d}"
            print(f"{run_num} {run_type}")
            # 1-2) restructure for BIDS format. Columns have onset/duration/trial_type
            events_df = restructure_task_cue_beh(beh_fname)
            # TODO: later save it to source BIDS dir
            save_events_fname = f'{sub}_{ses}_task-cue_acq-mb8_{run}_runtype-{run_type}_events.tsv'
            save_events_sub_dir = os.path.join(save_events_dir, sub, ses)
            Path(save_events_sub_dir).mkdir(parents = True, exist_ok = True)
            events_df.to_csv(os.path.join(save_events_sub_dir, save_events_fname), sep='\t', index=False)
            print(events_df.head())
            # NOTE: FUTURE REFERENCE. IF YOU NEED TO FIND THE EVENTS BASED ON THE KEYWRODS
            # regex = re.compile(r'event-(.+?)_')
            # events_df.trial_type.str.extract(regex)

# %%
import os
import glob

folder_path = '/Users/h/Documents/projects_local/cue_expectancy/data/beh/beh03_bids_ttl1'

# Iterate over the folder and its subfolders
for dirpath, dirnames, filenames in os.walk(folder_path):
    # Search for .tsv files with "runtype-" keyword in the current directory
    for tsv_file in glob.glob(os.path.join(dirpath, '*runtype-*.tsv')):
        print(f"Removing: {tsv_file}")
        os.remove(tsv_file)

# %%
