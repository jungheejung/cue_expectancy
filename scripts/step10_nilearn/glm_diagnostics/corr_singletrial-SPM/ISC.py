# %%----------------------------------------------------------------------
#                                   libraries
# ----------------------------------------------------------------------
import os, glob, re, gzip, shutil, json
from os.path import join
import pathlib
import numpy as np
import scipy
import nilearn
from scipy import stats
from nilearn import image, plotting
import argparse
from nilearn.image import new_img_like, resample_to_img, math_img
import matplotlib.pyplot as plt
from scipy.spatial.distance import squareform
__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

"""
load nifti_masker
load numpy (it's a numpy array, averaged per subject)
get correlation and diagonal element for isc 
save as plot and nii
"""
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
npy_dir = join(main_dir, 'analysis/fmri/nilearn/deriv05_singletrialnpy')
canlab_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'
save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv07_isc'

imgfname = join(main_dir, 'analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz')
ref_img = image.load_img(imgfname)

mask = image.load_img(canlab_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii.gz')
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine=ref_img.affine, target_shape=ref_img.shape)
nifti_masker = nilearn.maskers.NiftiMasker(mask_img=mask_img, smoothing_fwhm=6,
                                            target_affine=ref_img.affine, target_shape=ref_img.shape, 
                                            memory_level=1)

x,y,z=ref_img.shape
flist = ['sub-avg_ses-avg_run-avg_event-stimulus_cuetype-high.npy', 'sub-avg_ses-avg_run-avg_event-stimulus_cuetype-low.npy']
arr = []
for fname in flist:
    data = np.load(join(npy_dir, fname))
    for index in range(data.shape[0]):

        arr.append(
            nifti_masker.fit_transform(
        new_img_like(ref_img, data[index].reshape(x,y,z)))
        )

    fmri_masked = np.vstack(arr)
    # %% 
    np.save(join(save_dir, 'masked_' + 'sub-avg_ses-avg_run-avg_event-stimulus_cuetype-high.npy'), fmri_masked)
    rowwise_corr = np.corrcoef(fmri_masked, rowvar=False, dtype=np.float32)
 
    isc = rowwise_corr[0]
    print(isc.shape)
    assert isc.shape == (98053,)
    np.save(join(save_dir, 'isc_' + os.path.splitext(os.path.basename(high_fname))[0]) + '.npy', isc) 
    singletrial_t = nifti_masker.inverse_transform(isc) 
    resampled_image = image.resample_to_img(singletrial_t, ref_img)
    plot = plotting.plot_stat_map(resampled_image,  display_mode = 'mosaic', title = f'{os.path.splitext(os.path.basename(high_fname))[0]}', cut_coords = 8)
    plot.savefig(join(save_dir ,os.path.splitext(os.path.basename(high_fname))[0] + '.png'))
    resampled_image.to_filename(join(save_dir, os.path.splitext(os.path.basename(high_fname))[0] + '.nii.gz'))
