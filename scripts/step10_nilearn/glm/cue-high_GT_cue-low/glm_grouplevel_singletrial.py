  
# TODO: save intermediate step. save submean into a nii image
# %%
import glob, os
import numpy as np
from nilearn import image
import scipy
from nilearn import plotting
# %%
group_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv03_univariate/contrast_cuehigh-GT-cuelow/'
grouplist = []
sub_list = sorted(next(os.walk(group_dir))[1])
for sub in sub_list:
    print(sub)
    subflist = glob.glob(os.path.join(group_dir, sub, f'contrast-cuehighGTcuelow_subwise-avg_{sub}_runtype-pain_event-stim.nii.gz'))
    if len(subflist) != 0:
        grouplist.append(subflist)

# %%
group_image = image.concat_imgs(grouplist)


# %%
scipy.stats.ttest_1samp(group_image.get_fdata(), 
                        popmean = 0, 
                        axis=0, nan_policy='omit', alternative='two-sided')



# %% t-test
import scipy
# stats, p = scipy.stats.ttest_1samp(a = np.asarray(groupmean), popmean = 0, axis = 0, nan_policy='omit', alternative = 'two-sided')
# stats, p = scipy.stats.ttest_ind(a = np.asarray(groupmeanL),
#                                  b = np.asarray(groupmeanH),
#                                  axis = 0,
#                                  nan_policy='omit', 
#                                  alternative = 'two-sided')
stats, p = scipy.stats.ttest_ind(a = np.asarray(groupmeanL.get_fdata()),
                                 b = np.asarray(groupmeanH.get_fdata()),
                                 axis = 0,
                                 nan_policy='omit', 
                                 alternative = 'two-sided')
# %%
# groupmeanimg = image.new_img_like(image.load_img(cueL_flist), 
                                #   np.nanmean(groupmean, axis = 0).reshape(orig_shape), affine = None, copy_header = True)
# nilearn.plotting.plot_stat_map(groupmeanimg, threshold = 0, display_mode = "z", vmax = 1, colorbar = True)
# %%
p_val = 0.001
p001_uncorrected = scipy.stats.norm.isf(p_val)
groupmeantest = image.new_img_like(image.load_img(cueL_flist), 
                                   stats.data.reshape(orig_shape), 
                                   affine = None, copy_header = True)
nilearn.plotting.plot_stat_map(groupmeantest, threshold = p001_uncorrected, display_mode = "mosaic",  colorbar = True)
# %%