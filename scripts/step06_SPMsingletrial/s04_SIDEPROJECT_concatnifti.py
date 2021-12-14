# TODO: use nibabel to stack niftis
# subject, environment variable
# directories
# %% libraries ________________________________________________________________________
import os, sys, glob, shutil
import pdb
from pathlib import Path
import itertools

# parameter ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

sub_num = int(float(sys.argv[1]))
sub = f"sub-{sub_num:04d}"
ses = int(float(sys.argv[2]))
run = int(float(sys.argv[3]))

print("STARTING fslmerge")
print(f"subject: {sub}")
task_list = ['pain', 'vicarious', 'cognitive']
event_list = ['cue', 'stim']

sub_nifti_dir = os.path.join(main_dir, 'analysis/fmri/spm/multivariate', 's02_isolatenifti', sub)
concat_dir = 
#TODO: glob all the nififiles while excluding those within "exclude"
niis = [log for log in glob.glob(os.path.join(sub_nifti_dir, '*.nii.gz')) if not os.path.isdir(log)]