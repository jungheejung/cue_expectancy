% resultsdir = 
% main_dir = fileparts(fileparts(pwd));
main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
xx = cell( length(sublist), 1);
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);


% save dir
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword,'_l2norm' ));
if not(exist(task_subfldr, 'dir'))
    mkdir(task_subfldr)
end d


subdir = fullfile(resultsdir, 'published_output');
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

pubfilename = [strcat('multivariate_mediation_brain_report_',contrastname,'_',Yname,'_') scn_get_datetime];

p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
    'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', true);
