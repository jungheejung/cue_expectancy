#!/usr/bin/env python3
"""
during the smoothing process, nifti files are unzipped
check if .nii.gz exists. if so, deleted the .nii file. 
"""

import os, shutil, glob
from pathlib import Path
from os.path import join

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

spacetop_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop'
preproc_glob = glob.glob(join(spacetop_dir, 'derivatives', 'fmriprep','*', '*', 'func', 'sub-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii'))

for nii in preproc_glob:
    nii_gz = str(nii) + '.gz'
    print(nii_gz)
    if nii_gz:
        print("remove")
        # os.remove(nii)