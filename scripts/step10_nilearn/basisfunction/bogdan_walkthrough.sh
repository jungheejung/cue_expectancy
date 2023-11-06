surface HCP: https://github.com/rmldj/hcp-utils/tree/master/hcp_utils/data
volumetric: /Users/h/Documents/MATLAB/spm12/canonical/cortex_5124.surf.gii 


# extract gii from cifti
/Applications/workbench/bin_macosx64/wb_command -cifti-separate /Users/h/Documents/projects_local/sandbox/fmriprep_bold/surface/sub-0061_ses-01_task-social_acq-mb8_run-1_space-fsLR_den-91k_bold.dtseries.nii \
COLUMN -metric CORTEX_LEFT test_left.func.gii

https://nbviewer.org/github/neurohackademy/nh2020-curriculum/blob/master/we-nibabel-markiewicz/NiBabel.ipynb
https://neurostars.org/t/how-to-read-a-cifti-file-header-with-nibabel/21341