function s07_rescalecontrasts(sub, spm_dir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overview - what motivated this script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-1. identify high cue vs low cue events
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify where the high cue and low cue events live
% sub = 'sub-0124';
% spm_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau';

sub_spm_dir = fullfile(spm_dir, sub);
save_dir = fullfile(spm_dir, '1stlevel_rescale', sub);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
    disp(['Folder "', save_dir, '" was created.']);
else
    disp(['Folder "', save_dir, '" already exists.']);
end


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
high_beta_pattern = [1,0,0, 1,0,0, 1,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,0];
low_beta_pattern = [0,0,0, 0,0,0, 0,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];

% Select high beta indices and names
[selectedIndicesHigh, selectedNamesHigh] = selectBetaIndices(numRegressorsPerRun, SPM, high_beta_pattern);
[selectedIndiceslow, selectedNamesLow] = selectBetaIndices(numRegressorsPerRun, SPM, low_beta_pattern);

% Initialize an empty vector for selected indices
% selectedIndices = [];
% currentIndex = 1; % Keeps track of the global index across all runs
% 
% % Loop through each run
% for run_ind = 1:length(numRegressorsPerRun)
%     % Update the high_beta to match the current run's regressor count
%     currentHighBeta = [high_beta, zeros(1, numRegressorsPerRun(run_ind) - length(high_beta))];
%     runSelectedIndices = find(currentHighBeta == 1);
%     runSelectedIndices = runSelectedIndices + currentIndex - 1;
%     selectedIndices = [selectedIndices, runSelectedIndices];
%     currentIndex = currentIndex + numRegressorsPerRun(run_ind);
% end
% 
% % selectedIndices now contains the indices of all selected betas across runs
% disp('Selected Beta Indices:');
% disp(selectedIndices);
% selectedNames = SPM.xX.name(selectedIndices);
% Assuming selectedFileNames is your cell array of selected regressor names
% for i = 1:length(selectedNames)
%     fprintf('Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
% end
%% low beta
% Define the low_beta pattern for selection
% low_beta = [0,0,0, 0,0,0, 0,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];

% % Initialize an empty vector for selected indices for low beta
% selectedIndicesLow = [];
% currentIndex = 1; % Reset for low beta
% 
% % Loop through each run for low beta
% for run_ind = 1:length(numRegressorsPerRun)
%     % Update the low_beta to match the current run's regressor count
%     currentLowBeta = [low_beta, zeros(1, numRegressorsPerRun(run_ind) - length(low_beta))];
%     runSelectedIndicesLow = find(currentLowBeta == 1);
%     runSelectedIndicesLow = runSelectedIndicesLow + currentIndex - 1;
%     selectedIndicesLow = [selectedIndicesLow, runSelectedIndicesLow];
%     currentIndex = currentIndex + numRegressorsPerRun(run_ind);
% end
% 
% % selectedIndices now contains the indices of all selected betas across runs
% disp('Selected Beta Indices:');
% disp(selectedIndicesLow);
% selectedNamesLow = SPM.xX.name(selectedIndicesLow);
% % Assuming selectedFileNames is your cell array of selected regressor names
% for i = 1:length(selectedNamesLow)
%     fprintf('Regressor no. %d: %s\n', selectedIndicesLow(i), selectedNamesLow{i});
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-2. save beta map file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regressor_savefname = fullfile(save_dir, strcat(sub, '_beta-highcue.txt'));
fileIDHigh = fopen(regressor_savefname, 'w');
if fileIDHigh == -1
    error('Failed to open the file for writing.');
else
    writeRegressorNamesToFile(fileIDHigh, selectedIndicesHigh, selectedNamesHigh);
    fclose(fileIDHigh);
end


fileIDLow = fopen(fullfile(save_dir, strcat(sub, '_beta-lowcue.txt')), 'w');
if fileIDLow == -1
    error('Failed to open the file for writing.');
else
    writeRegressorNamesToFile(fileIDLow, selectedIndicesLow, selectedNamesLow);
    fclose(fileIDLow);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-3. load beta maps into fmridata object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selectedFileNamesHigh = cell(1, length(selectedIndicesHigh));
selectedFileNamesLow = cell(1, length(selectedIndiceslow));
for i = 1:length(selectedIndicesHigh)
    indexStr = sprintf('%04d', selectedIndicesHigh(i));
    fileName = strcat('beta_', indexStr, '.nii');
    selectedFileNamesHigh{i} = fullfile(sub_spm_dir, fileName);
end

selectedFileNamesLow = cell(1, length(selectedIndicesLow));
for i = 1:length(selectedIndicesLow)
    indexStr = sprintf('%04d', selectedIndicesLow(i));
    fileNameLow = strcat('beta_', indexStr, '.nii');
    selectedFileNamesLow{i} = fullfile(sub_spm_dir, fileNameLow);
end


% rescale
% save as high cue and low cue
% save events for inspection
% 2. scale them specifically
high_beta_obj = fmri_data(selectedFileNamesHigh);
high_betadata = rescale(high_beta_obj, 'prctileimages');
low_betaobj = fmri_data(selectedFileNamesLow); % You need to construct selectedFileNamesLow similarly
low_betadata = rescale(low_betaobj, 'prctileimages');

save_highfname = fullfile(save_dir, 'P_simple_STIM_cue_high.nii');
save_lowfname = fullfile(save_dir, 'P_simple_STIM_cue_low.nii');
write(high_betadata, 'fname', save_highfname);
write(low_betadata, 'fname', save_lowfname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. compute contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subtract low from high beta maps

high_beta_mean = mean(high_betadata);
low_beta_mean = mean(low_betadata);
high_gt_low = high_beta_mean.dat - low_beta_mean.dat;

contrast_obj = high_beta_mean;
contrast_obj.dat = high_gt_low;
contrast_obj.dat_descrip = strcat('contrast of high cue > low cue for ', sub, '\n');
contrast_obj.image_names =  [selectedFileNames, selectedFileNamesLow];
% Save the subtracted image
save_contrast_fname = fullfile(save_dir, 'P_simple_STIM_cue_high_gt_low_rescale.nii');
write(contrast_obj, 'fname', save_contrast_fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [selectedIndices, selectedNames] = selectBetaIndices(numRegressorsPerRun, SPM, pattern)
    selectedIndices = [];
    currentIndex = 1; % Keeps track of the global index across all runs

    for run_ind = 1:length(numRegressorsPerRun)
        % Update the pattern to match the current run's regressor count
        currentPattern = [pattern, zeros(1, numRegressorsPerRun(run_ind) - length(pattern))];
        runSelectedIndices = find(currentPattern == 1);
        runSelectedIndices = runSelectedIndices + currentIndex - 1;
        selectedIndices = [selectedIndices, runSelectedIndices];
        currentIndex = currentIndex + numRegressorsPerRun(run_ind);
    end

    selectedNames = SPM.xX.name(selectedIndices);
end

function writeRegressorNamesToFile(fileID, selectedIndices, selectedNames)
    for i = 1:length(selectedIndices)
        fprintf(fileID, 'Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
    end
end

end


