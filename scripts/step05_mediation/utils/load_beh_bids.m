function finalTable = load_beh_bids(beh_dir, unique_bids)
    %LOAD_BEH_BASED_ON_BIDS Loads behavioral data files based on BIDS (Brain Imaging Data Structure) naming conventions.
    %
    % This function iterates through a set of unique combinations of subject, session, 
    % and run identifiers (unique_bids) to load corresponding behavioral data files from 
    % a specified directory. It assumes that the files are named following the BIDS standard,
    % specifically for task-cue event files in .tsv format.
    %
    % Parameters
    % ----------
    % beh_dir : string
    %   The directory path where the behavioral data files are stored.
    % 
    % unique_bids : numeric matrix
    %   A matrix with unique combinations of subject (sub), session (ses), and run numbers.
    %   Each row represents a unique combination with columns for 'sub', 'ses', and 'run'.
    %
    % Returns
    % -------
    % finalTable : table
    %   A MATLAB table consolidating all the loaded .tsv files. Each file's data is appended
    %   as rows in the final table.
    %
    % Example
    % -------
    % beh_dir = '/path/to/behavioral/data';
    % unique_bids = [1 1 1; 1 1 2; ...]; % Example unique combinations of sub/ses/run
    % finalTable = load_beh_based_on_bids(beh_dir, unique_bids);
    %
    % Notes
    % -----
    % The function assumes that the .tsv files are named in a specific format:
    % 'sub-XXXX_ses-YY_task-cue_*run-ZZ_runtype-*_events.tsv', where 'XXXX', 'YY', 
    % and 'ZZ' are subject, session, and run numbers respectively.
    %
    % The function will print a message and skip any combination for which no corresponding file is found.
    %
    % See also READTABLE, DIR, FULLFILE, SPRINTF

    finalTable = table();
    % Loop through each unique bid
    for i = 1:size(unique_bids, 1)
        % Extract sub, ses, and run for each row
        sub = unique_bids(i, 1);
        ses = unique_bids(i, 2);
        run = unique_bids(i, 3);
        disp(sub)
        % Generate the file path pattern based on BIDS naming convention
        
        fname_pattern = sprintf('sub-%04d_ses-%02d_task-cue_*run-%02d_*_events.tsv', sub, ses, run);
        disp(fname_pattern);
        filepathPattern = fullfile(beh_dir, sprintf('sub-%04d', sub), fname_pattern);
        disp(filepathPattern)
        files = dir(filepathPattern); % Find files that match the pattern
        disp(files)

        % Check if any file was found and load it
        if isempty(files)
            fprintf('No file found for sub-%04d ses-%02d run-%02d\n', sub, ses, run);
            continue;
        else
            filename = files(1).name;
    
            % Extract metadata from the filename
            tokens = regexp(filename, 'sub-(\d+)_ses-(\d+)_task-cue_.*_run-(\d+)_desc-(\w+)_events', 'tokens');
            runtype = tokens{1}{4};
            disp(runtype)
    
        end
        
        % Load the .tsv file
        tsvFilePath = fullfile(files(1).folder, files(1).name);
        tsvData = readtable(tsvFilePath, 'FileType', 'text', 'Delimiter', '\t');

        %% condition extract
        % Sample condition
        expect_condition = strcmpi(tsvData.trial_type, 'expectrating');
        expect = tsvData(expect_condition, { 'trial_index','rating_value_fillna', 'rating_glmslabel_fillna'});

        stim_condition = strcmpi(tsvData.trial_type, 'stimulus');
        stim = tsvData(stim_condition, { 'trial_index','cue', 'stimulusintensity'});

        outcome_condition = strcmpi(tsvData.trial_type, 'outcomerating');
        outcome = tsvData(outcome_condition, { 'trial_index', 'rating_value_fillna', 'rating_glmslabel_fillna'});

        % Assuming selectedData is your table
        expect.Properties.VariableNames{'rating_value_fillna'} = 'expectrating';
        expect.Properties.VariableNames{'rating_glmslabel_fillna'} = 'expectlabel';
        outcome.Properties.VariableNames{'rating_value_fillna'} = 'outcomerating';
        outcome.Properties.VariableNames{'rating_glmslabel_fillna'} = 'outcomelabel';
 
        % add metadata
        numRows = height(stim); % Get the number of rows in your table

        % Correctly generate values for sub, ses, and run columns
        subValues = arrayfun(@(x) sprintf('sub-%04d', sub), (1:numRows)', 'UniformOutput', false);
        sesValues = arrayfun(@(x) sprintf('ses-%02d', ses), (1:numRows)', 'UniformOutput', false);
        runValues = arrayfun(@(x) sprintf('run-%02d', run), (1:numRows)', 'UniformOutput', false);

        runtypeValues = repmat({runtype}, numRows, 1);  
        stim = addvars(stim, subValues, sesValues, runValues, runtypeValues, ...
            'Before', 'trial_index', 'NewVariableNames', {'sub', 'ses', 'run', 'runtype'});




        % First, merge the 'expect' and 'stim' tables on 'trial_index'
        sub_mergedData1 = outerjoin(stim, expect, 'Keys', 'trial_index', 'MergeKeys', true);
        subMergedData = outerjoin(sub_mergedData1, outcome, 'Keys', 'trial_index', 'MergeKeys', true);
        subMergedData.trial_index = subMergedData.trial_index -1;
                % Extract cue_level and stim_level by stripping specific words and formatting
        cue_level = strrep(subMergedData.cue, '_cue', '');
        stim_level = strrep(subMergedData.stimulusintensity, '_stim', '');
        trial_index_formatted = sprintfc('%03d', subMergedData.trial_index);


        filenames = arrayfun(@(index) sprintf('%s_%s_%s_runtype-%s_event-stimulus_trial-%s_cuetype-%s_stimintensity-%s.nii.gz', ...
                                               subMergedData.sub{index}, ...
                                               subMergedData.ses{index}, ...
                                               subMergedData.run{index}, ...
                                               subMergedData.runtype{index}, ...
                                               trial_index_formatted{index}, ...
                                               cue_level{index}, ...
                                               stim_level{index}), ...
                             (1:height(subMergedData))', 'UniformOutput', false);

        % Assuming your table is named 'data'
        
        % Convert 'expectrating' column from string to numeric values, handling empty strings

        % Example for 'expectrating' column
% Find rows with empty character arrays or strings and set them to NaN
% Ensure the column is treated as a cell array, regardless of its current format
expectratingCells = table2cell(subMergedData(:, 'expectrating'));
outcomeratingCells = table2cell(subMergedData(:, 'outcomerating'));

% Convert strings to numbers, handling empty and non-empty strings
for i = 1:length(expectratingCells)
    if ischar(expectratingCells{i}) || isstring(expectratingCells{i})
        if isempty(strtrim(expectratingCells{i}))
            expectratingCells{i} = NaN;
        else
            expectratingCells{i} = str2double(expectratingCells{i});
        end
    end
end

% Repeat for outcomerating
for i = 1:length(outcomeratingCells)
    if ischar(outcomeratingCells{i}) || isstring(outcomeratingCells{i})
        if isempty(strtrim(outcomeratingCells{i}))
            outcomeratingCells{i} = NaN;
        else
            outcomeratingCells{i} = str2double(outcomeratingCells{i});
        end
    end
end

% Update the original table with the processed data
subMergedData.expectrating = cell2mat(expectratingCells);
subMergedData.outcomerating = cell2mat(outcomeratingCells);


%         for i = 1:height(subMergedData)
%             if isempty(subMergedData.expectrating{i})  % Check for empty char
%                 subMergedData.expectrating{i} = NaN;  % Assign NaN for missing values
%             else
%                 % Convert string to number
%                 subMergedData.expectrating{i} = str2double(subMergedData.expectrating{i});
%             end
%         end
%         
%         % Since the table initially contains cells of mixed types (strings and NaNs),
%         % you need to unify the data type for the entire column. Convert cell array to a numeric array.
%         subMergedData.expectrating = cell2mat(subMergedData.expectrating);
% 
%         for i = 1:height(subMergedData)
%             if isempty(subMergedData.outcomerating{i})  % Check for empty char
%                 subMergedData.outcomerating{i} = NaN;  % Assign NaN for missing values
%             else
%                 % Convert string to number
%                 subMergedData.outcomerating{i} = str2double(subMergedData.outcomerating{i});
%             end
%         end
%         
%         % Since the table initially contains cells of mixed types (strings and NaNs),
%         % you need to unify the data type for the entire column. Convert cell array to a numeric array.
%         subMergedData.outcomerating = cell2mat(subMergedData.outcomerating);
% % 
%         % Construct the filename using string concatenation
%         filenames = strcat(subMergedData.sub, '_', subMergedData.ses, '_', subMergedData.run, ...
%             '_runtype-', subMergedData.runtype, '_event-stimulus_trial-', trial_index_formatted, ...
%             '_cuetype-', cue_level, '_stimintensity-', stim_level, '.nii.gz');
        
        % Add the filenames as a new column to your table
        subMergedData.singletrial_fname = filenames;
        disp(subMergedData)
%         finalTable = [finalTable; tsvData]; % Append data to the final table
        finalTable = [finalTable; subMergedData]; % Append data to the final table

    end
end
