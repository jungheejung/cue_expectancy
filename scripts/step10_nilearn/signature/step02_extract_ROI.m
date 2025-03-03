function step02_extract_ROI()
    % addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step08_applyNPS')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'));
    % addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns'))
    % addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Atlases_and_parcellations'))
    
    % Purpose of this code: to apply NPS to the extracted singletrials.
    %% 1. load filenames as fmri_data
    current_dir = pwd;
%     main_dir = fileparts(fileparts(fileparts(current_dir)));
    nps_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_painpathway';
    singletrial_dir = fullfile('/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');
%     singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial');
%     nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'nilearn', 'signature_canlabcore');
    d = dir(singletrial_dir);
    dfolders = d([d(:).isdir]);
    dfolders = dfolders(~ismember({dfolders(:).name},{'.','..','archive','beh','sub-0000'}));
    % Further filter to include only folders that start with "sub-"
    dfolders_remove = dfolders(startsWith({dfolders.name}, 'sub-'));

    key = 'stimulus';
    sub_list = {dfolders_remove.name};
    for sub_ind = 1:length(sub_list)
        disp(sub_ind)
            sub = sub_list{sub_ind};
            test_files = dir(fullfile(singletrial_dir, sub, sprintf('*_event-%s*.nii.gz', key)));

    sub = sub;    ses = '*';    run = '*';    runtype = 'pain';    event = 'stimulus';
    fname_template = fullfile(singletrial_dir, sub, ...
    strcat(sub, '_', ses, '_', run, '_runtype-', runtype, '_event-', event,'*.nii.gz'));
    fname_list = dir(fname_template);
    flist4table = {fname_list.name};
    output_table = cell2table(flist4table', 'VariableNames', {'singletrial_fname'});

    dat = fmri_data(filenames(fname_template));
    %% 2. load pain pathwy object
    % pathway_obj = ''
    pain_pathways = load_atlas(which('pain_pathways_atlas_obj.mat'));
    % full areas
%     pain_pathways = pain_pathways.select_atlas_subset({'Thal_VPLM_R','Thal_VPLM_L','Thal_IL','Thal_MD',...
%     'Hythal','pbn_R','pbn_L','Bstem_PAG','rvm_R','Amy_R','Amy_L','dpIns_L','dpIns_R','S2_L','S2_R','mIns_L','mIns_R',...
%     'aIns_L','aIns_R','aMCC_MPFC','s1_foot_L','s1_foot_R','s1_handplus_L','s1_handplus_R'});
%     pain_pathways_mean = extract_roi_averages(dat, fmri_data(pain_pathways), 'unique_mask_values', 'nonorm');
%     % output_table
%     output_table = [ table(pain_pathways_mean.dat, 'VariableNames', pain_pathways.labels)  output_table]; 
%     table_fname = fullfile(nps_dir, strcat(sub,'_roi-painpathway_runtype-pain_event-', event, '.csv'));
%     writetable(output_table, table_fname, 'Delimiter',',');



    pain_pathways_subset = pain_pathways.select_atlas_subset({'dpIns', 'aMCC_MPFC', 'Thal_VPLM','Thal_MD', });
    pain_pathways_subset_mean = extract_roi_averages(dat, fmri_data(pain_pathways_subset), 'unique_mask_values', 'nonorm');
    output_table = [ table(pain_pathways_subset_mean.dat, 'VariableNames', pain_pathways_subset.labels)  output_table]; 
    table_fname = fullfile(nps_dir, strcat(sub,'_roi-painpathwaysubset_runtype-pain_event-', event, '.csv'));
    writetable(output_table, table_fname, 'Delimiter',',');
    end
%     table_fname = fullfile(nps_dir, strcat('roi-painpathway_sub-all_runtype-pvc_event-', event, '.tsv'));
%     writetable(output_table, table_fname, 'Delimiter',' ');
end