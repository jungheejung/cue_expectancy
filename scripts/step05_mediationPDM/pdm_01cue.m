clear; close all;

%%
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : N subject x 1 cell [ K voxel x T trials ]
event = 'stim'; %string(event);
csv = 'cue-actual'; %string(csv);
y_rating = 'actual';% string(y_rating);
x_keyword = 'cue';
m_keyword = 'stim';
y_keyword = 'actual'
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');

%addpath(genpath('/Users/h/Documents/MATLAB/MediationToolbox'));
%addpath(genpath('/Users/h/Documents/MATLAB/CanlabCore'));
%addpath(genpath('/Users/h/Documents/MATLAB/spm12'));
%rmpath(genpath('/Users/h/Documents/MATLAB/spm12/external/fieldtrip'));
%rmpath('/Users/h/Documents/MATLAB/spm12/external/fieldtrip/external/stats');
% parameters __________________________________________________________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(pwd));
disp(main_dir); %main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
xx = cell( length(sublist), 1); 
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);

run = {'pain', 'vicarious', 'cognitive'};
for r = 1:length(run)
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword));
    if not(exist(task_subfldr, 'dir'))
        mkdir(task_subfldr)
    end
dat_fname =  fullfile(task_subfldr, strcat('task-',run{r},'_PDM_', x_keyword, '-', m_keyword,'-',y_keyword, '_DAT.mat'));
if ~isfile(dat_fname)
for s = 1:length(sublist)
    % step 01 __________________________________________________________________
    % grab metadata
    sub = strcat('sub-', sprintf("%04d", sublist(s)));
    fname = strcat('metadata_', sub ,'_task-social_run-', run{r}, '_ev-', event, '.csv');
    T = readtable(fullfile(nifti_dir, sub, fname));
    basename = strrep(strrep(fname,'metadata_',''), '.csv', '');

    % step 02 __________________________________________________________________
    % grab nifti and unzip
    fname_nifti = fullfile(nifti_dir, sub, strcat(basename, '.nii.gz'));
    fname_nii = fullfile(nifti_dir, sub, strcat(basename, '.nii'));
    if ~exist(fname_nii,'file'), gunzip(fname_nifti)
    end

    % step 03 __________________________________________________________________
    % provide input as XMY
    xx{s, 1} = T.cue_con; % table2array(T(:, 'cue_con'));% T.cue; %
    dat =  fmri_data(char(fname_nii));
    mm{s, 1} = dat.dat;
    yy{s, 1} = T.actual_rating;% table2array(T(:,strcat(y_rating, '_rating'))); %T.actual_rating;
    %% diagnostics
    assignin('base','dat',dat);
    options.codeToEvaluate = sprintf('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/@fmri_data/plot(%s)','dat'); 
    options.format = 'html'; options.outputDir = fullfile(save_dir, 'diagnostics');
    options.imageFormat = 'png';
    mydoc = publish('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/@fmri_data/plot.m',options);
    [folder, name] = fileparts(mydoc);
    movefile(mydoc, fullfile(save_dir, task_subfldr,'diagnostics',['singletrial-diagnostics_run-', run{r},'_sub-' , sub,'_',datestr(now,'mm-dd-yy'), '.html']));
end
else
load(dat_fname);
end

save(dat_fname,'xx','yy','mm','-v7.3');
end

%% PDM
for r = 1:length(run)
assignin('base','task',run{r});
assignin('base','sublist', sublist); 
options.codeToEvaluate = sprintf('pdm_01cue_plot(%s)','task');%strcat('task=', run{r});
options.format = 'html'; 
options.outputDir = task_subfldr;    
options.imageFormat = 'png';
pdm_output = publish('pdm_01cue_plot.m',options);

[folder, name] = fileparts(pdm_output);
movefile(pdm_output, fullfile(task_subfldr, ['singletrial-pdm_task-',run{r},'_stimlevel-stim-actual',datestr(now,'mm-dd-yy'), '.html']));
end
