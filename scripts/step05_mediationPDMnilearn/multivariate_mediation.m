% TODO: if dat file exists, skip ddat
clear; close all;

%%
% xx : N subject x 1 cell
% yy : N subject x 1 cell
% mm : 
run_type = 'cognitive'; % string(run_type)
event = 'stim'; %string(event);
csv = 'cue-actual'; %string(csv);
y_rating = 'actual';% string(y_rating);
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');

% parameters __________________________________________________________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(pwd));
disp(main_dir);

% TODO: __________________________________________________________________
% load bad_runs.json
json_fname = fullfile(main_dir, 'scripts/step00_qc/qc03_fmriprep_visualize/bad_runs.json');
fileContent = fileread(json_fname);
jsonData = jsondecode(fileContent);
% Access the first element of the JSON array
firstElement = jsonData(1);
% Access a property of the JSON object
propertyValue = jsonData.propertyName;
% __________________________________________________________________
% based on this, exclude participants and runs. 

nifti_dir = fullfile(main_dir,'analysis','fmri','nilearn','singletrial');
beh_dir = fullfile(main_dir, 'data', 'beh', 'beh03_bids'); % /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids/sub-0082/ses-03
save_dir = fullfile(main_dir,'analysis','fmri','mediation','pdm');


sublist = [6,7,8,9,10,11,13,14,15,16,17,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,74,76,78,79,80,81,84,85];
sublist = [6,7,8,9,10,11,13,14,15,16,17,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,73,76,78,79,80,81,84,85]; 

xx = cell( length(sublist), 1); 
mm = cell( length(sublist), 1);
mm_fdata = cell( length(sublist), 1);
yy = cell( length(sublist), 1);
% TODO: glob. if file exists, then run
% if event == 'cue'
%  else if event == 'stim'
%x_col =
dat_fname =  fullfile(save_dir, strcat('task-',run_type, '_PDM_stimlin-stim-actual_DAT.mat'));
if ~isfile(dat_fname)
for s = 1:length(sublist)
    % RESTRUCTURE:
    % beh: based on globed fmri filenames, extract sub, ses, run combination
    % beh:From that load behavioral files and load it as table
    % fmri: stack data and keep track of files. all the metadata is there
    % step 01 __________________________________________________________________
    % grab metadata
    % TODO: load behavioral data
    sub = strcat('sub-', sprintf("%04d", sublist(s)));
    ses = strcat('ses-', sprintf("%02d", sublist(ses_num)));
    run = strcat('run-', sprintf("%03d", sublist(run_num)));
    % fname = strcat('metadata_', sub ,'_task-social_run-', run_type, '_ev-', event, '.csv');
    % sub-0082_ses-03_task-cue_acq-mb8_run-03_events.tsv
    T = readtable(fullfile(beh_dir, sub, ses, strcat(sub, '_', ses, '_', 'task-cue_acq-mb8_', run, '_events.tsv')));
    % T = readtable(fullfile(nifti_dir, sub, fname));
    %basename = strrep(strrep(fname,'metadata_',''), '.csv', '');

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

end
else
load(dat_fname);
end
%save_dat = fullfile(save_dir, strcat('task-',run_type, '_PDM_stimlin-stim-actual_DAT.mat'));

save(dat_fname,'xx','yy','mm','-v7.3');

%% check dimensions

new_m = mm; new_x = xx; new_y = yy;
remove_sub = [];
for s = 1:length(new_y)
if ~isequal(size(new_m{s},2), size(new_y{s},1))
remove_sub = [remove_sub ;s]
end
end

for s = 1:length(remove_sub)
 disp('-------------------------------------------')
 disp(strcat(sublist(s), 'is odd, dimensions dont match. removing for now'))
 disp('-------------------------------------------')
end

if ~isempty(remove_sub)
new_x(remove_sub) = [];
new_y(remove_sub) = [];
new_m(remove_sub) = [];
%    for s = 1:length(remove_sub)
%    disp('-------------------------------------------')
%    disp(strcat(sublist(s), 'is odd, dimensions dont match. removing for now'))
%    disp('-------------------------------------------')
%    new_x(remove_sub(s)) = [];   
%    new_m(remove_sub(s)) = [];   
%    new_y(remove_sub(s)) = [];
%    end
end
disp('SIZE -------------')
disp(size(new_x))
disp(size(new_m))
disp(size(new_y))
% new_x = cell( length(xx), 1); 
% new_m = cell( length(xx), 1);
% new_y = cell( length(xx), 1);
X = cell( size(new_x,1), 1);
Y = cell( size(new_x,1), 1);
M = cell( size(new_x,1), 1);
for s = 1:length(new_y)
idx_nan = [];
idx_nan = ~isnan(new_y{s});
Y{s} = new_y{s}(idx_nan,:);
M{s} = new_m{s}(:,idx_nan');
X{s} = new_x{s}(idx_nan,:);
end


%% Reduce the dimensionality of the brain-mediator data using PVD
xx = X; yy= Y; mm = M;
min_comp = min(cellfun('size',yy,1))
% project onto lower dimensional space keeping th max number of components
pdm = multivariateMediation(xx,yy,mm,'noPDMestimation');

% same as above, but keep only 25 components
pdm = multivariateMediation(xx,yy,mm,'noPDMestimation','B',min_comp);

% If you have one trial/condition per subject use SVD option
% pdm = multivariateMediation(xx,yy,mm,'B',20,'svd');

%% Compute the multivariate brain mediators

% use previous PVD dimension reduction, compute all 25 PDMs, and plot path coeff
pdm = multivariateMediation(pdm,'nPDM', 7, 'plots');

% select the number of PDMs (3) based on the |ab| coeff plot, like a scree-plot
% pdm = multivariateMediation(pdm,'nPDM',3);


%% bootstrap voxel weights for significance

% bootstrap the first PDM with 100 samples
pdm = multivariateMediation(pdm,'noPDMestimation','bootPDM',1,'Bsamp',100);
pdm = multivariateMediation(xx,yy,mm,'B',min_comp,'nPDM',3,'bootPDM',1:3,'bootJPDM','Bsamp',100,'save2file','PDMresults.mat');

save_fname = fullfile(save_dir, strcat('task-',run_type, '_PDM_stimlin-stim-actual.mat'));
save(save_fname,'pdm','-append');
