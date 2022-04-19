#!/usr/bin/env python3
"""
move smoothed files from datalad to separate repository
We want to keep files modular
* fmriprep smooth source: /dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep/sub-0066/ses-03/func
* smooth destination: /dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/smooth_6mm
"""

import os, shutil, glob
from pathlib import Path
from os.path import join
import json

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

spacetop_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop'
smooth_glob = glob.glob(join(spacetop_dir, 'derivatives','fmriprep', '*', '*', 'func', 'smooth_6mm_*MNI152NLin2009cAsym_desc-preproc_bold.nii'))

for gname in sorted(smooth_glob):
    filename = Path(gname).stem
    # smooth_6mm_sub-0026_ses-03_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii
    entities = dict(
    match.split('-')
    for match in filename.split('_')
    if '-' in match
    )
    sub_str = f"sub-{int(entities['sub']):04d}"
    ses_str = f"ses-{int(entities['ses']):02d}"
    task_str = f"task-{entities['task']}"
    run_str = f"run-{int(entities['run']):01d}"

    dest_fpath = join(spacetop_dir, 'derivatives', 'smooth_6mm', sub_str, ses_str, 'func')
    dest_fname = f"smooth_6mm_{sub_str}_{ses_str}_{task_str}_acq-mb8_{run_str}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii"
    Path(dest_fpath).mkdir(parents=True,exist_ok=True)
    print(f"source is {gname}")
    print(f"destination is {join(dest_fpath,dest_fname)}")
    shutil.move(gname, join(dest_fpath,dest_fname))