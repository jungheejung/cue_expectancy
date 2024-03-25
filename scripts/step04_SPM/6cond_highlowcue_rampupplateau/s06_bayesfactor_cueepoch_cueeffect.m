clear all;
close all;

%% Overview ____________________________________________________________________
% The purpose of this script is to calculate bayes factor maps for cue effects during cue epoch. 
% Question: are there domain-general cue representations, across all modalities?
% What are the domain-specific cue representations?


%% Parameter ___________________________________________________________________
save_bayesdir = '/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau/BayesFactor';
nifti_save_dir = '/Users/h/Documents/projects_local/cue_expectancy/resources/plots_dissertation/SPM_univariate/6cond_highlowcue_rampupplateau';
nifti_save_fname_prefix = 'model01-6cond_epoch-cue_dummy-cuelinear';
mount_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau/1stlevel';
contrast_name = {
    'P_VC_STIM_cue_high_gt_low', 'V_PC_STIM_cue_high_gt_low', 'C_PV_STIM_cue_high_gt_low',...% contratss
    'P_VC_STIM_stimlin_high_gt_low', 'V_PC_STIM_stimlin_high_gt_low', 'C_PV_STIM_stimlin_high_gt_low',...
    'P_VC_STIM_stimquad_med_gt_other', 'V_PC_STIM_stimquad_med_gt_other', 'C_PV_STIM_stimquad_med_gt_other',...
    'P_VC_STIM_cue_int_stimlin','V_PC_STIM_cue_int_stimlin', 'C_PV_STIM_cue_int_stimlin',...
    'P_VC_STIM_cue_int_stimquad','V_PC_STIM_cue_int_stimquad','C_PV_STIM_cue_int_stimquad',...
    'motor',... %motor
    'P_simple_STIM_cue_high_gt_low',      'V_simple_STIM_cue_high_gt_low', 'C_simple_STIM_cue_high_gt_low',... % dummay contrasts
    'P_simple_STIM_stimlin_high_gt_low',  'V_simple_STIM_stimlin_high_gt_low', 'C_simple_STIM_stimlin_high_gt_low',...
    'P_simple_STIM_stimquad_med_gt_other','V_simple_STIM_stimquad_med_gt_other', 'C_simple_STIM_stimquad_med_gt_other',...
    'P_simple_STIM_cue_int_stimlin',      'V_simple_STIM_cue_int_stimlin', 'C_simple_STIM_cue_int_stimlin',...
    'P_simple_STIM_cue_int_stimquad',     'V_simple_STIM_cue_int_stimquad','C_simple_STIM_cue_int_stimquad',...
    'P_simple_STIM_highcue_highstim',     'P_simple_STIM_highcue_medstim', 'P_simple_STIM_highcue_lowstim',... % pain events
    'P_simple_STIM_lowcue_highstim',      'P_simple_STIM_lowcue_medstim', 'P_simple_STIM_lowcue_lowstim',...
    'V_simple_STIM_highcue_highstim',     'V_simple_STIM_highcue_medstim', 'V_simple_STIM_highcue_lowstim',... % vicarious events
    'V_simple_STIM_lowcue_highstim',      'V_simple_STIM_lowcue_medstim', 'V_simple_STIM_lowcue_lowstim',...
    'C_simple_STIM_highcue_highstim',    'C_simple_STIM_highcue_medstim', 'C_simple_STIM_highcue_lowstim',... % cognitive events
    'C_simple_STIM_lowcue_highstim',    'C_simple_STIM_lowcue_medstim', 'C_simple_STIM_lowcue_lowstim',...
    'P_VC_CUE_cue_high_gt_low','V_PC_CUE_cue_high_gt_low','C_PV_CUE_cue_high_gt_low',...% cue epoch contrasts
    'P_simple_CUE_cue_high_gt_low','V_simple_CUE_STIM_cue_high_gt_low','C_simple_CUE_cue_high_gt_low',...% cue epoch dummy
    'G_simple_CUE_cue_high_gt_low',...
    'P_VC_STIM', 'V_PC_STIM', 'C_PV_STIM'

};


%% 1. load t-map per cue effect (stim epoch) ___________________________________

% 1-1) pain ____________________________________________________________________
contrast_of_interest = 'P_simple_CUE_cue_high_gt_low';

index = find(strcmp(contrast_name, contrast_of_interest));
con_name = sprintf('*con_%04d_%s.nii', index, contrast_of_interest);
con_list = dir(fullfile(mount_dir, '*', con_name));
spm('Defaults','fMRI') 
con_fldr = {con_list.folder}; fname = {con_list.name};
con_files = strcat(con_fldr,'/', fname)';
con_data_obj = fmri_data(con_files);
% Pain only :: check data coverage
m = mean(con_data_obj);
m.dat = sum(~isnan(con_data_obj.dat) & con_data_obj.dat ~= 0, 2);
[wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
con = con_data_obj;
disp(strcat("current length is ", num2str(size(con_data_obj.dat,2))));

con.dat = con_data_obj.dat(:,~wh_outlier_corr);
con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);

disp(strcat("after removing ", num2str(sum(wh_outlier_corr)), " participants, size is now ",num2str(size(con.dat,2))));
[path,n,e] = fileparts(con_fldr(wh_outlier_corr));
disp(strcat("participants that are outliers:... ", n));
disp(n);
% Pain only :: plot diagnostics, after l2norm
imgs2 = con.rescale('l2norm_images');
% Pain only :: ttest
pain_t = ttest(imgs2);


% 1-2) Vicarious _______________________________________________________________
contrast_of_interest = 'V_simple_CUE_STIM_cue_high_gt_low';
index = find(strcmp(contrast_name, contrast_of_interest));
con_name = sprintf('*con_%04d_%s.nii', index, contrast_of_interest);
con_list = dir(fullfile(mount_dir, '*', con_name));
spm('Defaults','fMRI') 
con_fldr = {con_list.folder}; fname = {con_list.name};
con_files = strcat(con_fldr,'/', fname)';
con_data_obj = fmri_data(con_files);
% Vicarious only :: check data coverage
m = mean(con_data_obj);
m.dat = sum(~isnan(con_data_obj.dat) & con_data_obj.dat ~= 0, 2);

[wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
% Vicarious only :: remove outliers based on plot
con = con_data_obj;
disp(strcat("current length is ", num2str(size(con_data_obj.dat,2))));
con.dat = con_data_obj.dat(:,~wh_outlier_corr);
con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);
%end
disp(strcat("after removing ", num2str(sum(wh_outlier_corr)), " participants, size is now ",num2str(size(con.dat,2))));
[path,n,e] = fileparts(con_fldr(wh_outlier_corr));
disp(strcat("participants that are outliers:... ", n));
disp(n);
% l2norm and ttest
imgs2 = con.rescale('l2norm_images');
vic_t = ttest(imgs2);


% 1-3) cognitive _______________________________________________________________
contrast_of_interest = 'C_simple_CUE_cue_high_gt_low'

index = find(strcmp(contrast_name, contrast_of_interest));
con_name = sprintf('*con_%04d_%s.nii', index, contrast_of_interest);
con_list = dir(fullfile(mount_dir, '*', con_name));
spm('Defaults','fMRI') 
con_fldr = {con_list.folder}; fname = {con_list.name};
con_files = strcat(con_fldr,'/', fname)';
con_data_obj = fmri_data(con_files);


% Cognitive only :: check data coverage
m = mean(con_data_obj);
% m.dat = sum(~isnan(con_data_obj.dat) & con_data_obj.dat ~= 0, 2);
orthviews(m, 'trans'); % display
% Cognitive only :: Plot diagnostics, before l2norm
drawnow; snapnow;

[wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
% Cognitive only :: run robfit
set(gcf,'Visible','on');
figure ('Visible', 'on');
drawnow, snapnow;
% Cognitive only :: remove outliers based on plot
con = con_data_obj;
disp(strcat("current length is ", num2str(size(con_data_obj.dat,2))));
%for s = 1:length(wh_outlier_corr)
   % disp(strcat("-------subject", num2str(s), "------"))
con.dat = con_data_obj.dat(:,~wh_outlier_corr);
con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);
%end
disp(strcat("after removing ", num2str(sum(wh_outlier_corr)), " participants, size is now ",num2str(size(con.dat,2))));
[path,n,e] = fileparts(con_fldr(wh_outlier_corr));
disp(strcat("participants that are outliers:... ", n));
disp(n);
% Cognitive only:: plot diagnostics, after l2norm
imgs2 = con.rescale('l2norm_images');
cog_t = ttest(imgs2);

%% 2. Cue representation during cue epoch ______________________________________


% 2-1. Bayes map of domain general cue representation __________________________
pain_bf = estimateBayesFactor(pain_t, 't');
vic_bf = estimateBayesFactor(vic_t, 't'); %  exp(BF/2) = 2xlog(BF)
cog_bf = estimateBayesFactor(cog_t, 't');


domaingeneral = pain_bf;
thres=3;
nondomain_thres = 0.3;

for i = 1:length(pain_bf.dat)
    if pain_bf.dat(i) > thres &&  vic_bf.dat(i) > thres && cog_bf.dat(i) > thres  %&& pain_t.dat(i) ~= 0 && vic_t.dat(i) ~= 0 && cog_t.dat(i) ~= 0 
            
        domaingeneral.dat(i) = 1;
    else
        domaingeneral.dat(i) = 0;
    end
end
montage(domaingeneral)
domaingeneral_obj = fmri_data(domaingeneral);
domaingeneral_obj.fullpath = fullfile(save_bayesdir, 'domaingeneral_cueepoch_BFmask.nii');
domaingeneral_obj.write('overwrite');


genBF_pain = domaingeneral_obj;
genBF_pain.dat = domaingeneral_obj.dat.*pain_t.dat;
genBF_pain.fullpath = fullfile(save_bayesdir, 'domaingeneral_cueepoch_pain_tmap.nii');
genBF_pain.write('overwrite');

genBF_vic = domaingeneral_obj;
genBF_vic.dat = domaingeneral_obj.dat.*vic_t.dat;
genBF_vic.fullpath = fullfile(save_bayesdir, 'domaingeneral_cueepoch_vic_tmap.nii');
genBF_vic.write('overwrite');

genBF_cog = domaingeneral_obj;
genBF_cog.dat = domaingeneral_obj.dat.*cog_t.dat;
genBF_cog.fullpath = fullfile(save_bayesdir, 'domaingeneral_cueepoch_cog_tmap.nii');
genBF_cog.write('overwrite');


% 2-1. Bayes map of domain speciric pain cue representation _______________
domainpain = pain_bf;
thres=3;
nondomain_thres = 0.3;

for i = 1:length(pain_bf.dat)
    if pain_bf.dat(i) > thres &&  vic_bf.dat(i) < nondomain_thres && cog_bf.dat(i) < nondomain_thres % && pain_t.dat(i) > 0 && vic_t.dat(i) == 0 && cog_t.dat(i) == 0 
            
        domainpain.dat(i) = 1;
    else
        domainpain.dat(i) = 0;
    end
end
montage(domainpain)

domainP_obj = fmri_data(domainpain);
domainP_obj.fullpath = fullfile(save_bayesdir, 'domainspecific_pain_cueepoch_BFmask.nii');
domainP_obj.write('overwrite');

pain_thresholdBF = domainP_obj;
pain_thresholdBF.dat = domainP_obj.dat.*pain_t.dat;

pain_thresholdBF.fullpath = fullfile(save_bayesdir, 'domainspecific_pain_cueepoch_tmap.nii');
pain_thresholdBF.write('overwrite');

% 2-2. Bayes map of domain specific vicarious cue representation __________
close all
domainV = pain_bf;
thres=3;
nondomain_thres = 0.3;

for i = 1:length(pain_bf.dat)
    if pain_bf.dat(i) < nondomain_thres &&  vic_bf.dat(i) > thres && cog_bf.dat(i) < nondomain_thres % && pain_t.dat(i) > 0 && vic_t.dat(i) == 0 && cog_t.dat(i) == 0 
            
        domainV.dat(i) = 1;
    else
        domainV.dat(i) = 0;
    end
end
montage(domainV)
domainV_obj = fmri_data(domainV);
domainV_obj.fullpath =  fullfile(save_bayesdir, 'domainspecific_vic_cueepoch_BFmask.nii');
domainV_obj.write('overwrite');

vic_thresholdBF = domainV_obj;
vic_thresholdBF.dat = domainV_obj.dat.*vic_t.dat;

vic_thresholdBF.fullpath = fullfile(save_bayesdir, 'domainspecific_vic_cueepoch_tmap.nii');
vic_thresholdBF.write('overwrite');

% 2-3. Bayes map of domain specific cognitive cue representation __________
domainC = pain_bf;
thres=3;
nondomain_thres = 0.3;

for i = 1:length(pain_bf.dat)
    if pain_bf.dat(i) < nondomain_thres &&  vic_bf.dat(i) <nondomain_thres && cog_bf.dat(i) > thres % && pain_t.dat(i) > 0 && vic_t.dat(i) == 0 && cog_t.dat(i) == 0 
            
        domainC.dat(i) = 1;
    else
        domainC.dat(i) = 0;
    end
end
montage(domainC)

domainC_obj = fmri_data(domainC);
domainC_obj.fullpath = fullfile(save_bayesdir, 'domainspecific_cog_cueepoch_BFmask.nii');
domainC_obj.write('overwrite');

cog_thresholdBF = domainC_obj;
cog_thresholdBF.dat = domainC_obj.dat.*cog_t.dat;

cog_thresholdBF.fullpath = fullfile(save_bayesdir, 'domainspecific_cog_cueepoch_tmap.nii');
cog_thresholdBF.write('overwrite');