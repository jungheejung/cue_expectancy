# %%
import json
import numpy as np
from nilearn import image, masking, plotting
import os, glob, re
from os.path import join
from sklearn import svm
from sklearn.model_selection import KFold, GroupKFold, LeavePGroupsOut, PredefinedSplit, GridSearchCV
from sklearn.linear_model import LassoCV
from sklearn.metrics import r2_score, accuracy_score
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import pandas as pd
import matplotlib.pyplot as plt
import h5py
import argparse


def json_extractbids(badruns_fname):
    with open(badruns_fname, "r") as json_file:
        bad_dict = json.load(json_file)
        subs = [];  ses = [];   runs = [];

        for key, valuelist in bad_dict.items():
            sub = int(key.split('-')[1])
            for value in valuelist:
            
                ses_value = int(value.split('_')[0].split('-')[1])
                run = int(value.split('_')[1].split('-')[1])
                subs.append(sub);   ses.append(ses_value);  runs.append(run)

        # Create DataFrame
        df = pd.DataFrame({
            'sub': subs,
            'ses': ses,
            'run': runs
        })
    return df

def filter_good_data(filenames, baddata_df):
    """
    Args:
        filenames (list): list of single trial file names
        baddata_df: (pd.dataframe): loaded from bad data json, converted as pandas 

    Returns:
        good_data (pd.DataFrame): dataframe, excluding bad data sub/ses/run 
    """
    # Create DataFrame from filenames
    df = pd.DataFrame({'filename': filenames})
    
    # Extract sub, ses, run from the filenames
    df['sub'] = df['filename'].str.extract(r'sub-(\d+)')
    df['ses'] = df['filename'].str.extract(r'ses-(\d+)')
    df['run'] = df['filename'].str.extract(r'run-(\d+)')
    
    # Convert the columns to numeric
    df['sub'] = pd.to_numeric(df['sub'])
    df['ses'] = pd.to_numeric(df['ses'])
    df['run'] = pd.to_numeric(df['run'])
    
    # Merge with index DataFrame and filter good data
    merged = df.merge(baddata_df, on=['sub', 'ses', 'run'], how='left', indicator=True)
    good_data = merged[merged['_merge'] != 'both']
    good_data = good_data.drop('_merge', axis=1)
    
    return good_data

def get_Xdata(singletrial_dir, sub_list, runtype, event, mask_fname, badruns_fname):

    # if sub_list is empty, grab every data in the singletrial_dir
    if not sub_list:
        sub_folders = next(os.walk(singletrial_dir))[1]
        sub_bids_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
        sub_list = [int(re.findall(r'\d+', item)[0].lstrip('0')) for item in sub_bids_list]
    print(sub_list)

    # apply graymatter mask to single trial data
    graymattermask = image.load_img(mask_fname)
    target_singletrial =  image.concat_imgs(
        glob.glob(os.path.join(singletrial_dir, f'sub-{sub_list[0]:04d}',
                      f'sub-{sub_list[0]:04d}_*_runtype-pain_event-stimulus*_cuetype-high*.nii.gz')))
    resampled_mask = image.resample_img(graymattermask,
                                   target_affine=target_singletrial.affine,
                                   target_shape=target_singletrial.shape[0:3],
                                   interpolation='nearest')
    mask_bool = np.array(resampled_mask.get_fdata(), dtype = bool)
    mask = image.new_img_like(target_singletrial, mask_bool.astype(int))
    X = np.empty((0, int(np.sum(mask.get_fdata()))), float)

    gooddata_high_concat = pd.DataFrame()
    gooddata_low_concat = pd.DataFrame()
    gooddata_highdf= pd.DataFrame()
    gooddata_lowdf= pd.DataFrame()
    gooddatadf = pd.DataFrame()

    for sub in sub_list:
        print(sub)
        highcuelist = []; lowcuelist = []
        highcuelist = sorted(glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-high*.nii.gz')))
        lowcuelist = sorted(glob.glob(os.path.join(singletrial_dir, f'sub-{sub:04d}',
                      f'sub-{sub:04d}_*_runtype-{runtype}_event-{event}*_cuetype-low*.nii.gz')))
        if highcuelist and lowcuelist:
        # exclude bad data _____________________
            baddf = json_extractbids(badruns_fname)
            gooddata_high = filter_good_data(highcuelist, baddf)
            gooddata_low = filter_good_data(lowcuelist, baddf)
            print(gooddata_high)
            gooddata_high_concat = pd.concat([gooddata_high_concat, pd.DataFrame(gooddata_high)], axis = 0, ignore_index=True)
            gooddata_low_concat = pd.concat([gooddata_low_concat, pd.DataFrame(gooddata_low)],axis = 0,  ignore_index=True)#gooddata_low_concat.append(gooddata_low)
            print(f"subject id: {sub}, number of high cues: {len(gooddata_high.filename)}, number of low cues: {len(gooddata_low.filename)}")
            assert len(gooddata_high) == len(gooddata_low) # == ntrials  
            hlist = sorted(gooddata_high.filename);    llist = sorted(gooddata_low.filename)
            stacked_highcue = image.concat_imgs(sorted(hlist));    stacked_lowcue = image.concat_imgs(sorted(llist))
            masked_high = masking.apply_mask(stacked_highcue, mask, dtype='f', smoothing_fwhm=None, ensure_finite=True)
            masked_low = masking.apply_mask(stacked_lowcue, mask, dtype='f', smoothing_fwhm=None, ensure_finite=True)
            subwise_cue = np.vstack((masked_high, masked_low))
            X = np.append(X, subwise_cue, axis=0)
            print(X.shape)
        else:
            continue
    gooddata_highdf = pd.concat([gooddata_highdf, gooddata_high_concat], ignore_index=True)
    gooddata_lowdf = pd.concat([gooddata_lowdf, gooddata_low_concat], ignore_index=True)
    gooddatadf = pd.concat([gooddata_highdf, gooddata_lowdf], ignore_index=True)

    return X, gooddatadf #gooddata_highdf, gooddata_lowdf

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

# ----------------------------------------------------------------------
#                               argparse
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
parser.add_argument("--maindir", type=str,
                    help="specify slurm array id")
parser.add_argument("--singletrialdir", type=str,
                    help="specify slurm array id")
parser.add_argument("--outputdir", type=str,
                    help="specify slurm array id")
parser.add_argument("--canlabcoredir", type=str,
                    help="specify slurm array id")
args = parser.parse_args()

slurm_id = args.slurm_id # e.g. 1, 2
main_dir = args.maindir
singletrial_dir = args.singletrialdir 
output_dir = args.outputdir 
canlabcore_dir = args.canlabcoredir
print(args.slurm_id)

# ----------------------------------------------------------------------
#                               paramters
# ----------------------------------------------------------------------
main_dir = '/Volumes/spacetop_projects_cue/'
singletrial_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial')
output_dir = '/Users/h/Desktop'
canlabcore_dir = '/Users/h/Documents/MATLAB/CanlabCore'
runtype = 'pain'
event = 'stimulus'
sub_list = [] 
badruns_fname = join(main_dir,'scripts', 'step00_qc', 'qc03_fmriprep_visualize', 'bad_runs.json' )

# ----------------------------------------------------------------------
#                               fetch data
# ----------------------------------------------------------------------
N = len(sub_list)
mask_fname = join(canlabcore_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii.gz')
X_painstim, paindf = get_Xdata(singletrial_dir, sub_list = sub_list, runtype = 'pain', event='stimulus', mask_fname = mask_fname, badruns_fname = badruns_fname)
X_cognitive, cogdf = get_Xdata(singletrial_dir, sub_list = sub_list, runtype = 'cognitive', event='stimulus', mask_fname = mask_fname, badruns_fname = badruns_fname)

# extract metadata from filenames
pattern = r'sub-(\d+)_ses-(\d+)_run-(\d+)_runtype-(\w+)_event-(\w+)_trial-(\d+)_cuetype-(\w+)_stimintensity-(\w+)\.nii\.gz'
keywords = paindf['filename'].str.extract(pattern)
keywords.columns = ['sub', 'ses', 'run', 'runtype', 'event', 'trial', 'cuetype', 'stimintensity']
paindf_meta = keywords.apply(lambda x: x.str.lstrip('0'))

# pattern = r'sub-(\d+)_ses-(\d+)_run-(\d+)_runtype-(\w+)_event-(\w+)_trial-(\d+)_cuetype-(\w+)_stimintensity-(\w+)\.nii\.gz'
keywords_cogh = cogdf['filename'].str.extract(pattern)
keywords_cogh.columns = ['sub', 'ses', 'run', 'runtype', 'event', 'trial', 'cuetype', 'stimintensity']
cogdf_meta = keywords_cogh.apply(lambda x: x.str.lstrip('0'))

# ----------------------------------------------------------------------
#                               save data
# ----------------------------------------------------------------------

with h5py.File(join(output_dir, 'task-pain_event-stimulus.h5'), 'w') as f:
    f.create_dataset('data', data=X_painstim)
paindf_meta.to_csv(join(output_dir, 'task-pain_event-stimulus.csv'))
# Load the saved array
with h5py.File(join(output_dir, 'task-pain_event-stimulus.h5'), 'r') as f:
    X_painstim = f['data'][:]

# save data 
with h5py.File(join(output_dir, 'task-cognitive_event-stimulus.h5'), 'w') as f:
    f.create_dataset('data', data=X_cognitive)
cogdf_meta.to_csv(join(output_dir, 'task-cognitive_event-stimulus.csv'))
# Load the saved array
with h5py.File(join(output_dir, 'task-cognitive_event-stimulus.h5'), 'r') as f:
    X_cognitive = f['data'][:]

print(f"{X_painstim.shape}")
print(f"{X_cognitive.shape}")# X, y should be identical for both pain and cognitive
# X = brain_maps # (conditions x subjects) x voxels . 2d (72 x subject) x voxel # NOTE: I could also average within conditions

# ======= NOTE: grab intersection of subjects in pain and cognitive
pdf = paindf_meta.copy()
cdf = cogdf_meta.copy()
pdf = pdf[pdf['sub'].isin(cdf['sub'])]
cdf = cdf[cdf['sub'].isin(pdf['sub'])]

X_pain = X_painstim[pdf.index]
X_cog = X_cognitive[cdf.index]
y = paindf_meta.loc[pdf.index, 'cuetype']
y_cog = cogdf_meta.loc[cdf.index, 'cuetype']
print(f"after balancing: \n * pain run: {X_pain.shape} \n * cog run: {X_cog.shape}")

# ----------------------------------------------------------------------
#                               k fold
# ----------------------------------------------------------------------

group_kfold = GroupKFold(n_splits=5)

subjects = pd.factorize(pdf['sub'])[0]
subjects_cog = pd.factorize(cdf['sub'])[0]

cv = PredefinedSplit(subjects)
accuracy_cognitive = []
accuracy_pain = []
group_kfold = GroupKFold(n_splits=5)

group_kfold.get_n_splits(X_pain, y, subjects)
for i, (train_index, test_index) in enumerate(group_kfold.split(X_pain, y, subjects)):
# for train_index, test_index in cv.split(X_pain, y):
    train_index_cog = np.where(np.isin(subjects_cog, np.unique(subjects[train_index])))[0]
    test_index_cog = np.where(np.isin(subjects_cog, np.unique(subjects[test_index])))[0]
    # NOTE: scaling standard scalar. .fit_transform(X_train) -> mean/sd of the transformed data__________________________________________
    scaler = StandardScaler() # TODO: standard scalar. .fit_transform(X_train) -> mean/sd of the transformed data
    X_pain_train = scaler.fit_transform(X_pain[train_index]) # z-score on the samples
    X_pain_test = scaler.transform(X_pain[test_index])
    X_cog_test = scaler.transform(X_cog[test_index_cog])
    # NOTE:  # 2) PCA in this loop - 80000 features-> 90% of the variance 
    pca = PCA(n_components=.9)
    X_pain_train = pca.fit_transform(X_pain[train_index])
    X_pain_test = pca.transform(X_pain[test_index])
    X_cog_test = pca.transform(X_cog[test_index_cog])
    print(f'number of PCs = {X_pain_train.shape[1]}')

    # 1) inner loop and grid search for hyperparameter C. 
    exponents = np.array([-3, -2, -1, 0, 1, 2, 3])
    Cs = np.exp(exponents)
    inner_cv = PredefinedSplit(subjects[train_index])
    grid_search = GridSearchCV(svm.LinearSVC(class_weight='balanced'), {'C': Cs}, cv=inner_cv)
    grid_search.fit(X_pain_train, y.iloc[train_index].values)
    C = grid_search.best_params_['C']
    #### snaglab meeting ####
    # TODO: find the model in grid_search and use it to predict X_cog_test
    # TODO: use group k fold
# you wouldn't want to fit a new model with the cognitive data
# you would want to fit the best model on pain and see if you can use that to predict cognitive
clf = svm.LinearSVC(class_weight = 'balanced', C = C) 
# clf.fit(X_pain, y)
clf.fit(X_pain_test, y.iloc[test_index].values)
pred_cog = clf.predict(X_cog_test) 
acc_cog = accuracy_score(y_cog[test_index_cog], pred_cog)
accuracy_cognitive.append(acc_cog)

pred_pain = clf.predict(X_pain_test)
acc_pain = accuracy_score(y[test_index], pred_pain)
accuracy_pain.append(acc_pain)


print(f"cognitive: {accuracy_cognitive}, pain: {accuracy_pain}")

withintask = 'pain'
crosstask = 'cognitive'
save_within_task = join(output_dir, f'accuracy-{withintask}_train-{withintask}.npy')
save_cross_task = join(output_dir, f'accuracy-{crosstask}_train-{withintask}.npy')
np.save(np.array(accuracy_pain), save_within_task)
np.save(np.array(accuracy_cognitive), save_within_task)

# ----------------------------------------------------------------------
#                               archive
# ----------------------------------------------------------------------

    # ########################
    # # between tasks prediction __________________________________________
    # # TODO: for inner_train_index, inner_test_index in cv.split(X_pain[train_index], y[train_index]):
    # clf = svm.LinearSVC(class_weight = 'balanced', C = C)    #svm.SVC()
    # clf.fit(X_pain_train, y_cog[train_index])
    # pred_cog = clf.predict(X_cog_test) 
    # # NOTE: DO  NOT fit a new model nor fit it, 
    # acc_cog = accuracy_score(y_cog[test_index_cog], pred_cog)
    # accuracy_cognitive.append(acc_cog)

    # # within tasks prediction __________________________________________
    # y_pain = clf.predict(X_pain_test)
    # acc_pain = accuracy_score(y[test_index], y_pain)
    # accuracy_pain.append(acc_pain)