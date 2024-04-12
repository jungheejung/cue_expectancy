# %% load library ________________________________________________________________
import os, re, json, glob
from datetime import datetime
from os.path import join
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, to_rgba
import seaborn as sns


# import h5py


# from nilearn import image, masking, plotting, datasets
# from nilearn.input_data import NiftiLabelsMasker, NiftiMapsMasker

# import neuromaps
# from neuromaps import datasets as neuromaps_datasets
# from neuromaps.datasets import fetch_annotation, fetch_fslr
# from neuromaps.parcellate import Parcellater
# from neuromaps.images import dlabel_to_gifti
# from neuromaps.transforms import fsaverage_to_fslr

# from netneurotools import datasets as nntdata

# from surfplot import Plot
from sklearn.model_selection import GroupKFold #StratifiedKFold, , GridSearchCV #, cross_val_predict
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, precision_recall_fscore_support #make_scorer
from sklearn.pipeline import Pipeline

plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.serif'] = 'Arial'


# %% create gradient ________________________________________________________________



# Define the colors at specific points
colors = [
    # (0, "#120041"),  # Start with blue at -1.9
    # (0, "#2500fa"),
    (0, "#84c6fd"),  # Start with blue at -1.9
    (0.33, "white"),    # Transition to white at 0
    # (0.6, "#ffa300"),
    # (0.4, "#ff0000"),    # Start transitioning to red just after 0 towards 1.2
    (1, "#ffd400")  # End with yellow at 1.2
]

colors_with_opacity = [
    # (0, to_rgba("#120041", alpha=1.0)),  # Fully opaque
    # (0, to_rgba("#2500fa", alpha=0.8)),  # Fully opaque
    (0, to_rgba("#008bff", alpha=0.6)),  # Fully opaque
    (0.33, to_rgba("white", alpha=1.0)),       # Fully opaque
    # (0.6, to_rgba("#ffa300", alpha=1.0)),   # 30% opacity
    # (0.4, to_rgba("#ffa300", alpha=0.8)),   # 60% opacity
    (1.0, to_rgba("#ff0000", alpha=1.0))    # Fully opaque
]



# Normalize the points to the [0, 1] interval
norm_points = np.linspace(0, 1, len(colors_with_opacity))
norm_colors = [c[1] for c in colors_with_opacity]
norm_points = (norm_points - norm_points.min()) / (norm_points.max() - norm_points.min())

# Create a custom colormap
cmap = LinearSegmentedColormap.from_list("custom_gradient", list(zip(norm_points, norm_colors)))

# Create a gradient image
gradient = np.linspace(0, 1, 256)
gradient = np.vstack((gradient, gradient))

# Plot the gradient
fig, ax = plt.subplots(figsize=(6, 2))
ax.imshow(gradient, aspect='auto', cmap=cmap)
ax.set_axis_off()

plt.show()


def extract_metadata(filename):
    pattern = re.compile(
        r"(?P<sub>sub-\d+)_"
        r"(?P<ses>ses-\d+)_"
        r"(?P<run>run-\d+)_"
        r"runtype-(?P<runtype>\w+)_"
        r"event-(?P<event>\w+)_"
        r"(?P<trial>trial-\d+)_"
        r"cuetype-(?P<cuetype>\w+)_"
        r"stimintensity-(?P<stimulusintensity>\w+)"
    )
    match = pattern.search(filename)
    if match:
        
        metadata = match.groupdict()
        metadata['cue'] = metadata['cuetype'] + '_cue'
        metadata['stim'] = metadata['stimulusintensity'] + '_stim'
        return metadata
    
    return {}


def parse_filename_with_regex_adjusted(filename):
    # Updated regular expression pattern to keep the prefixes in the extracted values
    pattern = r"(sub-\d+)_(ses-\d+)_(run-\d+)_runtype-(\w+)_event-(\w+)_trial-(\d+)_cuetype-(\w+)_stimintensity-(\w+)"
    match = re.match(pattern, filename)
    
    if match:
        metadata = {
            'sub': match.group(1),  # Keeping the prefix for sub
            'ses':  match.group(2),  # Adding 'ses-' prefix
            'run':  match.group(3),  # Adding 'run-' prefix
            'runtype': match.group(4),
            'event': match.group(5),
            'trial_index': int(match.group(6)),  # Convert trial_index to integer
            'cue': match.group(7) + '_cue',  # Append "_cue" to cue value
            'stimulusintensity': match.group(8),  # Append "_stim" to stimulusintensity value
        }
        return metadata
    else:
        return {}
# %% load data
# roi = 'dACC'
roi_list = [ 'npsneg_rIPL',  'npsneg_pgACC','npsneg_rLOC', 'npsneg_lLOC', 
            'npspos_dACC', 'npspos_rdpIns', 'npspos_rS2_Op', 'npspos_rV1', 'npspos_vermis']
for roi in roi_list:
    data_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv02_parcel-NPS'
    save_dir = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv04_NPSdecoding'
    Path(save_dir).mkdir(parents=True, exist_ok=True)
    npy_nps = np.load(join(data_dir, f'{roi}_event-stimulus.npy'))
    npy_nps_metadata = join(data_dir, f'{roi}_event-stimulus.json')
    with open(npy_nps_metadata, 'r') as file:
        npy_nps_meta = json.load(file)


    singletrial_fname = npy_nps_meta['filenames']
    nps_roi = pd.DataFrame({'singletrial_fname': singletrial_fname})


    # Step 1: extract metadata from filenames and store into pandas columns ________________
    metadata_df = pd.DataFrame(nps_roi['singletrial_fname'].apply(extract_metadata).tolist())
    metadata_df = pd.concat([metadata_df, nps_roi], axis=1)

    # Step 2: append single trial voxel weights into pandas ________________________________
    prefix = f"{roi}_"
    columns = [prefix + str(i) for i in range(npy_nps.shape[1])]
    arraydf = pd.DataFrame(npy_nps, columns=columns)

    nps_roi = pd.concat([metadata_df, arraydf], axis=1)
    # Step 3: Define the mapping
    mapping = {'high_stim': 0, 'med_stim': 1, 'low_stim': 2}
    nps_roi['stim_num'] = nps_roi['stim'].map(mapping)


    # Step 4: Check average activation
    df_pain_index = nps_roi[(nps_roi['runtype'] == 'pain') 
                                        ].index
    df_pain = nps_roi[(nps_roi['runtype'] == 'pain') 
                                    ].copy().reset_index(drop=True)

    # Step 4-1: Compute the row-wise mean of the NPS scores __________________________
    df_pain['NPS_mean'] = df_pain.filter(regex=rf'^{roi}_\d+').mean(axis=1)

    # Step 4-2: Aggregate data to compute the mean NPS score per 'stim' for each 'sub'
    grouped_data = df_pain.groupby(['sub', 'stimulusintensity'])['NPS_mean'].mean().reset_index()

    # Step 4-3: Adjust order of 'stim' levels ________________________________________
    stim_order = ['high', 'med', 'low']
    grouped_data['stimulusintensity'] = pd.Categorical(grouped_data['stimulusintensity'], categories=stim_order, ordered=True)

    # Step 4-4: Plot _________________________________________________________________
    g = sns.catplot(x='stimulusintensity', y='NPS_mean', col='sub', data=grouped_data, kind='bar',
                    height=4, aspect=.7, col_wrap=5, order=stim_order)

    # Optional: Adjust plot aesthetics
    g.set_axis_labels("Stimulation Level", "Average NPS Score")
    g.set_titles("{col_name}")
    #g.set(ylim=(0, grouped_data['NPS_mean'].max()*1.1)) # Adjust y-axis limits if necessary
    plt.xticks(rotation=45) # Rotate x-axis labels if needed

    plt.show()


    #  Step 5: load behavioral data and layer in metadata _________________________________________________________________
    ratings = pd.read_csv('/Users/h/Documents/projects_local/cue_expectancy/data/beh/sub-all_task-all_events.tsv', sep = '\t')
    ratings

    # Step 6: Test the adjusted function with the sample filename
    ratings_parsed = (ratings['singletrial_fname']).apply(parse_filename_with_regex_adjusted).apply(pd.Series)
    rating_merge = pd.concat([ratings[['singletrial_fname', 'expectrating', 'outcomerating']], ratings_parsed], axis=1)

    nps_roi['trial_index'] = nps_roi['trial'].str.extract('(\d+)').astype(int)

    brain_metadf = pd.merge(rating_merge, nps_roi, on=[ "sub", "ses", "run", "runtype", "trial_index", "cue", "stimulusintensity"], how="inner")

    ################################################################################
    # Main analysis 1: 
    ################################################################################

    # Step 1: subset pain data with high cue trials ________________________________

    for cuetype in ['high_cue', 'low_cue']:
        print(f'______________ decoding {cuetype} ______________')
        # high_cue_pain_index = nps_roi[(nps_roi['runtype'] == 'pain') & 
        #                                     (nps_roi['cue'] == cuetype)].index
        df = nps_roi[(nps_roi['runtype'] == 'pain') & 
                                        (nps_roi['cue'] == cuetype)].copy().reset_index(drop=True)


        # Step 2: filter dataframe based on stimulus intensity trials per sub/ses ______
        # Ensure that for each subject (sub), within, each session-run combination (ses_run), 
        # there are at least two trials for each level of stimulus intensity (stimulusintensity). 
        # This step aims to exclude subjects or trials that don't meet this criterion, 
        # ensuring a minimum level of data availability for each condition.

        df['ses_run'] =  df['ses'] + '_' + df['run'] 
        unique_subs_before = df['sub'].unique()
        # Correcting the approach to identify participants to exclude
        # filtered_df = df.groupby(['sub', 'ses_run']).filter(lambda x: {'high_stim', 'med_stim', 'low_stim'}.issubset(x['stim'].unique()))

        filtered_groups = df.groupby(['sub', 'ses_run', 'stimulusintensity']).filter(lambda x: len(x) < 2)
        participants_to_exclude = filtered_groups['sub'].unique()
        filtered_df = df[~df['sub'].isin(participants_to_exclude)]


        # Step 3: How many subjects would be dropped after this filtering? _____________
        # Print the number of subjects that do not have more than two trials per condition
        # in every run

        unique_subs_after = filtered_df['sub'].unique()
        subs_dropped = [sub for sub in unique_subs_before if sub not in unique_subs_after]
        num_subs_dropped = len(subs_dropped)
        print(f"Number of unique subjects dropped: {num_subs_dropped}")

        # Step 4: group level arrays
        runs_per_sub = filtered_df.groupby('sub')['ses_run'].nunique()
        subs_to_drop = runs_per_sub[runs_per_sub <= 1].index
        print(f"subs to drop: {subs_to_drop}")
        df_filtered = filtered_df[~filtered_df['sub'].isin(subs_to_drop)]
        confusion_matrices = []
        overall_results = []
        all_Y_test = []
        all_Y_pred = []
        group_confusion_matrices = []
        desired_order = {'high_stim': 0, 'med_stim': 1, 'low_stim': 2}

        f1df = pd.DataFrame(columns=['sub', 'ses_run', 'F1_high', 'F1_med', 'F1_low'])
        accuracy_df = pd.DataFrame(columns=['sub', 'ses_run', 'Accuracy_high', 'Accuracy_med', 'Accuracy_low'])

        # Step 5: Iterate over each subject
        for sub in df_filtered['sub'].unique():

            df_sub = df_filtered[df_filtered['sub'] == sub]
            filtered_sub = df_sub.groupby('ses_run').filter(lambda x: {'high_stim', 'med_stim', 'low_stim'}.issubset(x['stim'].unique()))

            X = filtered_sub.filter(regex=rf'^{roi}_\d+').values
            Y_mapped = filtered_sub['stim'].map(desired_order)
            Y = Y_mapped.values
            uniques = np.array(['high_stim', 'med_stim', 'low_stim'])
            

            # 5-1. subject wise items to save __________________________________________
            # Initialization: Set up structures to store subject-specific metrics like 
            # accuracy and F1 scores, along with confusion matrices for later analysis.
            test_indices = []
            sub_true = []; sub_predictions = []; sub_accuracies = []; sub_f1_scores = []
            sub_confusion_matrices = [] 
            sub_accuracies_dict = {'high_stim': [], 'med_stim': [], 'low_stim': []}
            # 5-2. K fold per run (unique session/run combination) _____________________
            # Group K fold based on run distinctions. Don't make the mistake of adding run 
            # or session as group distinctions. There are session/run combinations that
            # constitutes different runs

            groups, unique_runs = pd.factorize(filtered_sub['ses_run'])
            cv = GroupKFold(n_splits=len(np.unique(groups)))
            
            for i,(train_idx, test_idx) in enumerate(cv.split(X, Y, groups=groups)):
            
                X_train, X_test = X[train_idx], X[test_idx]
                Y_train, Y_test = Y[train_idx], Y[test_idx]
                groups_train, groups_test = groups[train_idx], groups[test_idx]

                # 5-3. Initialize and train the SVM model ______________________________
                # subjectwise SVM - calculate accuracy, f1 score and save the true vs. 
                # predicted classes
                svc = SVC(kernel='linear', probability=True, class_weight='balanced', decision_function_shape='ovr')

                svc.fit(X_train, Y_train)
                Y_pred = svc.predict(X_test)

                sub_true.extend(Y_test)
                sub_predictions.extend(Y_pred)
                sub_accuracies.append(accuracy_score(Y_test, Y_pred))
                sub_f1_scores.append(f1_score(Y_test, Y_pred, average='weighted'))

                # HIGHLIGHT: append f1 score to pandas per CV _____________________________________
                precision, recall, f1_scores, _ = precision_recall_fscore_support(Y_test, Y_pred, labels=[0, 1, 2])
                row = {
                    'sub': sub,
                    'ses_run':i,
                    'F1_high': f1_scores[0],
                    'F1_med': f1_scores[1],
                    'F1_low': f1_scores[2]
                }
                row_df = pd.DataFrame([row])  # Make a DataFrame from the row dictionary
                f1df = pd.concat([f1df, row_df], ignore_index=True)

                # HIGHLIGHT: append accuracy to pandas per CV 
                        # Calculate accuracies for each condition within this fold
                for condition, index in desired_order.items():
                    condition_mask = Y_test == index
                    if condition_mask.sum() > 0:  # Ensure there are samples for this condition
                        condition_accuracy = accuracy_score(Y_test[condition_mask], Y_pred[condition_mask])
                        sub_accuracies_dict[condition].append(condition_accuracy)
                mean_accuracies = {condition: np.mean(acc) for condition, acc in sub_accuracies_dict.items()}
                accuracy_row = {
                    'sub': sub,
                    'ses_run': 'mean',  # Or however you wish to denote aggregated results
                    'Accuracy_high': mean_accuracies['high_stim'],
                    'Accuracy_med': mean_accuracies['med_stim'],
                    'Accuracy_low': mean_accuracies['low_stim']
                    }
                accuracy_df = pd.concat([accuracy_df, pd.DataFrame([accuracy_row])], ignore_index=True)

                # 5-4. Store the test index and predictions ____________________________
                # Also, normalize the confusion matrix so that we can stack it per participant
                test_indices.extend(test_idx)
                cm = confusion_matrix(Y_test, Y_pred)
                cv_cm_normalized = cm / cm.sum(axis=1, keepdims=True)
                cv_cm_normalized[np.isnan(cv_cm_normalized)] = 0  # Replace NaNs with 0s if any row sum was 0

                sub_confusion_matrices.append(cv_cm_normalized)

                all_Y_test.extend(Y_test)
                all_Y_pred.extend(Y_pred)

            # Step 6. Store the mean accuracy for this subject _________________________________
            mean_accuracy = np.mean(sub_accuracies)     
            mean_f1_score = np.mean(sub_f1_scores)
            overall_results.append({'sub': sub, 
                                    'accuracy': mean_accuracy, 
                                    'f1_score': mean_f1_score})
            
            # Step 7. Aggregate the confusion matrices _________________________________
            # for a given subject, average the normalized confusion matrix and stack into
            # group variable group_confusion_matrices
            sub_cm_sum = np.mean(sub_confusion_matrices, axis=0)
            group_confusion_matrices.append(sub_cm_sum) # stack subject average Confusion matrix

        # Step 8. Convert overall results to a DataFrame for easier analysis ___________
        highcue_results_df = pd.DataFrame(overall_results)
        # print(highcue_results_df)
        desired_class_order = ['high_stim', 'med_stim', 'low_stim']

        # Step 9. Plot confusion matrix ________________________________________________
        average_normalized_cm = np.mean(group_confusion_matrices, axis=0)
        print("Normalized Confusion Matrix (by Actual Class Totals):")
        print(average_normalized_cm)

        cuename = cuetype.strip('_cue')

        plt.figure(figsize=(4,4))
        sns.heatmap(average_normalized_cm, 
                    annot=True, fmt=".2%", cmap=cmap, vmin=.25, vmax=.45,
                    xticklabels=desired_class_order, 
                    yticklabels=desired_class_order)
        plt.ylabel('Actual label')
        plt.xlabel('Predicted label')
        plt.title(f'{roi} {cuetype}\nClassify high/med/low stim')
        plt.savefig(join(save_dir, f'roi-{roi}_cue-{cuename}_confusionmatrix.png'))
        plt.show()

        print(f"high cue f1score: {highcue_results_df['f1_score'].mean()}")
        print(f"high cue accuracy: {highcue_results_df['accuracy'].mean()}")

        f1df['roi'] = roi
        f1df.to_csv(join(save_dir, f'roi-{roi}_cue-{cuename}_f1score.tsv'), 
                    sep='\t', index=False)
        accuracy_df['roi'] = roi
        accuracy_df.to_csv(join(save_dir, f'roi-{roi}_cue-{cuename}_accuracy.tsv'), 
                        sep='\t', index=False)
        
# %%
