function finalTable = load_beh_based_on_bids(beh_dir, unique_bids)
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

        % Generate the file path pattern based on BIDS naming convention
        fname_pattern = sprintf('sub-%04d_ses-%02d_task-cue_*run-%02d_runtype-*_events.tsv', sub, ses, run);
        filepathPattern = fullfile(beh_dir, sprintf('sub-%04d', sub), sprintf('ses-%02d', ses), fname_pattern);
        files = dir(filepathPattern); % Find files that match the pattern
        
        % Check if any file was found and load it
        if isempty(files)
            fprintf('No file found for sub-%04d ses-%02d run-%02d\n', sub, ses, run);
            continue;
        end
        
        % Load the .tsv file
        tsvFilePath = fullfile(files(1).folder, files(1).name);
        tsvData = readtable(tsvFilePath, 'FileType', 'text', 'Delimiter', '\t');
        finalTable = [finalTable; tsvData]; % Append data to the final table
    end
end
