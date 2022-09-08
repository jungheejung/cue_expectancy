% Purpose of script:
% plotting PDM outputs


% plot A: stimulus (linear contrast) -> stimulus brain -> actual rating
% _____________________________________________________________________
run = {'vicarious', 'cognitive', 'general'}; %'pain'};
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
    pdm = out;
    if isfield(pdm,'WfullThresh')
        WfPlot  = pdm.WfullThresh(~cellfun(@isempty,pdm.WfullThresh));
        WfLabel = strsplit(strtrim(sprintf('PDM%2d\n',1:numel(WfPlot))),'\n');
    end
    if isfield(pdm,'WfullJointThresh')
        WfPlot = horzcat(WfPlot, pdm.WfullJointThresh);
        WfLabel = horzcat(WfLabel,'Joint PDM');
    end
    
    figure_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/mediationPDM/stimlin-stim-actual';
    % for each PDM, save an image for component
    
    for k = 1:size(WfPlot,2)
        if not(exist(fullfile(figure_dir, run{r}), 'dir'))
            mkdir(fullfile(figure_dir, run{r}))
        end
        pdmplot = fmri_data();
        pdmplot.dat = WfPlot{k};
        pdmplot.volInfo =  S.volInfo;
        f(k) = figure(k); clf; set(f(k),'color','w','name',WfLabel{k});
        % img_fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/ohbm/tst_save.nii';
        % write(A, 'fname', img_fname, 'overwrite')
        o1 = canlab_results_fmridisplay(pdmplot,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
        scn_export_papersetup(400);
        saveas(gcf, fullfile(figure_dir,run{r}, strcat('mediationPDM_task-',run{r}, '_stimlin-stim-actual_component-', num2str(sprintf('%02d', k)), '_l2norm_colorbar.png')));
    end
end

% plot B: cue (high/low linear contrast) -> stimulus brain -> actual rating
% _____________________________________________________________________

run = {'pain'};%'general'};%'pain', 'vicarious', 'cognitive'}; %'pain'};
event = 'cue';
main_dir = '/Volumes/spacetop_projects_social';
pdm_dir = fullfile(main_dir, 'analysis', 'fmri', 'mediation', 'pdm');

for r = 1:length(run)
    WfPlot = [];
    WfLabel = [];
    
    single_nii = fullfile(main_dir, strcat('/analysis/fmri/spm/multivariate_24dofcsd/s03_concatnifti/sub-0065/sub-0065_task-social_run-', run{r}, '_ev-', event,'_l2norm.nii'));
    S = fmri_data(single_nii);
    load(fullfile(pdm_dir,strcat('task-', run{r},'_', event,'-stim-actual_l2norm'),...
        strcat('task-', run{r},'_PDM-bootstrap_cue-stim-actual.mat')));
    % A  = fmri_data();
    % % A.dat = out.Wfull{1,1} .* (out.boot.p{1,1} > out.pThreshold(1));
    % A.dat= out.WfullThresh{1,1}(~cellfun(@isempty,out.WfullThresh{1,1}));
    % A.volInfo = S.volInfo;
    pdm = out;
    if isfield(pdm,'WfullThresh')
        WfPlot  = pdm.WfullThresh(~cellfun(@isempty,pdm.WfullThresh));
        WfLabel = strsplit(strtrim(sprintf('PDM%2d\n',1:numel(WfPlot))),'\n');
    end
    if isfield(pdm,'WfullJointThresh')
        WfPlot = horzcat(WfPlot, pdm.WfullJointThresh);
        WfLabel = horzcat(WfLabel,'Joint PDM');
    end
    
    figure_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/mediationPDM/cue-stim-actual';
    % for each PDM, save an image for component
    
    for k = 1:size(WfPlot,2)
        if not(exist(fullfile(figure_dir, run{r}), 'dir'))
            mkdir(fullfile(figure_dir, run{r}))
        end
        pdmplot = fmri_data();
        pdmplot.dat = WfPlot{k};
        pdmplot.volInfo =  S.volInfo;
        f(k) = figure(k); clf; set(f(k),'color','w','name',WfLabel{k});
        % img_fname = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/figure/ohbm/tst_save.nii';
        % write(A, 'fname', img_fname, 'overwrite')
        o1 = canlab_results_fmridisplay(pdmplot,'outline','linewidth',0.1,'montagetype','outlinecolor',[0.3 0.3 0.3],'full hcp','splitcolor',{[.1 .8 .8] [.1 .1 .8] [.9 .4 0] [1 1 0]},'overlay','mni_icbm152_t1_tal_nlin_sym_09a_brainonly.img'); % o1 is an fmridisplay object - methods fmridisplay for help
        scn_export_papersetup(400);
        saveas(gcf, fullfile(figure_dir,run{r}, strcat('mediationPDM_task-',run{r}, '_cue-stim-actual_component-', num2str(sprintf('%02d', k)), '_l2norm.png')));
    end
end
%