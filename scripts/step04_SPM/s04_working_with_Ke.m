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
% pain
pain_t = dir('/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel/*/spmT_0005.nii');    
pain_fldr = {pain_t.folder}; fname = {pain_t.name};
pain_scan_files = strcat(pain_fldr,'/', fname)';
spm('Defaults','fMRI')
pain_fd = fmri_data(pain_scan_files);

% vicarious
vic_t = dir('/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel/*/spmT_0006.nii');    
vic_fldr = {vic_t.folder}; fname = {vic_t.name};
vic_scan_files = strcat(vic_fldr,'/', fname)';
spm('Defaults','fMRI')
vic_fd = fmri_data(vic_scan_files);

cog_t = dir('/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel/*/spmT_0007.nii');    
cog_fldr = {cog_t.folder}; fname = {cog_t.name};
cog_scan_files = strcat(cog_fldr,'/', fname)';
spm('Defaults','fMRI')
cog_fd = fmri_data(cog_scan_files);

gen_t = dir('/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel/*/spmT_0008.nii');    
gen_fldr = {gen_t.folder}; fname = {gen_t.name};
gen_scan_files = strcat(gen_fldr,'/', fname)';
spm('Defaults','fMRI')
gen_fd = fmri_data(gen_scan_files);

%% 4 t maps
pain_dat = ttest(pain_fd);
vic_dat = ttest(vic_fd);
cog_dat = ttest(cog_fd);
gen_dat = ttest(gen_fd);

pain_dat.fullpath = fullfile('/Users/h/Documents/projects_local/social_influence_analysis/figures', 'stim_P_T.nii');
write(pain_dat)
vic_dat.fullpath = fullfile('/Users/h/Documents/projects_local/social_influence_analysis/figures', 'stim_V_T.nii');
write(vic_dat)
cog_dat.fullpath = fullfile('/Users/h/Documents/projects_local/social_influence_analysis/figures', 'stim_C_T.nii');
write(cog_dat)
gen_dat.fullpath = fullfile('/Users/h/Documents/projects_local/social_influence_analysis/figures', 'stim_G_T.nii');
write(gen_dat)
%% parametric analysis
P_fdr = threshold(pain_dat, .05, 'fdr');
V_fdr = threshold(vic_dat, .05, 'fdr');
C_fdr = threshold(cog_dat, .05, 'fdr');
G_fdr = threshold(gen_dat, .05, 'fdr');

% montage(P_fdr);
create_figure('montage'); axis off
drawnow, snapnow;
montage(P_fdr);
saveas(gcf,'../../figures/STIMpsmod_fdr_01pain.png');
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(V_fdr);
saveas(gcf,'../../figures/STIMpmod_fdr_02vicarious.png');
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(C_fdr);
saveas(gcf,'../../figures/STIMpmod_fdr_03cognitive.png');
close all

create_figure('montage'); axis off
drawnow, snapnow;
montage(G_fdr);
saveas(gcf,'../../figures/STIMpmod_fdr_04general.png');
close all


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

%initialize pain bf map
pain_tstat1 = pain_bf;
thres = 1;
for i=1:length(pain_bf.dat)
   if pain_bf.dat(i) > thres &&  vic_bf.dat(i) < -1*thres   && cog_bf.dat(i) < -1*thres  && pain_dat.dat(i) > 0
%    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
       pain_tstat1.dat(i) = 1;
   else
       pain_tstat1.dat(i)=0;
   end
end


create_figure('montage'); axis off
drawnow, snapnow;
montage(pain_tstat1);
saveas(gcf,'../../figures/STIMbayesfactor_01pain.png');
close all


%% vicarious
vic_tstat1 = vic_bf;
thres = 1;
for i=1:length(vic_bf.dat)
   if vic_bf.dat(i) > thres && pain_bf.dat(i) < -1*thres  && cog_bf.dat(i) < -1*thres && pain_dat.dat(i) > 0
%    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
       vic_tstat1.dat(i) = 1;
   else
       vic_tstat1.dat(i)=0;
   end
end

create_figure('montage'); axis off
drawnow, snapnow;
montage(vic_tstat1);
saveas(gcf,'../../figures/STIMbayesfactor_02vicarious.png');
close all
% orthviews(pain_tstat1)

%% cognitive fix code
cog_tstat1 = cog_bf;
thres = 1;
for i=1:length(cog_bf.dat)
   if cog_bf.dat(i) > thres && pain_bf.dat(i) < -1*thres  && vic_bf.dat(i) < -1*thres && pain_dat.dat(i) > 0
%    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
       cog_tstat1.dat(i) = 1;
   else
       cog_tstat1.dat(i)=0;
   end
end


create_figure('montage'); axis off
drawnow, snapnow;
montage(cog_tstat1);
saveas(gcf,'../../figures/STIMbayesfactor_03cognitive.png');
close all

%% general fix code
gen_tstat1 = gen_bf;
thres = 1;
for i=1:length(gen_bf.dat)
   if gen_bf.dat(i) > thres && gen_dat.dat(i) > 0
%    if BF_RegNeg.dat(i) >Threshold && BF_NegNeu.dat(i) >Threshold && tRegNeg.dat(i)>0 && tNegNeu.dat(i)>0  && tbase.dat(i)>0
       gen_tstat1.dat(i) = gen_bf.dat(i);
   else
       gen_tstat1.dat(i)=0;
   end
end


create_figure('montage'); axis off
drawnow, snapnow;
montage(gen_tstat1);
saveas(gcf,'../../figures/STIMbayesfactor04_general.png');
close all


gen_tstat1 = gen_bf;
thres = 2.2;
for i=1:length(gen_bf.dat)
   if gen_bf.dat(i) < thres && gen_dat.dat(i) > 0
       gen_tstat1.dat(i) = gen_bf.dat(i);
   else
       gen_tstat1.dat(i)=0;
   end
end

create_figure('montage'); axis off
drawnow, snapnow;
montage(gen_tstat1);
saveas(gcf,'../../figures/STIMbayesfactor_04general_favornull.png');
close all