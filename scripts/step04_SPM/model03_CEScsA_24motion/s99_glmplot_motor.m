% % load single trial analysis from SPM
% % insert volumne info
% % save as nifti file
% run = {'pain','vicarious', 'cognitive', 'general'}; %'pain'};
% % r = 1;
% event = 'stim';
% main_dir = '/Volumes/spacetop_projects_social';
% pdm_dir = fullfile(main_dir, 'analysis', 'fmri', 'mediation', 'pdm');
% figure_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure';
% mount_dir = '/Volumes/spacetop_projects_social/analysis/fmri/spm/univariate/model-03_CEScsA_24dofcsd/1stLevel';
% contrast_name = {'cue_P', 'cue_V', 'cue_C',...
%     'stim_P', 'stim_V', 'stim_C',...
%     'stimXcue_P', 'stimXcue_V', 'stimXcue_C',...
%     'stimXint_P', 'stimXint_V', 'stimXint_C',...
%     'motor', ...
%     'simple_cue_P', 'simple_cue_V', 'simple_cue_C','simple_cue_G',...
%     'simple_stim_P', 'simple_stim_V', 'simple_stim_C','simple_stim_G',...
%     'simple_stimXcue_P', 'simple_stimXcue_V', 'simple_stimXcue_C','simple_stimXcue_G',...
%     'simple_stimXint_P', 'simple_stimXint_V','simple_stimXint_C', 'simple_stimXint_G'};
% 
% con_num = [18,19,20,21,22,23,24,25,26,27,28,29];
% for c = 1:length(con_num)
% con_list = dir(fullfile(mount_dir, strcat('*/con_00', num2str(con_num(c)),'.nii')));
% spm('Defaults','fMRI')
% con_fldr = {con_list.folder}; fname = {con_list.name};
% con_files = strcat(con_fldr,'/', fname)';
% con_data_obj = fmri_data(con_files);
% 
% [wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
% con.dat = con_data_obj.dat(:,~wh_outlier_corr);
% con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
% con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
% con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);
% imgs2 = con.rescale('l2norm_images');
% t = ttest(imgs2);
% t = threshold(t, .05, 'fdr', 'k', 10);
% o1 = canlab_results_fmridisplay(t,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
% scn_export_papersetup(400);
% saveas(gcf, fullfile(figure_dir,strcat('glm_model-03_CEScsA_24dofcsd_con-',num2str(con_num(c)),'_', contrast_name{con_num(c)},'_l2norm_fdr-05_colorbar.png')));
% end
% 
% con_01 = [18,19,20,21];
% for c = 1:length(con_01)
% con_list = dir(fullfile(mount_dir, strcat('*/con_00', num2str(con_num(c)),'.nii')));
% spm('Defaults','fMRI')
% con_fldr = {con_list.folder}; fname = {con_list.name};
% con_files = strcat(con_fldr,'/', fname)';
% con_data_obj = fmri_data(con_files);
% 
% [wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
% con.dat = con_data_obj.dat(:,~wh_outlier_corr);
% con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
% con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
% con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);
% imgs2 = con.rescale('l2norm_images');
% t = ttest(imgs2);
% t = threshold(t, .001, 'fdr', 'k', 10);
% o1 = canlab_results_fmridisplay(t,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
% scn_export_papersetup(400);
% saveas(gcf, fullfile(figure_dir,strcat('glm_model-03_CEScsA_24dofcsd_con-',num2str(con_num(c)),'_', contrast_name{con_num(c)},'_l2norm_fdr-001_colorbar.png')));
% end

motor = [13];
for c = 1:length(motor)
con_list = dir(fullfile(mount_dir, strcat('*/con_0013.nii')));
spm('Defaults','fMRI')
con_fldr = {con_list.folder}; fname = {con_list.name};
con_files = strcat(con_fldr,'/', fname)';
con_data_obj = fmri_data(con_files);

[wh_outlier_uncorr, wh_outlier_corr] = plot(con_data_obj);
con.dat = con_data_obj.dat(:,~wh_outlier_corr);
con.image_names = con_data_obj.image_names(~wh_outlier_corr,:);
con.fullpath = con_data_obj.fullpath(~wh_outlier_corr,:);
con.files_exist = con_data_obj.files_exist(~wh_outlier_corr,:);
imgs2 = con.rescale('l2norm_images');
t = ttest(imgs2);
t = threshold(t, .001, 'fdr', 'k', 10);
o1 = canlab_results_fmridisplay(t,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
scn_export_papersetup(400);
saveas(gcf, fullfile(figure_dir,strcat('glm_model-03_CEScsA_24dofcsd_con-0013_motor_l2norm_fdr-001_colorbar.png')));
end