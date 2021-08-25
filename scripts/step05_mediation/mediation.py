# %%
"""
The purpose of this script is multi-path mediation analyses on beta maps. 

1st path: Find M2
input: 
    - a: contrast map that serves as mediator (e.g. shape (15, 458295))
    - b: contrast map that serves as outcome map (e.g. shape (15, 458295))

    1. With these two 1st level contrast maps -- a & b -- we calculate the mediation map by ...
    using the hadamard product, i.e. element wise product of map a * b. (e.g. shape (15, 458295))
    2. From this, we average across the brain voxels and derive one scalar per participant. (e.g. shape (15, 1))

output: 
    - M2 scalar values per participant


2nd path: Find M1
input: 
    - X: cue effect beta coefficient (random slopes per participant)
    - M: search for M1  
    - Y: M2 scalar values derived from 1st path
"""
# load libraries
import os
from pathlib import Path
import nibabel as nib
import numpy as np
from nilearn import image


# def _prepare_m2(sub_list, con_num, path_dir):
#     fmri_concat = None
#     for sub in sub_list:
#         con_fname = os.path.join(path_dir, 'sub-{0}'.format(str(sub).zfill(4)), 'con_{0}.nii'.format(str(con_num).zfill(4)))
#         con = nib.load(con_fname)
#         con_f = np.array(con.get_fdata().flatten())
#         if fmri_concat is None:
#             fmri_concat = con_f
#         else:
#             fmri_concat = np.vstack([fmri_concat, con_f])
#     del con, con_f
#     return fmri_concat


# %% 
# directories

cwd = os.getcwd() # top > scrtips > step05_mediation
top_dir = Path(__file__).parents[2]
top_dir = '/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop/social'
model_dir = os.path.join(top_dir, 'analysis', 'fmri', 'spm', 'model-01_CcEScaA')

con1_path_dir = os.path.join(top_dir, 'analysis', 'fmri', 'spm',  'model-01_CcEScaA', '1stLevel')
con2_path_dir = os.path.join(top_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model-02_CcEScA', '1stLevel')
# con_dir = os.path.join()
sublist = [3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29]
# %%
# Step 1 __________________________________________________
# format X, M, Y
# first mediation: M will be stimulus phase contrast
# Y will be actual behavioral rating

# con-12_stimXcue_G * con-16_stimXactual_G
# def _prepare_m2(sub_list):
    # list of all subjects 
    # load con 12 
    # load con 16

    # average across data

def _prepare_m2_con(sub, con_num, path_dir):
    # fmri_concat = None
    con_fname = os.path.join(path_dir, 'sub-{0}'.format(str(sub).zfill(4)), 'con_{0}.nii'.format(str(con_num).zfill(4)))
    con = nib.load(con_fname)
    con_f = np.array(con.get_fdata().flatten())
    del con_fname
    return con, con_f

def _multiply_save():
    #multiply
    #save
    return
# x-cue_m-stim_y-actual
# %%
x = [(27,34, 'pain'), (28,35, 'vicarious'), (29,36, 'cognitive')]
for sub in sublist:
    for a, b, c in x:
        original, con1 = _prepare_m2_con(sub, a, con1_path_dir)
        original, con2 = _prepare_m2_con(sub, b, con2_path_dir)

        # %%
        # a*b = hadamard product (element-wise multiplication) of two beta maps
        ab = np.multiply(con1, con2)
        ab.shape
        ab_nii = image.new_img_like(original, ab)
        new_dir = os.path.join(top_dir, 'analysis', 'fmri', 'spm', 'univariate', 'mediation_ab', 'med_X-cue_M-stim_Y-actual', c, '1stLevel')
        Path(new_dir).mkdir(parents=True, exist_ok=True)
        fname = 'sub-{0}_ab_con{1}Xcon{2}_{3}.nii'.format( str(sub).zfill(4), str(a).zfill(2), str(b).zfill(2) , str(c) )
        ab_nii.to_filename(os.path.join(new_dir,fname))

        # TODO: save file into nifti and do a t-test


# % second mediation: M will be expectation phase contrast
# % recovered M from first mediation will serve as Y

# for every columns of voxel 
# calculate path ab for X - M - Y
# save p value for voxel
# threshold it 
# find voxel indices and plot
