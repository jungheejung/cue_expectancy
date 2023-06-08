contrast_name = {### ADD };

% load dataset
mount_dir = '/Volumes/spacetop_projects_social/analysis/fmri/spm/univariate/model02_CESciO/1stLevel'

% TODO: grab subject contrasts that match subject id in the model simulated data
% TODO: load module simulated dataframe
con_list = dir(fullfile(mount_dir, '*/con_0017.nii'));
spm('Defaults','fMRI')
con_fldr = {con_list.folder}; fname = {con_list.name};
con_files = strcat(con_fldr,'/', fname)';
con_data_obj = fmri_data(con_files);
% load behavioral data and attach to dataobject

%% check data coverage
m = mean(con_data_obj);
m.dat = sum(~isnan(con_data_obj.dat) & con_data_obj.dat ~= 0, 2);
orthviews(m, 'trans') % display
% -- check that we have valid data by calculating average

%% run ols
out = regress(con_data_obj, .05, 'unc', 'nodisplay');
regressor
out = robfit_parcelwise(con_data_obj, 'names', );
% run robust