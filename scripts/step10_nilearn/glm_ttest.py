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
from nilearn import image
from nilearn import plotting

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
beta_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
sub_list = next(os.walk(beta_dir))[1]
groupmean = []
for sub in sorted(sub_list):
    print(f"_____________{sub}_____________")
    flist= glob.glob(os.path.join(beta_dir, sub, f"{sub}_*.nii.gz"))
    unique_ses, unique_run = extract_ses_and_run(flist)
    sesmean = []
    for ses in unique_ses:
        runmeans = []
        runmean = []
        for run in unique_run:
            print(run)
            runmeanimg = []
            runmeanconcat = []
            matching_files = []
            newflist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*.nii.gz"))
            if len(newflist) !=0:
                # for file in flist:
                    # if ses in file and run in file
                # matching_files.append(newflist)
                brain = image.load_img(newflist)
                meanimg = image.mean_img(brain)
                orig_shape = meanimg.get_fdata().shape
                runmeanimg.append(meanimg.get_fdata().ravel())
                image.concat_imgs([runmeanconcat, meanimg])
                
            else:
                continue
        runmean = np.mean(runmeanimg, axis = 0 )
        runmeans = image.mean_img(runmeanconcat)
        print(f"runmean: {runmean.shape}")
        sesmean.append(runmean)
        print(f"sesmean: {len(sesmean)}")
    submean = np.mean(sesmean, axis = 0 )
    # TODO: save intermediate step. save submean into a nii image
    groupmean.append(submean)




# %% t-test
import scipy
stats, p = scipy.stats.ttest_1samp(a = np.asarray(groupmean), popmean = 0, axis = 0, nan_policy='omit', alternative = 'two-sided')

# %%
groupmeanimg = image.new_img_like(brain, np.nanmean(groupmean, axis = 0).reshape(orig_shape), affine = None, copy_header = True)
nilearn.plotting.plot_stat_map(groupmeanimg, threshold = 0, display_mode = "z", vmax = 1, colorbar = True)
# %%
p_val = 0.001
p001_uncorrected = scipy.stats.norm.isf(p_val)
groupmeantest = image.new_img_like(brain, stats.data.reshape(orig_shape), affine = None, copy_header = True)
nilearn.plotting.plot_stat_map(groupmeantest, threshold = p001_uncorrected, display_mode = "mosaic",  colorbar = True)
# %%
