# %%

import numpy as np
from nilearn import image, masking, plotting
import os, glob
from sklearn import svm
from sklearn.model_selection import KFold, GroupKFold, LeavePGroupsOut, PredefinedSplit
from sklearn.linear_model import LassoCV
from sklearn.metrics import r2_score, accuracy_score

############ schaefer 2018
    # from nilearn import datasets
    # from nilearn.maskers import NiftiLabelsMasker
    # dataset = datasets.fetch_atlas_schaefer_2018()
    # atlas_filename = dataset.maps
    # # labels = dataset.labels
    # labels = np.insert(dataset.labels, 0, 'Background')
    # masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
    #                         memory='nilearn_cache', verbose=5)
    # if atlas == True: 
    #     arr = np.empty((0, len(dataset['labels'])), int)  
    # elif atlas == False:
    #     get_shape = glob.glob(os.path.join(
    #             singletrial_dir, sub, f'{sub}_{ses}_run-01_runtype-*_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz'))
    #     get_shape_data = image.mean_img(image.concat_imgs(get_shape)).get_fdata().ravel()
    #     arr = np.empty((0, get_shape_data.shape[0]), int)
    # 
############

############# subcortical mask
# subcortical 
##############

def get_Xdata(singletrial_dir, sub_list, runtype, event, ntrials, mask_fname):
    # TODO: use a generic brain mask and discard voxels that are outside of the brain
    # resample. nearest neighbors
    # nimg.get_fdata()[gm_mask]
    # niftimasker
    graymattermask = image.load_img(mask_fname)
    target_singletrial =  image.concat_imgs(glob.glob(os.path.join(singletrial_dir, f'sub-{sub_list[0]:04d}',
                      f'sub-{sub_list[0]:04d}_*_runtype-pain_event-stimulus*_cuetype-high*.nii.gz')))
    resampled_mask = image.resample_img(graymattermask,
                                   target_affine=target_singletrial.affine,
                                   target_shape=target_singletrial.shape[0:3],
                                   interpolation='nearest')
    mask_bool = np.array(resampled_mask.get_fdata(), dtype = bool)
    mask = image.new_img_like(target_singletrial, mask_bool.astype(int))
    X = np.empty((0, int(np.sum(mask.get_fdata()))), float)
    for sub in sub_list:
        print(sub)
        highcuelist = []; lowcuelist = []
        highcuelist = glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-high*.nii.gz'))
        lowcuelist = glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-low*.nii.gz'))
        print(sub, len(highcuelist), len(lowcuelist))
        assert len(highcuelist) == len(lowcuelist) == ntrials  
        # print(highcuelist)
        hlist = sorted(highcuelist);    llist = sorted(lowcuelist)
        stacked_highcue = image.concat_imgs(sorted(hlist));    stacked_lowcue = image.concat_imgs(sorted(llist))
        masked_high = masking.apply_mask(stacked_highcue, mask, dtype='f', smoothing_fwhm=None, ensure_finite=True)
        masked_low = masking.apply_mask(stacked_lowcue, mask, dtype='f', smoothing_fwhm=None, ensure_finite=True)
        # img_shape = masked_high.shape
        # voxellength = img_shape[0] * img_shape[1] * img_shape[2]
        # subwise_highcue = masked_high.get_fdata().reshape(voxellength, 36)
        # subwise_lowcue = masked_low.get_fdata().reshape(voxellength, 36)
        # subwise_cue = np.hstack((subwise_highcue, subwise_lowcue))
        subwise_cue = np.vstack((masked_high, masked_low))
        X = np.append(X, subwise_cue, axis=0)
        print(X.shape)
    assert X.shape[0] == len(sub_list)*ntrials*2
    return X.T, hlist, llist
    ####################### check alignment between single trial and graymatter mask
    # display = plotting.plot_stat_map(image.mean_img(target_singletrial),display_mode='mosaic',
    #                    cut_coords=(5, 4, 10),
    #                    title="display_mode='z', cut_coords=5")
    # display.add_overlay(mask,cmap=plotting.cm.purple_green)
    ############################################################################################
    ####################### convert back to brain ##############################################
    # import nibabel as nib
    # new_image = nib.Nifti1Image(
    #     np.zeros_like(target_singletrial.get_fdata()), 
    #     target_singletrial.affine, 
    #     header=target_singletrial.header)

    # new_image_data = new_image.get_fdata()
    # new_image_data[mask_bool] = masked_single.T
    # new_image = nib.Nifti1Image(
    #     new_image_data,
    # target_singletrial.affine, 
    # header=target_singletrial.header)
    # plotting.plot_stat_map(image.mean_img(X),display_mode='mosaic',
    #                    cut_coords=(5, 4, 10),
    #                    title="display_mode='z', cut_coords=5")
    ############################################################################################


# %% ver1
"""
Version 1 doesn't work. 
 Cannot have number of splits n_splits=100 greater than the number of groups: 2.

N = 100
ntrials = 36
y = np.tile(np.tile(np.repeat(['high', 'low'], ntrials), N), 2)# high cue, low cue
X = np.random.randn(len(y))
subjects = np.tile(np.repeat(np.arange(N), ntrials*2), 2)
groups = np.repeat(['pain', 'cognitive'], N*ntrials*2)
assert len(y) == len(subjects) == len(groups)
# group_kfold = GroupKFold(n_splits=N)
group_kfold = LeavePGroupsOut(n_groups=N)
for i, (train_index, test_index) in enumerate(group_kfold.split(X, y, groups)):
    print(f"Fold {i}:")
    print(f"  Train: index={train_index}, group={groups[train_index]}")
    print(f"  Test:  index={test_index}, group={groups[test_index]}")
"""


# %% ver 2 # predefined split
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
#stack high from first participants, stack low from first participant
# test partiicpants: "sub-0034", "sub-0036", "sub-0037", "sub-0061", "sub-0062"
runtype = 'pain'
event = 'stimulus'
ntrials = 36 # average maps

sub_list = [  18, 25, 29, 31] 
#32, 33, 34, 36, 37, 38, 39, 43, 44, 46, 50, 51, 52, 53, 55,
            # 56, 57, 58, 60, 61, 62, 65, 73, 78, 80, 81, 86, 87, 90, 91, 92, 93, 94, 95, 98, 99, 100, 
            # 101, 102, 104, 105, 106, 107, 109, 115, 116, 122, 124, 126, 127, 128, 129, 130, 132, 133]
N = len(sub_list)
y = np.tile(np.repeat(['high', 'low'], ntrials), N) # high cue, low cue

mask_fname = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii.gz'
X_pain, painhighlist, painlowlist = get_Xdata(singletrial_dir, sub_list, runtype = 'pain', event='stimulus', ntrials=36, mask_fname = mask_fname)
X_cognitive, coghighlist, coglowlist = get_Xdata(singletrial_dir, sub_list, runtype = 'cognitive', event='stimulus', ntrials=36, mask_fname = mask_fname)

# X, y should be identical for both pain and cognitive
# X = brain_maps # (conditions x subjects) x voxels . 2d (72 x subject) x voxel # NOTE: I could also average within conditions
# %%
# Here is a brief explanation of what the code is doing:

# The subjects array is created by repeating the numbers from 0 to N-1, ntrials*2 times each. This creates an array of indices that will be used to split the data into train and test sets.
# The assert statement checks that the length of the target variable y is the same as the length of the subjects array. This ensures that each sample is associated with a subject.
# The PredefinedSplit() function is used to create the cross-validation object cv, which will generate the train-test splits according to the subjects array.
# Two empty lists, accuracy_cognitive and accuracy_pain, are created to store the accuracy scores for each fold of cross-validation.
# The for loop iterates over the train and test indices generated by cv.split(). In each iteration, a support vector machine (SVM) classifier is trained on the training data and then used to predict the target variable for the test data.
# The accuracy_score() function is used to compute the accuracy of the predictions, and the resulting score is appended to either the accuracy_cognitive or accuracy_pain list, depending on which type of data was being predicted.
# After all iterations of the for loop, the mean accuracy scores for cognitive and pain data are printed out.
# Overall, the code looks correct, and should perform PredefinedSplit cross-validation to generate predictions of y_cog and y_pain, and then calculate the accuracy of those predictions.
subjects = np.repeat(np.arange(N), ntrials*2)
assert len(y) == len(subjects) 
cv = PredefinedSplit(subjects)
accuracy_cognitive = []
accuracy_pain = []
for train_index, test_index in cv.split(X_pain, y):
    clf = svm.SVC()
    clf.fit(X_pain.T[train_index], y[train_index])
    y_cog = clf.predict(X_cognitive.T[test_index])
    acc_cog = accuracy_score(y[test_index], y_cog)
    accuracy_cognitive.append(acc_cog)

    y_pain = clf.predict(X_pain.T[test_index])
    acc_pain = accuracy_score(y[test_index], y_pain)
    accuracy_pain.append(acc_pain)
print(f"cognitive: {accuracy_cognitive}, pain: {accuracy_pain}")

    # print(f"Fold {i}:")
    # print(f"  Train: index={train_index}")
    # print(f"  Test:  index={test_index}")
# TODO:
# permutation labels
# boot strap accuracy


# %%