
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
