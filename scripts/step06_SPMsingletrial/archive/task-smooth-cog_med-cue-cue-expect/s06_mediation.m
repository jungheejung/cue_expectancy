% TODO:
% 1. grab nifti and unzip
% 2. grab metadata
% 3. provide input as XMY
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));
rmpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip'));
rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');
% parameters __________________________________________________________________
nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/fsl/multivariate/concat_nifti';
main_dir = fileparts(fileparts(fileparts(pwd)));
nifti_dir = fullfile(main_dir, 'analysis','fmri','spm','multivariate','s03_concatnifti')
% sublist = {'sub-0002','sub-0003','sub-0005',...
% 'sub-0006','sub-0007','sub-0008','sub-0009','sub-0010',...
% 'sub-0014','sub-0015','sub-0016','sub-0018' ,'sub-0019','sub-0020',...
% 'sub-0021','sub-0023','sub-0024','sub-0025',...
% 'sub-0026','sub-0028','sub-0029','sub-0030',...  
% 'sub-0031','sub-0032','sub-0033','sub-0035'};
% 2,7,11,13,17,18,19,20,21,23,25,26,43,60
sublist=[3,4,5,6,8,9,10,14,15,16,24,28,29,30,31,32,33,35,37,47,51,53,55,58];
%ddsublist = [3,4,5,6,7,8,9,10,14,15,16,19,20,21,23,24,25,26,28,29,30,31,32,33,35,37,43,47,51,53,55,58,60];
X = cell(1, length(sublist));
M = cell(1, length(sublist));
Y = cell(1, length(sublist));


for s = 1:length(sublist)
    % step 01 __________________________________________________________________
    % grab metadata
    sub = strcat('sub-', sprintf('%04d', sublist(s)));
    fname = strcat('metadata_', sub ,'_task-cognitive_ev-cue.csv');
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
    X{1, s} = T.cue_con;
    M{1, s} = char(fname_nii);
    Y{1, s} = T.expect_rating;

end
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

printhdr('Path a: Cue to Brain Response')

mediation_brain_results('a', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');


% Results for Path b
% Generate results for effects of brain responses on pain reports, controlling for stimulus  temperature. 
printhdr('Path b: Brain Response to Actual Rating, Adjusting for Cue')

mediation_brain_results('b', 'thresh', ...
SETUP.fdr_p_thresh, 'size', 5, ...
'slices', 'tables', 'names', 'save');

% Results for Path a*b
% Generate results for the mediation effect. Here, we'll return some clusters structures with results to the workspace as output so we can examine them later. (We can also load them from disk).
printhdr('Path a*b: Brain Mediators of Cue Effects on General')

[clpos, clneg, clpos_data, clneg_data, clpos_data2, clneg_data2] = mediation_brain_results('ab', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');

%    load('cl_M-Y_pvals_003_k5_noprune.mat')
%    whos cl*
