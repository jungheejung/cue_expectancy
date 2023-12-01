function unique_bids = unique_combination_bids(filenames)
    %UNIQUE_COMBINATION_BIDS Extracts and finds unique combinations of subject, session, and run IDs from filenames.
    %
    % This function processes a cell array of filenames and extracts unique combinations 
    % of subject (sub), session (ses), and run identifiers. These identifiers are expected 
    % to be embedded in the filenames following a specific format: 'sub-XXXX_ses-YY_run-ZZ', 
    % where 'XXXX', 'YY', and 'ZZ' are placeholders for the actual numbers.
    %
    %   Parameters
    %   ----------
    %   filenames : cell array of strings
    %           Filenames from which to extract the sub/ses/run information. Each filename should 
    %           follow the format 'sub-XXXX_ses-YY_run-ZZ'.
    %
    %   Returns
    %   -------
    %   unique_bids : double array
    %           An array with unique combinations of sub/ses/run. Each row represents a unique 
    %           combination, with columns corresponding to 'sub', 'ses', and 'run' in that order.
    %
    %   Example
    %   -------
    %           filenames = {'sub-001_ses-01_run-01_image.nii', 'sub-001_ses-02_run-01_image.nii', ...};
    %           uniqueCombinations = unique_combination_bids(filenames);
    %
    %   See also REGEXP, UNIQUE
    pattern = 'sub-(\d+)_ses-(\d+)_run-(\d+)'; % Regular expression pattern  
    tempArray = zeros(length(filenames), 3); % Temporary array to store extracted numbers

    for i = 1:length(filenames)
        matches = regexp(filenames{i}, pattern, 'tokens'); 
        % If a match is found, extract the first match
        if ~isempty(matches)
            match = matches{1};
            % Convert the matched strings to numbers and store in tempArray
            tempArray(i, 1) = str2double(match{1}); % sub
            tempArray(i, 2) = str2double(match{2}); % ses
            tempArray(i, 3) = str2double(match{3}); % run
        end
    end
    % Find unique rows in tempArray
    unique_bids = unique(tempArray, 'rows'); 
end
