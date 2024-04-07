%% -------------------------------------------------------------------------
% script overview
% -------------------------------------------------------------------------

% This is a script that runs the multilevel mediation analysis 
% for the cue expectancy pain task
% 
% X is stimulus contrast (high med low = 1, 0, -1)
% M is singletrials from stimulus epoch (pain plateau)
% Y is outcome rating from behavioral measures
% cov is cue contrast, given that we need to account for the other experimental factor
% l2m is a moderator, a between subject variable, average NPS response.

%% -------------------------------------------------------------------------
% directories and parameters
% -------------------------------------------------------------------------

addpath(genpath('./utils'));

% Define the case variable
dir_location = 'local';  % 'local' vs. 'discovery' as needed
switch dir_location
    case 'local'
        matlab_moduledir = '/Users/h/Documents/MATLAB';
        main_dir =  '/Users/h/Documents/projects_local/cue_expectancy';%'/Volumes/spacetop_projects_cue';
        singletrial_dir = fullfile('/Volumes/seagate/cue_singletrials/uncompressed_singletrial_rampupplateau');
        beh_dir = '/Volumes/seagate/cue_singletrials/beh';
        NPS_fname = '/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/rampup_plateau/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv';
        graymatter_mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii';
    case 'discovery'
        matlab_moduledir = '/dartfs-hpc/rc/lab/C/CANlab/modules';
        main_dir =  '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue';
        singletrial_dir = fullfile('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau');
        beh_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh';
        NPS_fname = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv';
        graymatter_mask = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step05_mediation/gray_matter_mask.nii';
    otherwise
        error('Invalid case specified.');

end


addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir,'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir,'MediationToolbox')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,'spm12/external/fieldtrip/external/stats')));

sublist = find_sublist_from_dir(singletrial_dir); % find subdirectories that start with keyword "sub-"
X = cell(1, length(sublist));
Minterim = cell(1, length(sublist));
Y = cell(1, length(sublist));
cov = cell(1, length(sublist));
l2m = zeros(1, length(sublist));
sub = cell(1, length(sublist));
eventlist = {'stim'}; 
%{'cue', 'stim'}

task = 'pain';
fprintf('step 1. parameter setup')

% -------------------------------------------------------------------------
% construct dataframes for mediation analysis
% -------------------------------------------------------------------------
NPS_fname = fullfile(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampup_plateau/signature-NPS_sub-all_runtype-pvc_event-stimulus.tsv');
npsdf = readtable(NPS_fname,"FileType","text", 'Delimiter', ',');

for e = 1:length(eventlist)
    for s = 1:length(sublist)
    
        % step 01: glob all the nifti files
        disp(strcat('starting ', sublist{s}))%strcat('sub-',sprintf('%04d', sublist(s)))))
        
        singletrial_flist = dir(fullfile(singletrial_dir, sublist{s},...
            strcat(sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
    %                         strcat('smooth-6mm_',sublist{s}, '*_runtype-', task, '*_event-',eventlist{e},'*.nii')   ));
        if ~isempty(singletrial_flist)
        singletrial_fldr = {singletrial_flist.folder}; fname = {singletrial_flist.name};
        singletrial_files = strcat(singletrial_fldr,'/', fname)';
            
    
        % step 02: identify number of unique sub/ses/runs and load behavioral files
        unique_bids = unique_combination_bids(singletrial_files);
    
        % step 03: merge the behavioral files and niftifiles based on intersection
        %          Extract the base filenames from the full path filenames
        beh_df = load_beh_bids(fullfile(beh_dir), unique_bids);
        combinedTable = innerjoin(npsdf, beh_df, 'Keys', 'singletrial_fname');
    %     beh_fname = fullfile(main_dir, 'data', 'beh', 'beh_singletrials', strcat(sublist{s}, '_task-', task, 'desc-singletrialbehintersection_events.tsv');
        mkdir(fullfile(main_dir, 'data', 'beh', 'beh_singletrials',strcat(sublist{s})));
        beh_fname = fullfile(main_dir, 'data', 'beh', 'beh_singletrials',sublist{s}, strcat(sublist{s}, '_task-', task, '_desc-singletrialbehintersection_events.tsv'));
        writetable(combinedTable, beh_fname, 'Delimiter', '\t', 'FileType', 'text');
        singletrial_basefname = cellfun(@(x) extractAfter(x, max(strfind(x, filesep))), singletrial_files, 'UniformOutput', false);
    %     if dir_location== 'discovery'
    % %     Define the prefix and merge dataframe based on single trial filenames
    %         prefix = 'smooth-6mm_';
    %         combinedTable.singletrial_fname = strcat(prefix, combinedTable.singletrial_fname);
    %     end
    
        merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, combinedTable);
    
        % step 04: if any of the Y regressors have NA values, the mediation will fail. Remove these instances
        metadf_clean = remove_missing_behvalues(merge_beh_nii, 'outcomerating');
        metadf_clean = remove_missing_behvalues(metadf_clean, 'expectrating');
    %     metadf_clean = remove_missing_behvalues(merge_beh_nii, 'outcomerating');
    
        % step 05: contrast code the X regressors. Originally, they are strings in my behavioral dataframe
        cue_contrast_mapper = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
        stim_contrast_mapper = containers.Map({'low_stim', 'med_stim', 'high_stim'}, [-1, 0, 1]);
        metadf_cue = contrast_coding(metadf_clean, 'cue', 'cue_contrast', cue_contrast_mapper);
        metadf_con = contrast_coding(metadf_cue, 'stimulusintensity', 'stim_contrast', stim_contrast_mapper);
    
    
    
        
        % step 06: the mediation code expects the full path of nifti files. Construct this based on the basename columns
        mediation_df = add_fullpath_column(metadf_con, singletrial_dir, sublist{s}, 'singletrial_fname', 'fullpath_fname');
    
        % step 07: final step! construct the X, Minterim, Y cells for the mediation analysis  
        X{1,s} = mediation_df.cue_contrast;
        Minterim{1,s} = mediation_df.fullpath_fname;
        Y{1,s} = mediation_df.outcomerating;
        cov{1,s} = [mediation_df.stim_contrast]; %mediation_df.expectrating,
%         cov{1,s} = covariates; %mediation_df.cue_contrast;
%         cov{2,s} = mediation_df.stim_contrast;
%         cov{1,s} = mediation_df.cue_contrast;
        l2m(s) = mean(mediation_df.NPS); 
        sub{1,s} = sublist{s}; 
    
        end
    end
end




    
fprintf('Size of X: %s\n', mat2str(size(X)));
fprintf('Size of Y: %s\n', mat2str(size(Y)));
fprintf('Size of Minterim: %s\n', mat2str(size(Minterim)));
fprintf('Size of cov: %s\n', mat2str(size(cov)));
fprintf('Size of l2m: %s\n', mat2str(size(l2m)));

save('mediation_XcueYoutcomeMcovL2.mat', 'X', 'Y', 'Minterim', 'cov', 'l2m', 'sub');

%----------------------------
%% drop missing rows (ver 1.)
% ----------------------------
load('mediation_XcueYoutcomeMcovL2.mat');
missingIndices = []; % Initialize an empty array to store missing indices
% Iterate over each index
for i = 1:size(X,2)
    if isempty(X{i}) || isempty(Y{i}) || isempty(Minterim{i}) || isempty(cov{i}) || isnan(l2m(i))
        missingIndices = [missingIndices i]; % Add the index to the missing list
    end
end
missingSubjects = sub(missingIndices); % Retrieve subject numbers for missing indices

% Display the missing indices and corresponding subject numbers
fprintf('Missing Indices: %s\n', mat2str(missingIndices));
logicalIndex = true(1, size(X,2)); % Create a logical array with all true values
logicalIndex(missingIndices) = false; % Set the indices corresponding to missingIndices to false

% Filter cell arrays (X, Y, Minterim, cov)
X_filtered = X(logicalIndex);
Y_filtered = Y(logicalIndex);
M_filtered = Minterim(logicalIndex);
cov_filtered = cov(logicalIndex);
sub_filtered = sub(logicalIndex);

% For l2m, which is a double array, we need a slightly different approach.
% We'll replace the values at missing indices with NaN and then remove all NaNs
l2m_temp = l2m;
l2m_temp(missingIndices) = NaN;  % Mark missing indices as NaN
l2m_filtered = l2m_temp(~isnan(l2m_temp)); % Remove NaNs to filter
l2m_centered = l2m_filtered-mean(l2m_filtered);
save('mediation_XexpectYoutcomeMcovL2.mat');
%----------------------------
%%  DROP MISSING ROWS & TRIALS LESS THAN 10
% ----------------------------
load('mediation_XexpectYoutcomeMcovL2.mat');
missingIndices = [];    % Initialize an empty array to store missing indices
insufficientDataIndices = []; % Initialize an empty array for indices with insufficient data
trial_cutoff = 10;      % remove subject less than 10 trials
% Iterate over each index
for i = 1:size(X_filtered,2)
    % Check for missing or NaN data
    if isempty(X{i}) || isempty(Y{i}) || isempty(Minterim{i}) || isempty(cov{i}) || isnan(l2m(i))
        missingIndices = [missingIndices i]; % Add the index to the missing list
    % Check for insufficient instances in each cell
    elseif numel(X{i}) < trial_cutoff || numel(Y{i}) < trial_cutoff || numel(Minterim{i}) < trial_cutoff || numel(cov{i}) < trial_cutoff
        insufficientDataIndices = [insufficientDataIndices i]; % Add index to the insufficient data list
    end
end

% Combine missing indices and insufficient data indices
combinedIndices = unique([missingIndices, insufficientDataIndices]);
missingSubjects = sub(combinedIndices);
fprintf('Combined Indices (Missing or Insufficient Data): %s\n', mat2str(combinedIndices));

% Create a logical array with all true values
logicalIndex = true(1, size(X,2));
logicalIndex(combinedIndices) = false;

% Filter cell arrays (X, Y, Minterim, cov) based on logicalIndex
X_filtered = X(logicalIndex);
Y_filtered = Y(logicalIndex);
M_filtered = Minterim(logicalIndex);
cov_filtered = cov(logicalIndex);
sub_filtered = sub(logicalIndex);

% For l2m, which is a double array, adjust for combinedIndices
l2m_temp = l2m;
l2m_temp(combinedIndices) = NaN;  % Mark combined indices as NaN
l2m_filtered = l2m_temp(~isnan(l2m_temp)); % Remove NaNs to filter
l2m_centered = l2m_filtered-mean(l2m_filtered);


fprintf('step 2. X, Y, M fully set up');


brain_check = fmri_data('/Users/h/Documents/projects_local/sandbox/smooth-6mm_sub-0064_ses-01_run-02_runtype-pain_event-stimulus_trial-000_cuetype-low_stimintensity-med.nii');
montage(brain_check)
%% -------------------------------------------------------------------------
% start mediation analysis
% -------------------------------------------------------------------------

addpath(genpath(fullfile(matlab_moduledir, 'CanlabCore')));
addpath(genpath(fullfile(matlab_moduledir, 'Neuroimaging_Pattern_Masks')));
addpath(genpath(fullfile(matlab_moduledir, 'MediationToolbox')));
addpath(genpath(fullfile(matlab_moduledir, 'spm12')));
rmpath(genpath(fullfile(matlab_moduledir,  'spm12/external/fieldtrip')));
rmpath(genpath(fullfile(matlab_moduledir,  'spm12/external/fieldtrip/external/stats')));


% ----------------------------
% z score across participants
% ----------------------------

num_participants = numel(Y_filtered);
all_data = vertcat(Y_filtered{:}); % Aggregate all data into one matrix (assuming each participant's data is a column vector)

% Compute the mean and standard deviation across all data
mean_data = mean(all_data); 
std_data = std(all_data);

% Z-score all data using the computed mean and standard deviation
zscored_Y = cell(num_participants, 1);

for i = 1:num_participants
    participant_data = Y_filtered{i}; % Access the data for the current participant
    zscored_Y{i} = (participant_data - mean_data) ./ std_data;
end
zscored_Y_filtered = zscored_Y';

% fprintf('Size of X: %s\n', mat2str(size(X)));
% fprintf('Size of zscored_y: %s\n', mat2str(size(zscored_Y)));
% fprintf('Size of M: %s\n', mat2str(size(M)));
% fprintf('Size of cov: %s\n', mat2str(size(cov)));
% fprintf('Size of l2m_centered: %s\n', mat2str(size(l2m_meancentered)));

SETUP.mask = '../new_graymattermask_thres2.nii'; %which(graymatter_mask);
SETUP.preprocX = 0;
SETUP.preprocY = 0;
SETUP.preprocM = 0;
SETUP.wh_is_mediator = 'M';
M_filtered_char = convert_cell2char(M_filtered);

mediation_brain_multilevel(X_filtered, zscored_Y_filtered, M_filtered_char, SETUP, 'nopreproc', 'covs', cov_filtered, 'L2M', l2m_centered', 'boot', 'bootsamples', 1000);
% mediation_brain_multilevel(X_filtered, zscored_Y_filtered, M_filtered_char, SETUP, 'nopreproc', 'covs', cov_filtered, 'boot', 'bootsamples', 1000);% 'L2M', l2m_meancentered',
% mediation_brain_multilevel(X_filtered, zscored_Y_filtered, M_filtered_char, SETUP, 'nopreproc', 'boot', 'bootsamples', 1000);
% mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'covs', cov, 'L2M', l2m_meancentered'); %, 'boot', 'bootsamples', 1000);
% mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'covs', cov, 'boot', 'bootsamples', 1000);% 'L2M', l2m_meancentered',
% mediation_brain_multilevel(X, Y, M, SETUP, 'nopreproc', 'boot', 'bootsamples', 1000);
SETUP = mediation_brain_corrected_threshold('fdr');

dashes = '----------------------------------------------';
printstr = @(dashes) disp(dashes);
printhdr = @(str) fprintf('\n\n%s\n%s\n%s\n%s\n%s\n\n', dashes, dashes, str, dashes, dashes);

printhdr('Path a: Cue to Brain Response')

mediation_brain_results('a', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_a_results.pdf', '-dpdf');

% Results for Path b
% Generate results for effects of brain responses on pain reports, controlling for stimulus  temperature.
printhdr('Path b: Brain Response to Actual Rating, Adjusting for Cue')

mediation_brain_results('b', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_b_results.pdf', '-dpdf');
% Results for Path a*b
% Generate results for the mediation effect. Here, we'll return some clusters structures with results to the workspace as output so we can examine them later. (We can also load them from disk).
printhdr('Path a*b: Brain Mediators of Cue Effects on General')

[clpos, clneg, clpos_data, clneg_data, clpos_data2, clneg_data2] = mediation_brain_results('ab', 'thresh', ...
    SETUP.fdr_p_thresh, 'size', 5, ...
    'slices', 'tables', 'names', 'save');
print('Path_ab_results.pdf', '-dpdf');



publish_mediation_report()

function [X_test, Y_test, M_test, cov_test, l2m_test] = filter_empty_cells(X, Y, M, cov, l2m)
    num_subjects = numel(X);

    % ----------------------------------------------------------------------------
    %  filter rows based on Y data
    % ----------------------------------------------------------------------------

    % Initialize cell arrays to store filtered data
    X_filtered = cell(num_subjects, 1);
    Y_filtered = cell(num_subjects, 1);
    M_filtered = cell(num_subjects, 1);
    cov_filtered = cell(num_subjects, 1);
    l2m_filtered = [];

    % Loop through subjects and filter out cells with empty arrays in Y
    for i = 1:num_subjects
        % Check if Y is not empty for the current subject
        if ~isempty(Y{i})
            X_filtered{i} = X{i};
            Y_filtered{i} = Y{i};
            M_filtered{i} = M{i};
            cov_filtered{i} = cov{i}; % If you want to filter cov as well
            l2m_filtered(i) = l2m(i); % If you want to filter l2m as well
        end
    end

    num_filtered = numel(Y_filtered);
    X_test = cell(num_filtered, 1);
    Y_test = cell(num_filtered, 1);
    M_test = cell(num_filtered, 1);
    cov_test = cell(num_filtered, 1);
    l2m_test = [];
    % Loop through subjects and filter out cells with empty arrays in Y


    % ----------------------------------------------------------------------------
    %  filter rows based on moderator data
    % ----------------------------------------------------------------------------
    % NPS values might have nans in there
    nan_indices = find(isnan(l2m_filtered));

    X_test = X_filtered([1:nan_indices-1, nan_indices+1:end]);
    Y_test = Y_filtered([1:nan_indices-1, nan_indices+1:end]);
    M_test = M_filtered([1:nan_indices-1, nan_indices+1:end]);
    cov_test = cov_filtered([1:nan_indices-1, nan_indices+1:end]);
    l2m_test = l2m_filtered([1:nan_indices-1, nan_indices+1:end]);

end
