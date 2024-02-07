function s07_rescalecontrasts(sub, main_dir, spm_dir, task)
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
addpath(genpath("/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"));
addpath(genpath("/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"));
sub_spm_dir = fullfile(spm_dir, sub);
onset_dir = fullfile(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM');
save_dir = fullfile(spm_dir, '1stlevel_rescale', sub);
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
    disp(['Folder "', save_dir, '" was created.']);
else
    disp(['Folder "', save_dir, '" already exists.']);
end

sub_spm_dir
SPM = load(fullfile(sub_spm_dir, "SPM.mat"));
SPM = SPM.SPM;
paths = cellstr(SPM.xY.P);

uniqueFilePaths = unique(cellfun(@(x) x(1:strfind(x, '.nii,')-1), paths, 'UniformOutput', false)); % Get unique file paths (without slice numbers)
numFiles = length(uniqueFilePaths); % Extract 'sub', 'ses', and 'run' info

%% extract metadata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% find onset files
onsetlist = dir(fullfile(onset_dir, sub, '*', strcat(sub, '_*_task-cue_*_events.tsv')));
onsetT = struct2table(onsetlist);
sortedonsetT = sortrows(onsetT, 'name');

sortedonsetT.sub_num(:) = str2double(extractBetween(sortedonsetT.name, 'sub-', '_'));
sortedonsetT.ses_num(:) = str2double(extractBetween(sortedonsetT.name, 'ses-', '_'));
sortedonsetT.run_num(:) = str2double(extractBetween(sortedonsetT.name, 'run-', '_'));
sortedonsetT.runtype = string(extractBetween(sortedonsetT.name, 'runtype-', '_'));

%% grab intersection images and onset files
A = innerjoin(sortedT, sortedonsetT, 'Keys', {'sub_num', 'ses_num', 'run_num'});
matlabbatch = cell(1,1);
runlength = size(A,1);
numRegressorsPerRun = arrayfun(@(x) length(x.col),SPM.Sess);
runtype_counts = tabulate(A.runtype)

%% subset runs of interest %%%%%%
if task == "all"
    istask = length(numRegressorsPerRun);
else
    istask = A.runtype == task;
end

taskIndices = find(istask);
% Define the high_beta pattern for selection
high_beta_pattern = [1,0,0, 1,0,0, 1,0,0, 0,0,0, 0,0,0, 0,0,0, 0,0,0,0];
low_beta_pattern = [0,0,0, 0,0,0, 0,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];

% Select high beta indices and names
[selectedIndicesHigh, selectedNamesHigh] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, high_beta_pattern);
[selectedIndicesLow, selectedNamesLow] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, low_beta_pattern);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-2. save beta map file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
regressor_savefname = fullfile(save_dir, strcat(sub,'_',task, '_beta-highcue.txt'));
fileIDHigh = fopen(regressor_savefname, 'w');
if fileIDHigh == -1
    error('Failed to open the file for writing.');
else
    writeRegressorNamesToFile(fileIDHigh, selectedIndicesHigh, selectedNamesHigh);
    fclose(fileIDHigh);
end


fileIDLow = fopen(fullfile(save_dir, strcat(sub,'_', task, '_beta-lowcue.txt')), 'w');
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
selectedFileNamesLow  = cell(1, length(selectedIndicesLow));
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
high_beta_mean = mean(high_beta_obj);
high_betadata = rescale(high_beta_mean, 'prctileimages');


low_betaobj = fmri_data(selectedFileNamesLow); 
low_beta_mean = mean(low_betaobj);
low_betadata = rescale(low_beta_mean, 'prctileimages');

save_highfname = fullfile(save_dir, strcat(sub, '_runtype-', task, '_simple_STIM_cue_high.nii'));
save_lowfname  = fullfile(save_dir, strcat(sub, '_runtype-', task, '_simple_STIM_cue_low.nii'));
write(high_betadata, 'fname', save_highfname, 'overwrite');
write(low_betadata,  'fname', save_lowfname, 'overwrite');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. compute contrasts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subtract low from high beta maps

high_gt_low = high_betadata.dat - low_betadata.dat;

contrast_obj = high_betadata;
contrast_obj.dat = high_gt_low;
contrast_obj.dat_descrip = strcat('contrast of high cue > low cue for ', sub, '\n');
contrast_obj.image_names =  [selectedFileNamesHigh, selectedFileNamesLow];
% Save the subtracted image
save_contrast_fname = fullfile(save_dir, strcat(sub,'_P_simple_STIM_cue_high_gt_low_rescale.nii'));
write(contrast_obj, 'fname', save_contrast_fname, 'overwrite');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     function [selectedIndices, selectedNames] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, pattern)
%     selectedIndices = [];
%     currentIndex = 1; % Keeps track of the global index across all runs
% 
%     for run_ind = taskIndices
%         % Update the pattern to match the current run's regressor count
%         currentPattern = [pattern, zeros(1, numRegressorsPerRun(run_ind) - length(pattern))];
%         runSelectedIndices = find(currentPattern == 1);
%         runSelectedIndices = runSelectedIndices + currentIndex - 1;
%         selectedIndices = [selectedIndices, runSelectedIndices];
%         currentIndex = currentIndex + numRegressorsPerRun(run_ind);
%     end
% 
%     selectedNames = SPM.xX.name(selectedIndices);
% end


function [selectedIndices, selectedNames] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, pattern)
%SELECTBETAINCIDICES Selects beta indices for specific runs based on task indices.
%
% [selectedIndices, selectedNames] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, pattern)
% selects the beta indices for the runs specified in taskIndices. It accounts for the cumulative
% number of regressors in all preceding runs to correctly offset the indices for each selected run.
%
% Inputs:
%   taskIndices - A vector of indices indicating the runs of interest.
%   numRegressorsPerRun - A vector indicating the number of regressors per run.
%   SPM - The SPM structure containing design matrix names in SPM.xX.name.
%   pattern - A binary vector indicating which regressors to select within each run.
%
% Outputs:
%   selectedIndices - The indices of the selected betas within the design matrix.
%   selectedNames - The names of the selected regressors corresponding to selectedIndices.
%
% Example:
%   taskIndices = [2, 4, 9];
%   numRegressorsPerRun = [48, 48, 52, ...]; % Complete vector for all runs
%   pattern = [1, 0, 1, ...]; % Define pattern for selecting regressors
%   [indices, names] = selectBetaIndices(taskIndices, numRegressorsPerRun, SPM, pattern);
%
% This function assumes that the number of elements in pattern does not exceed the number of
% regressors in any run specified by taskIndices. If the pattern is shorter than the number of
% regressors in a run, it's padded with zeros to match the length.

    selectedIndices = [];
    % Compute the cumulative sum of regressors per run to use as an offset
    cumulativeRegressors = cumsum(numRegressorsPerRun);
    
    for i = 1:length(taskIndices)
        run_ind = taskIndices(i); % Get the current run index from taskIndices
        
        % Calculate the starting index for the current run
        % If run_ind is the first run, the starting index is 1
        % Otherwise, it's the cumulative sum of regressors up to the previous run + 1
        if run_ind == 1
            currentIndex = 1;
        else
            currentIndex = cumulativeRegressors(run_ind - 1) + 1;
        end
        
        % Update the pattern for the current run if necessary
        currentPattern = [pattern, zeros(1, numRegressorsPerRun(run_ind) - length(pattern))];
        
        % Find indices of the current run's selected regressors
        runSelectedIndices = find(currentPattern == 1);
        runSelectedIndices = runSelectedIndices + currentIndex - 1; % Adjust by the current global index
        
        % Append the current run's selected indices to the overall list
        selectedIndices = [selectedIndices, runSelectedIndices];
    end
    
    % Extract the names of the selected regressors from SPM.xX.name
    selectedNames = SPM.xX.name(selectedIndices);
end




function writeRegressorNamesToFile(fileID, selectedIndices, selectedNames)
    for i = 1:length(selectedIndices)
        fprintf(fileID, 'Regressor no. %d: %s\n', selectedIndices(i), selectedNames{i});
    end
end

end


