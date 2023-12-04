function merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df)
    %MERGE_ON_NIFTI_BEH Merges behavior data frame with NIfTI file list based on matching filenames.
    %
    %   Function to filter a behavior data frame (table), keeping only those
    %   rows where the 'singletrial_fname' field matches any filename in the
    %   provided list of NIfTI filenames.
    %
    %   The function loops through the list of base filenames extracted from
    %   NIfTI files and checks each one against the 'singletrial_fname' column
    %   in the behavior data frame. Rows in the data frame with a matching
    %   filename are retained.
    %
    %   Usage:
    %   merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df)
    %
    %   Parameters
    %   ----------
    %   singletrial_basefname - Cell array of strings, where each element is a base filename
    %               extracted from a NIfTI file.
    %   beh_df     - Table containing behavioral data, including a column named
    %               'singletrial_fname' which contains filenames to be matched
    %               against the NIfTI filenames.
    %
    %   Returns
    %   -------
    %   merge_beh_nii - Table containing only the rows from the original
    %                    behavior data frame that have a corresponding match
    %                    in the provided NIfTI filenames.
    %
    %   Example:
    %   singletrial_basefname = {'filename1.nii', 'filename2.nii', ...};
    %   beh_df = table(...); % Behavior data frame with 'singletrial_fname' column
    %   merge_beh_nii = merge_on_nifti_beh(singletrial_basefname, beh_df);
    %
    %   See also: strcmp

    % Initialize a logical vector for matches
    matches = false(size(beh_df, 1), 1);

    % Loop through each filename in singletrial_basefname
    for i = 1:numel(singletrial_basefname)
        % Update matches where there's a corresponding element in beh_df.singletrial_fname
        filename = singletrial_basefname{i};
        % Use regular expression to match both .nii and .nii.gz extensions
        pattern = ['^' regexprep(filename, '\.nii(\.gz)?$', '\\.(nii|nii\\.gz)')];
        % Convert the cell array to a logical array and perform logical OR
        matches = matches | cellfun(@(x) ~isempty(x), regexp(beh_df.singletrial_fname, pattern, 'once'));
    end

    % Filter beh_df to retain only rows where there was a match
    merge_beh_nii = beh_df(matches, :);
end
