def restructure_task_cue_beh(beh_fname):
    import pandas as pd
    import numpy as np
    beh = pd.read_csv(beh_fname, sep = '\t')

    onset01_cue = pd.DataFrame({
        'onset' : list(beh['onset01_cue']),
        'duration' : list(np.repeat(1,len(beh['onset01_cue']))),
        'trial_type' : list(np.repeat('cue',len(beh['onset01_cue']))),
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
    events_df = pd.concat([onset01_cue, onset02_expectrating, onset03_stim, onset04_outcomerating])
    events_df = events_df.reset_index(drop=True)
    return events_df