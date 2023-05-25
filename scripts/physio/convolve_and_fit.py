#

"""
The purposee is to model physio data just like an fMRI glm. 
Let's grab a canonical physio signal
Then, from the known onset times, we'll convolve the signals and construct a model physio signal.

"""
# %%
import matplotlib.pyplot as plt
import numpy as np
from scipy import signal
import pandas as pd
import scipy
from sklearn.linear_model import LinearRegression
# %%
physio_fname = '/Volumes/spacetop_data/physio/physio03_bids/task-cue/sub-0037/ses-01/sub-0037_ses-01_task-cue_run-04-pain_recording-ppg-eda-trigger_physio.tsv'
ttl_fname = '/Volumes/spacetop_data/physio/physio04_ttl/task-cue/sub-0037/ses-01/sub-0037_ses-01_task-cue_run-04-pain_recording-medocttl_physio.tsv'
beh_fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/sub-0037/ses-01/sub-0037_ses-01_task-social_run-04-pain_beh.csv'
physiodf = pd.read_csv(physio_fname, sep = '\t')
ttldf = pd.read_csv(ttl_fname, sep = ',')
behdf = pd.read_csv(beh_fname)
# %%
physiodf[['trigger_heat', 'physio_eda']].plot()
ttldf['ttl_2']
# pulse = np.where(y1 > y2, y1 - y2, 0)
sig = np.repeat([0., 1., 0.], 100)
win = signal.windows.hann(50)
filtered = signal.convolve(sig, win, mode='same') / sum(win)

resample_eda = scipy.signal.resample(physiodf['physio_eda'], 872)


# %%
from nilearn.glm.first_level import make_first_level_design_matrix

hrf_model = "glover"
eventdf = pd.DataFrame(
    {"trial_type": behdf['param_stimulus_type'], 
     "onset": ttldf['ttl_2']/2000, 
     "duration": np.repeat(5, len(ttldf))}
)
design_matrix = make_first_level_design_matrix(
    np.arange(872)*.46,   
    eventdf,
    hrf_model='fir',
)
# %% convolve stim intensity and plot against raw signal
from nilearn.plotting import plot_design_matrix
fig, (ax1) = plt.subplots(figsize=(10, 6), nrows=1, ncols=1)
# plot_design_matrix(design_matrix, ax=ax1)
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
#################################
# different parametric curvees for 3 levels of stim intensity
lowind = behdf[behdf['param_stimulus_type'] == 'low_stim'].index
temp = ttldf.iloc[lowind.tolist()]/2000*1/.46
total_duration = temp['ttl_3'].max()
boxcarL = np.zeros(872)
for _, row in temp.iterrows():
    start = int(row['ttl_2'])
    end = int(row['ttl_3'])
    boxcarL[start:end] = 1

medind = behdf[behdf['param_stimulus_type'] == 'med_stim'].index
temp = ttldf.iloc[medind.tolist()]/2000*1/.46
boxcarM = np.zeros(872)
for _, row in temp.iterrows():
    start = int(row['ttl_2'])
    end = int(row['ttl_3'])
    boxcarM[start:end] = 5

highind = behdf[behdf['param_stimulus_type'] == 'high_stim'].index
temp = ttldf.iloc[highind.tolist()]/2000*1/.46
boxcarH = np.zeros(872)
# Iterate over each row in the DataFrame
for _, row in temp.iterrows():
    start = int(row['ttl_2'])
    end = int(row['ttl_3'])
    boxcarH[start:end] = 9
# Print the boxcar function
# filtered_H = signal.convolve(design_matrix['high_stim_delay_0'], win, mode='same') / sum(win)
# filtered_L = signal.convolve(design_matrix['low_stim_delay_0'], win, mode='same') / sum(win)
xscaled = scaler.fit_transform(resample_eda.reshape(-1, 1))
filtered_boxcarH = signal.convolve(boxcarH, win, mode='same') / sum(win)
filtered_boxcarL = signal.convolve(boxcarL, win, mode='same') / sum(win)
filtered_boxcarM = signal.convolve(boxcarM, win, mode='same') / sum(win)

plt.plot(xscaled, label = 'source data')
plt.plot(filtered_boxcarH, label='high stim')
plt.plot(filtered_boxcarM, label='med stim')
plt.plot(filtered_boxcarL, label='low stim')
plt.legend()
plt.title('glm modeling on EDA source data', size = 20)
plt.xlabel('time (TR)')
plt.ylabel('AR')
# %% sklearn 
# sklearn.linear_model.LinearRegression()
reg = LinearRegression().fit(np.hstack([filtered_boxcarH.reshape([-1,1]),
                              filtered_boxcarM.reshape([-1,1]),
                              filtered_boxcarL.reshape([-1,1])]), xscaled)
# reg.fit(X, y)
predH = reg.predict(filtered_boxcarH.reshape([-1,1]),
                    xscaled)
# %%
from nilearn.glm.first_level import run_glm
# https://nilearn.github.io/dev/auto_examples/04_glm_first_level/plot_localizer_surface_analysis.html#sphx-glr-auto-examples-04-glm-first-level-plot-localizer-surface-analysis-py
contrast_matrix = np.eye(design_matrix.shape[1])
basic_contrasts = dict([(column, contrast_matrix[i])
                        for i, column in enumerate(design_matrix.columns)])
labels, estimates = run_glm(resample_eda.reshape(872,1), design_matrix.values)
contrasts = {'high > low': (basic_contrasts['high_stim_delay_0'] - basic_contrasts['low_stim_delay_0'])}
# first_level_model = X1.fit(physiodf[['physio_eda']], events=eventdf)

from nilearn import plotting
from nilearn.glm.contrasts import compute_contrast

for index, (contrast_id, contrast_val) in enumerate(contrasts.items()):
    print('  Contrast % i out of %i: %s, right hemisphere' %
          (index + 1, len(contrasts), contrast_id))
    # compute contrast-related statistics
    contrast = compute_contrast(labels, estimates, contrast_val,
                                contrast_type='t')
    # we present the Z-transform of the t map
# %%
import matplotlib.pyplot as plt
fig, (ax_orig, ax_win, ax_filt) = plt.subplots(3, 1, sharex=True)
ax_orig.plot(sig)
ax_orig.set_title('Original pulse')
ax_orig.margins(0, 0.1)
ax_win.plot(win)
ax_win.set_title('Filter impulse response')
ax_win.margins(0, 0.1)
ax_filt.plot(filtered)
ax_filt.set_title('Filtered signal')
ax_filt.margins(0, 0.1)
fig.tight_layout()
fig.show()
# %%
