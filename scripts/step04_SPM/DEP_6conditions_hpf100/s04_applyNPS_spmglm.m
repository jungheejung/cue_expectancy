function applynps_spmglm(input, main_dir)
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
contrast_name = {'P_VC_cue_high_gt_low','V_PC_cue_high_gt_low', 'C_PV_cue_high_gt_low',...
'P_VC_stimlin_high_gt_low', 'V_PC_stimlin_high_gt_low', 'C_PV_stimlin_high_gt_low',...
'P_VC_stimquad_med_gt_other', 'V_PC_stimquad_med_gt_other', 'C_PV_stimquad_med_gt_other',...
'P_VC_cue_int_stimlin','V_PC_cue_int_stimlin', 'C_PV_cue_int_stimlin',...
'P_VC_cue_int_stimquad','V_PC_cue_int_stimquad','C_PV_cue_int_stimquad',...
'motor',...
'P_simple_cue_high_gt_low', 'V_simple_cue_high_gt_low', 'C_simple_cue_high_gt_low',...
'P_simple_stimlin_high_gt_low', 'V_simple_stimlin_high_gt_low', 'C_simple_stimlin_high_gt_low',...
'P_simple_stimquad_med_gt_other', 'V_simple_stimquad_med_gt_other', 'C_simple_stimquad_med_gt_other',...
'P_simple_cue_int_stimlin', 'V_simple_cue_int_stimlin', 'C_simple_cue_int_stimlin',...
'P_simple_cue_int_stimquad','V_simple_cue_int_stimquad','C_simple_cue_int_stimquad',...
'P_simple_highcue_highstim', 'P_simple_highcue_medstim', 'P_simple_highcue_lowstim',...
'P_simple_lowcue_highstim', 'P_simple_lowcue_medstim', 'P_simple_lowcue_lowstim',...
'V_simple_highcue_highstim', 'V_simple_highcue_medstim', 'V_simple_highcue_lowstim',...
'V_simple_lowcue_highstim', 'V_simple_lowcue_medstim', 'V_simple_lowcue_lowstim',...
'C_simple_highcue_highstim', 'C_simple_highcue_medstim', 'C_simple_highcue_lowstim',...
'C_simple_lowcue_highstim', 'C_simple_lowcue_medstim', 'C_simple_lowcue_lowstim'
};
%% 2. test run
current_dir = pwd;
disp(strcat('contrasts num: ', input));
con = strcat('con_', sprintf('%04d', input));
%main_dir = fileparts(fileparts(current_dir));
disp(main_dir);
glm_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_6cond','1stLevel');
nps_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_6cond', 'extract_nps');
d = dir(glm_dir);
dfolders = d([d(:).isdir]);
dfolders_remove = dfolders(~ismember({dfolders(:).name},{'.','..','sub-0000','sub-0002'}));
sub_list = {dfolders_remove.name};
% key_list = {'pain-early', 'pain-late', 'pain-post', 'pain-plateau', 'pain'};
% sub = char(sub_list(input));
group = [];

for sub = 1:length(sub_list)
    dat = [];
    subject = [];
    s = []; sub_table = [];
    test_file = [];
    meta_nifti = [];
    test_file = fullfile(glm_dir, sub_list(sub), strcat(con, '.nii'));
    disp(strcat('loading ', sub_list(sub), ' test file: ', test_file));
    if isfile(test_file)

        %
        %% Xiaochun code
        dat = fmri_data(test_file);
        disp(which('brainmask.nii'));        
        refmask = fmri_data('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask.nii');  % shell image

% glm_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model-03_CEScsA_24dofcsd', '1stLevel');
        nps = which('weights_NSF_grouppred_cvpcr.img');
        npspos = which('weights_NSF_positive_smoothed_larger_than_10vox.img');
        npsneg = which('weights_NSF_negative_smoothed_larger_than_10vox.img');
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
        clneg_corr = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'correlation', 'contiguous_regions', 'nonorm');
        clneg_cosine = extract_roi_averages(all_dat2, npsneg, 'pattern_expression', 'cosine_similarity', 'contiguous_regions', 'nonorm');
        npsneg_exp_by_region = cat(2, clneg.dat);
        npsneg_corr_exp_by_region = cat(2, clneg_corr.dat);
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
        s = table(subject);
        sub_table = [s dat.metadata_table];
        group = [group; sub_table];


        
    else
        disp(strcat('participant ', sub_list(sub), ' does not have ', 'con', ' nifti file'));
        continue
    end
    if ~exist(char(fullfile(nps_dir )), 'dir')
        mkdir(char(fullfile(nps_dir)))
    end
    disp(strcat("complete job", sub_list(sub)));
end
    disp(group);
    table_fname = fullfile(nps_dir,  strcat('extract-nps_model01-6cond_',con,'-',contrast_name{input},'.csv'));
    writetable(group, table_fname);
    % clear dat meta_nifti test_file
    

end



