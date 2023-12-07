function charArrays = convert_cell2char(M)
%CONVERTCELLARRAYTOSTRINGS Converts a cell array of cell arrays to a cell
%array of character arrays.
%
%   charArrays = CONVERTCELLARRAYTOSTRINGS(M) takes a cell array M where
%   each cell contains an inner cell array of strings. It converts the
%   inner cell arrays to a cell array of character arrays, padding each
%   string to the maximum length within the inner cell array.
%
%   Input:
%   - M: A cell array where each cell contains an inner cell array of
%        strings.
%
%   Output:
%   - charArrays: A cell array of character arrays where each element
%                 corresponds to the inner cell array in M.
%
%   Example:
%   M = {{'apple', 'banana', 'cherry'}, {'dog', 'elephant', 'fox', 'giraffe'}};
%   charArrays = convertCellArrayToStrings(M);
%
%   charArrays will be a cell array like this:
%   {'applebanana cherry', 'dog     elephant fox     giraffe'}

    charArrays = cell(size(M));

    % Loop through each element in the main cell array
    for i = 1:length(M)
        % Extract the inner cell array
        innerCellArray = M{i};

        % Check if the inner cell array is empty
        if isempty(innerCellArray)
            charArrays{i} = [];
            continue;
        end

        % Determine the maximum string length in the inner cell array
        maxLength = max(cellfun(@length, innerCellArray));

        % Convert the inner cell array to a character array
        charArrays{i} = char(innerCellArray);
    end
end
