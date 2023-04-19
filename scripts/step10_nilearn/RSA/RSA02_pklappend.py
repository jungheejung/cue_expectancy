from scipy.spatial.distance import pdist, squareform
from matplotlib.colors import LinearSegmentedColormap
from rsatoolbox.inference import eval_fixed
from rsatoolbox.model import ModelFixed
import rsatoolbox.rdm as rsr
import rsatoolbox.data as rsd
import rsatoolbox
import os, sys, glob, re
import pandas as pd
fmri_data = []
# load pkl
pkl_dir = "/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_rdmpkl"
flist = glob.glob(os.path.join(pkl_dir, '*', f"*.pkl"))
# fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step10_nilearn/RSA/sub-0078_ses-01_RDM.pkl'
# append with 
for fname in flist:
    obj = pd.read_pickle(fname)
    des = {'session': os.path.basename(fname).split('_')[1], 
           'subj': os.path.basename(fname).split('_')[0]}
    # rdm_pkl = rsatoolbox.data.Dataset(obj)
    # fmri_data = rsatoolbox.rdm.rdms.rdms_from_dict(obj)
    rdm_dict = rsatoolbox.data.Dataset(measurements=obj['measurements'],
                                     descriptors=des,
                                     obs_descriptors=obj['obs_descriptors'],
                                     channel_descriptors=obj['channel_descriptors'])
#     rdms_fmri = rsr.calc_rdm(rdm_dict)
    fmri_data.append(rdm_dict)

# visualize
fig, ax, ret_val = rsatoolbox.vis.show_rdm(rsr.calc_rdm(fmri_data))
fig.savefig('/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/resources/temp_rdm.png', bbox_inches='tight', dpi=300)