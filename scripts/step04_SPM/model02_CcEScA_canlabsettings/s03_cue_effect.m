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


% expect pain (simple effect)
pain_t = dir('/Volumes/social/analysis/fmri/spm/model-02_CcEScA_canlabsettings/1stLevel/*/spmT_0018.nii');    
pain_fldr = {pain_t.folder}; fname = {pain_t.name};
pain_scan_files = strcat(pain_fldr,'/', fname)';
spm('Defaults','fMRI')
pain_fd = fmri_data(pain_scan_files);

% expect vicarious (simple effect)
vic_t = dir('/Volumes/social/analysis/fmri/spm/model-02_CcEScA_canlabsettings/1stLevel/*/spmT_0019.nii');    
vic_fldr = {vic_t.folder}; fname = {vic_t.name};
vic_scan_files = strcat(vic_fldr,'/', fname)';
spm('Defaults','fMRI')
vic_fd = fmri_data(vic_scan_files);

% expect cognitive (simple effect)
cog_t = dir('/Volumes/social/analysis/fmri/spm/model-02_CcEScA_canlabsettings/1stLevel/*/spmT_0020.nii');    
cog_fldr = {cog_t.folder}; fname = {cog_t.name};
cog_scan_files = strcat(cog_fldr,'/', fname)';
spm('Defaults','fMRI')
cog_fd = fmri_data(cog_scan_files);

% expect general (simple effect)
gen_t = dir('/Volumes/social/analysis/fmri/spm/model-02_CcEScA_canlabsettings/1stLevel/*/spmT_0004.nii');    
gen_fldr = {gen_t.folder}; fname = {gen_t.name};
gen_scan_files = strcat(gen_fldr,'/', fname)';
spm('Defaults','fMRI')
gen_fd = fmri_data(gen_scan_files);

% expect motor (simple effect)
motor_t = dir('/Volumes/social/analysis/fmri/spm/model-02_CcEScA_canlabsettings/1stLevel/*/spmT_0017.nii');    
motor_fldr = {motor_t.folder}; fname = {motor_t.name};
motor_scan_files = strcat(motor_fldr,'/', fname)';
spm('Defaults','fMRI')
motor_fd = fmri_data(motor_scan_files);

%% 4 t maps
pain_dat = ttest(pain_fd);
vic_dat = ttest(vic_fd);
cog_dat = ttest(cog_fd);
gen_dat = ttest(gen_fd);
motor_dat = ttest(motor_fd);

save_dir = '/Volumes/spacetop_projects_social/figure/spm_univariate_model'
pain_dat.fullpath = fullfile(save_dir, 'cue_P_T.nii');
write(pain_dat)
vic_dat.fullpath = fullfile(save_dir, 'cue_V_T.nii');
write(vic_dat)
cog_dat.fullpath = fullfile(save_dir, 'cue_C_T.nii');
write(cog_dat)
gen_dat.fullpath = fullfile(save_dir, 'cue_G_T.nii');
write(gen_dat)
motor_dat.fullpath = fullfile(save_dir, 'motor_T.nii');
write(motor_dat)

%% parametric analysis
P_fdr = threshold(pain_dat, .05, 'fdr');
V_fdr = threshold(vic_dat, .05, 'fdr');
C_fdr = threshold(cog_dat, .05, 'fdr');
G_fdr = threshold(gen_dat, .05, 'fdr');
M_fdr = threshold(motor_dat, .05, 'fdr');

%% montage(P_fdr);
create_figure('montage'); axis off
drawnow, snapnow;
montage(P_fdr);
saveas(gcf, fullfile(save_dir,'cue_fdr_01pain.png'));

P_unc = threshold(pain_dat, .005, 'unc', 'k', 10);
montage(P_unc)
drawnow, snapnow;
saveas(gcf, fullfile(save_dir,'cue_unc_01pain.png'));

%% V
create_figure('montage'); axis off
drawnow, snapnow;
montage(V_fdr);
saveas(gcf,fullfile(save_dir,'cue_fdr_02vicarious.png'));

V_unc = threshold(vic_dat, .005, 'unc', 'k', 10);
montage(V_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'cue_unc_02vicarious.png'));
close all

%% C
create_figure('montage'); axis off
drawnow, snapnow;
montage(C_fdr);
saveas(gcf,fullfile(save_dir,'cue_fdr_03cognitive.png'));

C_unc = threshold(cog_dat, .005, 'unc', 'k', 10);
montage(C_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'cue_unc_03cognitive.png'));
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(G_fdr);
saveas(gcf,fullfile(save_dir,'cue_fdr_04general.png'));

G_unc = threshold(gen_dat, .005, 'unc', 'k', 10);
montage(G_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'cue_unc_04general.png'));
close all


%% montage(P_fdr);
create_figure('montage'); axis off
drawnow, snapnow;
montage(M_fdr);
saveas(gcf,fullfile(save_dir,'/motor_fdr.png'));

M_unc = threshold(motor_dat, .005, 'unc', 'k', 10);
montage(M_unc)
drawnow, snapnow;
saveas(gcf,fullfile(save_dir,'/motor_unc.png'));



%% bayesian analysis
pain_bf =estimateBayesFactor(pain_dat,'t'); % con-05_stim_P-gt-VC
vic_bf = estimateBayesFactor(vic_dat,'t'); % con-05_stim_P-gt-VC
cog_bf = estimateBayesFactor(cog_dat,'t'); % con-05_stim_P-gt-VC
gen_bf = estimateBayesFactor(gen_dat,'t');

orthviews(pain_bf)
orthviews(vic_bf)
orthviews(cog_bf)
orthviews(gen_bf)
% 1) pain bayes factor
% pain_bf > thres && Vbf < thres && Cbf < thres
% i) search for all voxels, 
% ii) t threshold (pain_dat > 0) greater than 0
% iii) dummy code, exclude negative values. 


% 20
% tdat = ttest(dat);
% t2 = threshold(tdat, .05, 'fdr');
% orthviews(t2)
% =estimateBayesFactor(tdat,'t');   %%%%Bayes factor
% BF_RegNeg=threshold(tdat, [-1000 -2.2], 'raw-between'); % not activated
% BF_RegNeg_th=threshold(tdat, [-1000 2.2], 'raw-outside'); %  activated
% orthviews(BF_RegNeg_th)

% %initialize pain bf map
% pain_tstat1 = pain_bf;
% thres = 2.2;
% for i=1:length(pain_bf.dat)
%    if pain_bf.dat(i) > thres && vic_bf.dat(i) < -1*thres  && cog_bf.dat(i) < -1*thres && pain_dat.dat(i) > 0
% %    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
%        pain_tstat1.dat(i) = 1;
%    else
%        pain_tstat1.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(pain_tstat1);
% saveas(gcf,'../../figures/CUEbayesfactor_01pain.png');
% close all


% %% vicarious
% vic_tstat1 = vic_bf;
% thres = 2.2;
% for i=1:length(vic_bf.dat)
%    if vic_bf.dat(i) > thres && pain_bf.dat(i) < -1*thres  && cog_bf.dat(i) < -1*thres && pain_dat.dat(i) > 0
% %    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
%        vic_tstat1.dat(i) = 1;
%    else
%        vic_tstat1.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(vic_tstat1);
% saveas(gcf,'../../figures/CUEbayesfactor_02vicarious.png');
% close all

% %% cognitive fix code
% cog_tstat1 = cog_bf;
% thres = 2.2;
% for i=1:length(cog_bf.dat)
%    if cog_bf.dat(i) > thres && pain_bf.dat(i) < -1*thres  && vic_bf.dat(i) < -1*thres && pain_dat.dat(i) > 0
% %    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
%        cog_tstat1.dat(i) = 1;
%    else
%        cog_tstat1.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(cog_tstat1);
% saveas(gcf,'../../figures/CUEbayesfactor_03cognitive.png');
% close all

% %% general fix code
% gen_tstat1 = gen_bf;
% thres = 2.2;
% for i=1:length(gen_bf.dat)
%    if gen_bf.dat(i) > thres && gen_dat.dat(i) > 0
% %    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
%        gen_tstat1.dat(i) = gen_bf.dat(i);
%    else
%        gen_tstat1.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(gen_tstat1);
% saveas(gcf,'../../figures/CUEbayesfactor_04general_favoralternative.png');
% close all


% %% general fix code
% gen_tstat2 = gen_bf;
% thres = 2.2;
% for i=1:length(gen_bf.dat)
%    if cog_bf.dat(i) > thres && pain_bf.dat(i) > thres  && vic_bf.dat(i) > thres && gen_dat.dat(i) > 0
% %    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
%        gen_tstat2.dat(i) = gen_bf.dat(i);
%    else
%        gen_tstat2.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(gen_tstat2);
% saveas(gcf,'../../figures/CUEbayesfactor_04general_favoralternative_v2.png');
% close all

% gen_tstat1 = gen_bf;
% thres = 2.2;
% for i=1:length(gen_bf.dat)
%    if gen_bf.dat(i) < thres && gen_dat.dat(i) > 0
%        gen_tstat1.dat(i) = gen_bf.dat(i);
%    else
%        gen_tstat1.dat(i)=0;
%    end
% end

% create_figure('montage'); axis off
% drawnow, snapnow;
% montage(gen_tstat1);
% saveas(gcf,'../../figures/CUEbayesfactor_04general_favornull.png');
% close all