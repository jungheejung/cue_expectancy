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

# %%0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
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
# %%0. argparse ________________________________________________________________________________

# %% ver 2 # predefined split
# singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'
# main_dir = os.getcwd()
#stack high from first participants, stack low from first participant
# test partiicpants: "sub-0034", "sub-0036", "sub-0037", "sub-0061", "sub-0062"
runtype = 'pain'
event = 'stimulus'
# ntrials = 36 # average maps

sub_list = [] #list(np.arange(1,134))
badruns_fname = join(main_dir,'scripts', 'step00_qc', 'qc03_fmriprep_visualize', 'bad_runs.json' )


# %%
N = len(sub_list)
# y = np.tile(np.repeat(['high', 'low'], ntrials), N) # high cue, low cue

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

# %% 
###########################################################################################################################
# save data 
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
    ###########################################################################################################################
# if np.sum(paindf_meta['cuetype'] == cogdf_meta['cuetype']) == len(paindf_meta['cuetype']):
    # y = np.array(paindf_meta['cuetype'])
#### try 1
# paindf_grouped = paindf_meta.groupby('sub').filter(lambda x: x['ses'].nunique() == 1)
# cogdf_grouped = cogdf_meta.groupby('sub').filter(lambda x: x['ses'].nunique() == 1)

# # Matching the filtered DataFrames based on the group column
# matched_data = pd.merge(paindf_grouped, cogdf_grouped, on='Group', suffixes=('_df1', '_df2'))
###########################################################################################################################
### try 2 ###########################################################################################################################
# TODO: 
# create a function, where you compare two dataframes absed on groupby 'sub', 'ses'
# From that, if the number of rows don't match, shuffle and drop number of rows from either dataframe that has excess number of rows

# # balance trials __________________________________________________________________________
# df1_trial_counts = paindf_meta.groupby('sub')['ses'].size()
# df2_trial_counts = cogdf_meta.groupby('sub')['ses'].size()
# diff = df1_trial_counts - df2_trial_counts
# diff_df = diff.reset_index().rename(columns={'index': 'sub', 0: 'diff'})
# # inspiration
# # https://stackoverflow.com/questions/45839316/pandas-balancing-data
# # g = df.groupby('class')
# # g.apply(lambda x: x.sample(g.size().min()).reset_index(drop=True))

# # sub 11, 24 diff
# selected_trial_counts = []
# pdf = paindf_meta.copy()
# cdf = cogdf_meta.copy()
# import random
# filtered_diff_df = diff_df[diff_df['ses'] > 0]
# for index, row in filtered_diff_df.iterrows():
#     print(sub)
#     sub = row['sub']
#     N = filtered_diff_df.loc[filtered_diff_df['sub'] == sub, 'ses'].values[0]
#     rows_to_drop = []
#     sub_rows = pdf[pdf['sub'] == sub]
#     if len(sub_rows) >= N:
#         # rows_to_drop = random.sample(sub_rows.index.tolist(), int(N))
#         # pdf = pdf.drop(rows_to_drop)
#         high_rows_to_drop = random.sample(sub_rows[sub_rows['cuetype'] == 'high'].index.tolist(), int(N/2))
#         low_rows_to_drop = random.sample(sub_rows[sub_rows['cuetype'] == 'low'].index.tolist(), int(N/2))
#         # rows_to_drop = random.sample(sub_rows.index.tolist(), int(negN))

#         pdf = pdf.drop(list(high_rows_to_drop) + list(low_rows_to_drop))

# negdiff_df = diff_df[diff_df['ses'] < 0]
# for index, row in negdiff_df.iterrows():
#     sub = row['sub']
#     print(sub)
#     negN = np.abs(negdiff_df.loc[negdiff_df['sub'] == sub, 'ses'].values[0])
#     rows_to_drop = []
#     sub_rows = cdf[cdf['sub'] == sub]
#     # TODO: equally drop two classes. 
#     if len(sub_rows) >= negN:
#         high_rows_to_drop = random.sample(sub_rows[sub_rows['cuetype'] == 'high'].index.tolist(), int(negN/2))
#         low_rows_to_drop = random.sample(sub_rows[sub_rows['cuetype'] == 'low'].index.tolist(), int(negN/2))
#         # rows_to_drop = random.sample(sub_rows.index.tolist(), int(negN))

#         cdf = cdf.drop(list(high_rows_to_drop) + list(low_rows_to_drop))
###########################################################################################################################
# y_cog = cogdf_meta['cuetype']
print(f"{X_painstim.shape}")
print(f"{X_cognitive.shape}")# X, y should be identical for both pain and cognitive
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

##############
# validation
pdf = paindf_meta.copy()
cdf = cogdf_meta.copy()
pdf = pdf[pdf['sub'].isin(cdf['sub'])]
cdf = cdf[cdf['sub'].isin(pdf['sub'])]

# validation
################


y = np.array(paindf_meta['cuetype'])
y_cog = np.array(cogdf_meta['cuetype'])
# only grab trials that match pdf and cdf index ( given that we dropped unbalanced trials)
X_pain = X_painstim[pdf.index]
X_cog = X_cognitive[cdf.index]
print(f"after balancing: \n * pain run: {X_pain.shape} \n * cog run: {X_cog.shape}")
# assert pdf['cuetype'].tolist() == cdf['cuetype'].tolist()
# assert pdf['sub'].tolist() == cdf['sub'].tolist()

# %%
subjects = pd.factorize(pdf['sub'])[0]#np.repeat(np.arange(N), ntrials*2)
subjects_cog = pd.factorize(cdf['sub'])[0]
# assert len(y) == len(subjects) 
cv = PredefinedSplit(subjects)
accuracy_cognitive = []
accuracy_pain = []
# TODO: retain the subject ides and 
for train_index, test_index in cv.split(X_pain, y):
    
    # TODO: 
    train_index_cog = np.where(subjects_cog == np.unique(subjects[train_index]))[0]
    test_index_cog = np.where(subjects_cog == np.unique(subjects[test_index]))[0]
    # sklearn.model_selection.GridSearchCV(clf
    # scaling __________________________________________
    scaler = StandardScaler() # TODO: standard scalar. .fit_transform(X_train) -> mean/sd of the transformed data
    X_pain_train = scaler.fit_transform(X_pain[train_index]) # z-score on the samples
    X_pain_test = scaler.transform(X_pain[test_index])
    # X_cog_train = scaler.fit_transform(X_cog[train_index]) # z-score on the samples
    # X_cog_test = scaler.transform(X_cog[test_index])

    # X_cog_train = scaler.transform(X_pain_train)
    X_cog_test = scaler.transform(X_cog[test_index_cog])
    # NOTE: 
    # 1) inner loop and grid search for hyperparameter C. 
        # 
    # 2) PCA in this loop - 80000 features-> 90% of the variance 
    pca = PCA(n_components=.9)
    X_pain_train = pca.fit_transform(X_pain[train_index])
    X_pain_test = pca.transform(X_pain[test_index])
    X_cog_test = pca.transform(X_cog[test_index_cog])
    print(f'number of PCs = {X_pain_train.shape[1]}')

    # Cs = [.001, .01, .1, 1.]
    exponents = np.array([-3, -2, -1, 0, 1, 2, 3])
    Cs = np.exp(exponents)
    inner_cv = PredefinedSplit(subjects[train_index])
    grid_search = GridSearchCV(svm.LinearSVC(class_weight='balanced'), {'C': Cs}, cv=inner_cv)
    grid_search.fit(X_pain_train, y[train_index])
    C = grid_search.best_params_['C']#grid_search.cv_results_["params"]["alpha"]

    # between tasks prediction __________________________________________
    # TODO: for inner_train_index, inner_test_index in cv.split(X_pain[train_index], y[train_index]):
    clf = svm.LinearSVC(class_weight = 'balanced', C = C)    #svm.SVC()
    clf.fit(X_pain_train, y_cog[train_index])
    pred_cog = clf.predict(X_cog_test) 
    acc_cog = accuracy_score(y_cog[test_index_cog], pred_cog)
    accuracy_cognitive.append(acc_cog)

    # within tasks prediction __________________________________________
    y_pain = clf.predict(X_pain_test)
    acc_pain = accuracy_score(y[test_index], y_pain)
    accuracy_pain.append(acc_pain)
print(f"cognitive: {accuracy_cognitive}, pain: {accuracy_pain}")

withintask = 'pain'
crosstask = 'cognitive'
save_within_task = join(output_dir, 'accuracy-{withintask}_train-{withintask}.npy')
save_cross_task = join(output_dir, 'accuracy-{crosstask}_train-{withintask}.npy')
np.save(np.array(accuracy_pain), save_within_task)
np.save(np.array(accuracy_cognitive), save_within_task)
# data = [1, 2, 2, 3, 3, 3, 4, 4, 5]
# %%
plt.hist(accuracy_pain, bins='auto')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.title('Histogram of Data')
plt.show()

# %% TODO: bootstrap

# mean acc per subject
# bootstrap. iter, with replacement
# bottom 2.5% does not overlap with 0.5
from sklearn.utils import resample

def bootstrap(data, iterations):
    bootstrap_samples = []
    n = len(data)
    
    for _ in range(iterations):
        bootstrap_sample = resample(data, replace=True, n_samples=n)
        bootstrap_samples.append(bootstrap_sample)
    
    return bootstrap_samples
def calculate_confidence_interval(bootstrap_samples, confidence=0.95):
    n = len(bootstrap_samples[0])
    num_iterations = len(bootstrap_samples)
    
    bootstrap_means = np.mean(bootstrap_samples, axis=1)
    sorted_means = np.sort(bootstrap_means)
    
    lower_index = int((1 - confidence) / 2 * num_iterations)
    upper_index = int((1 + confidence) / 2 * num_iterations)
    
    lower_bound = sorted_means[lower_index]
    upper_bound = sorted_means[upper_index]
    
    return lower_bound, upper_bound
# Example usage
# original_data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
bootstrap_samples = bootstrap(accuracy_cognitive, 1000)
lower_bound, upper_bound = calculate_confidence_interval(bootstrap_samples, confidence=0.95)
print("Lower bound:", lower_bound)
print("Upper bound:", upper_bound)
# Print the first few bootstrap samples
# for i in range(5):
#     print("Bootstrap Sample", i+1, ":", bootstrap_samples[i])
    # print(f"Fold {i}:")
    # print(f"  Train: index={train_index}")
    # print(f"  Test:  index={test_index}")
# TODO:
# permutation labels
# boot strap accuracy



# %%
