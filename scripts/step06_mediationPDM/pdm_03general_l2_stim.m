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
disp(main_dir);
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate_24dofcsd','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm'));
% input variables
stim_input = struct();

stim_input.x_keyword = x_keyword;
stim_input.m_keyword = m_keyword;
stim_input.y_keyword = y_keyword;
stim_input.main_dir = main_dir;
stim_input.single_nii = fullfile(main_dir, strcat('/analysis/fmri/spm/multivariate_24dofcsd/s03_concatnifti/sub-0065/sub-0065_task-social_run-', run{r}, '_ev-', event,'_l2norm.nii'));

stim_input.task = run{r};
stim_input.iter = 5000;
stim_input.num_components = 6;
stim_input.alpha = 0.05;
stim_input.sig = 'fdr';
stim_input.dat_fpath = fullfile(task_subfldr, strcat('task-',run{r},'_PDM_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm_DAT.mat'));
stim_input.task_subfldr = task_subfldr


task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm'));
if not(exist(task_subfldr, 'dir'))
    mkdir(task_subfldr)
end
dat_fname =  fullfile(task_subfldr, strcat('task-',run{r},'_PDM_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm_DAT.mat'));

% if ~isfile(dat_fname)
    niilist = dir(fullfile(nifti_dir, '*', strcat('*_task-social_run-', run{r}, '_ev-', event, '_l2norm.nii')));
    nT = struct2table(niilist); % convert the struct array to a table
    sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
    sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
    stim_input.sublist = sortedT.sub_num;

    % build cells based on subject length
    xx = cell( size(sortedT,1), 1);
    mm = cell( size(sortedT,1), 1);
    mm_fdata = cell( size(sortedT,1), 1);
    yy = cell( size(sortedT,1), 1);
    outlier = cell( size(sortedT,1),1);   

    for s = 1:size(sortedT,1)
        % step 01 __________________________________________________________________
        % grab metadata
        basename = strrep(char(sortedT.name(s)), '_l2norm.nii', '');
        sub = strcat('sub-', sprintf('%04d',  sortedT.sub_num(s)));
        T = readtable(fullfile(nifti_dir, sub, strcat('metadata_', basename, '.csv')));
        % basename = strrep(strrep(char(sortedT.name(s)),'metadata_',''), '.csv', '');
        
        % step 02 __________________________________________________________________
        % grab nifti and unzip
        fname_nifti = fullfile(nifti_dir, sub, strcat(basename, '_l2norm.nii.gz'));
        fname_nii = fullfile(nifti_dir, sub, strcat(basename, '_l2norm.nii'));
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
       % movefile(mydoc, fullfile(task_subfldr,'diagnostics',strcat('singletrial-diagnostics_run-',char( run{r}),'_sub-' , sub, '_l2norm.pdf')));
    end
% else
    % load(dat_fname);
% end
save(dat_fname,'xx','yy','mm','outlier','-v7.3');


%% PDM
task_subfldr = fullfile(save_dir, strcat('task-',run{r},'_', x_keyword, '-', m_keyword,'-',y_keyword, '_l2norm'));
    niilist = dir(fullfile(nifti_dir, '*', strcat('*_task-social_run-', run{r}, '_ev-', event, '_l2norm.nii')));
    nT = struct2table(niilist); % convert the struct array to a table
    sortedT = sortrows(nT, 'name'); % sort the table by 'DOB'
    sortedT.sub_num(:) = str2double(extractBetween(sortedT.name, 'sub-', '_'));
    stim_input.sublist = sortedT.sub_num;
assignin('base','input',stim_input);
options.codeToEvaluate = sprintf('plot_pdm(%s)','input');
options.format = 'pdf';
options.outputDir = task_subfldr;
options.imageFormat = 'jpg';
pdm_output = publish('plot_pdm.m',options);

[folder, name] = fileparts(pdm_output);
movefile(pdm_output, fullfile(task_subfldr, ...
strcat('singletrial-pdm_task-',run{r},'_', x_keyword, '-', m_keyword, '-', y_keyword, '_',datestr(now,'mm-dd-yy'), '_l2norm.pdf')));

