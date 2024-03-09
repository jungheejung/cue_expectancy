function step02_apply_NPS()
    % TODO: 
    %% 1. Data directories and parameters
    current_dir = pwd;
    main_dir = fileparts(fileparts(current_dir));
    % sub-0060_ses-04_run-05_runtype-pain_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz
    % sub-0060_ses-04_run-06_runtype-cognitive_event-stimulus_trial-000_cuetype-low_stimintensity-high.nii.gz
    
    %% 2. test run
    % main_dir = '/Volumes/spacetop_projects_social';
    singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial');
    nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'signature_canlabcore');
    d = dir(singletrial_dir);
    dfolders = d([d(:).isdir]);
    dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
    sub_list = {dfolders_remove.name};
    key_list = {'cue', 'stimulus'};
    % sub = char(sub_list(input));
    ses = '*';    run = '*';    runtype = '*';    event = 'stimulus';

    % for s = 1:length(sub_list)
    %     sub = char(sub_list(s)); 
    for k = 1:length(key_list)
        
        key = char(key_list(k));
        dat = [];
        meta_nifti = [];
        % glob all files
        test_file = dir(fullfile(singletrial_dir, sub, ...
        strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', key,'*.nii.gz')));
        flist4table = {test_file.name}
        output_table = cell2table(flist4table', "VariableNames",  ["singletrial_fname"])

        [nps_values,image_names, ~, npspos_exp_by_region, npsneg_exp_by_region] = apply_nps(data_objects);