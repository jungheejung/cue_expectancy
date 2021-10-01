%% hypothesis:
% parametric modulation maps would differ as a function of large scale system and psych. domain.
% concern: Averaging across entire networks seems like an overly simple approach though...
% potentially the  ?buckner_networks_atlas_object.mat? and extract_roi_averages?
% 
% You would have 3 maps x N regions for each subject
% 
% And you could do an ANOVA or similar and specify contrasts at anatomical levels of interest

%% load atlas
mount_dir='/Volumes/social/analysis/fmri/spm/model-01_CcEScaA/1stLevel';


drawnow, snapnow
%% 1. simple PAIN ==============================================================
simpleP_t = dir(fullfile(mount_dir, '/*/con_0018.nii'));    
simpleP_t(15,:) = [];
out = regress(simpleP_t);
t = threshold(out.t, .05, 'fdr');

simpleP_fldr = {simpleP_t.folder}; fname = {simpleP_t.name};
simpleP_files = strcat(simpleP_fldr,'/', fname)';
spm('Defaults','fMRI')
simpleP_fd = fmri_data(simpleP_files);
OUT = robfit_parcelwise(simpleP_fd);

o2 = canlab_results_fmridisplay(get_wh_image(t, 2), 'montagetype', 'full', 'noverbose');
o2 = removeblobs(o2);
o2 = addblobs(o2, get_wh_image(t_obj, 1));

OUT = robfit_parcelwise(simpleP_fd, 'csf_wm_covs', 'remove_outliers');
 
vnames = {'Visual','Somatomotor','dAttention','vAttention','Limbic','Frontoparietal','Default'};
vtypes = {'double', 'double','double','double','double','double','double'};

Pr = extract_roi_averages(simpleP_fd, atlas_obj);
P_roi_averages = cat(2, Pr.dat);
PT = table('Size', [size(P_roi_averages)], 'VariableNames',atlas_obj.labels,'VariableTypes', vtypes);

PT = array2table(P_roi_averages);
PT.Properties.VariableNames = atlas_obj.labels;
PT.task = repmat('pain', size(P_roi_averages,1), 1);
PT.sub = [1:size(P_roi_averages,1)]';


% sub_save_dir = '/Users/h/Documents/projects_local/social_influence_analysis/analysis/fmri';
saveFileName = fullfile(sub_save_dir,'atlas-buckner_task-cognitive_con.csv' );
writetable(CT,saveFileName);
