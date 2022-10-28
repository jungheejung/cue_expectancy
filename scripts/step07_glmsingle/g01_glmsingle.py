import numpy as np
import pandas as pd
import scipy
import scipy.stats as stats
import scipy.io as sio
import matplotlib.pyplot as plt
import nibabel as nib
import nilearn
from nilearn import image
from pathlib import Path 
import itertools

import os, sys, glob, re
from os.path import join, exists, split
import urllib.request
import copy
import warnings
from tqdm import tqdm
from pprint import pprint
warnings.filterwarnings('ignore')
import time
import argparse

import glmsingle
from glmsingle.glmsingle import GLM_single

__author__ = "cvnlab"
__copyright__ = "Spatial Topology Project"
__credits__ = [""] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

cluster = 1
if cluster:
    glmsingle_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/GLMsingle'
#     fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'
    fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
    current_dir = os.getcwd()
    main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
else:
    glmsingle_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/GLMsingle'
    fmriprep_dir = '/Volumes/spacetop/derivatives/fmriprep'
    main_dir = '/Volumes/spacetop_projects_social'

main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'

datadir = join(main_dir,'analysis','fmri','glmsingle','data')
outputdir = join(main_dir,'analysis','fmri','glmsingle','output')
Path(datadir).mkdir(parents=True, exist_ok=True)
Path(outputdir).mkdir(parents=True, exist_ok=True)
print(f'directory to save example dataset:\n\t{datadir}\n')
print(f'directory to save example1 outputs:\n\t{outputdir}\n')

onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/data/d03_onset/onset02_SPM'


# sub_ind = [73]
ttl_key = 'plateau'
# task = 'pain'
ses_list = [1,3,4]

parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
                    help="specify slurm array id")
parser.add_argument("-r", "--runtype",
                    choices=['pain','vicarious','cognitive','all'], help="specify runtype name (e.g. pain, cognitive, variance)")
args = parser.parse_args()


# parser.add_argument("-o", "--operating",
#                     choices=['local', 'discovery'],
#                     help="specify where jobs will run: local or discovery")
print(args.slurm_id)
sub_ind = [args.slurm_id] # e.g. 1, 2
runtype = args.runtype # e.g. 'task-social' 'task-fractional' 'task-alignvideos'
print(sub_ind)

# ttl_dir = {
#     'early':'d06_singletrial_SPM_01-pain-early',
#     'late':'d06_singletrial_SPM_02-pain-late',
#     'post':'d06_singletrial_SPM_03-pain-post',
#     'plateau':'d06_singletrial_SPM_04-pain-plateau'
# }
# ses = sys.argv[2]
design = []
extra = []
data = []
ses_indicator = []

beh_list = []
sub_ses = list(itertools.product(sub_ind, ses_list))

for i, (sub_ind, ses_ind) in enumerate(sub_ses):
    sub = f'sub-{sub_ind:04d}'
    ses = f'ses-{ses_ind:02d}'
#    /sub-0061/ses-04/sub-0061_ses-04_task-social_run-06-pain_events_ttl.tsv
# TODO
# if pain, see if ttl exists. If so, glob them. if not, use ordinary pain run
# if not pain, glob corresponding
# iff all, glob pain and 
    if runtype == 'pain':
        beh_names = sorted(glob.glob(join(onset_dir,  sub, ses,  f"{sub}_{ses}_task-social_run-*-pain_events_ttl.tsv")))
    elif runtype == 'vicarious' or 'cognitive':
        beh_names = sorted(glob.glob(join(onset_dir,  sub, ses,  f"{sub}_{ses}_task-social_run-*-{runtype}_events.tsv")))
    elif runtype == 'all':
        v_names = sorted(glob.glob(join(onset_dir,  sub, ses,  f"{sub}_{ses}_task-social_run-*-vicarious_events.tsv")))
        c_names = sorted(glob.glob(join(onset_dir,  sub, ses,  f"{sub}_{ses}_task-social_run-*-cognitive_events.tsv")))
        p_names = sorted(glob.glob(join(onset_dir,  sub, ses,  f"{sub}_{ses}_task-social_run-*-pain_events_ttl.tsv")))
        beh_names = [v_names, c_names, p_names]
    
    #beh_list = glob.glob(join(main_dir, 'data', 'dartmouth', 'd02_preprocessed', sub, ses,  f"{sub}_{ses}_task-social_run-*-pain_beh.csv"))
    Path(join(datadir, sub)).mkdir(parents=True, exist_ok=True)
    Path(join(outputdir, sub)).mkdir(parents=True, exist_ok=True)
    beh_list.append(beh_names)

flat_list = [item for sublist in beh_list for item in sublist]

stimdur = 5
tr = 0.46


ses_ind = []
design = []
extra = []
data = []
ses_indicator = []
for beh_fname in flat_list:
    # extract info from globbed files
    beh_basename = os.path.basename(beh_fname)
    ses_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "ses" in match][0])[0])
    run_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "run" in match][0])[0])
    task_name = re.match("(run)-(\d+)-(\w+)", [match for match in beh_basename.split('_') if "run" in match][0])[3]
    ses = 'ses-{:02d}'.format(ses_num)
    run = 'run-{:02d}'.format(run_num)
    print(f"sub: {sub}, ses: {ses}, run: {run}")
    # load csv and clean 
    beh = pd.read_csv(beh_fname, sep = '\t')
    # TODO, check if plataeu exists
    # ttl = pd.read_csv(join(main_dir, 'data', 'dartmouth', ttl_dir[ttl_key], sub, f"{sub}_singletrial_{ttl_key}.csv"))
    metafiles = glob.glob(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial*.csv"))
    if len(metafiles) > 1:
        meta = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial_plateau.csv"))
    else:
        meta = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial.csv"))
    rating = pd.read_csv(join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_{ses}_{run}_covariate-circularrating.csv"))
    run_df = meta[((meta['ses'] == ses_num)& (meta['run'] == run_num) & (meta['ev'] == 'stim'))]
    run_df.insert(2, 'cond_name', np.nan)
    # %% building <design> from glmsingle _______________________________________________________________
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='low_stim')), 'cond_name'] = int(0)
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='med_stim')), 'cond_name'] = int(1)
    run_df.loc[((run_df['cue_type'] == 'low_cue') & (run_df['stim_type']  =='high_stim')),'cond_name'] = int(2)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='low_stim')), 'cond_name'] = int(3)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='med_stim')), 'cond_name'] = int(4)
    run_df.loc[((run_df['cue_type'] == 'high_cue') & (run_df['stim_type'] =='high_stim')),'cond_name'] = int(5)

    design_df = pd.DataFrame(columns = ['order', 'onset', 'condition_type', 'cue', 'stim', 'task'])
    onset = run_df['onset']
    df_dict = {'order':list(range(len(run_df))), 
    'onset':np.array(run_df['onset']), 
    'condition_type':run_df['cond_name'], 
    'task':task_name}
    design_df = pd.DataFrame.from_dict(df_dict)
    # design_df['condition_name'] = design_df['condition_type'].map(cond_name_inv)
    design_df['tr'] = round(design_df['onset'].apply(lambda x: float(x))/0.46).astype(int) # round(design_df['onset']/0.46).astype(int)
    design_df['condition_type'] = design_df['condition_type'].astype(int)
    dim_x = 872;    dim_y = 6
    order_tr = list(design_df[['tr','condition_type']].apply(tuple, axis = 1))
    design_mat = np.zeros((dim_x, dim_y), dtype = int)
    for el_x, el_y in order_tr:
        design_mat[el_x-1, el_y] = 1
    design.append(design_mat)
    
    xtra_y = 1;
    rating_onset = rating['rating']#pd.concat([ev2,ev4],ignore_index = True)
    motion_fname = join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_{ses}_task-social_{run}_confounds-subset.txt")
    motion_df = pd.read_csv(motion_fname, sep = '\t', header = None)
    rating_tr = round(rating_onset/0.46).astype(int)
    # load motion covariates and concat
    rating_df = pd.DataFrame(np.zeros(dim_x), dtype = int)
    for x in rating_tr:
        rating_df.iloc[x-1, 0] = 1
    extra_df = pd.concat([rating_df, motion_df], axis = 1)
    extra.append(np.array(extra_df))

    nii_name = join(fmriprep_dir, sub, ses, 'func', f"{sub}_{ses}_task-social_acq-mb8_run-{run_num}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz")
    print(nii_name)
    nilearn_data = image.load_img(nii_name) 
    data.append(nilearn_data.get_fdata())

    ses_ind.append(ses_num)


a = np.array(ses_ind)
x,ses_ind_zerobased = np.unique(a,return_inverse = True)
print(f"number of runs in this dataset: {len(data)}")
print(f"list of sessions: {ses_ind}")

# print some relevant metadata
print(f'* There are {len(data)} runs in total')
print(f'* N = {data[0].shape[3]} TRs per run')
print(f'* The dimensions of the data for each run are: {data[0].shape}')
print(f'* The stimulus duration is {stimdur} seconds')
print(f'* XYZ dimensionality is: {data[0].shape[:3]} (one slice only in this example)')
print(f'* Numeric precision of data is: {type(data[0][0,0,0,0])}')
outputdir_glmsingle = join(outputdir,sub, runtype)
figuredur = join(outputdir, sub, runtype, 'figure')
Path(join(outputdir_glmsingle)).mkdir(parents=True, exist_ok=True) # (main_dir,'analysis','fmri','glmsingle','output', 'sub-0001', 'task-social')
Path(figuredur).mkdir(parents=True,exist_ok=True)
opt = dict()

opt['wantlibrary'] = 1
opt['wantglmdenoise'] = 0
opt['wantfracridge'] = 1

opt['wantfileoutputs'] = [1,1,0,1]
opt['wantmemoryoutputs'] = [1,1,1,1]
# opt['sessionindicator'] = [1, 1]
#opt['extra_regressors'] = False
opt['sessionindicator'] = list(ses_ind_zerobased +1)
opt['chunklen'] = 50000
glmsingle_obj = GLM_single(opt)

pprint(glmsingle_obj.params) 


start_time = time.time()

if not exists(join(outputdir_glmsingle,'TYPED_FITHRF_GLMDENOISE_RR.npy')):

    print(f'running GLMsingle...')
    
    # run GLMsingle
    results_glmsingle = glmsingle_obj.fit(
       design,
       data,
       stimdur,
       tr,
       outputdir=outputdir_glmsingle,
        figuredir=figuredur)
    # we assign outputs of GLMsingle to the "results_glmsingle" variable.
    # note that results_glmsingle['typea'] contains GLM estimates from an ONOFF model,
    # where all images are treated as the same condition. these estimates
    # could be potentially used to find cortical areas that respond to
    # visual stimuli. we want to compare beta weights between conditions
    # therefore we are not going to include the ONOFF betas in any analyses of 
    # voxel reliability
    
else:
    print(f'loading existing GLMsingle outputs from directory:\n\t{outputdir_glmsingle}')
    
    # load existing file outputs if they exist
    results_glmsingle = dict()
    results_glmsingle['typea'] = np.load(join(outputdir_glmsingle,'TYPEA_ONOFF.npy'),allow_pickle=True).item()
    results_glmsingle['typeb'] = np.load(join(outputdir_glmsingle,'TYPEB_FITHRF.npy'),allow_pickle=True).item()
    results_glmsingle['typec'] = np.load(join(outputdir_glmsingle,'TYPEC_FITHRF_GLMDENOISE.npy'),allow_pickle=True).item()
    results_glmsingle['typed'] = np.load(join(outputdir_glmsingle,'TYPED_FITHRF_GLMDENOISE_RR.npy'),allow_pickle=True).item()

elapsed_time = time.time() - start_time

print(
    '\telapsed time: ',
    f'{time.strftime("%H:%M:%S", time.gmtime(elapsed_time))}'
)
