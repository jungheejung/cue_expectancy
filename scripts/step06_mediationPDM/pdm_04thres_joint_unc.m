% load single trial analysis from SPM
% insert volumne info
% save as nifti file
run = {'pain', 'vicarious', 'cognitive'}; %'pain'};
% r = 1;
event = 'stim';
main_dir = '/Volumes/spacetop_projects_social';
pdm_dir = fullfile(main_dir, 'analysis', 'fmri', 'mediation', 'pdm');

for r = 1:length(run)
    WfPlot = [];
    WfLabel = [];
    
    single_nii = fullfile(main_dir, strcat('/analysis/fmri/spm/multivariate_24dofcsd/s03_concatnifti/sub-0065/sub-0065_task-social_run-', run{r}, '_ev-', event,'_l2norm.nii'));
    S = fmri_data(single_nii);
    load(fullfile(pdm_dir,strcat('task-', run{r},'_stimlin-stim-actual_l2norm'),...
        strcat('task-', run{r},'_PDM-bootstrap_stimlin-stim-actual.mat')));
    pdmplot  = fmri_data();
    pdmplot.dat = out.WfullJoint .* (out.boot.pJointPDM{1,1} > 0.1);
    
    pdmplot.volInfo = S.volInfo;
    
    
    figure_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/mediationPDM/stimlin-stim-actual';
    
    if not(exist(fullfile(figure_dir, run{r}), 'dir'))
        mkdir(fullfile(figure_dir, run{r}))
    end
    
    f = figure; clf; set(f,'color','w','name','joint');
    
    o1 = canlab_results_fmridisplay(pdmplot,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full hcp','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
    scn_export_papersetup(400);
    saveas(gcf, fullfile(figure_dir,run{r}, strcat('mediationPDM_task-',run{r}, '_stimlin-stim-actual_component-', num2str(sprintf('%02d', k)), '_l2norm_JOINT.png')));
    
end

%% cue stim actual
run = {'pain', 'vicarious', 'cognitive'}; %'pain'};
% r = 1;
event = 'cue';
main_dir = '/Volumes/spacetop_projects_social';
pdm_dir = fullfile(main_dir, 'analysis', 'fmri', 'mediation', 'pdm');

for r = 1:length(run)
    WfPlot = [];
    WfLabel = [];
    
    single_nii = fullfile(main_dir, strcat('/analysis/fmri/spm/multivariate_24dofcsd/s03_concatnifti/sub-0065/sub-0065_task-social_run-', run{r}, '_ev-', event,'_l2norm.nii'));
    S = fmri_data(single_nii);
    load(fullfile(pdm_dir,strcat('task-', run{r},'_cue-stim-actual_l2norm'),...
        strcat('task-', run{r},'_PDM-bootstrap_cue-stim-actual.mat')));
    pdmplot  = fmri_data();
    pdmplot.dat = out.WfullJoint .* (out.boot.pJointPDM{1,1} > 0.1);
    
    pdmplot.volInfo = S.volInfo;
    
    
    figure_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/mediationPDM/cue-stim-actual';
    
    if not(exist(fullfile(figure_dir, run{r}), 'dir'))
        mkdir(fullfile(figure_dir, run{r}))
    end
    
    f = figure; clf; set(f,'color','w','name','joint');
    
    o1 = canlab_results_fmridisplay(pdmplot,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full hcp','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
    scn_export_papersetup(400);
    saveas(gcf, fullfile(figure_dir,run{r}, strcat('mediationPDM_task-',run{r}, '_cue-stim-actual_component-', num2str(sprintf('%02d', k)), '_l2norm_JOINT.png')));
    
end