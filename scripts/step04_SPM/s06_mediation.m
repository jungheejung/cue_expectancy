% s06_ab_ttest

pain_t = dir('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/pain/1stLevel/*.nii');    
pain_fldr = {pain_t.folder}; fname = {pain_t.name};
pain_scan_files = strcat(pain_fldr,'/', fname)';
spm('Defaults','fMRI')
pain_fd = fmri_data(pain_scan_files);

% vicarious
vic_t = dir('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/vicarious/1stLevel/*.nii');    
vic_fldr = {vic_t.folder}; fname = {vic_t.name};
vic_scan_files = strcat(vic_fldr,'/', fname)';
spm('Defaults','fMRI')
vic_fd = fmri_data(vic_scan_files);

cog_t = dir('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/cognitive/1stLevel/*.nii');    
cog_fldr = {cog_t.folder}; fname = {cog_t.name};
cog_scan_files = strcat(cog_fldr,'/', fname)';
spm('Defaults','fMRI')
cog_fd = fmri_data(cog_scan_files);

pain_dat = ttest(pain_fd);
vic_dat = ttest(vic_fd);
cog_dat = ttest(cog_fd);

% /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/pain/2ndLevel
pain_dat.fullpath = fullfile('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/pain/2ndLevel', 'med_onesamplet_P.nii');
write(pain_dat, 'overwrite')
vic_dat.fullpath = fullfile('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/vicarious/2ndLevel', 'med_onesamplet_V.nii');
write(vic_dat, 'overwrite')
cog_dat.fullpath = fullfile('/Volumes/social/analysis/fmri/spm/univariate/mediation_ab/med_X-cue_M-stim_Y-actual/cognitive/2ndLevel', 'med_onesamplet_C.nii');
write(cog_dat, 'overwrite')

P_fdr = threshold(pain_dat, .05, 'unc');
V_fdr = threshold(vic_dat, .05, 'unc');
C_fdr = threshold(cog_dat, .05, 'unc');

% montage(P_fdr);
create_figure('montage'); axis off
drawnow, snapnow;
montage(P_fdr);
saveas(gcf,'../../figures/med_X-cue_M-stim_Y-actual_P_unc.png');
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(V_fdr);
saveas(gcf,'../../figures/med_X-cue_M-stim_Y-actual_V_unc.png');
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(C_fdr);
saveas(gcf,'../../figures/med_X-cue_M-stim_Y-actual_C-unc.png');
close all
