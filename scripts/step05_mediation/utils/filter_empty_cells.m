function [X_test, Y_test, M_test, cov_test, l2m_test] = filter_empty_cells(X, Y, M, cov, l2m)
    num_subjects = numel(X);

    % ----------------------------------------------------------------------------
    %  filter rows based on Y data
    % ----------------------------------------------------------------------------

    % Initialize cell arrays to store filtered data
    X_filtered = cell(num_subjects, 1);
    Y_filtered = cell(num_subjects, 1);
    M_filtered = cell(num_subjects, 1);
    cov_filtered = cell(num_subjects, 1);
    l2m_filtered = [];

    % Loop through subjects and filter out cells with empty arrays in Y
    for i = 1:num_subjects
        % Check if Y is not empty for the current subject
        if ~isempty(Y{i})
            X_filtered{i} = X{i};
            Y_filtered{i} = Y{i};
            M_filtered{i} = M{i};
            cov_filtered{i} = cov{i}; % If you want to filter cov as well
            l2m_filtered(i) = l2m(i); % If you want to filter l2m as well
        end
    end

    num_filtered = numel(Y_filtered);
    X_test = cell(num_filtered, 1);
    Y_test = cell(num_filtered, 1);
    M_test = cell(num_filtered, 1);
    cov_test = cell(num_filtered, 1);
    l2m_test = [];
    % Loop through subjects and filter out cells with empty arrays in Y


    % ----------------------------------------------------------------------------
    %  filter rows based on moderator data
    % ----------------------------------------------------------------------------
    % NPS values might have nans in there
    nan_indices = find(isnan(l2m_filtered));

    X_test = X_filtered([1:nan_indices-1, nan_indices+1:end]);
    Y_test = Y_filtered([1:nan_indices-1, nan_indices+1:end]);
    M_test = M_filtered([1:nan_indices-1, nan_indices+1:end]);
    cov_test = cov_filtered([1:nan_indices-1, nan_indices+1:end]);
    l2m_test = l2m_filtered([1:nan_indices-1, nan_indices+1:end]);

end
