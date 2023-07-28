% load singletrial as fmri_data object
singletrial_dir = '/Volumes/spacetop_projects_cue'; %'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
filename_pattern = filenames(fullfile(singletrial_dir, 'analysis/fmri/nilearn/singletrial/sub-*/sub-*_runtype-pain_event-stimulus_trial-*_cuetype-*.nii'));
pain_st = fmri_data(filename_pattern);
% 
[values, components, full_data_objects, l2norms] = extract_gray_white_csf(pain_st);