function applyVPS_spmglm(input)
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
% current_dir = pwd;
% main_dir = fileparts(fileparts(current_dir));
contrast_name = {'cue_P', 'cue_V', 'cue_C', 'cue_G',...
    'cueXcue_P', 'cueXcue_V', 'cueXcue_C', 'cueXcue_G',...
    'stim_P', 'stim_V', 'stim_C', 'stim_G',...
    'stimXcue_P', 'stimXcue_V', 'stimXcue_C', 'stimXcue_G',...
    'motor', ...
    'simple_cue_P', 'simple_cue_V', 'simple_cue_C',...
    'simple_cueXcue_P', 'simple_cueXcue_V', 'simple_cueXcue_C', ...
    'simple_stim_P', 'simple_stim_V', 'simple_stim_C',...
    'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C'};

%% 2. test run
current_dir = pwd;
con = strcat('con_', sprintf('%04d', input));
main_dir = fileparts(fileparts(current_dir));
disp(main_dir);
%main_dir = '/Volumes/spacetop_projects_social';
singletrial_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model-02_CcEScA', '1stLevel');
vps_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate','model-02_CcEScA', 'extract_vps');
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
group = [];
for sub = 1:length(sub_list)
    dat = [];
    subject = [];
    s = []; sub_table = [];
    test_file = [];
    meta_nifti = [];
    test_file = fullfile(singletrial_dir, sub_list(sub), strcat(con, '.nii'));
    disp(strcat('loading ', sub_list(sub), ' test file: ', test_file));
    if isfile(test_file)
        dat = fmri_data(test_file);
        
        refmask = fmri_data(which('brainmask.nii'));  % shell image
        vps = which('bmrk4_VPS_unthresholded.nii');
        vpsw = resample_space(fmri_data(vps), refmask);
%         
        vps_values = apply_mask(dat, vpsw, 'pattern_expression', 'ignore_missing');
        vps_corr_values = apply_mask(dat, vpsw, 'pattern_expression', 'correlation', 'ignore_missing');
        vps_cosine_values = apply_mask(dat, vpsw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        
        dat.metadata_table.vps = vps_values;
        dat.metadata_table.vps_corr = vps_corr_values;
        dat.metadata_table.vps_cosine = vps_cosine_values;
        
        subject = sub_list(sub);
        s = table(subject);
        sub_table = [s dat.metadata_table];
        group = [group; sub_table];
        
    else
        disp(strcat('participant ', sub_list(sub), ' does not have ', 'con', ' nifti file'));
    end
    if ~exist(char(fullfile(vps_dir, 'model-02_CcEScA')), 'dir')
        mkdir(char(fullfile(vps_dir, 'model-02_CcEScA')))
    end
    disp(strcat("complete job", sub_list(sub)));
end
    table_fname = fullfile(vps_dir, 'model-02_CcEScA', strcat('model-02_CcEScA_', con, '_biomarker-VPS.csv'));
    writetable(group, table_fname);
    % clear dat meta_nifti test_file
    

end



