nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial';
nifti_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial';
X = dir(fullfile(nifti_dir, '*', 'sub-0035*event-stimulus*stimintensity-*.nii.gz'));

flist = fmri_data(X);