#
from nilearn import image
import glob
import nilearn
import nibabel as nib
import numpy as np
from nilearn.input_data import NiftiMasker


# helpful resources:
# https://neurostars.org/t/niftimasker-in-niilearn/6703/4
# 
img_4d = []
stim = glob.glob('/Users/h/Dropbox/test_social/sub-01/*stim*.nii')
for img in sorted(stim):
    # print(img)
    # single_nii = nilearn.image.load_img(img)
    mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii'
    single_nii = nib.load(img)
    # nilearn.image.concat_imgs
    # nifti_masker = NiftiMasker(mask_img=None,mask_strategy='epi',
    #                        standardize=False, memory='nilearn_cache',
    #                        memory_level=1)
    # fmri_masked = nifti_masker.fit_transform(single_nii)
    a = np.array(single_nii.dataobj)
    # a.flatten()
    img_4d.append(a)
    # new_arr = a.reshape(73*86*73,)
    # img_4d = nilearn.image.concat_imgs([img_4d, single_nii])
# a=np.concatenate(1)
# 
# final = np.vstack(img_4d)
final = np.stack(img_4d, axis = -1)
clipped_img = nib.Nifti1Image(final, single_nii.affine, single_nii.header)
clipped_img.to_filename('./concat_single_trial_sub-01.nii.gz')


# nilearn.image.concat_imgs()
# 
