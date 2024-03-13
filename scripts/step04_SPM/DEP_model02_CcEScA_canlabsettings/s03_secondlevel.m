function s03_secondlevel

addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12')); 
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); 
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model02_CcEScA_canlabsettings'));

contrast_name ={ 'cue_P', 'cue_V', 'cue_C', 'cue_G',...
'cueXcue_P', 'cueXcue_V', 'cueXcue_C', 'cueXcue_G',...
'stim_P', 'stim_V', 'stim_C', 'stim_G', ...
'stimXcue_P', 'stimXcue_V', 'stimXcue_C', 'stimXcue_G',...
'motor', ...
'simple_cue_P', 'simple_cue_V', 'simple_cue_C',...
'simple_cueXcue_P', 'simple_cueXcue_V', 'simple_cueXcue_C',...
'simple_stim_P', 'simple_stim_V', 'simple_stim_C',...
'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C'};

contrast_folder = {'con-01_cue_P-gt-VC', 'con-02_cue_V-gt_PC', 'con-03_cue_C-gt-PV', 'con-04_cue_G',...
'con-05_cuexcue_P-gt-VC', 'con-06_cuexcue_V-gt-PC', 'con-07_cuexcue_C-gt-PV', 'con-08_cuexcue_G',...
'con-09_stim_P-gt-VC', 'con-10_stim_V-gt-PC', 'con-11_stim_C-gt-PV', 'con-12_stim_G',...
'con-13_stimXcue_P-gt-VC', 'con-14_stimXcue_V-gt-PC', 'con-15_stimXcue_C-gt-PV', 'con-16_stimXcue_G',...
'con-17_motor',...
'con-18_simple_cue_P', 'con-19_simple_cue_V', 'con-20_simple_cue_C',...
'con-21_simple_cueXcue_P', 'con-22_simple_cueXcue_V', 'con-23_simple_cueXcue_C',...
'con-24_simple_stim_P', 'con-25_simple_stim_V', 'con-26_simple_stim_C',...
'con-27_simple_stimXcue_P', 'con-28_simple_stimXcue_V', 'con-29_simple_stimXcue_C'};

main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social';
contrast_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model-02_CcEScA_canlabsettings', '1stLevel' );
% main_dir = '/Users/h/Documents/projects_local/conformity.01';
% contrast_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'model-01_CcEScaA', '1stLevel' );

matlabbatch = cell(1,3);

for con_num = 1: length(contrast_name) % 1: NoC              number of contrast
    disp( contrast_name{con_num} );
    %% design matrix ______________________________________________________
    % scan_files = cell(length(subject),1);
    tnii = dir(fullfile(contrast_dir, '*', strcat('spmT_', sprintf('%04d', con_num), '.nii') ));
    fldr = {tnii.folder}; fname = {tnii.name};
    scan_files = strcat(fldr,'/', fname, ',1')'
    % scan_files = strcat(fldr,'/', fname)';
    %char_files = vertcat( scan_files{:} )
    % for sub_num = 1:length(subject) % for each participant - find the contrast
    %     con_fname = fullfile(contrast_dir, strcat('sub-', subject{sub_num}), ...
    %         strcat('con_', sprintf('%04d', con_num), '.nii'));
    %     scan_files{sub_num,1}= con_fname;
    % end

    second_dir = fullfile(main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model-02_CcEScA_canlabsettings',...
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
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    %% t stat ______________________________________________________________
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = contrast_name{con_num};
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;


    est_fname = fullfile(second_dir, 'secondlevel_estimation_matlabbatch.mat' );
    save( est_fname  ,'matlabbatch');

    % run ______________________________________________________________
    spm_jobman('run',matlabbatch);
    clearvars matlabbatch
end

end
