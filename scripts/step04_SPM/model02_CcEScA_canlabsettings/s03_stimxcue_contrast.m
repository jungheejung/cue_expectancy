% load fMRI object
% 
% tNegNeu= ttest(NegMinusNeu)
% t2 = threshold(tNegNeu, .05, 'fdr')
% orthviews(t2)
% BF_RegNeg=estimateBayesFactor(tRegNeg,'t');   %%%%Bayes factor
% orthviews(BF_RegNeg_th)
% 

%% check first level contrast
% con_list = dir('/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel/*/spmT_0001.nii');
% con_fldr = {con_list.folder}; fname = {con_list.name};
% con_names = strcat(con_fldr,'/', fname)';
% con = fmri_data(con_names);
% orthviews(con)
clear all
close all
main_dir = '/Volumes/spacetop_projects_social';
spm_1stlevel_dir = fullfile(main_dir,'analysis','fmri','spm','univariate','model-02_CcEScA_canlabsettings','1stLevel');

% expect pain (simple effect)
pain_t = dir(fullfile(spm_1stlevel_dir, '*/spmT_0013.nii'));    
pain_fldr = {pain_t.folder}; fname = {pain_t.name};
pain_scan_files = strcat(pain_fldr,'/', fname)';
spm('Defaults','fMRI')
pain_fd = fmri_data(pain_scan_files);

% expect vicarious (simple effect)
vic_t = dir(fullfile(spm_1stlevel_dir,'*/spmT_0014.nii'));    
vic_fldr = {vic_t.folder}; fname = {vic_t.name};
vic_scan_files = strcat(vic_fldr,'/', fname)';
spm('Defaults','fMRI')
vic_fd = fmri_data(vic_scan_files);

% expect cognitive (simple effect)
cog_t = dir(fullfile(spm_1stlevel_dir,'*/spmT_0015.nii'));    
cog_fldr = {cog_t.folder}; fname = {cog_t.name};
cog_scan_files = strcat(cog_fldr,'/', fname)';
spm('Defaults','fMRI')
cog_fd = fmri_data(cog_scan_files);

% expect general (simple effect)
% gen_t = dir(fullfile(spm_1stlevel_dir,'*/spmT_0016.nii'));    
% gen_fldr = {gen_t.folder}; fname = {gen_t.name};
% gen_scan_files = strcat(gen_fldr,'/', fname)';
% spm('Defaults','fMRI')
% gen_fd = fmri_data(gen_scan_files);

% expect motor (simple effect)
% motor_t = dir(fullfile(spm_1stlevel_dir,'*/spmT_0017.nii'));    
% motor_fldr = {motor_t.folder}; fname = {motor_t.name};
% motor_scan_files = strcat(motor_fldr,'/', fname)';
% spm('Defaults','fMRI')
% motor_fd = fmri_data(motor_scan_files);

%% 4 t maps
pain_dat = ttest(pain_fd);
vic_dat = ttest(vic_fd);
cog_dat = ttest(cog_fd);
% gen_dat = ttest(gen_fd);
% motor_dat = ttest(motor_fd);

save_dir = fullfile(main_dir,'/figure/spm_univariate_model/model-02_CcEScA_canlabsettings');
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end
if ~exist(fullfile(save_dir,'stimxcue_contrast'), 'dir');
    mkdir(fullfile(save_dir,'stimxcue_contrast'));
end
pain_dat.fullpath = fullfile(save_dir,'stimxcue_contrast', 'stimxcue_P_gt_VC_T.nii');
write(pain_dat)
vic_dat.fullpath = fullfile(save_dir,'stimxcue_contrast', 'stimxcue_V_gt_PC_T.nii');
write(vic_dat)
cog_dat.fullpath = fullfile(save_dir,'stimxcue_contrast', 'stimxcue_C_gt_PV_T.nii');
write(cog_dat)
% gen_dat.fullpath = fullfile(save_dir, 'stimxcue_G_T.nii');
% write(gen_dat)
% motor_dat.fullpath = fullfile(save_dir, 'motor_T.nii');
% write(motor_dat)

%% parametric analysis
P_fdr = threshold(pain_dat, .05, 'fdr');
V_fdr = threshold(vic_dat, .05, 'fdr');
C_fdr = threshold(cog_dat, .05, 'fdr');
% G_fdr = threshold(gen_dat, .05, 'fdr');
% M_fdr = threshold(motor_dat, .05, 'fdr');

%% montage(P_fdr);
create_figure('montage'); axis off
drawnow, snapnow;
montage(P_fdr);
saveas(gcf, fullfile(save_dir,'stimxcue_contrast','stimxcue_P_gt_VC_fdr_01pain.png'));

P_unc = threshold(pain_dat, .005, 'unc', 'k', 10);
montage(P_unc)
drawnow, snapnow;
saveas(gcf, fullfile(save_dir,'stimxcue_contrast','stimxcue_P_gt_VC_unc_01pain.png'));
close all
%% V
create_figure('montage'); axis off
drawnow, snapnow;
montage(V_fdr);
saveas(gcf,fullfile(save_dir,'stimxcue_contrast','stimxcue_V_gt_PC_fdr_02vicarious.png'));

V_unc = threshold(vic_dat, .005, 'unc', 'k', 10);
montage(V_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'stimxcue_contrast','stimxcue_V_gt_PC_unc_02vicarious.png'));
close all

%% C
create_figure('montage'); axis off
drawnow, snapnow;
montage(C_fdr);
saveas(gcf,fullfile(save_dir,'stimxcue_contrast','stimxcue_C_gt_PV_fdr_03cognitive.png'));

C_unc = threshold(cog_dat, .005, 'unc', 'k', 10);
montage(C_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'stimxcue_contrast','stimxcue_C_gt_PV_unc_03cognitive.png'));
close all
