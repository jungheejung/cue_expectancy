% load singletrial as fmri_data object
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial'; %'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
cd singletrial_dir;
filename_pattern = filenames('*/*_runtype-pain_event-stimulus_*.nii');
pain_st = fmri_data(fullfile(singletrial_dir,filename_pattern));
% 
[values, components, full_data_objects, l2norms] = extract_gray_white_csf(pain_st);

myTable = table(filename_pattern, values);
myTable = table(filename_pattern, values(:, 1), values(:, 2), values(:, 3),...
    'VariableNames', {'fname', 'graymatter', 'whitematter', 'csf'});
writetable(myTable, '/Users/h/Documents/projects_local/cue_expectancy/scripts/step10_nilearn/whitematter_csf/whitematter_csf_pain.csv');