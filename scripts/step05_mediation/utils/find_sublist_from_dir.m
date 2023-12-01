function sublist = find_sublist_from_dir(nifti_dir)
    %FIND_SUBLIST_FROM_DIR Extracts a list of subject directories from a given directory.
    %
    % This function scans a specified directory and identifies all subdirectories 
    % that start with 'sub-', which are commonly used in neuroimaging data (e.g., NIfTI files).
    % It returns a cell array of the names of these subject directories.
    %
    % Parameters
    % ----------
    % nifti_dir : string
    %   The path to the directory to be scanned. It should contain subdirectories 
    %   following the naming convention 'sub-XXXX', where 'XXXX' is the subject identifier.
    %
    % Returns
    % -------
    % sublist : cell array of strings
    %   A cell array containing the names of all subdirectories in `nifti_dir` that start 
    %   with 'sub-'. Each cell contains one directory name as a string.
    %
    % Example
    % -------
    % nifti_dir = '/path/to/nifti/data';
    % subjects = find_sublist_from_dir(nifti_dir);
    %
    % Note
    % ----
    % This function is specifically designed for file structures common in neuroimaging data,
    % where participant or subject data is often stored in subdirectories named with a 'sub-' prefix.
    %
    % See also DIR, STARTSWITH

    % Retrieve all items in the specified directory
    items = dir(nifti_dir);

    % Filter to include only directories that start with 'sub-'
    sub_dirs = items([items.isdir] & startsWith({items.name}, 'sub-'));

    % Extract the names of these directories
    sublist = {sub_dirs.name}';
end
