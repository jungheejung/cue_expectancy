clear all;
clc;

subject = {};

contrastName ={ 'cue_P', 'cue_V', 'cue_C', 'cue_G',...
'stim_P', 'stim_V', 'stim_C', 'stim_G', ...
'stimXcue_P', 'stimXcue_V', 'stimXcue_C', 'stimXcue_G',...
'stimXactual_P', 'stimXactual_V', 'stimXactual_C', 'stimXactual_G', 'motor'};
contrast_folder = {'con-01_cue_P-gt-VC', 'con-02_cue_V-gt_PC', 'con-03_cue_C-gt-PV', 'con-04_cue_G',...
'con-05_stim_P-gt-VC', 'con-06_stim_V-gt-PC', 'con-07_stim_C-gt-PV', 'con-08_stim_G',...
'con-09_stimXcue_P-gt-VC', 'con-10_stimXcue_V-gt-PC', 'con-11_stimXcue_C-gt-PV', 'con-12_stimXcue_G',...
'con-13_stimXactual_P-gt-VC', 'con-14_stimXactual_V-gt-PC', 'con-15_stimXactual_C-gt-PV', 'con-16_stimXactual_G',...
'con-17_motor'};

main_dir = '/Users/h/Documents/projects_local/conformity.01';

contrast_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'model-01_CcEScaA', '1stLevel' );
matlabbatch = cell(1,2);

for con_num = 1: length(contrastName) % 1: NoC              number of contrast
    disp( contrastName{con_num} );
    %% design matrix ______________________________________________________
    scan_files = cell(length(subject),1);

    for sub_num = 1:length(subject) % for each participant - find the contrast
        con_fname = fullfile(contrast_dir, strcat('sub-', subject{sub_num}), ...
            strcat('con_', sprintf('%04d', con_num), '.nii'));
        scan_files{sub_num,1}= con_fname;
    end

    second_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'model-01_CcEScaA',...
        '2ndLevel',contrast_folder{con_num});
    if 0==exist(second_dir ,'dir')
        mkdir(second_dir);
    end


    matlabbatch{1}.spm.stats.factorial_design.dir = cellstr( second_dir );
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scan_files;

    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;


    %% estimation ______________________________________________________________
    spm_fname= fullfile( second_dir, 'SPM.mat' );
    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(spm_fname);
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


    est_fname = fullfile(second_dir, 'secondlevel_estimation_matlabbatch.mat' );
    save( est_fname  ,'matlabbatch');

    % run ______________________________________________________________
    spm_jobman('run',matlabbatch);
    clearvars matlabbatch
end
