function [X_filtered, Y_filtered, M_filtered, cov_filtered, l2m_filtered] = filter_empty_cells(X, Y, M, cov, l2m)
    num_subjects = numel(X);

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

    % Remove cells with empty arrays from the filtered arrays
    X_filtered = X_filtered(~cellfun('isempty', X_filtered));
    Y_filtered = Y_filtered(~cellfun('isempty', Y_filtered));
    M_filtered = M_filtered(~cellfun('isempty', M_filtered));
    cov_filtered = cov_filtered(~cellfun('isempty', cov_filtered));
    
    % Remove empty entries in l2m_filtered
    l2m_filtered = l2m_filtered(~isnan(l2m_filtered));
end
