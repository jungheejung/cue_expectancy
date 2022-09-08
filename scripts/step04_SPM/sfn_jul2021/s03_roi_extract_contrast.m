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
atlas_obj = load_atlas('buckner_networks_atlas_object.mat');
atlas_obj.probability_maps = [];
orthviews(atlas_obj);
o2 = montage(atlas_obj);

drawnow, snapnow
%% 1. simple PAIN ==============================================================
simpleP_t = dir(fullfile(mount_dir, '/*/con_0018.nii'));    
simpleP_t(15,:) = [];
simpleP_fldr = {simpleP_t.folder}; fname = {simpleP_t.name};
simpleP_files = strcat(simpleP_fldr,'/', fname)';
spm('Defaults','fMRI')
simpleP_fd = fmri_data(simpleP_files);

vnames = {'Visual','Somatomotor','dAttention','vAttention','Limbic','Frontoparietal','Default'};
vtypes = {'double', 'double','double','double','double','double','double'};

Pr = extract_roi_averages(simpleP_fd, atlas_obj);
P_roi_averages = cat(2, Pr.dat);
PT = table('Size', [size(P_roi_averages)], 'VariableNames',atlas_obj.labels,'VariableTypes', vtypes);

PT = array2table(P_roi_averages);
PT.Properties.VariableNames = atlas_obj.labels;
PT.task = repmat('pain', size(P_roi_averages,1), 1);
PT.sub = [1:size(P_roi_averages,1)]';
% Now make the figure:
create_figure('Buckner regions', 1, 2);

barplot_columns(P_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Pr)), 'names', atlas_obj.labels);
xlabel('Region')
ylabel('ROI activity')

subplot(1, 2, 2)

barplot_columns(P_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Pr)), 'names', atlas_obj.labels, 'noind', 'noviolin');
xlabel('Region')
ylabel('ROI activity')
saveas(gcf,'../../figures/buckner_Pain_con.png');

%% vicarious ==============================================================
simpleV_t = dir(fullfile(mount_dir, '/*/con_0019.nii'));   
simpleV_t(15,:) = [];
simpleV_fldr = {simpleV_t.folder}; fname = {simpleV_t.name};
simpleV_files = strcat(simpleV_fldr,'/', fname)';
% filteredarray = simpleV_files(contains(simpleV_files, 'Z1P') & contains(yourcellarray, 'Z1P') & contains(yourcellarray, 'Z1G'));
spm('Defaults','fMRI')
simpleP_fd = fmri_data(simpleV_files);
vtypes = {'double', 'double','double','double','double','double','double'};

Vr = extract_roi_averages(simpleP_fd, atlas_obj);
V_roi_averages = cat(2, Vr.dat);
VT = table('Size', [size(V_roi_averages)], 'VariableNames',atlas_obj.labels,'VariableTypes', vtypes);
VT = array2table(V_roi_averages);
VT.Properties.VariableNames = atlas_obj.labels;
VT.task = repmat('vicarious', size(V_roi_averages,1), 1);
VT.sub = [1:size(V_roi_averages,1)]';
% Now make the figure: ____________________________________________________
close all
create_figure('Buckner regions', 1, 2);

barplot_columns(V_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Vr)), 'names', atlas_obj.labels);
xlabel('Region')
ylabel('ROI activity')

subplot(1, 2, 2)

barplot_columns(V_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Vr)), 'names', atlas_obj.labels, 'noind', 'noviolin');
xlabel('Region')
ylabel('ROI activity')


saveas(gcf,'../../figures/buckner_Vicarious_con.png');


%% cognitive ==============================================================
simpleC_t = dir(fullfile(mount_dir, '/*/con_0020.nii'));   
simpleC_t(15,:) = [];
simpleC_fldr = {simpleC_t.folder}; fname = {simpleC_t.name};
simpleC_files = strcat(simpleC_fldr,'/', fname)';
spm('Defaults','fMRI')
simpleC_fd = fmri_data(simpleC_files);
vtypes = {'double', 'double','double','double','double','double','double'};

Cr = extract_roi_averages(simpleC_fd, atlas_obj);
C_roi_averages = cat(2, Cr.dat);
CT = table('Size', [size(C_roi_averages,1) size(C_roi_averages,2)], 'VariableNames',atlas_obj.labels,'VariableTypes', vtypes);
CT(:,1:7) = array2table(C_roi_averages);
CT.Properties.VariableNames = atlas_obj.labels;
CT.task = repmat('cognitive', size(C_roi_averages,1), 1);
CT.sub = [1:size(C_roi_averages,1)]';
% Now make the figure: ____________________________________________________
create_figure('Buckner regions', 1, 2);

barplot_columns(C_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Cr)), 'names', atlas_obj.labels);
xlabel('Region')
ylabel('ROI activity')

subplot(1, 2, 2)

barplot_columns(C_roi_averages, 'nofig', 'colors', scn_standard_colors(length(Cr)), 'names', atlas_obj.labels, 'noind', 'noviolin');
xlabel('Region')
ylabel('ROI activity')

saveas(gcf,'../../figures/buckner_Cognitive_con.png');
sub_save_dir = '/Users/h/Documents/projects_local/social_influence_analysis/analysis/fmri/roi_extraction';
saveFileName = fullfile(sub_save_dir,'atlas-buckner_task-pain_con.csv' );
writetable(PT,saveFileName);

% sub_save_dir = '/Users/h/Documents/projects_local/social_influence_analysis/analysis/fmri';
saveFileName = fullfile(sub_save_dir,'atlas-buckner_task-vicarious_con.csv' );
writetable(VT,saveFileName);

% sub_save_dir = '/Users/h/Documents/projects_local/social_influence_analysis/analysis/fmri';
saveFileName = fullfile(sub_save_dir,'atlas-buckner_task-cognitive_con.csv' );
writetable(CT,saveFileName);
