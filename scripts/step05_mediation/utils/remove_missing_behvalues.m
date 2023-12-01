function modifiedTable = remove_missing_behvalues(inputTable, columnName)
    %REMOVE_MISSING_BEHVALUES Removes rows with missing values in a specified column of a table.
    %
    % This function filters a table by removing rows where the specified column has missing values.
    % The function can handle missing values in numeric or categorical columns.
    %
    % Usage
    % -----
    % modifiedTable = remove_missing_behvalues(inputTable, columnName)
    %
    % Inputs
    % ------
    % inputTable : table
    %   The MATLAB table from which rows with missing values are to be removed.
    %
    % columnName : string
    %   The name of the column in the inputTable to check for missing values.
    %
    % Outputs
    % -------
    % modifiedTable : table
    %   The modified table with rows containing missing values in the specified column removed.
    %
    % Example
    % -------
    % behTable = readtable('behavior_data.csv');
    % cleanTable = remove_missing_behvalues(behTable, 'responseTime');
    %
    % Notes
    % -----
    % The function checks for NaN values in numeric columns and 'undefined' values in categorical columns.
    % An error is thrown if the column data type is neither numeric nor categorical.
    %
    % See also ISNAN, ISUNDEFINED

    % Check if the specified column contains NaN or undefined values
    if isnumeric(inputTable.(columnName))
        nanRows = isnan(inputTable.(columnName));
    elseif iscategorical(inputTable.(columnName))
        nanRows = isundefined(inputTable.(columnName));
    else
        error('Column data type not supported for missing value check.');
    end

    % Remove rows where the specified column is NaN or undefined
    modifiedTable = inputTable(~nanRows, :);
end
