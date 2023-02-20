# %%
import pandas as pd
from scipy import signal
import matplotlib.pyplot as plt
import numpy as np
# %% physio: load physio tsv
pname = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/physio/spacetop_fmriprep/sub-0061/ses-01/sub-0061_ses-01_task-cue_run-01-pain_recording-ppg-eda-trigger_physio.tsv'
physio = pd.read_csv(pname, sep = '\t')
physio.plot(y = "physio_eda")
len(physio)
# %% physio: down sample method 1
x = np.arange(0,872,1)
sampling_rate = 2000
fmri_rate = 1/.46
number_of_samples = round(len(physio) * float(fmri_rate) / sampling_rate)
resampled_data = signal.resample(physio["physio_eda"], number_of_samples)
resampled_ttl = signal.resample(physio["trigger_heat"], number_of_samples)
plt.plot(x,resampled_data, label = 'physio')
# %% fmriprep: plot motion covariate
fname = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/physio/spacetop_fmriprep/motion_covariates/sub-0061_ses-01_task-social_acq-mb8_run-1_desc-confounds_timeseries.tsv'
motion = pd.read_csv(fname, sep = '\t')
filter_col = [col for col in motion if col.startswith('motion')]
# combine physio info to motion df
motion['physio'] = resampled_data
motion['trigger_heat'] = resampled_ttl/40
filter_col.append('physio')
filter_col.append('trigger_heat')
plt.plot(x,motion[filter_col], alpha=0.5)

