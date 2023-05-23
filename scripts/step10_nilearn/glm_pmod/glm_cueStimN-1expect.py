# model onset
# pmod
# % PARAMETERS
# %     - CUE
# %     - EXPECT
# %     - STIM
# %     - STIM x cue
#       - STIM x intensity
#       - STIM x N-1 outcome rating
# %     - ACTUAL
    """
    Goal of this script is to create a parametric model 
    with (N-1) expectation ratings from past trials. 
    Another is to create a model with expectation ratings in the univariate model
    
    """

https://neurostars.org/t/parametric-modulation-in-nistats/3392/2

from nistats.design_matrix import make_first_level_design_matrix
import numpy as np

n_scans = 200
tr = 2.
frame_times = np.arange(n_scans) * tr

# assuming you have onset, duration, trial_type, and modulation columns
# mean-center modulation to orthogonalize w.r.t. main effect of condition
events['modulation'] = events['modulation'] - events['modulation'].mean()

# create design matrix with modulation
dm_pm = make_first_level_design_matrix(
    frame_times,
    events,
    )

# remove modulation column
events = events[['onset', 'duration', 'trial_type']]

# create normal design matrix with modulation column added
# this assumes that you have one trial type (trial_type), so
# you'll need to edit the regs and names if not
dm = make_first_level_design_matrix(
    frame_times,
    events,
    add_regs=dm_pm[['trial_type']],
    add_reg_names=['modulator*trial_type'],
    )