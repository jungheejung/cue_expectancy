function T = add_fullpath_column(T, baseDir, sub, existingColName, newColName)
    %ADD_FULLPATH_COLUMN Appends a base directory path and subject folder to filenames in a table column to create full paths.
    %
    %   This function takes a table and appends a base directory and subject-specific
    %   folder paths to each filename in a specified column, then adds these full
    %   paths as a new column in the table.
    %
    %   Usage:
    %   T = add_fullpath_column(T, baseDir, sublist, existingColName, newColName)
    %
    %   Inputs:
    %   T             - A MATLAB table containing the existing filename column.
    %   baseDir       - A string representing the base directory path.
    %   sublist       - A cell array of subject folder names.
    %   existingColName - The name of the existing column containing the filenames.
    %   newColName    - The name for the new column to be added to the table.
    %
    %   Outputs:
    %   T             - The modified table with the new full path column added.

    % Check if the existing column name is valid
    if ~ismember(existingColName, T.Properties.VariableNames)
        error('The specified existing column name does not exist in the table.');
    end

    % Initialize a cell array to store the full path filenames
    fullpathFnames = cell(height(T), 1);

    % Loop through each row in T
    for i = 1:height(T)
        % Get the original filename
        originalFilename = T.(existingColName){i};
        
        % Remove ".nii.gz" extension and replace with ".nii"
        newFilename = strrep(originalFilename, '.nii.gz', '.nii');
        
        % Concatenate to form the full path
        fullpathFnames{i} = fullfile(baseDir, sub, newFilename);
    end

    % Add the full path filenames as a new column in T
    T.(newColName) = fullpathFnames;
end
