function applyVPS_singletrial(input)
% This code is to apply NPS to the TTL extracted pain onsets.
% The purpose is to identify the correct way to model HRF of pain elicited BOLD signals.
%%  TODO:
% 1. load filenames as fmri_data
% Inputs

% Inputs:
% -------------------------------------------------------------------------
% input_images           multiple formats:
%                        - fmri_data object (or other image_vector object)
%                        - fmri_data objects (or other image_vector objects) in cell { }
%                        - list of image names
%                        - cell { } with multiple lists of image names
%                        - image wildcard (NOTE: uses filenames.m, needs
%                        system compatibility)
%                        - cell { } with multiple image wildcards
% Optional inputs:
% 'noverbose'           suppress screen output
%                       not recommended for first run, as verbose output
%                       prints info about missing voxels in each image
% 'notables'            suppress text table output with images and values
%
%                       Note:Similarity metric passed through to canlab_pattern_similarity
% 'cosine_similarity'   Use cosine similarity measure instead of dot product
% 'correlation'         Use correlation measure instead of dot product

%% 1. Data directories and parameters
current_dir = pwd;
main_dir = fileparts(fileparts(current_dir));
contrast_name = {'cue_P', 'cue_V', 'cue_C',...
'stim_P', 'stim_V', 'stim_C',...
'stimXcue_P', 'stimXcue_V', 'stimXcue_C',...
'stimXint_P', 'stimXint_V', 'stimXint_C',...
'motor', ...
'simple_cue_P', 'simple_cue_V', 'simple_cue_C','simple_cue_G',...
'simple_stim_P', 'simple_stim_V', 'simple_stim_C','simple_stim_G',...
'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C','simple_stimXcue_G',...
'simple_stimXint_P', 'simple_stimXint_V','simple_stimXint_C', 'simple_stimXint_G'};
fname_key = {'cognitive_ev-cue_l2norm', 'cognitive_ev-cue', 'cognitive_ev-stim_l2norm', 'cognitive_ev-stim',...
    'pain_ev-cue_l2norm', 'pain_ev-cue', 'pain_ev-stim_l2norm', 'pain_ev-stim',...
    'vicarious_ev-cue_l2norm', 'vicarious_ev-cue', 'vicarious_ev-stim_l2norm', 'vicarious_ev-stim'};
%% 2. test run

singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate_24dofcsd', 's03_concatnifti');
vps_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate_24dofcsd','s04_extractbiomarker');
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
group = [];

for sub = 1:length(sub_list)
    if ~exist(char(fullfile(vps_dir, sub_list(sub))), 'dir')
        mkdir(char(fullfile(vps_dir, sub_list(sub))))
    end
    dat = [];    subject = [];   s = []; sub_table = [];    test_file = [];
    meta_nifti = [];
    nii_files = dir(char(fullfile(singletrial_dir, sub_list(sub), char(strcat('*',fname_key(input),'*.nii')))));
    % for fl = 1:length(nii_files)
    test_file = fullfile(nii_files.folder, nii_files.name);
    disp(strcat('loading ', sub_list(sub), ' test file: ', test_file));
    if isfile(test_file)
        
        dat = fmri_data(test_file);
        fname = nii_files.name(1:strfind(nii_files.name,'.')-1);
        refmask = fmri_data(which('brainmask.nii'));  % shell image
        vps = '/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Multivariate_signature_patterns/2016_Krishnan_eLife_VPS/bmrk4_VPS_unthresholded.nii';
        vpsw = resample_space(fmri_data(vps), refmask);
        vps_values = apply_mask(dat, vpsw, 'pattern_expression', 'ignore_missing');
        vps_corr_values = apply_mask(dat, vpsw, 'pattern_expression', 'correlation', 'ignore_missing');
        vps_cosine_values = apply_mask(dat, vpsw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        dat.metadata_table.vps = vps_values;
        dat.metadata_table.vps_corr = vps_corr_values;
        dat.metadata_table.vps_cosine = vps_cosine_values;
        
        % subject = repmat(sub_list(sub),size(dat.metadata_table,1),1);
        % fname = repmat(fname_noext,size(dat.metadata_table,1),1);
        % s = table(subject)
        % f = table(fname)
        % sub_table = [s dat.metadata_table];
        % group = [group; sub_table];
        subject = sub_list(sub);
        fname_noext = fname_key(input);
        % s = table(subject);
        % f = table(fname_noext);
        a = table(subject, fname_noext);
        % a = table(s, fname)
        sub_table = [repmat(a, size(dat.metadata_table,1),1) dat.metadata_table];
        group = [group; a];
        sub_fname = fullfile(vps_dir, sub_list(sub), strcat('extract-VPS_', sub_list(sub), '_', fname_noext, '.csv'));
        disp(sub_fname);
        writetable(sub_table, char(sub_fname));


    else
        disp(strcat('participant ', sub_list(sub), ' does not have ', 'con', ' nifti file'));
    end
    
    disp(strcat("complete job", sub_list(sub)));
end
table_fname = fullfile(vps_dir, char(strcat('extract-VPS_', fname_key(input), '.csv')));
writetable(group, char(table_fname));
% clear dat meta_nifti test_file


end



