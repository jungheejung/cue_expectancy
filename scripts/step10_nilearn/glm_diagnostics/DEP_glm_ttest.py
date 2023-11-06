"""
SPM group t-test results look different from the nilearn results
How to investigate?
1) average run-wise and ses-wise
2) stack mean images (ravel)
3) t-test
4) plot brains
"""
# %%sub_
import os, glob, re
import numpy as np
import scipy
import nilearn
import pathlib
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like


# %%0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
args = parser.parse_args()
slurm_id = args.slurm_id 

def extract_ses_and_run(flist):
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r'ses-(\d+)', path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r'run-(\d+)', path)
        if run_match:
            unique_run.add(run_match.group(0))

    # Print the unique values of 'ses' and 'run'
    print(f"Unique ses values: {sorted(unique_ses)}")
    print(f"Unique run values: {sorted(unique_run)}")
    return list(sorted(unique_ses)), list(sorted(unique_run))

# %% load participant data. average per run
# beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
# save_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv03_univariate/contrast_cuehigh-GT-cuelow'
beta_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
save_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv03_univariate/contrast_cuehigh-GT-cuelow'
sub_list = sorted(next(os.walk(beta_dir))[1])
groupmean = []; groupmeanL = []; groupmeanH = []
task = 'pain'
# %%
testlist = sub_list[slurm_id]
# %%
for sub in [testlist]:
    print(f"_____________{sub}_____________")
    flist= glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.nii.gz"))
    unique_ses, unique_run = extract_ses_and_run(flist)
    sesmean = []
    sesmean_L, sesmean_H = [], []
    for ses in unique_ses:
        # runmeans = []
        # runmean = []
        runstackL = []; runstackH = []
        for run in unique_run:
            print(run)
            runmeanimg = []
            runmeanconcat = []
            matching_files = []
            
            # newflist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stim_*_cuetype-low*.nii.gz"))
            cueL_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_cuetype-low*.nii.gz"))
            cueH_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_cuetype-high*.nii.gz"))
            print(cueL_flist)
            if len(cueL_flist) !=0:
                meanimg_L = image.mean_img(image.smooth_img(image.load_img(cueL_flist), fwhm = 6))
                meanimg_H = image.mean_img(image.smooth_img(image.load_img(cueH_flist), fwhm = 6))
                orig_shape = meanimg_L.get_fdata().shape
                # runmeanimg.append(meanimg.get_fdata().ravel())
                runstackL.append(meanimg_L)
                runstackH.append(meanimg_H)
                # runmeanimgL = image.concat_imgs([runstackL, meanimg_L])
                # meanimg_H = image.mean_img(image.smooth_img(image.load_img(cueH_flist)))
                # image.concat_imgs([runstackH, meanimg_H])
            else:
                continue
        # runmean = np.mean(runmeanimg, axis = 0 )
        print(runstackL)
        runallmeanL = image.mean_img(image.concat_imgs(runstackL))
        runallmeanH = image.mean_img(image.concat_imgs(runstackH))
        # print(f"runmean: {runmean.shape}")
        # sesmean.append(runmean)
        sesmean_L.append(runallmeanL) #image.concat_imgs([sesmean_L, runallmeanL])
        sesmean_H.append(runallmeanH) #image.concat_imgs([sesmean_H, runallmeanH])
        # print(f"sesmean: {len(sesmean)}")
    # submean = np.mean(sesmean, axis = 0 )
    submean_L = image.mean_img(image.concat_imgs(sesmean_L))
    submean_H = image.mean_img(image.concat_imgs(sesmean_H))
    nifti_path = pathlib.Path(os.path.join(save_dir, sub))
    nifti_path.mkdir(parents = True, exist_ok = True)
    submean_L.to_filename(os.path.join(save_dir, sub, f"subwise-avg_{sub}_runtype-{task}_event-stim_cuetype-low.nii.gz"))
    submean_H.to_filename(os.path.join(save_dir, sub, f"subwise-avg_{sub}_runtype-{task}_event-stim_cuetype-high.nii.gz"))
    # contrast = scipy.stats.ttest_ind(submean_H.get_fdata().ravel(), submean_L.get_fdata().ravel(),
    #                                  axis = 1, nan_policy = 'omit',alternative='two-sided' )
    # contrasts = math_img("img1 - img2", img1=submean_H, img2=resample_to_img(submean_L, submean_H))
    # contrastimg = new_img_like(meanimg_L, contrast.get_fdata())
    # contrastimg.to_filename(os.path.join(save_dir, sub, f"contrast-cuehighGTcuelow_subwise-avg_{sub}_runtype-{task}_event-stim.nii.gz"))
    
    # TODO: save intermediate step. save submean into a nii image
    # groupmeanL = image.concat_imgs(submean_L)
    # groupmeanH = image.concat_imgs(submean_H)


# %% group level t-test
subwise_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv03_univariate/contrast_cuehigh-GT-cuelow'
sub='*'
runtype='pain'
fnameL = f'subwise-avg_{sub}_runtype-{runtype}_event-stim_cuetype-low.nii.gz'
fnameH = f'subwise-avg_{sub}_runtype-{runtype}_event-stim_cuetype-high.nii.gz'
lowlist = glob.glob(os.path.join(subwise_dir, '*', fnameL))
highlist = glob.glob(os.path.join(subwise_dir, '*', fnameH))
groupmean_L = []
for lowfname in lowlist:
    submean_L = image.load_img(lowfname).get_fdata().ravel()
    groupmean_L.append(submean_L)
groupmean_H = []
for highfname in highlist:
    submean_H = image.load_img(highfname).get_fdata().ravel()
    groupmean_H.append(submean_H)
# %%
groupmean_low = np.vstack(groupmean_L)
groupmean_high = np.vstack(groupmean_H)

low_img = image.load_img(lowfname)
#  %% t-test
plotting.plot_stat_map(new_img_like(low_img, np.mean(groupmean_low, axis = 0).reshape(low_img.shape)))
plotting.plot_stat_map(new_img_like(low_img, np.mean(groupmean_high, axis = 0).reshape(low_img.shape)))
# %%
contrast = scipy.stats.ttest_ind(groupmean_low, groupmean_high,
                                     axis = 0, nan_policy = 'propagate',alternative='two-sided' )
# %%

statmap = contrast.statistic.reshape(low_img.shape)
pval = contrast.pvalue.reshape(low_img.shape)
indices = np.where(pval < 0.01)
selected_t_values = statmap[indices]
# %% canlab mask
mask = image.load_img('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = low_img.affine, target_shape = low_img.shape)
stat_img = new_img_like(low_img, statmap)
maskedstatmap = nilearn.masking.apply_mask( stat_img, mask_img)
masked_stat_img = image.math_img('img1 * img2', img1=stat_img, img2=mask_img)

# %%
plotting.plot_stat_map(masked_stat_img, threshold = 2, display_mode = 'mosaic')
# %%import scipy
# # stats, p = scipy.stats.ttest_1samp(a = np.asarray(groupmean), popmean = 0, axis = 0, nan_policy='omit', alternative = 'two-sided')
# # stats, p = scipy.stats.ttest_ind(a = np.asarray(groupmeanL),
# #                                  b = np.asarray(groupmeanH),
# #                                  axis = 0,
# #                                  nan_policy='omit', 
# #                                  alternative = 'two-sided')
# stats, p = scipy.stats.ttest_ind(a = np.asarray(groupmeanL.get_fdata()),
#                                  b = np.asarray(groupmeanH.get_fdata()),
#                                  axis = 0,
#                                  nan_policy='omit', 
#                                  alternative = 'two-sided')
# # %%
# # groupmeanimg = image.new_img_like(image.load_img(cueL_flist), 
#                                 #   np.nanmean(groupmean, axis = 0).reshape(orig_shape), affine = None, copy_header = True)
# # nilearn.plotting.plot_stat_map(groupmeanimg, threshold = 0, display_mode = "z", vmax = 1, colorbar = True)
# # %%
# p_val = 0.001
# p001_uncorrected = scipy.stats.norm.isf(p_val)
# groupmeantest = image.new_img_like(image.load_img(cueL_flist), 
#                                    stats.data.reshape(orig_shape), 
#                                    affine = None, copy_header = True)
# nilearn.plotting.plot_stat_map(groupmeantest, threshold = p001_uncorrected, display_mode = "mosaic",  colorbar = True)
# # %%


# %%
