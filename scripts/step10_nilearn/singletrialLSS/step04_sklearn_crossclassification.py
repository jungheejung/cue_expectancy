from sklearn.linear_model import LassoCV
from sklearn.metrics import r2_score, accuracy_score
import numpy as np
from nilearn import image
from nilearn import plotting
import os, glob
from sklearn import svm
import numpy as np
from sklearn.model_selection import KFold, GroupKFold, LeavePGroupsOut, PredefinedSplit

def get_Xdata(singletrial_dir,sub_list, runtype, event, ntrials):
    X = np.empty((458294, 0), float)
    for sub in sub_list:
        print(sub)
        highcuelist = []; lowcuelist = []
        highcuelist = glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-high*.nii.gz'))
        lowcuelist = glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-low*.nii.gz'))
        assert len(highcuelist) == len(lowcuelist) == ntrials
        
        print(highcuelist)
        hlist = sorted(highcuelist);    llist = sorted(lowcuelist)
        stacked_highcue = image.concat_imgs(sorted(hlist));    stacked_lowcue = image.concat_imgs(sorted(llist))
        img_shape = stacked_highcue.get_fdata().shape
        voxellength = img_shape[0] * img_shape[1] * img_shape[2]
        subwise_highcue = stacked_highcue.get_fdata().reshape(voxellength, 36)
        subwise_lowcue = stacked_lowcue.get_fdata().reshape(voxellength, 36)
        subwise_cue = np.hstack((subwise_highcue, subwise_lowcue))
        X = np.append(X, subwise_cue, axis=1)
        print(X.shape)
    assert X.shape[1] == len(sub_list)*ntrials*2
    return X

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
# 4,5,6,9,10, 34
sub_list = [  18, 25, 29, 31, 32, 33, 34, 36, 37, 38, 39, 43, 44, 46, 50, 51, 52, 53, 55,
            56, 57, 58, 60, 61, 62, 65, 73, 78, 80, 81, 86, 87, 90, 91, 92, 93, 94, 95, 98, 99, 100, 
            101, 102, 104, 105, 106, 107, 109, 115, 116, 122, 124, 126, 127, 128, 129, 130, 132, 133]
N = len(sub_list)
y = np.tile(np.repeat(['high', 'low'], ntrials), N) # high cue, low cue
X_pain = get_Xdata(singletrial_dir, sub_list, runtype = 'pain', event='stimulus', ntrials=36)
X_cognitive = get_Xdata(singletrial_dir, sub_list, runtype = 'cognitive', event='stimulus', ntrials=36)

# X, y should be identical for both pain and cognitive
# X = brain_maps # (conditions x subjects) x voxels . 2d (72 x subject) x voxel # NOTE: I could also average within conditions

subjects = np.repeat(np.arange(N), ntrials*2)
assert len(y) == len(subjects) 
cv = PredefinedSplit(subjects)
accuracy_total = []
for train_index, test_index in cv.split(X, y):
    clf = svm.SVC()
    clf.fit(X_pain[train_index], y[train_index])
    y_pred = clf.predict(X_cognitive[test_index])
    acc = accuracy_score(y[test_index], y_pred)
    accuracy_total.append(acc)
print(accuracy_total)

    # print(f"Fold {i}:")
    # print(f"  Train: index={train_index}")
    # print(f"  Test:  index={test_index}")
# TODO:
# permutation labels
# boot strap accuracy

<<<<<<< HEAD
r2_score(y, y_pred)
=======
>>>>>>> 8601f627b3fe4fc8073bc8b9f6e7444a768824b4
