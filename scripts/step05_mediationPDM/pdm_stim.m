% TODO: if dat file exists, skip ddat
clear; close all;

%%
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : 
% run_type = 'cognitive'; % string(run_type)
event = 'stim'; %string(event);
csv = 'cue-actual'; %string(csv);
y_rating = 'actual';% string(y_rating);
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
disp(main_dir);
%main_dir = '/Volumes/spacetop_projects_social';
nifti_dir = fullfile(main_dir,'analysis','fmri','spm','multivariate','s03_concatnifti');
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');
% sublist = [3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60];
sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
sublist = [6,7,8,9,10,11,13,14,15,16,17,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,76,78,79,80,81,84,85]; 
% sublist = [6,7,8];
xx = cell( length(sublist), 1); 
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);
% TODO: glob. if file exists, then run
% if event == 'cue'
%  else if event == 'stim'
%x_col =
run = {'pain', 'vicarious', 'cognitive'};
for r = 1:length(run)
dat_fname =  fullfile(save_dir, strcat('task-',run{r}, '_PDM_stimlin-stim-actual_DAT.mat'));
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
%     mm{s, 1} = char(fname_nii);
    yy{s, 1} = T.actual_rating;% table2array(T(:,strcat(y_rating, '_rating'))); %T.actual_rating;
    % publish(plot(dat));
    options.codeToEvaluate = 'dat=dat'; options.format = 'html'; options.outputDir = save_dir;
    options.imageFormat = 'png';

    mydoc = publish('plot.m',options);
    % mydoc          = publish(plot(dat), 'html');
    [folder, name] = fileparts(mydoc);
    movefile(mydoc, fullfile(save_dir, 'diagnostics',['singletrial-diagnostics_run-', run{r},'_sub-' , sub,'_',datestr(now,'mm-dd-yy'), '.html']));
end
else
load(dat_fname);
end
%save_dat = fullfile(save_dir, strcat('task-',run{r}, '_PDM_stimlin-stim-actual_DAT.mat'));

save(dat_fname,'xx','yy','mm','-v7.3');
end
options.codeToEvaluate = 'single_nii=fname_nii; save_dir=save_dir'; options.format = 'html'; 
options.outputDir = save_dir;    options.imageFormat = 'png';
pdm_output = publish('pdm_n_plot.m',options);
% pdm_output = publish(pdm_n_plot(fname_nii));
[folder, name] = fileparts(pdm_output);
movefile(pdm_output, fullfile(save_dir, ['singletrial-pdm_',datestr(now,'mm-dd-yy'), '.html']));
