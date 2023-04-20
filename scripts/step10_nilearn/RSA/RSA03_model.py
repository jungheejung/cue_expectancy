import numpy as np
import pandas as pd
import os, glob, re, sys
from scipy.spatial.distance import pdist, squareform
from matplotlib.colors import LinearSegmentedColormap
from rsatoolbox.inference import eval_fixed
from rsatoolbox.model import ModelFixed
import rsatoolbox.rdm as rsr
import rsatoolbox.data as rsd
import rsatoolbox
import matplotlib.pyplot as plt
from nilearn import image

def load_expect(data_dir, sub, ses ):
    tasklist = ['pain', 'vicarious', 'cognitive']
    seswise_expect = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(os.path.join(data_dir, sub, ses, f"{sub}_{ses}_*{task}_beh.csv"))
        for f in flist: 
            df = pd.read_csv(f)
            df['trial'] = df.index
            df['trial_order'] = df.groupby('param_cond_type', as_index=False)['param_cond_type'].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df['run_order'] = runwise_df['param_run_num'].gt(np.mean(runwise_df['param_run_num']), 0)*1
        seswise_02expect = runwise_df.pivot_table(index=['param_cue_type','param_stimulus_type'], columns=['trial_order', 'run_order'],
                            values=['event02_expect_angle']) #, aggfunc='first')
        seswise_02expect.columns  = [col[0]+'_'+str(col[1]) for col in seswise_02expect.columns.values]
        seswise_02expect = seswise_02expect.reset_index()
        seswise_02expect["condition"] = task + '_' + seswise_02expect['param_cue_type'].astype(str) + '_' + seswise_02expect["param_stimulus_type"]

        # reorder values
        seswise_02expect['stim_order'] = seswise_02expect['param_stimulus_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})  
        seswise_02expect['cue_order'] = seswise_02expect['param_cue_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})    
        ses_expect = seswise_02expect.sort_values(['cue_order','stim_order'])
        seswise_expect = pd.concat([seswise_expect, ses_expect])
    return(seswise_expect.reset_index(drop = True))

def load_outcome(data_dir, sub, ses):
    tasklist = ['pain', 'vicarious', 'cognitive']
    seswise_outcome = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(os.path.join(data_dir, sub, ses, f"{sub}_{ses}_*{task}_beh.csv"))
        for f in flist:
            df = pd.read_csv(f)
            df['trial'] = df.index
            df['trial_order'] = df.groupby('param_cond_type', as_index=False)['param_cond_type'].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df['run_order'] = runwise_df['param_run_num'].gt(np.mean(runwise_df['param_run_num']), 0)*1
        seswise_04outcome = runwise_df.pivot_table(index=['param_cue_type','param_stimulus_type'], columns = ['trial_order', 'run_order'],
                            values=['event04_actual_angle']) #, aggfunc='first')
        seswise_04outcome.columns  = [ col[0]+'_'+str(col[1]) for col in seswise_04outcome.columns.values]
        seswise_04outcome = seswise_04outcome.reset_index()
        seswise_04outcome["condition"] = task + '_' + seswise_04outcome['param_cue_type'].astype(str) + '_' + seswise_04outcome["param_stimulus_type"]

        # reorder values
        seswise_04outcome['stim_order'] = seswise_04outcome['param_stimulus_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})
        seswise_04outcome['cue_order'] = seswise_04outcome['param_cue_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})
        ses_outcome = seswise_04outcome.sort_values(['cue_order','stim_order'])
        seswise_outcome = pd.concat([seswise_outcome, ses_outcome])
    return(seswise_outcome.reset_index(drop = True))

def load_fmri(singletrial_dir, sub, ses, run, atlas):
    from nilearn import datasets
    from nilearn.maskers import NiftiLabelsMasker
    dataset = datasets.fetch_atlas_schaefer_2018()
    atlas_filename = dataset.maps
    # labels = dataset.labels
    labels = np.insert(dataset.labels, 0, 'Background')
    masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                            memory='nilearn_cache', verbose=5)
    if atlas == True: 
        arr = np.empty((0, len(dataset['labels'])), int)  
    elif atlas == False:
        get_shape = glob.glob(os.path.join(
                singletrial_dir, sub, f'{sub}_{ses}_run-01_runtype-*_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz'))
        get_shape_data = image.mean_img(image.concat_imgs(get_shape)).get_fdata().ravel()
        arr = np.empty((0, get_shape_data.shape[0]), int)
    # task_array = np.empty((18,0), int)
    
    for runtype in ['pain','cognitive', 'vicarious']:
        stim_H_cue_H = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz')))
        stim_M_cue_H = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-med.nii.gz')))
        stim_L_cue_H = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-low.nii.gz')))
        stim_H_cue_L = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-high.nii.gz')))
        stim_M_cue_L = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-med.nii.gz')))
        stim_L_cue_L = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-low.nii.gz')))
        stim_flist = []
        [stim_flist.extend(l) for l in (stim_H_cue_H, stim_M_cue_H, stim_L_cue_H, stim_H_cue_L, stim_M_cue_L, stim_L_cue_L)]

        
        # task_array = np.vstack((task_array, runwise_array))
        # arr = np.append(arr, runwise_array, axis=0)
        if atlas == True:
            stim_H_cue_H_mean = image.mean_img(image.concat_imgs(stim_H_cue_H))
            stim_M_cue_H_mean = image.mean_img(image.concat_imgs(stim_M_cue_H))
            stim_L_cue_H_mean = image.mean_img(image.concat_imgs(stim_L_cue_H))
            stim_H_cue_L_mean = image.mean_img(image.concat_imgs(stim_H_cue_L))
            stim_M_cue_L_mean = image.mean_img(image.concat_imgs(stim_M_cue_L))
            stim_L_cue_L_mean = image.mean_img(image.concat_imgs(stim_L_cue_L))
            runwise_array = masker.fit_transform(image.concat_imgs([stim_H_cue_H_mean,
                                                          stim_M_cue_H_mean,
                                                          stim_L_cue_H_mean,
                                                          stim_H_cue_L_mean,
                                                          stim_M_cue_L_mean,
                                                          stim_L_cue_L_mean
                                                           ])) # (trials, parcels)
            arr = np.concatenate((arr,runwise_array),axis=0)
    # np.vstack((arr, runwise_array))
        elif atlas == False:
            stim_H_cue_H_mean = image.mean_img(image.concat_imgs(stim_H_cue_H)).get_fdata().ravel()
            stim_M_cue_H_mean = image.mean_img(image.concat_imgs(stim_M_cue_H)).get_fdata().ravel()
            stim_L_cue_H_mean = image.mean_img(image.concat_imgs(stim_L_cue_H)).get_fdata().ravel()
            stim_H_cue_L_mean = image.mean_img(image.concat_imgs(stim_H_cue_L)).get_fdata().ravel()
            stim_M_cue_L_mean = image.mean_img(image.concat_imgs(stim_M_cue_L)).get_fdata().ravel()
            stim_L_cue_L_mean = image.mean_img(image.concat_imgs(stim_L_cue_L)).get_fdata().ravel()
            runwise_array = np.vstack((stim_H_cue_H_mean, stim_M_cue_H_mean, stim_L_cue_H_mean, stim_H_cue_L_mean, stim_M_cue_L_mean, stim_L_cue_L_mean))
            arr = np.concatenate((arr,runwise_array),axis=0)
        mask = ~np.isnan(image.load_img(image.concat_imgs(stim_H_cue_H)).get_fdata())
    return(mask, arr, stim_flist)

def upper_tri(RDM):
    """upper_tri returns the upper triangular index of an RDM

    Args:
        RDM 2Darray: squareform RDM

    Returns:
        1D array: upper triangular vector of the RDM
    """
    # returns the upper triangle
    m = RDM.shape[0]
    r, c = np.triu_indices(m, 1)
    return RDM[r, c]

# load pickl and concat RDM ________________________________________________________________________________
fmri_data = []
# load pkl
pkl_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_RDMpkl"
flist = glob.glob(os.path.join(pkl_dir, '*', f"*.pkl"))
expect_df = pd.DataFrame()
expect_df = load_expect(data_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh02_preproc/",
                        sub="sub-0038", ses="ses-01")
# fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step10_nilearn/RSA/sub-0078_ses-01_RDM.pkl'
# append with 
for fname in flist:
    obj = pd.read_pickle(fname)
    des = {'session': os.path.basename(fname).split('_')[1], 
           'subj': os.path.basename(fname).split('_')[0]}
    # rdm_pkl = rsatoolbox.data.Dataset(obj)
    # fmri_data = rsatoolbox.rdm.rdms.rdms_from_dict(obj)
    rdm_dict = rsatoolbox.data.Dataset(measurements=obj['measurements'],
                                     descriptors=des,
                                     obs_descriptors=obj['obs_descriptors'],
                                     channel_descriptors=obj['channel_descriptors'])
#     rdms_fmri = rsr.calc_rdm(rdm_dict)
    fmri_data.append(rdm_dict)

data_rdms = rsatoolbox.rdm.calc_rdm(fmri_data)
# visualize
fig, ax, ret_val = rsatoolbox.vis.show_rdm(rsr.calc_rdm(fmri_data))
fig.savefig('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv06_RDMmodelcomparison/fmri_RDM.png', bbox_inches='tight', dpi=300)

# orthogonal _______________________________________________________________________________
stim = np.array([1, 0, -1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

c1 = np.array([[1,0,0],
              [0,0,0],
              [0,0,1]])
c2 = np.array([[1,0,0],
              [0,1,0],
              [0,0,0]])
c3 = np.array([[0,0,0],
              [0,1,0],
              [0,0,1]])
xy = np.concatenate([
    np.dot(np.dot(tcs[:6,], c1), c1.T),
    np.dot(np.dot(tcs[6:12,], c2), c2.T),
    np.dot(np.dot(tcs[12:,], c3), c3.T)], axis=0)

xy = np.concatenate([
    np.dot(np.dot(tcs[:6,], c3), c3.T),
    np.dot(np.dot(tcs[6:12,], c2), c2.T),
    np.dot(np.dot(tcs[12:,], c1), c1.T)], axis=0)

model_features = [rsatoolbox.data.Dataset(np.array(xy))]
model_orthogonal = rsatoolbox.rdm.calc_rdm(model_features)

# model_cue ________________________________________________________________________________

stim = np.array([1, 0, -1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

c1 = np.array([[1,0,0],
              [0,0,0],
              [0,0,1]])
c2 = np.array([[1,0,0],
              [0,1,0],
              [0,0,0]])
c3 = np.array([[0,0,0],
              [0,1,0],
              [0,0,1]])
c4 = np.array([[0,0,0],
              [0,1,0],
              [0,0,0]])
xy = np.concatenate([
    np.dot(np.dot(tcs[:6,], c4), c4.T),
    np.dot(np.dot(tcs[6:12,], c4), c4.T),
    np.dot(np.dot(tcs[12:,], c4), c4.T)], axis=0)

model_features = [rsatoolbox.data.Dataset(np.array(xy))]
model_cue = rsatoolbox.rdm.calc_rdm(model_features)

# model_stim ________________________________________________________________________________

stim = np.array([1,2,3])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

c1 = np.array([[1,0,0],
              [0,0,0],
              [0,0,1]])
c2 = np.array([[1,0,0],
              [0,1,0],
              [0,0,0]])
c3 = np.array([[0,0,0],
              [0,1,0],
              [0,0,1]])
c4 = np.array([[0,0,0],
              [0,1,0],
              [0,0,0]])
c5 = np.array([[0,0,0],
              [0,0,0],
              [0,0,1]])
xy = np.concatenate([
    np.dot(np.dot(tcs[:6,], c5),np.eye(3)),
    np.dot(np.dot(tcs[6:12,], c5), np.eye(3)),
    np.dot(np.dot(tcs[12:,], c5), np.eye(3))], axis=0)

model_features = rsatoolbox.data.Dataset(np.array(xy))
model_stim = rsatoolbox.rdm.calc_rdm(model_features)

# model_grid ________________________________________________________________________________
stim = np.array([1,0,-1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

model_features = [rsatoolbox.data.Dataset(np.array(tcs))]
model_grid = rsatoolbox.rdm.calc_rdm(model_features)

# model_rotationgrid __________________________________________________________________________
stim = np.array([1,0,-1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

c1 = np.array([[1,0,0],
              [0,0,0],
              [0,0,1]])
c2 = np.array([[1,0,0],
              [0,1,0],
              [0,0,0]])
c3 = np.array([[0,0,0],
              [0,1,0],
              [0,0,1]])
c4 = np.array([[0,0,0],
              [0,1,0],
              [0,0,0]])
c5 = np.array([[0,0,0],
              [0,0,0],
              [0,0,1]])
rot = np.array([[1,0,0],
                [0, np.cos(np.deg2rad(90)), np.sin(np.deg2rad(90))],
                [0, -np.sin(np.deg2rad(90)), np.cos(np.deg2rad(90))]])

xy = np.concatenate([
    np.dot(tcs[:6,], rot),
    tcs[6:12,],
    tcs[12:,]],
    axis=0)

model_features = [rsatoolbox.data.Dataset(np.array(xy))]
model_rotationgrid = rsatoolbox.rdm.calc_rdm(model_features)


# model_diagonal ________________________________________________________________________________

stim = np.array([1,0,-1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

P = np.array([[1,0],[0, np.cos(np.deg2rad(45))],[0, np.sin(np.deg2rad(45))]])
xy = np.dot(tcs, P)

model_features = [rsatoolbox.data.Dataset(np.array(xy))]
model_diagonal = rsatoolbox.rdm.calc_rdm(model_features)


# model_parallel ________________________________________________________________________________
stim = np.array([1,0,-1])
cue = np.array([ 1, 1, 1, -1, -1, -1])
task = np.array([1, 0, -1])
t = np.repeat(task, 6)
s = np.tile(stim, 6)
c = np.tile(cue, 3)

tcs = np.vstack((t,c,s)).T

c1 = np.array([[1,0,0],
              [0,0,0],
              [0,0,1]])
c2 = np.array([[1,0,0],
              [0,1,0],
              [0,0,0]])
c3 = np.array([[0,0,0],
              [0,1,0],
              [0,0,1]])
c4 = np.array([[0,0,0],
              [0,1,0],
              [0,0,0]])
c5 = np.array([[0,0,0],
              [0,0,0],
              [0,0,1]])
rot = np.array([[1,0,0],
                [0, np.cos(np.deg2rad(90)), np.sin(np.deg2rad(90))],
                [0, -np.sin(np.deg2rad(90)), np.cos(np.deg2rad(90))]])
result = np.dot(np.dot(tcs[:6,], c2), rot)
xy = np.concatenate([
    result,
    np.dot(tcs[6:12,], c1),
    np.dot(tcs[12:,], c2)], axis=0)

model_feaures = rsatoolbox.data.Dataset(np.array(xy))
model_parallel = rsatoolbox.rdm.calc_rdm(model_feaures)

# stack models ________________________________________________________________________________
rdm_model = np.vstack([model_orthogonal.dissimilarities[0],
                       model_cue.dissimilarities[0],
                       model_stim.dissimilarities[0],
                       model_grid.dissimilarities[0],
                       model_rotationgrid.dissimilarities[0],
                       model_diagonal.dissimilarities[0],
                       model_parallel.dissimilarities[0]])

# rdm_model
model_rdms_copycat = rsatoolbox.rdm.RDMs(rdm_model,
                                         rdm_descriptors={
    'model_names':['orthogonal', 'cue', 'stim', 'grid', 'rotationgrid', 'diagonal', 'parallel']},
    pattern_descriptors = {'cond_names':expect_df.condition},
                            dissimilarity_measure='Euclidean'
                           )

models = []
model_names = ['orthogonal', 'cue', 'stim', 'grid', 'rotationgrid', 'diagonal', 'parallel']
for i_model in np.unique(model_names):
    rdm_m = model_rdms_copycat.subset('model_names', i_model)
    m = rsatoolbox.model.ModelFixed(i_model, rdm_m)
    models.append(m)

print('created the following models:')
for i in range(len(models)):
    print(models[i].name)

results_1 = rsatoolbox.inference.eval_fixed(models, data_rdms, method='corr')
fig, ax, ret_val = rsatoolbox.vis.plot_model_comparison(results_1)
fig.savefig('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv06_RDMmodelcomparison/temp_rdm.png', bbox_inches='tight', dpi=300)

print(results_1)
