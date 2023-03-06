#!/usr/bin/env python

import pandas as pd
from scipy import signal
import matplotlib.pyplot as plt
import numpy as np
import neurokit2 as nk
import os, glob
import argparse
from pathlib import Path

# TODO: why is the plot showing us a v shaped line, instead of a vertical line? How do I fix this?
# TODO: make the line color the same
# 0. parameters
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
physio_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/physio/physio03_bids/task-cue/'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
save_figdir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/figure/physio/qc/raw_eda'
parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
                    help="specify slurm array id")
parser.add_argument("--session-num", type=int,
                    help="specify session number")
args = parser.parse_args()
print(args.slurm_id)
slurm_id = args.slurm_id
ses_num = args.session_num
sub_folders = next(os.walk(physio_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
# TODO; TEST for now, feed in subject id directly
# sub = sub_list[slurm_id]
sub = sub_list[slurm_id]
ses = 'ses-{:02d}'.format(ses_num)
print(f" ________ {sub} {ses} ________")

# physio: load physio tsv ___________

physio_flist = glob.glob(os.path.join(physio_dir, sub, ses, f"{sub}_{ses}_task-cue*recording-ppg-eda-trigger_physio.tsv"))
print(physio_flist)
for physio_fname in physio_flist:
    print(physio_fname)    
    physio = pd.read_csv(physio_fname, sep = '\t')
    samplingrate = 2000
    physio.plot(y = "physio_eda")

    #extract meta datta from physio filename
    fname = os.path.basename(physio_fname)

    # sub_num = int([match for match in fname.split('_') if "sub" in match][0].split('-')[1])
    # ses_num = int([match for match in fname.split('_') if "ses" in match][0].split('-')[1])
    run_num = int([match for match in fname.split('_') if "run" in match][0].split('-')[1])
    runtype = [k for k in ['pain', 'cognitive', 'vicarious'] if k in fname][0]
    # sub = f"sub-{sub_num:04d}"
    # ses = f"ses-{ses_num:02d}"
    run = f"run-{run_num:02d}"

    scr_signal = nk.signal_sanitize(
        physio['physio_eda'])
    scr_filters = nk.signal_filter(scr_signal,
                                    sampling_rate=samplingrate,
                                    highcut=1,
                                    method="butterworth",
                                    order=2)  # ISABEL: Detrend
    scr_detrend = nk.signal_detrend(scr_filters)
    physio['eda_preproc'] = scr_detrend

    # %% physio: down sample method 1
    x = np.arange(0,872,1)
    sampling_rate = 2000
    fmri_rate = 1/.46
    number_of_samples = round(len(physio) * float(fmri_rate) / sampling_rate)
    resampled_data = signal.resample(physio["eda_preproc"], number_of_samples)
    resampled_ttl = signal.resample(physio["trigger_heat"], number_of_samples)

    # %% fmriprep: plot motion covariate
    
    confounds_fname = os.path.join(fmriprep_dir, sub, ses, 'func', f"{sub}_{ses}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv") 
    confounds = pd.read_csv(confounds_fname, sep = '\t')
    filter_col = []
    filter_col = [col for col in confounds if col.startswith('motion')]
    # combine physio info to motion df
    confounds['physio'] = resampled_data
    threshold, upper, lower = (max(resampled_ttl)-min(resampled_ttl))/2, 1, 0
    confounds['trigger_heat'] = np.where(resampled_ttl>threshold, upper, lower) * -1 # resampled_ttl/15 

    # grab the indices of the motion covariates. we will plot the indexes
    motion_outlier_idx= []
    for col in filter_col:
        ind = np.where(confounds[col])
        motion_outlier_idx.append(ind[0][0])
    ys = np.zeros(len(motion_outlier_idx))

    #motion_outlier_idx: [216, 222, 265, 362, 363, 364, 424, 495, 700, 701]
    #ys: array([1., 1., 1., 1., 1., 1., 1., 1., 1., 1.])
    filter_col.append('physio')
    filter_col.append('trigger_heat')
    fig, axes = plt.subplots(ncols=1, figsize=(30, 10))
    plt.ylim([min(confounds['physio'])-0.1, max(confounds['physio'])+0.1 ])
    plt.axvline(x = 7, color = 'b', label = 'axvline - full height')

    plt.plot(confounds[filter_col], alpha=1, linewidth=2 )
    plt.plot(confounds['physio'], alpha=1, linewidth=10, )

    # plot indices of motion covariates
    for x,y in zip(motion_outlier_idx,ys):
        plt.text(x, y + .15, x,
                color = 'gray', rotation = 60,
                rotation_mode = 'anchor', fontsize = 10)
    
    plt.xlabel('time (872 TRs)',fontsize = 20)
    plt.ylabel('EDA amplitude (downsample + filter + detrend)', fontsize = 20)
    plt.title(f"{sub}_{ses}_{run}_{runtype}", fontsize= 40)
    plt.show()
    save_figsubdir = os.path.join(save_figdir, sub)
    Path(save_figsubdir).mkdir(parents = True, exist_ok = True)
    fig.savefig(os.path.join(save_figsubdir, f'qc-eda_{sub}_{ses}_{run}_runtype-{runtype}_desc-motioncovariate.png'),dpi = 300)
