
%% Generic scheme
% load concatenated niftis

%% cue -> stim -> actual
clear; close all;
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : N subject x 1 cell [ K voxel x T trials ]
event = 'stim'; %string(event);
csv = 'cue-actual'; %string(csv);
y_rating = 'actual';% string(y_rating);
x_keyword = 'cue';
m_keyword = 'stim';
y_keyword = 'actual';
r = 1
run = {'general'}
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');
% parameters __________________________________________________________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(pwd));
disp(main_dir); %main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];

% input variables
cue_input = struct();

cue_input.x_keyword = x_keyword;
cue_input.m_keyword = m_keyword;
cue_input.y_keyword = y_keyword;
cue_input.main_dir = main_dir;
cue_input.single_nii = fullfile(main_dir, '/analysis/fmri/spm/multivariate/s03_concatnifti/sub-0065/sub-0065_task-social_run-general_ev-cue.nii');
cue_input.sublist = sublist;
cue_input.task = 'general';
cue_input.iter = 5000;
cue_input.num_components = 2;


xx = cell( length(sublist), 1);
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);
outlier = cell( length(sublist),1);

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
        [wh_outlier_uncorr, wh_outlier_corr]  = plot(dat);
        outlier{s,1} = wh_outlier_corr;
        assignin('base','dat',dat);
        options.codeToEvaluate = sprintf('plot(%s)','dat');
        options.format = 'pdf';
        options.showCode = false;
        if not(exist(fullfile(task_subfldr,'diagnostics'),'dir'))
            mkdir(fullfile(task_subfldr,'diagnostics'))
        end
        options.outputDir = fullfile(task_subfldr, 'diagnostics');
        options.imageFormat = 'jpg';
        mydoc = publish('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/@fmri_data/plot.m',options);
        [folder, name] = fileparts(mydoc);

        movefile(mydoc, fullfile(task_subfldr,'diagnostics',strcat('singletrial-diagnostics_run-', char(run{r}),'_sub-' , sub, '.pdf')));
    end
else
    load(dat_fname);
end
save(dat_fname,'xx','yy','mm','outlier','-v7.3');


%% PDM
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword));
assignin('base','input',cue_input);
options.codeToEvaluate = sprintf('pdm_03gen_plot(%s)','input');
options.format = 'pdf';
options.outputDir = task_subfldr;
options.imageFormat = 'jpg';
pdm_output = publish('pdm_03gen_plot.m',options);

[folder, name] = fileparts(pdm_output);
movefile(pdm_output, fullfile(task_subfldr, ...
strcat('singletrial-pdm_task-',run{r},'_', x_keyword, '-', m_keyword, '-', y_keyword, '_',datestr(now,'mm-dd-yy'), '.pdf')));








%% stim level -> stim -> actual
clear; close all;
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : N subject x 1 cell [ K voxel x T trials ]
event = 'stim'; %string(event);
csv = 'stim-actual'; %string(csv);
y_rating = 'actual';% string(y_rating);
x_keyword = 'stimlevel';
m_keyword = 'stim';
y_keyword = 'actual';
r = 1
run = {'general'}
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');
% parameters __________________________________________________________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(pwd));
disp(main_dir); %main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];

% input variables
cue_input = struct();

cue_input.x_keyword = x_keyword;
cue_input.m_keyword = m_keyword;
cue_input.y_keyword = y_keyword;
cue_input.main_dir = main_dir;
cue_input.single_nii = fullfile(main_dir, '/analysis/fmri/spm/multivariate/s03_concatnifti/sub-0065/sub-0065_task-social_run-general_ev-stim.nii');
cue_input.sublist = sublist;
cue_input.task = 'general';
cue_input.iter = 5000;
cue_input.num_components = 2;


xx = cell( length(sublist), 1);
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);
outlier = cell( length(sublist), 1);

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
        xx{s, 1} = T.stim_lin; % table2array(T(:, 'cue_con'));% T.cue; %
        dat =  fmri_data(char(fname_nii));
        mm{s, 1} = dat.dat;
        yy{s, 1} = T.actual_rating;% table2array(T(:,strcat(y_rating, '_rating'))); %T.actual_rating;
        %% diagnostics
        [wh_outlier_uncorr, wh_outlier_corr]  = plot(dat);
        outlier{s,1} = wh_outlier_corr
        assignin('base','dat',dat);
        options.codeToEvaluate = sprintf('plot(%s)','dat');
        options.format = 'pdf';
        options.showCode = false;
        if not(exist(fullfile(task_subfldr,'diagnostics'),'dir'))
            mkdir(fullfile(task_subfldr,'diagnostics'))
        end
        options.outputDir = fullfile(task_subfldr, 'diagnostics');
        options.imageFormat = 'jpg';
        mydoc = publish('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/@fmri_data/plot.m',options);
        [folder, name] = fileparts(mydoc);
        % files = dir(fullfile(task_subfldr, 'diagnostics', 'plot*.png'));
        % Loop through each file 
        % for id = 1:length(files)
            % Get the file name 
         %   [~, f,ext] = fileparts(files(id).name);
         %   rename = strcat('singletrial-diagnostics_run-', run{r},'_sub-' , sub,f,'_',ext) ; 
         %   movefile(files(id).name, rename); 
        % end
        movefile(mydoc, fullfile(task_subfldr,'diagnostics',strcat('singletrial-diagnostics_run-',char( run{r}),'_sub-' , sub, '.pdf')));
    end
else
    load(dat_fname);
end
save(dat_fname,'xx','yy','mm','outlier','-v7.3');


%% PDM
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword));
assignin('base','input',cue_input);
options.codeToEvaluate = sprintf('pdm_03gen_plot(%s)','input');
options.format = 'pdf';
options.outputDir = task_subfldr;
options.imageFormat = 'jpg';
pdm_output = publish('pdm_03gen_plot.m',options);

[folder, name] = fileparts(pdm_output);
movefile(pdm_output, fullfile(task_subfldr, ...
strcat('singletrial-pdm_task-',run{r},'_', x_keyword, '-', m_keyword, '-', y_keyword, '_',datestr(now,'mm-dd-yy'), '.pdf')));

