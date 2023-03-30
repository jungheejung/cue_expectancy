function step02_extract_ROI()
    % addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step08_applyNPS')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'));
    % addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns'))
    % addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Atlases_and_parcellations'))
    
    % Purpose of this code: to apply NPS to the extracted singletrials.
    %% 1. load filenames as fmri_data
    current_dir = pwd;
    main_dir = fileparts(fileparts(fileparts(current_dir)));
    singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial');
    nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'signature_canlabcore');
    d = dir(singletrial_dir);
    dfolders = d([d(:).isdir]);
    dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
    sub_list = {dfolders_remove.name};
    sub = '*';    ses = '*';    run = '*';    runtype = '*';    event = 'stimulus';
    test_file = dir(fullfile(singletrial_dir, sub, ...
    strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz')));
    flist4table = {test_file.name};
    output_table = cell2table(flist4table', "VariableNames",  ["singletrial_fname"]);

    dat = fmri_data(fullfile(test_file.folder, test_file.name));
    %% 2. load pain pathwy object
    % pathway_obj = ''
    pain_pathways = load_atlas(which('pain_pathways_atlas_obj.mat'));
    pain_pathways = pain_pathways.select_atlas_subset({'dpIns', 'aMCC_MPFC', 'Thal_VPLM','Thal_MD'});
    pain_pathways_mean = extract_roi_averages(dat, fmri_data(pain_pathways), 'unique_mask_values', 'nonorm');
    % output_table
    output_table = [ table(pain_pathways_mean.dat, 'VariableNames', pain_pathways.labels)  output_table]; 


    table_fname = fullfile(nps_dir, strcat('roi-painpathway_sub-all_runtype-pvc_event-', event, '.tsv'));
    writetable(output_table, table_fname, 'Delimiter',' ');
