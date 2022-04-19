function s06_template_mediation(run_type, event, csv, y_rating)
% TODO:
% 1. grab nifti and unzip
% 2. grab metadata
% 3. provide input as XMY
% 4. create folder
run_type = string(run_type)
event = string(event);
csv = string(csv);
y_rating = string(y_rating);
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');
% parameters __________________________________________________________________
% nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(fileparts(pwd)));
nifti_dir = fullfile(main_dir, 'analysis','fmri','spm','multivariate','s03_concatnifti')

<<<<<<< HEAD
% sublist = [3,4,5,6,7,8,9,10,14,15,16,18,19,20,21,23,24,25,26,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60];
sublist = [6,7,8,9,10,11,13,14,15,16,17,20,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,84,85];
=======
sublist = [6,7,8,9,10,11,13,14,15,16,17,18,20,21,23,24,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60,61,62,64,65,66,68,69,70,71,73,74,75,76,77,78,79,80,81,84,85];
>>>>>>> 8f421d534e5cc24259ee71f74c30e537f7fbc1e5
X = cell(1, length(sublist));
M = cell(1, length(sublist));
Y = cell(1, length(sublist));
% TODO: glob. if file exists, then run
% if event == 'cue'
%  else if event == 'stim'
%x_col = 
for s = 1:length(sublist)
    % step 01 __________________________________________________________________
    % grab metadata
    sub = strcat('sub-', sprintf("%04d", sublist(s)));
    fname = strcat('metadata_', sub ,'_task-social_run-', run_type, '_ev-', event, '.csv');
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
    X{1, s} = table2array(T(:, 'cue_con'));% T.cue; %
    M{1, s} = char(fname_nii);
    Y{1, s} = table2array(T(:,strcat(y_rating, '_rating'))); %T.actual_rating;

end
disp(X);
disp(M);
disp(Y);
SETUP.mask = which('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii');
SETUP.preprocX = 0;
SETUP.preprocY = 0;
SETUP.preprocM = 0;
SETUP.wh_is_mediator = 'M';
mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc')

SETUP = mediation_brain_corrected_threshold('fdr');

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('\n\n%s\n%s\n%s\n%s\n%s\n\n', dashes, dashes, str, dashes, dashes);

printhdr(strcat('Path a: ', event, '(X) to Brain Response (M)'))

mediation_brain_results('a', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');


% Results for Path b
% Generate results for effects of brain responses on pain reports, controlling for stimulus  temperature. 
printhdr(strcat('Path b: Brain Response (M) to ', y_rating, ' rating (Y), Adjusting for ', event, ' (X)'))

mediation_brain_results('b', 'thresh', ...
SETUP.fdr_p_thresh, 'size', 5, ...
'slices', 'tables', 'names', 'save');

% Results for Path a*b
% Generate results for the mediation effect. Here, we'll return some clusters structures with results to the workspace as output so we can examine them later. (We can also load them from disk).
<<<<<<< HEAD
printhdr(strcat('Path a*b: Brain Mediators (M) of ',event, '(X) Effects on ', run_type))
=======
printhdr(strcat('Path a*b: Brain Mediators (M) of ',event '(X) Effects on ', run_type))
>>>>>>> 8f421d534e5cc24259ee71f74c30e537f7fbc1e5

[clpos, clneg, clpos_data, clneg_data, clpos_data2, clneg_data2] = mediation_brain_results('ab', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');

%    load('cl_M-Y_pvals_003_k5_noprune.mat')
%    whos cl*
end
