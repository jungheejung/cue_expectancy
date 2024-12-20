% function applynps_singletrial(input)
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
% contrast_name = {'cue_P', 'cue_V', 'cue_C',...
% 'stim_P', 'stim_V', 'stim_C',...
% 'stimXcue_P', 'stimXcue_V', 'stimXcue_C',...
% 'stimXint_P', 'stimXint_V', 'stimXint_C',...
% 'motor', ...
% 'simple_cue_P', 'simple_cue_V', 'simple_cue_C','simple_cue_G',...
% 'simple_stim_P', 'simple_stim_V', 'simple_stim_C','simple_stim_G',...
% 'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C','simple_stimXcue_G',...
% 'simple_stimXint_P', 'simple_stimXint_V','simple_stimXint_C', 'simple_stimXint_G'};
% 
% % fname_key = {'cognitive_ev-cue_l2norm', 'cognitive_ev-cue', 'cognitive_ev-stim_l2norm', 'cognitive_ev-stim',...
%     'pain_ev-cue_l2norm', 'pain_ev-cue', 'pain_ev-stim_l2norm', 'pain_ev-stim',...
%     'vicarious_ev-cue_l2norm', 'vicarious_ev-cue', 'vicarious_ev-stim_l2norm', 'vicarious_ev-stim'};
fname_key = {'*'};
input = 1;
%% 2. test run
current_dir = pwd;
main_dir = fileparts(fileparts(current_dir));
%main_dir = '/Volumes/spacetop_projects_social';
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau_nosmooth'; %uncompressed_singletrial_rampupplateau';%'/Volumes/seagate/cue_singletrials/uncompressed_singletrial_rampupplateau'; %fullfile(main_dir, 'analysis', 'fmri', 'spm', 'multivariate_24dofcsd', 's03_concatnifti');
nps_dir = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv05_canlabapplyNPS_nosmooth';
d = dir(singletrial_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..', 'archive','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
group = [];

for sub = 1:length(sub_list)
    if ~exist(char(fullfile(nps_dir, sub_list(sub))), 'dir')
        mkdir(char(fullfile(nps_dir, sub_list(sub))))
    end
    dat = [];    subject = [];   s = []; sub_table = [];    test_file = [];
    meta_nifti = [];
    nii_files = dir(char(fullfile(singletrial_dir, sub_list(sub), char(strcat('*.nii.gz')))));
%     nii_filenames = fullfile(string({nii_files.folder}), string({nii_files.name}));
    nii_filenames = char(arrayfun(@(f) fullfile(f.folder, f.name), nii_files, 'UniformOutput', false));
    % for fl = 1:length(nii_files)i
    disp(nii_files)
    if ~isempty(nii_filenames)
%         test_file = fullfile(nii_files(1).folder, nii_files(1).name);
%     disp(strcat('loading ', sub_list(sub), ' test file: ', test_file));
    %if isfile(test_file)
        
        dat = fmri_data(nii_filenames);
%         fname = nii_files.name(1:strfind(nii_files.name,'.')-1);
        refmask = fmri_data('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii');  % shell image
        nps = which('weights_NSF_grouppred_cvpcr.img');
        npspos = which('weights_NSF_positive_smoothed_larger_than_10vox.img.gz');
        npsneg = which('weights_NSF_negative_smoothed_larger_than_10vox.img.gz');
        posnames = {'vermis'    'rIns'    'rV1'    'rThal'    'lIns'    'rdpIns'    'rS2_Op'    'dACC'};
        negnames = {'rLOC'    'lLOC'    'rpLOC'    'pgACC'    'lSTS'    'rIPL'    'PCC'};
        
        npsw = resample_space(fmri_data(nps), refmask);
        npsposw = resample_space(fmri_data(npspos), refmask);
        npsnegw = resample_space(fmri_data(npsneg), refmask);
        
        nps_values = apply_mask(dat, npsw, 'pattern_expression', 'ignore_missing');
        nps_corr_values = apply_mask(dat, npsw, 'pattern_expression', 'correlation', 'ignore_missing');
        nps_cosine_values = apply_mask(dat, npsw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        npspos_values = apply_mask(dat, npsposw, 'pattern_expression', 'ignore_missing');
        npspos_corr_values = apply_mask(dat, npsposw, 'pattern_expression', 'correlation', 'ignore_missing');
        npspos_cosine_values = apply_mask(dat, npsposw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        npsneg_values = apply_mask(dat, npsnegw, 'pattern_expression', 'ignore_missing');
        npsneg_corr_values = apply_mask(dat, npsnegw, 'pattern_expression', 'correlation', 'ignore_missing');
        npsneg_cosine_values = apply_mask(dat, npsnegw, 'pattern_expression', 'cosine_similarity', 'ignore_missing');
        
        all_dat2 = resample_space(dat, npspos);
        clpos = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'contiguous_regions', 'nonorm');
        clpos_corr = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'correlation', 'contiguous_regions', 'nonorm');
        clpos_cosine = extract_roi_averages(all_dat2, npspos, 'pattern_expression', 'cosine_similarity', 'contiguous_regions', 'nonorm');
        npspos_exp_by_region = cat(2, clpos.dat);
        npspos_corr_exp_by_region = cat(2, clpos_corr.dat);
        npspos_cosine_exp_by_region = cat(2, clpos_cosine.dat);
        
        clneg = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'contiguous_regions', 'nonorm');
        try
            clneg_corr = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'correlation', 'contiguous_regions', 'nonorm');
        catch
            clneg_corr = fmri_data();
            clneg_corr.dat = nan(size(npspos_corr_values));
        end

        clneg_cosine = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'cosine_similarity', 'contiguous_regions', 'nonorm');
        npsneg_exp_by_region = cat(2, clneg.dat);
        npsneg_corr_exp_by_region = cat(2, clneg.dat);%#cat(2, clneg_corr.dat);
        npsneg_cosine_exp_by_region = cat(2, clneg_cosine.dat);
        
        dat.metadata_table.nps = nps_values;
        dat.metadata_table.nps_corr = nps_corr_values;
        dat.metadata_table.nps_cosine = nps_cosine_values;
        
        dat.metadata_table.npspos = npspos_values;
        dat.metadata_table.npspos_corr = npspos_corr_values;
        dat.metadata_table.npspos_cosine = npspos_cosine_values;
        
        dat.metadata_table.npsneg = npsneg_values;
        dat.metadata_table.npsneg_corr = npsneg_corr_values;
        dat.metadata_table.npsneg_cosine = npsneg_cosine_values;
        %% Save
        for p = 1:length(posnames)
            pos_value_name{p} = ['pos_nps_',posnames{p}];
            pos_corr_name{p} = ['pos_nps_',posnames{p},'_corr'];
            pos_cosine_name{p} = ['pos_nps_',posnames{p},'_cosine'];
            temp_npspos = table(npspos_exp_by_region(:,p), 'VariableNames',pos_value_name(p));
            temp_npspos_corr = table(npspos_corr_exp_by_region(:,p), 'VariableNames',pos_corr_name(p));
            temp_npspos_cosine = table(npspos_cosine_exp_by_region(:,p), 'VariableNames',pos_cosine_name(p));
            
            dat.metadata_table = [dat.metadata_table temp_npspos temp_npspos_corr temp_npspos_cosine];
        end
        
        for p = 1:length(negnames)
            neg_value_name{p} = ['neg_nps_',negnames{p}];
            neg_corr_name{p} = ['neg_nps_',negnames{p},'_corr'];
            neg_cosine_name{p} = ['neg_nps_',negnames{p},'_cosine'];
            temp_npsneg = table(npsneg_exp_by_region(:,p), 'VariableNames',neg_value_name(p));
            temp_npsneg_corr = table(npsneg_corr_exp_by_region(:,p), 'VariableNames',neg_corr_name(p));
            temp_npsneg_cosine = table(npsneg_cosine_exp_by_region(:,p), 'VariableNames',neg_cosine_name(p));
            
            dat.metadata_table = [dat.metadata_table temp_npsneg temp_npsneg_corr temp_npsneg_cosine];
        end
        subject = sub_list(sub);
        fname_noext = fname_key(input);
        s = table(subject);
%         f = table(nii_filenames);%fname_noext);
%         a = [s f];
        ftable = table(char(nii_files.name), 'VariableNames', {'filename'});

        sub_table = [repmat(s,  size(dat.metadata_table,1),1), ftable, dat.metadata_table];
        group = [group; sub_table];
        sub_fname = fullfile(nps_dir, sub_list(sub), strcat('extract-NPS_', sub_list(sub),'.csv')); %'_', fname_noext, '.csv'));
        disp(sub_fname);
        writetable(sub_table, char(sub_fname));
	
    else
        disp(strcat('participant ', sub_list(sub), ' does not have ', 'con', ' nifti file'));
    end
    
    disp(strcat("complete job", sub_list(sub)));
end




