%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load single trial data
singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
task = "pain"
flist = fullfile(file.path(singletrial_dir, "sub-*", ["*runtype-", task, "_event-*_cuetype-*.nii.gz"]))
fprint(["Found ", length(flist), " NIfTI files."])
% extract metadata from filename
% unzip in scratch
% behavioral metadata








% load behavioral data
% if outcome rating is NA, remove both cue and brain data
% load dataframe
% data_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/pls';
data_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/pls';
info = h5info(fullfile(data_dir, 'singletrial_pvc.h5')); % Get information about the HDF5 file
datasetName = info.Datasets(1).Name; % Assuming you want to read the first dataset
data = h5read(fullfile(data_dir, 'singletrial_pvc.h5'), ['/' datasetName]); % Read the dataset
niidata = data';

% load behavioral data
beh = readtable(fullfile(data_dir, 'singletrial_pvc.csv'));

% identify number of subjects
unique_subs = unique(beh.sub);
length_subs = numel(unique_subs);
% length_subs = length(unique_subs);
% per subject, input cue, actual rating and brain data
% subsetTables = cell(length_subs, 1);
X = cell(1, length(unique_subs));
M = cell(1, length(unique_subs));
Y = cell(1, length(unique_subs));

for s = 1:length_subs
    sub_mask = strcmp(beh.sub, unique_subs{s});
    
    X{1,s} = beh.gen_cue(sub_mask);
    M{1,s} = niidata(sub_mask, :);
    Y{1,s} = beh.outcomerating(sub_mask);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mediation

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
