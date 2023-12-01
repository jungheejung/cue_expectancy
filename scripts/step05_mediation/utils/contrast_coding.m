function modifiedTable = contrast_coding(inputTable, columnName, newColumnName, mappingDict)
    %CONTRAST_CODING Converts specific string values in a table column to numeric values and adds them as a new column.
    %
    % This function takes a table, a column name, a new column name, and a mapping dictionary. It converts string values
    % in the specified column of the table to numeric values based on the provided mapping dictionary. These numeric values 
    % are then appended as a new column in the table.
    %
    % Usage
    % -----
    % modifiedTable = contrast_coding(inputTable, columnName, newColumnName, mappingDict)
    %
    % Inputs
    % ------
    % inputTable : table
    %   A MATLAB table containing the column to be processed.
    %
    % columnName : string
    %   The name of the column in the inputTable that contains string values to be converted.
    %
    % newColumnName : string
    %   The name for the new column to be added to the table, which will contain the numeric values.
    %
    % mappingDict : container.Map or struct
    %   A mapping dictionary that maps string values to numeric values.
    %   e.g., mappingDict = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
    %
    % Outputs
    % -------
    % modifiedTable : table
    %   The modified table with the new column of numeric values.
    %
    % Example
    % -------
    % behTable = readtable('behavior_data.csv');
    % mappingDict = containers.Map({'low_cue', 'high_cue'}, [-1, 1]);
    % behTable = contrast_coding(behTable, 'cueType', 'cueContrast', mappingDict);
    %
    % Notes
    % -----
    % The function checks for mapped values in the specified column and converts them to numeric values. 
    % An error is thrown for any unmapped string value.
    %
    % See also CONTAINERS.MAP, ISKEY, HEIGHT

    % Check for the existence of the specified column in the table
    if ~ismember(columnName, inputTable.Properties.VariableNames)
        error('Specified column does not exist in the table.');
    end

    % Initialize an array for storing numeric values
    numericValues = zeros(height(inputTable), 1);

    % Convert string values to numeric based on the mapping dictionary
    for i = 1:height(inputTable)
        strValue = char(inputTable.(columnName){i});
        if isKey(mappingDict, strValue)
            numericValues(i) = mappingDict(strValue);
        else
            error('Unmapped string value encountered: %s', strValue);
        end
    end

    % Append the numeric values as a new column in the table
    inputTable.(newColumnName) = numericValues;

    % Return the modified table
    modifiedTable = inputTable;
end
