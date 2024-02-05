%% Overview - what motivated this script

% we were getting some global parcel wise cue effects, generic across the
% brain. Tor suggested I rescale the contrasts. Rescaling would remove big
% differences across trial conditions. 

% we're getting some weird cue effects , though stim effects look really nice.  
% In addition to diagnostic plots suggested above, you might try a new function in the repo:
% rescale(obj, 'prctile_images')
% You'd rescale the images BEFORE calculating contrasts, then calculate contrasts on the rescaled images. 
% If there are big shifts across the brain that are different across conditions, 
% contaminating the contrast maps, then this could remove them.  
% Definitely exploratory, but i'm curious to see if the results make sense, b
% ecause the cue effects look like artifacts to me

%% TODO
% 1-1. identify high cue vs low cue events
% identify where the high cue and low cue events live
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'));
sub_spm_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau/sub-0124';
regressor_savefname = 
load(fullfile(sub_spm_dir, "SPM.mat"))
paths = cellstr(SPM.xY.P);

uniqueFilePaths = unique(cellfun(@(x) x(1:strfind(x, '.nii,')-1), paths, 'UniformOutput', false)); % Get unique file paths (without slice numbers)
numFiles = length(uniqueFilePaths); % Extract 'sub', 'ses', and 'run' info

subInfo = zeros(1, numFiles);  % Pre-allocate a matrix for efficiency
sesInfo = zeros(1, numFiles);   % We will keep these as cells since you didn't specify to change them
runInfo = zeros(1, numFiles);   % Same here

for i = 1:numFiles
    [~, fileName, ~] = fileparts(uniqueFilePaths{i});
    subInfo(i) = str2double(regexp(fileName, '(?<=sub-)\d+', 'match', 'once'));
    sesInfo(i) = str2double(regexp(fileName, '(?<=ses-)\d+', 'match', 'once'));
    runInfo(i) = str2double(regexp(fileName, '(?<=run-)\d+', 'match', 'once'));
end

% create a table. Aftereward, find the corresponding run-type info
sortedT = table(subInfo', sesInfo', runInfo', 'VariableNames', {'sub_num', 'ses_num', 'run_num'});

matlabbatch = cell(1,1);
runlength = size(A,1);
numRegressorsPerRun = arrayfun(@(x) length(x.col), SPM.Sess);
runtype_counts = tabulate(A.runtype);
% Define the high_beta pattern for selection
high_beta = [1,0,0, 1,0,0, 1,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,0];
low_beta = [0,0,0, 0,0,0, 0,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];
% STIM_cue_high_gt_low         = [1,0,0, 1,0,0, 1,0,0, -1,0,0, -1,0,0, -1,0,0, 0,0,0,0];

% Initialize an empty vector for selected indices
selectedIndices = [];
currentIndex = 1; % Keeps track of the global index across all runs

% Loop through each run
for run_ind = 1:length(numRegressorsPerRun)
    % Update the high_beta to match the current run's regressor count
    currentHighBeta = [high_beta, zeros(1, numRegressorsPerRun(run_ind) - length(high_beta))];
    runSelectedIndices = find(currentHighBeta == 1);
    runSelectedIndices = runSelectedIndices + currentIndex - 1;
    selectedIndices = [selectedIndices, runSelectedIndices];
    currentIndex = currentIndex + numRegressorsPerRun(run_ind);
end

% selectedIndices now contains the indices of all selected betas across runs
disp('Selected Beta Indices:');
disp(selectedIndices);
selectedNames = SPM.xX.name(selectedIndices);
% Assuming selectedNames is your cell array of selected regressor names
for i = 1:length(selectedNames)
    fprintf('Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
end
%% low beta
% Define the low_beta pattern for selection
low_beta = [0,0,0, 0,0,0, 0,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];

% Initialize an empty vector for selected indices for low beta
selectedIndicesLow = [];
currentIndex = 1; % Reset for low beta

% Loop through each run for low beta
for run_ind = 1:length(numRegressorsPerRun)
    % Update the low_beta to match the current run's regressor count
    currentLowBeta = [low_beta, zeros(1, numRegressorsPerRun(run_ind) - length(low_beta))];
    runSelectedIndicesLow = find(currentLowBeta == 1);
    runSelectedIndicesLow = runSelectedIndicesLow + currentIndex - 1;
    selectedIndicesLow = [selectedIndicesLow, runSelectedIndicesLow];
    currentIndex = currentIndex + numRegressorsPerRun(run_ind);
end

% selectedIndices now contains the indices of all selected betas across runs
disp('Selected Beta Indices:');
disp(selectedIndices);
selectedNames = SPM.xX.name(selectedIndices);
% Assuming selectedNames is your cell array of selected regressor names
for i = 1:length(selectedNames)
    fprintf('Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
end

%% 1-2. save beta map file
regressor_savefname = ;
fileID = fopen(regressor_savefname, 'w');
if fileID == -1
    error('Failed to open the file for writing.');
end

for i = 1:length(selectedNames)
    fprintf(fileID, 'Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
end

fclose(fileID);
disp('Selected regressor names and numbers have been written to selectedRegressors.txt');

%% 1-3. load beta maps into fmridata object
selectedFileNames = cell(1, length(selectedIndices));

for i = 1:length(selectedIndices)
    indexStr = sprintf('%04d', selectedIndices(i));
    fileName = strcat('beta_', indexStr, '.nii');
    selectedFileNames{i} = fullfile(sub_spm_dir, fileName);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% delete later %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display the file names (optional)
disp('Selected Beta File Names:');
disp(selectedFileNames);
for i = 1:length(selectedFileNames)
    fprintf('Regressor no.: %s\n', selectedFileNames{i});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% delete later %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rescale
% save as high cue and low cue
% save events for inspection
% 2. scale them specifically
high_beta = fmri_data(selectedFileNames);
high_betadata = rescale(high_beta, 'prctile_images');
save_highfname = ;
save_lowfname = ;
write(high_betadata, 'fname', save_highfname);

% Assuming high_beta and low_beta are loaded as fmri_data objects
low_beta = fmri_data(selectedFileNamesLow); % You need to construct selectedFileNamesLow similarly
low_betadata = rescale(low_beta, 'prctile_images');

% Save paths need to be defined
save_highfname = 'path/to/high_beta_rescaled.nii';
save_lowfname = 'path/to/low_beta_rescaled.nii';

% Save the rescaled high and low beta data
write(high_betadata, 'fname', save_highfname);
write(low_betadata, 'fname', save_lowfname);

% 3. compute contrasts
% Subtract low from high beta maps
high_gt_low = high_betadata.dat - low_betadata.dat;

% Create a new fmri_data object for the result (assuming compatibility)
high_gt_low_data = high_betadata; % Clone the structure
high_gt_low_data.dat = high_gt_low; % Update the data

% Save the subtracted image
save_subtracted_fname = 'path/to/high_gt_low.nii';
write(high_gt_low_data, 'fname', save_subtracted_fname);

% 4. plot

contrast_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau/1stlevel_rescale';
beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau';

